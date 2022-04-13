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
using namespace hls;

struct ConvHelper {
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

  bool equalAttr(ConvHelper &rhs) {
    return (op.pad() == rhs.op.pad()) && (op.stride() == rhs.op.stride()) &&
           (op.dilation() == rhs.op.dilation());
  }

  bool equalShape(ConvHelper &rhs) {
    return (this->getInputShape() == rhs.getInputShape()) &&
           (this->getOutputShape() == rhs.getOutputShape()) &&
           (this->getWeightShape() == rhs.getWeightShape());
  }

  bool isEmptyKey() {
    void *pointer = llvm::DenseMapInfo<void *>::getEmptyKey();
    return tosa::Conv2DOp::getFromOpaquePointer(pointer) == op;
  }

  bool isTombstoneKey() {
    void *pointer = llvm::DenseMapInfo<void *>::getTombstoneKey();
    return tosa::Conv2DOp::getFromOpaquePointer(pointer) == op;
  }

  bool operator==(ConvHelper &rhs) {
    if (this->isEmptyKey() || rhs.isEmptyKey()) {
      if (this->isEmptyKey() && rhs.isEmptyKey()) {
        return true;
      }
      return false;
    }

    if (this->isTombstoneKey() || rhs.isTombstoneKey()) {
      if (this->isTombstoneKey() && rhs.isTombstoneKey()) {
        return true;
      }
      return false;
    }

    return this->equalAttr(rhs) && this->equalShape(rhs);
  }

  bool operator<(const ConvHelper &rhs) const {
    ConvHelper lhs = *this;
    ConvHelper rhsCopy = rhs;
    if (lhs == rhsCopy) {
      return false;
    } else {
      return (this->op < rhs.op);
    }
  }
};

namespace llvm {
template <> struct DenseMapInfo<ConvHelper> {
  static ConvHelper getEmptyKey() {
    void *pointer = llvm::DenseMapInfo<void *>::getEmptyKey();
    return ConvHelper{tosa::Conv2DOp::getFromOpaquePointer(pointer)};
  }
  static ConvHelper getTombstoneKey() {
    void *pointer = llvm::DenseMapInfo<void *>::getTombstoneKey();
    return ConvHelper{tosa::Conv2DOp::getFromOpaquePointer(pointer)};
  }
  static unsigned getHashValue(ConvHelper Val) {
    return mlir::hash_value(Val.op);
  }
  static bool isEqual(ConvHelper LHS, ConvHelper RHS) { return LHS == RHS; }
};
} // namespace llvm

static FuncOp createSharedFunction(ModuleOp module, tosa::Conv2DOp sharedConv,
                                   StringRef functionName) {
  auto builder = OpBuilder(module);

  // Create a function that contains the most frequent convolution.
  SmallVector<Type, 16> inputTypes;
  for (auto operand : sharedConv.getOperands()) {
    inputTypes.push_back(operand.getType());
  }
  auto resultType = sharedConv.getResult().getType();
  auto newType = builder.getFunctionType(inputTypes, resultType);
  builder.setInsertionPointToStart(module.getBody());
  auto newFuncOp =
      builder.create<FuncOp>(builder.getUnknownLoc(), functionName, newType);
  newFuncOp->setAttr("shared", UnitAttr::get(newFuncOp->getContext()));
  newFuncOp->setAttr("name", builder.getStringAttr(functionName));
  auto entryBlock = newFuncOp.addEntryBlock();
  builder.setInsertionPointToStart(entryBlock);

  // Create Conv2DOp inside the created function/
  auto input = entryBlock->getArgument(0);
  auto weight = entryBlock->getArgument(1);
  auto bias = entryBlock->getArgument(2);
  auto outputType = newFuncOp.getResultTypes()[0];
  auto pad = sharedConv.pad();
  auto stride = sharedConv.stride();
  auto dilation = sharedConv.dilation();
  auto newConvOp =
      builder.create<tosa::Conv2DOp>(builder.getUnknownLoc(), outputType, input,
                                     weight, bias, pad, stride, dilation);

  // Create ReturnOp inside the created function/
  builder.create<func::ReturnOp>(builder.getUnknownLoc(), newConvOp.output());

  return newFuncOp;
}

