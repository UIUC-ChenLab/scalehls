//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

struct ConvInfo {
  tosa::Conv2DOp op;

  ArrayRef<int64_t> getInputShape() {
    auto input = op.getOperand(0);
    return input.getType().cast<RankedTensorType>().getShape();
  }

  ArrayRef<int64_t> getOutputShape() {
    auto output = op.getResult();
    return output.getType().cast<RankedTensorType>().getShape();
  }

  ArrayRef<int64_t> getWeightShape() {
    auto weight = op.getOperand(1);
    return weight.getType().cast<RankedTensorType>().getShape();
  }

  int64_t numOutputChannels() {
    auto shape = this->getWeightShape();
    return shape[0];
  }

  int64_t numInputChannels() {
    auto shape = this->getWeightShape();
    return shape[3];
  }

  int64_t kernelSize() {
    auto shape = this->getWeightShape();
    return shape[1];
  }

  int64_t getInputSize() {
    auto shape = this->getInputShape();
    return shape[1];
  }

  bool operator==(ConvInfo& rhs) {
    return (this->getInputShape() == rhs.getInputShape()) &&
           (this->getOutputShape() == rhs.getOutputShape()) &&
           (this->getWeightShape() == rhs.getWeightShape());
  }

  bool operator<(const ConvInfo& rhs) const {
    ConvInfo lhs = *this;
    ConvInfo rhsCopy = rhs;
    if (lhs == rhsCopy) {
      return false;
    }
    else {
      return (this->op < rhs.op);
    }
  }
};

