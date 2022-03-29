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

  bool equalAttr(ConvInfo& rhs) {
    return (op.pad() == rhs.op.pad()) &&
           (op.stride() == rhs.op.stride()) &&
           (op.dilation() == rhs.op.dilation());
  }

  bool equalShape(ConvInfo& rhs) {
    return (this->getInputShape() == rhs.getInputShape()) &&
           (this->getOutputShape() == rhs.getOutputShape()) &&
           (this->getWeightShape() == rhs.getWeightShape());
  }

  bool operator==(ConvInfo& rhs) {
    return this->equalAttr(rhs) && this->equalShape(rhs);
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
        ConvInfo info = {Conv2DOp};
        if (info.equalAttr(sharedKernel)) {
          opToErase.push_back(Conv2DOp);
          builder.setInsertionPoint(Conv2DOp);

          int64_t outChannelDiv = (info.numOutputChannels() + sharedKernel.numOutputChannels() - 1) / sharedKernel.numOutputChannels();
          int64_t inChannelDiv = (info.numInputChannels() + sharedKernel.numInputChannels() - 1) / sharedKernel.numInputChannels();
          int64_t inSizeDiv = (info.getInputSize() + sharedKernel.getInputSize() - 1) / sharedKernel.getInputSize();

          if (outChannelDiv <= 1 && inChannelDiv <= 1 && inSizeDiv <= 1) {
            auto newCallOp = builder.create<CallOp>(Conv2DOp.getLoc(), functionName, Conv2DOp->getResultTypes(), Conv2DOp->getOperands());
            Conv2DOp.replaceAllUsesWith(newCallOp);
          }
          else {
            SmallVector<Value, 16> slicedOutChannel;
            for (auto outChannelIter = 0; outChannelIter < outChannelDiv; outChannelIter++) {
              SmallVector<Value, 16> slicedOutInChannel;
              for (auto inChannelIter = 0; inChannelIter < inChannelDiv; inChannelIter++) {
                SmallVector<Value, 16> slicedOutRows;
                for (auto inWidthIter = 0; inWidthIter < inSizeDiv; inWidthIter++) {
                  SmallVector<Value, 16> slicedOutColumns;
                  for (auto inHeightIter = 0; inHeightIter < inSizeDiv; inHeightIter++) {
                    Value slicedInput, slicedWeight, slicedBias;

                    if (inChannelDiv <= 1 && inSizeDiv <= 1) {
                      slicedInput = Conv2DOp.getOperand(0);
                    }
                    else {
                      auto inputStart = builder.getI64ArrayAttr({0, inWidthIter * sharedKernel.getInputSize(), inHeightIter * sharedKernel.getInputSize(), 0});
                      auto inputSize = builder.getI64ArrayAttr({1, sharedKernel.getInputSize(), sharedKernel.getInputSize(), sharedKernel.numInputChannels()});
                      auto inputType = sharedKernel.op.getOperand(0).getType();
                      slicedInput = builder.create<tosa::SliceOp>(Conv2DOp.getLoc(), inputType, Conv2DOp->getOperand(0), inputStart, inputSize).output();
                    }
                    
                    if (outChannelDiv <= 1 && inChannelDiv <= 1) {
                      slicedWeight = Conv2DOp->getOperand(1);
                    }
                    else {
                      auto weightStart = builder.getI64ArrayAttr({outChannelIter * sharedKernel.numOutputChannels(), 0, 0, inChannelIter * sharedKernel.numInputChannels()});
                      auto weightSize = builder.getI64ArrayAttr({sharedKernel.numOutputChannels(), sharedKernel.kernelSize(), sharedKernel.kernelSize(), sharedKernel.numInputChannels()});
                      auto weightType = sharedKernel.op.getOperand(1).getType();
                      slicedWeight = builder.create<tosa::SliceOp>(Conv2DOp.getLoc(), weightType, Conv2DOp->getOperand(1), weightStart, weightSize).output();
                    }

                    if (inChannelIter == 0) {
                      if (outChannelDiv <= 1) {
                        slicedBias = Conv2DOp->getOperand(2);
                      }
                      else {
                        auto biasStart = builder.getI64ArrayAttr({outChannelIter * sharedKernel.numOutputChannels()});
                        auto biasSize = builder.getI64ArrayAttr({sharedKernel.numOutputChannels()});
                        auto biasType = sharedKernel.op.getOperand(2).getType();
                        slicedBias = builder.create<tosa::SliceOp>(Conv2DOp.getLoc(), biasType, Conv2DOp->getOperand(2), biasStart, biasSize).output();
                      }
                    }
                    else {
                      auto biasTensor = RankedTensorType::get(sharedKernel.numOutputChannels(), builder.getF32Type());
                      auto biasAttr = DenseFPElementsAttr::get(biasTensor, std::vector<float>(sharedKernel.numOutputChannels()));
                      auto biasType = sharedKernel.op.getOperand(2).getType();
                      slicedBias = builder.create<tosa::ConstOp>(Conv2DOp.getLoc(), biasType, biasAttr);
                    }

                    auto operands = {slicedInput, slicedWeight, slicedBias};
                    slicedOutColumns.push_back(builder.create<CallOp>(Conv2DOp.getLoc(), functionName, sharedKernel.op->getResultTypes(), operands).getODSResults(0)[0]);
                  }
                  if (slicedOutColumns.size() == 1) {
                    slicedOutRows.push_back(slicedOutColumns[0]);
                  }
                  else {
                    auto columnResultShape = ArrayRef<int64_t>({1, sharedKernel.getInputSize(), info.getInputSize(), sharedKernel.numOutputChannels()});
                    auto columnResultType = RankedTensorType::get((columnResultShape), builder.getF32Type());
                    slicedOutRows.push_back(builder.create<tosa::ConcatOp>(Conv2DOp.getLoc(), columnResultType, slicedOutColumns, 2));
                  }
                }
                if (slicedOutRows.size() == 1) {
                  slicedOutInChannel.push_back(slicedOutRows[0]);
                }
                else {
                  auto rowResultShape = ArrayRef<int64_t>({1, info.getInputSize(), info.getInputSize(), sharedKernel.numOutputChannels()});
                  auto rowResultType = RankedTensorType::get((rowResultShape), builder.getF32Type());
                  slicedOutInChannel.push_back(builder.create<tosa::ConcatOp>(Conv2DOp.getLoc(), rowResultType, slicedOutRows, 1));
                }
              }
              if (slicedOutInChannel.size() == 1) {
                slicedOutChannel.push_back(slicedOutInChannel[0]);
              }
              else {
                auto inChResultShape = ArrayRef<int64_t>({1, info.getInputSize(), info.getInputSize(), sharedKernel.numOutputChannels()});
                auto inChResultType = RankedTensorType::get((inChResultShape), builder.getF32Type());
                slicedOutChannel.push_back(builder.create<tosa::AddOp>(Conv2DOp.getLoc(), inChResultType, slicedOutInChannel));
              }
            }
            if (slicedOutChannel.size() == 1) {
              Conv2DOp.replaceAllUsesWith(slicedOutChannel[0]);
            }
            else {
              Operation* newConcatOp = builder.create<tosa::ConcatOp>(Conv2DOp.getLoc(), Conv2DOp->getResultTypes(), slicedOutChannel, 3);
              Conv2DOp.replaceAllUsesWith(newConcatOp);
            }
          }
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