static bool replaceFunction(ModuleOp module, tosa::Conv2DOp sharedConv,
                            FuncOp newFuncOp) {
  auto builder = OpBuilder(module);

  // Traverse the entire module and count all the convolutions.
  auto funcs = module.getOps<FuncOp>();
  // Shared convolution
  ConvHelper SharedHelper = {sharedConv};
  // Shared function name
  auto functionName = newFuncOp->getAttr("name").dyn_cast<StringAttr>();
  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Convert matching convolutions into CallOp to shared function.
  for (auto func : funcs) {
    if (!func->getAttr("shared")) {
      func.walk([&](Operation *op) {
        if (auto Conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
          ConvHelper CurrHelper = {Conv2DOp};
          if (CurrHelper.equalAttr(SharedHelper)) {
            opToErase.push_back(Conv2DOp);
            builder.setInsertionPoint(Conv2DOp);

            int64_t outChannelDiv = (CurrHelper.numOutputChannels() +
                                     SharedHelper.numOutputChannels() - 1) /
                                    SharedHelper.numOutputChannels();
            int64_t inChannelDiv = (CurrHelper.numInputChannels() +
                                    SharedHelper.numInputChannels() - 1) /
                                   SharedHelper.numInputChannels();
            int64_t inSizeDiv =
                (CurrHelper.getInputSize() + SharedHelper.getInputSize() - 1) /
                SharedHelper.getInputSize();

            if (outChannelDiv <= 1 && inChannelDiv <= 1 && inSizeDiv <= 1) {
              auto newCallOp = builder.create<func::CallOp>(
                  Conv2DOp.getLoc(), functionName, Conv2DOp->getResultTypes(),
                  Conv2DOp->getOperands());
              Conv2DOp.replaceAllUsesWith(newCallOp);
            } else {
              SmallVector<Value, 16> slicedOutChannel;
              for (auto outChannelIter = 0; outChannelIter < outChannelDiv;
                   outChannelIter++) {
                SmallVector<Value, 16> slicedOutInChannel;
                for (auto inChannelIter = 0; inChannelIter < inChannelDiv;
                     inChannelIter++) {
                  SmallVector<Value, 16> slicedOutRows;
                  for (auto inWidthIter = 0; inWidthIter < inSizeDiv;
                       inWidthIter++) {
                    SmallVector<Value, 16> slicedOutColumns;
                    for (auto inHeightIter = 0; inHeightIter < inSizeDiv;
                         inHeightIter++) {
                      Value slicedInput, slicedWeight, slicedBias;

                      if (inChannelDiv <= 1 && inSizeDiv <= 1) {
                        slicedInput = Conv2DOp.getOperand(0);
                      } else {
                        auto inputStart = builder.getI64ArrayAttr(
                            {0, inWidthIter * SharedHelper.getInputSize(),
                             inHeightIter * SharedHelper.getInputSize(), 0});
                        auto inputSize = builder.getI64ArrayAttr(
                            {1, SharedHelper.getInputSize(),
                             SharedHelper.getInputSize(),
                             SharedHelper.numInputChannels()});
                        auto inputType =
                            SharedHelper.op.getOperand(0).getType();
                        slicedInput = builder
                                          .create<tosa::SliceOp>(
                                              Conv2DOp.getLoc(), inputType,
                                              Conv2DOp->getOperand(0),
                                              inputStart, inputSize)
                                          .output();
                      }

                      if (outChannelDiv <= 1 && inChannelDiv <= 1) {
                        slicedWeight = Conv2DOp->getOperand(1);
                      } else {
                        auto weightStart = builder.getI64ArrayAttr(
                            {outChannelIter * SharedHelper.numOutputChannels(),
                             0, 0,
                             inChannelIter * SharedHelper.numInputChannels()});
                        auto weightSize = builder.getI64ArrayAttr(
                            {SharedHelper.numOutputChannels(),
                             SharedHelper.kernelSize(),
                             SharedHelper.kernelSize(),
                             SharedHelper.numInputChannels()});
                        auto weightType =
                            SharedHelper.op.getOperand(1).getType();
                        slicedWeight = builder
                                           .create<tosa::SliceOp>(
                                               Conv2DOp.getLoc(), weightType,
                                               Conv2DOp->getOperand(1),
                                               weightStart, weightSize)
                                           .output();
                      }

                      if (inChannelIter == 0) {
                        if (outChannelDiv <= 1) {
                          slicedBias = Conv2DOp->getOperand(2);
                        } else {
                          auto biasStart = builder.getI64ArrayAttr(
                              {outChannelIter *
                               SharedHelper.numOutputChannels()});
                          auto biasSize = builder.getI64ArrayAttr(
                              {SharedHelper.numOutputChannels()});
                          auto biasType =
                              SharedHelper.op.getOperand(2).getType();
                          slicedBias = builder
                                           .create<tosa::SliceOp>(
                                               Conv2DOp.getLoc(), biasType,
                                               Conv2DOp->getOperand(2),
                                               biasStart, biasSize)
                                           .output();
                        }
                      } else {
                        auto biasTensor = RankedTensorType::get(
                            SharedHelper.numOutputChannels(),
                            builder.getF32Type());
                        auto biasAttr = DenseFPElementsAttr::get(
                            biasTensor, std::vector<float>(
                                            SharedHelper.numOutputChannels()));
                        auto biasType = SharedHelper.op.getOperand(2).getType();
                        slicedBias = builder.create<tosa::ConstOp>(
                            Conv2DOp.getLoc(), biasType, biasAttr);
                      }

                      auto operands = {slicedInput, slicedWeight, slicedBias};
                      slicedOutColumns.push_back(
                          builder
                              .create<func::CallOp>(
                                  Conv2DOp.getLoc(), functionName,
                                  SharedHelper.op->getResultTypes(), operands)
                              .getODSResults(0)[0]);
                    }
                    if (slicedOutColumns.size() == 1) {
                      slicedOutRows.push_back(slicedOutColumns[0]);
                    } else {
                      auto columnResultShape =
                          ArrayRef<int64_t>({1, SharedHelper.getInputSize(),
                                             CurrHelper.getInputSize(),
                                             SharedHelper.numOutputChannels()});
                      auto columnResultType = RankedTensorType::get(
                          (columnResultShape), builder.getF32Type());
                      slicedOutRows.push_back(builder.create<tosa::ConcatOp>(
                          Conv2DOp.getLoc(), columnResultType, slicedOutColumns,
                          2));
                    }
                  }
                  if (slicedOutRows.size() == 1) {
                    slicedOutInChannel.push_back(slicedOutRows[0]);
                  } else {
                    auto rowResultShape =
                        ArrayRef<int64_t>({1, CurrHelper.getInputSize(),
                                           CurrHelper.getInputSize(),
                                           SharedHelper.numOutputChannels()});
                    auto rowResultType = RankedTensorType::get(
                        (rowResultShape), builder.getF32Type());
                    slicedOutInChannel.push_back(builder.create<tosa::ConcatOp>(
                        Conv2DOp.getLoc(), rowResultType, slicedOutRows, 1));
                  }
                }
                if (slicedOutInChannel.size() == 1) {
                  slicedOutChannel.push_back(slicedOutInChannel[0]);
                } else {
                  auto inChResultType = slicedOutInChannel[0].getType();
                  auto newAddOp = builder.create<tosa::AddOp>(
                      Conv2DOp.getLoc(), inChResultType,
                      ValueRange(
                          {slicedOutInChannel[0], slicedOutInChannel[1]}));
                  for (auto inChannelIter = 2; inChannelIter < inChannelDiv;
                       inChannelIter++) {
                    newAddOp = builder.create<tosa::AddOp>(
                        Conv2DOp.getLoc(), inChResultType,
                        ValueRange(
                            {newAddOp, slicedOutInChannel[inChannelIter]}));
                  }
                  slicedOutChannel.push_back(newAddOp);
                }
              }
              if (slicedOutChannel.size() == 1) {
                Conv2DOp.replaceAllUsesWith(slicedOutChannel[0]);
              } else {
                Operation *newConcatOp = builder.create<tosa::ConcatOp>(
                    Conv2DOp.getLoc(), Conv2DOp->getResultTypes(),
                    slicedOutChannel, 3);
                Conv2DOp.replaceAllUsesWith(newConcatOp);
              }
            }
          }
        }
      });
    }
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

static bool applyShareTensorOperation(ModuleOp module) {
  // Count the number of each shape of convolution.
  DenseMap<ConvHelper, unsigned> countMap;

  // Traverse the entire module and count all the convolutions.
  auto funcs = module.getOps<FuncOp>();
  for (auto func : funcs) {
    func.walk([&](Operation *op) {
      if (auto Conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvHelper info;
        info.op = Conv2DOp;
        if (!countMap.count(info)) {
          countMap[info] = 1;
        } else {
          countMap[info] += 1;
        }
      }
    });
  }

  // Find the shape of convolution that happens most frequently.
  unsigned maxCount = 0;
  ConvHelper sharedHelper;
  for (auto item : countMap) {
    if (item.second > maxCount) {
      maxCount = item.second;
      sharedHelper = item.first;
    }
  }

  auto functionName = "shared_convolution";
  auto newFuncOp = createSharedFunction(module, sharedHelper.op, functionName);
  replaceFunction(module, sharedHelper.op, newFuncOp);

  return true;
}

namespace {
struct ShareTensorOperation
    : public ShareTensorOperationBase<ShareTensorOperation> {
  void runOnOperation() override {
    auto module = getOperation();
    applyShareTensorOperation(module);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createShareTensorOperationPass() {
  return std::make_unique<ShareTensorOperation>();
}