static bool applyShareTensorOperation(ModuleOp module) {
  auto builder = OpBuilder(module);

  // Count the number of each shape of convolution.
  std::map<ConvInfo, unsigned> countMap;

  // Traverse the entire module and count all the convolutions.
  auto funcs = module.getOps<FuncOp>();
  for (auto func : funcs) {
    func.walk([&](Operation *op) {
      if (auto Conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvInfo info;
        info.op = Conv2DOp;
        if (!countMap.count(info)) {
          countMap[info] = 1;
        }
        else {
          countMap[info] += 1;
        }
      }
    });
  }

  // Find the shape of convolution that happens most frequently.
  unsigned maxCount = 0;
  ConvInfo sharedKernel;
  for (auto item : countMap) {
    if (item.second > maxCount) {
      maxCount = item.second;
      sharedKernel = item.first;
    }
  }

  // Create a function that contains the most frequent convolution.
  SmallVector<Type, 16> inputTypes;
  for (auto operand : sharedKernel.op.getOperands()) {
    inputTypes.push_back(operand.getType());
  }
  auto functionName = "shared_convolution";
  auto resultType = sharedKernel.op.getResult().getType();
  auto newType = builder.getFunctionType(inputTypes, resultType);
  builder.setInsertionPointToStart(module.getBody());
  auto newFuncOp = builder.create<FuncOp>(builder.getUnknownLoc(), functionName, newType);
  auto entryBlock = newFuncOp.addEntryBlock();
  builder.setInsertionPointToStart(entryBlock);

  // Create Conv2DOp inside the created function/
  auto input = entryBlock->getArgument(0);
  auto weight = entryBlock->getArgument(1);
  auto bias = entryBlock->getArgument(2);
  auto outputType = newFuncOp.getType().getResults()[0];
  auto pad = sharedKernel.op.pad();
  auto stride = sharedKernel.op.stride();
  auto dilation = sharedKernel.op.dilation();
  auto newConvOp = builder.create<tosa::Conv2DOp>(builder.getUnknownLoc(), outputType, input, weight, bias, pad, stride, dilation);

  // Create ReturnOp inside the created function/
  builder.create<ReturnOp>(builder.getUnknownLoc(), newConvOp.output());

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Convert matching convolutions into CallOp to shared function.
  for (auto func : funcs) {
    func.walk([&](Operation *op) {
      if (auto Conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvInfo info;
        info.op = Conv2DOp;
        if (sharedKernel == info) {
          opToErase.push_back(Conv2DOp);
          builder.setInsertionPoint(Conv2DOp);
          auto newCallOp = builder.create<CallOp>(Conv2DOp.getLoc(), functionName, Conv2DOp->getResultTypes(), Conv2DOp->getOperands());
          Conv2DOp.replaceAllUsesWith(newCallOp);
        }
        else if (info.numOutputChannels() > sharedKernel.numOutputChannels()) {
          opToErase.push_back(Conv2DOp);
          builder.setInsertionPoint(Conv2DOp);
          int64_t numIterations = info.numOutputChannels() / sharedKernel.numOutputChannels();

          SmallVector<Value, 16> slicedOutputs;
          for (int outIter = 0; outIter < numIterations; outIter++) {
            auto start = builder.getI64ArrayAttr({outIter * sharedKernel.numOutputChannels(), 0, 0, 0});
            auto size = builder.getI64ArrayAttr({sharedKernel.numOutputChannels(), sharedKernel.kernelSize(), sharedKernel.kernelSize(), sharedKernel.numInputChannels()});
            auto weightType = sharedKernel.op.getOperand(1).getType();
            auto slicedWeight = builder.create<tosa::SliceOp>(Conv2DOp.getLoc(), weightType, Conv2DOp->getOperand(1), start, size).output();
            
            start = builder.getI64ArrayAttr({outIter * sharedKernel.numOutputChannels()});
            size = builder.getI64ArrayAttr({sharedKernel.numOutputChannels()});
            auto biasType = sharedKernel.op.getOperand(2).getType();
            auto slicedBias = builder.create<tosa::SliceOp>(Conv2DOp.getLoc(), biasType, Conv2DOp->getOperand(2), start, size).output();
            auto operands = {Conv2DOp.getOperand(0), slicedWeight, slicedBias};

            slicedOutputs.push_back(builder.create<CallOp>(Conv2DOp.getLoc(), functionName, sharedKernel.op->getResultTypes(), operands).getODSResults(0)[0]);
          }
          Operation* newConcatOp = builder.create<tosa::ConcatOp>(Conv2DOp.getLoc(), Conv2DOp->getResultTypes(), slicedOutputs, 3);
          Conv2DOp.replaceAllUsesWith(newConcatOp);
        }
        else if (info.numInputChannels() > sharedKernel.numInputChannels()) {
          opToErase.push_back(Conv2DOp);
          builder.setInsertionPoint(Conv2DOp);
          int64_t numIterations = info.numInputChannels() / sharedKernel.numInputChannels();

          SmallVector<Value, 16> slicedOutputs;
          for (int inIter = 0; inIter < numIterations; inIter++) {
            auto start = builder.getI64ArrayAttr({0, 0, 0, inIter * sharedKernel.numInputChannels()});
            auto size = builder.getI64ArrayAttr({sharedKernel.numOutputChannels(), sharedKernel.kernelSize(), sharedKernel.kernelSize(), sharedKernel.numInputChannels()});
            auto weightType = sharedKernel.op.getOperand(1).getType();
            auto slicedWeight = builder.create<tosa::SliceOp>(Conv2DOp.getLoc(), weightType, Conv2DOp->getOperand(1), start, size).output();
            
            start = builder.getI64ArrayAttr({0, 0, 0, inIter * sharedKernel.numInputChannels()});
            size = builder.getI64ArrayAttr({1, sharedKernel.getInputSize(), sharedKernel.getInputSize(), sharedKernel.numInputChannels()});
            auto inputType = sharedKernel.op.getOperand(0).getType();
            auto slicedInput = builder.create<tosa::SliceOp>(Conv2DOp.getLoc(), inputType, Conv2DOp->getOperand(0), start, size).output();
            Value bias;
            if (inIter == 0) {
              bias = Conv2DOp->getOperand(2);
            }
            else {
              // Set bias to zero to prevent redundant addition of bias
              auto bias_tensor = RankedTensorType::get(sharedKernel.numOutputChannels(), builder.getF32Type());
              auto bias_attr = DenseFPElementsAttr::get(bias_tensor, std::vector<float>(sharedKernel.numOutputChannels()));
              bias = builder.create<tosa::ConstOp>(Conv2DOp.getLoc(), sharedKernel.op.getOperand(2).getType(), bias_attr);
            }
            auto operands = {slicedInput, slicedWeight, bias};

            slicedOutputs.push_back(builder.create<CallOp>(Conv2DOp.getLoc(), functionName, sharedKernel.op->getResultTypes(), operands).getODSResults(0)[0]);
          }
          Operation* newAddOp = builder.create<tosa::AddOp>(Conv2DOp.getLoc(), Conv2DOp->getResultTypes(), slicedOutputs);
          Conv2DOp.replaceAllUsesWith(newAddOp);
        }

        else if (info.getInputSize() > sharedKernel.getInputSize()) {
          opToErase.push_back(Conv2DOp);
          builder.setInsertionPoint(Conv2DOp);
          int64_t numIterations = info.getInputSize() / sharedKernel.getInputSize();

          SmallVector<Value, 16> slicedRows;
          for (int widthIter = 0; widthIter < numIterations; widthIter++) {
            SmallVector<Value, 16> slicedColumns;
            for (int heightIter = 0; heightIter < numIterations; heightIter++) {
              auto start = builder.getI64ArrayAttr({0, widthIter * sharedKernel.getInputSize(), heightIter * sharedKernel.getInputSize(), 0});
              auto size = builder.getI64ArrayAttr({1, sharedKernel.getInputSize(), sharedKernel.getInputSize(), sharedKernel.numInputChannels()});
              auto inputType = sharedKernel.op.getOperand(0).getType();
              auto slicedInput = builder.create<tosa::SliceOp>(Conv2DOp.getLoc(), inputType, Conv2DOp->getOperand(0), start, size).output();
              auto operands = {slicedInput, Conv2DOp->getOperand(1), Conv2DOp->getOperand(2)};

              slicedColumns.push_back(builder.create<CallOp>(Conv2DOp.getLoc(), functionName, sharedKernel.op->getResultTypes(), operands).getODSResults(0)[0]);
            }
            auto columnResultShape = ArrayRef<int64_t>({1, sharedKernel.getInputSize(), info.getInputSize(), info.numOutputChannels()});
            auto columnResultType = RankedTensorType::get((columnResultShape), builder.getF32Type());
            slicedRows.push_back(builder.create<tosa::ConcatOp>(Conv2DOp.getLoc(), columnResultType, slicedColumns, 2));
          }
          Operation* newConcatOp = builder.create<tosa::ConcatOp>(Conv2DOp.getLoc(), Conv2DOp->getResultTypes(), slicedRows, 1);
          Conv2DOp.replaceAllUsesWith(newConcatOp);
        }
      }
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

namespace {
struct ShareTensorOperation : public ShareTensorOperationBase<ShareTensorOperation> {
  void runOnOperation() override {
    auto module = getOperation();
    applyShareTensorOperation(module);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createShareTensorOperationPass() {
  return std::make_unique<ShareTensorOperation>();
}
