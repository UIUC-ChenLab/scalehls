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
  int64_t newinCh;
  int64_t newOutCh;
  int64_t newInSize;

  ConvHelper() {}

  ConvHelper(tosa::Conv2DOp convOp) {
    op = convOp;
    if (!this->isEmptyKey() && !this->isTombstoneKey()) {
      newinCh = this->inCh();
      newOutCh = this->outCh();
      newInSize = this->inSize();
    }
  }

  ArrayRef<int64_t> inShape() {
    auto input = op.getOperand(0);
    return input.getType().cast<RankedTensorType>().getShape();
  }

  ArrayRef<int64_t> outShape() {
    auto output = op.getResult();
    return output.getType().cast<RankedTensorType>().getShape();
  }

  ArrayRef<int64_t> weightShape() {
    auto weight = op.getOperand(1);
    return weight.getType().cast<RankedTensorType>().getShape();
  }

  int64_t outCh() {
    auto shape = this->weightShape();
    return shape[0];
  }

  int64_t inCh() {
    auto shape = this->weightShape();
    return shape[3];
  }

  int64_t kernelSize() {
    auto shape = this->weightShape();
    return shape[1];
  }

  int64_t inSize() {
    auto shape = this->inShape();
    return shape[1];
  }

  int64_t outSize() {
    auto shape = this->outShape();
    return shape[1];
  }

  bool equalAttr(ConvHelper &rhs) {
    return (op.pad() == rhs.op.pad()) && (op.stride() == rhs.op.stride()) &&
           (op.dilation() == rhs.op.dilation()) &&
           (this->kernelSize() == rhs.kernelSize());
  }

  bool equalShape(ConvHelper &rhs) {
    return (this->inShape() == rhs.inShape()) &&
           (this->outShape() == rhs.outShape()) &&
           (this->weightShape() == rhs.weightShape());
  }

  void takeSmallerDim(ConvHelper &rhs) {
    newinCh = newinCh < rhs.newinCh ? newinCh : rhs.newinCh;
    newOutCh = newOutCh < rhs.newOutCh ? newOutCh : rhs.newOutCh;
    newInSize = newInSize < rhs.newInSize ? newInSize : rhs.newInSize;
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

    // return this->equalAttr(rhs) && this->equalShape(rhs);
    return this->equalAttr(rhs);
  }

  bool operator<(const ConvHelper &rhs) const {
    ConvHelper lhs = ConvHelper(*this);
    ConvHelper rhsCopy = ConvHelper(rhs);
    if (lhs == rhsCopy) {
      return false;
    } else {
      return (this->op < rhs.op);
    }
  }

  bool isEmptyKey() {
    void *pointer = llvm::DenseMapInfo<void *>::getEmptyKey();
    return tosa::Conv2DOp::getFromOpaquePointer(pointer) == op;
  }

  bool isTombstoneKey() {
    void *pointer = llvm::DenseMapInfo<void *>::getTombstoneKey();
    return tosa::Conv2DOp::getFromOpaquePointer(pointer) == op;
  }
};

namespace llvm {
template <> struct DenseMapInfo<ConvHelper> {
  static ConvHelper getEmptyKey() {
    void *pointer = llvm::DenseMapInfo<void *>::getEmptyKey();
    return ConvHelper(tosa::Conv2DOp::getFromOpaquePointer(pointer));
  }
  static ConvHelper getTombstoneKey() {
    void *pointer = llvm::DenseMapInfo<void *>::getTombstoneKey();
    return ConvHelper(tosa::Conv2DOp::getFromOpaquePointer(pointer));
  }
  static unsigned getHashValue(ConvHelper Val) {
    return 0; // mlir::hash_value(Val.op);
  }
  static bool isEqual(ConvHelper LHS, ConvHelper RHS) { return LHS == RHS; }
};
} // namespace llvm

static FuncOp createSharedFunction(ModuleOp module, ConvHelper &sharedHelper,
                                   StringRef functionName) {
  auto builder = OpBuilder(module);
  auto sharedConv = sharedHelper.op;

  // Create a function that contains the most frequent convolution.
  SmallVector<Type, 16> inputTypes;
  auto inputShape =
      ArrayRef<int64_t>({1, sharedHelper.newInSize, sharedHelper.newInSize,
                         sharedHelper.newinCh});
  auto inputType = RankedTensorType::get((inputShape), builder.getF32Type());
  inputTypes.push_back(inputType);
  auto weightShape =
      ArrayRef<int64_t>({sharedHelper.newOutCh, sharedHelper.kernelSize(),
                         sharedHelper.kernelSize(), sharedHelper.newinCh});
  auto weightType = RankedTensorType::get((weightShape), builder.getF32Type());
  inputTypes.push_back(weightType);
  auto biasShape = ArrayRef<int64_t>({sharedHelper.newOutCh});
  auto biasType = RankedTensorType::get((biasShape), builder.getF32Type());
  inputTypes.push_back(biasType);

  auto resultSize =
      (sharedHelper.newInSize - sharedHelper.kernelSize() +
       sharedConv.pad()[0].dyn_cast<IntegerAttr>().getInt() * 2 + 1) /
      sharedConv.stride()[0].dyn_cast<IntegerAttr>().getInt();
  auto resultShape =
      ArrayRef<int64_t>({1, resultSize, resultSize, sharedHelper.newOutCh});
  auto resultType = RankedTensorType::get((resultShape), builder.getF32Type());

  auto newType = builder.getFunctionType(inputTypes, resultType);
  builder.setInsertionPointToStart(module.getBody());
  auto newFuncOp =
      builder.create<FuncOp>(builder.getUnknownLoc(), functionName, newType);
  newFuncOp->setAttr("shared", UnitAttr::get(newFuncOp->getContext()));
  newFuncOp->setAttr("name", builder.getStringAttr(functionName));
  newFuncOp->setAttr("count", builder.getI64IntegerAttr(0));
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
  sharedHelper.op = newConvOp;

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
  ConvHelper SharedHelper = ConvHelper(sharedConv);
  // Shared function name
  auto functionName = newFuncOp->getAttr("name").dyn_cast<StringAttr>();
  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Convert matching convolutions into CallOp to shared function.
  for (auto func : funcs) {
    if (!func->getAttr("shared")) {
      func.walk([&](Operation *op) {
        if (auto Conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
          ConvHelper CurrHelper = ConvHelper(Conv2DOp);
          if (CurrHelper.equalAttr(SharedHelper)) {
            opToErase.push_back(Conv2DOp);
            builder.setInsertionPoint(Conv2DOp);

            int64_t outChDiv = (CurrHelper.outCh() + SharedHelper.outCh() - 1) /
                               SharedHelper.outCh();
            int64_t inChDiv = (CurrHelper.inCh() + SharedHelper.inCh() - 1) /
                              SharedHelper.inCh();
            int64_t inSizeDiv =
                (CurrHelper.inSize() + SharedHelper.inSize() - 1) /
                SharedHelper.inSize();

            if (outChDiv <= 1 && inChDiv <= 1 && inSizeDiv <= 1) {
              auto newCallOp = builder.create<func::CallOp>(
                  Conv2DOp.getLoc(), functionName, Conv2DOp->getResultTypes(),
                  Conv2DOp->getOperands());
              auto count =
                  newFuncOp->getAttr("count").dyn_cast<IntegerAttr>().getInt();
              newFuncOp->setAttr("count", builder.getI64IntegerAttr(count + 1));
              Conv2DOp.replaceAllUsesWith(newCallOp);
            } else {
              SmallVector<Value, 16> slicedOutCh;
              for (auto outChIt = 0; outChIt < outChDiv; outChIt++) {
                SmallVector<Value, 16> slicedOutInCh;
                for (auto inChIt = 0; inChIt < inChDiv; inChIt++) {
                  SmallVector<Value, 16> slicedOutRows;
                  for (auto inWidthIt = 0; inWidthIt < inSizeDiv; inWidthIt++) {
                    SmallVector<Value, 16> slicedOutCols;
                    for (auto inHeightIt = 0; inHeightIt < inSizeDiv;
                         inHeightIt++) {
                      Value slicedInput, slicedWeight, slicedBias;

                      if (inChDiv <= 1 && inSizeDiv <= 1) {
                        slicedInput = Conv2DOp.getOperand(0);
                      } else {
                        auto inputStart = builder.getI64ArrayAttr(
                            {0, inWidthIt * SharedHelper.inSize(),
                             inHeightIt * SharedHelper.inSize(), 0});
                        auto inputSize = builder.getI64ArrayAttr(
                            {1, SharedHelper.inSize(), SharedHelper.inSize(),
                             SharedHelper.inCh()});
                        auto inputType =
                            SharedHelper.op.getOperand(0).getType();
                        slicedInput = builder
                                          .create<tosa::SliceOp>(
                                              Conv2DOp.getLoc(), inputType,
                                              Conv2DOp->getOperand(0),
                                              inputStart, inputSize)
                                          .output();
                      }

                      if (outChDiv <= 1 && inChDiv <= 1) {
                        slicedWeight = Conv2DOp->getOperand(1);
                      } else {
                        auto weightStart = builder.getI64ArrayAttr(
                            {outChIt * SharedHelper.outCh(), 0, 0,
                             inChIt * SharedHelper.inCh()});
                        auto weightSize = builder.getI64ArrayAttr(
                            {SharedHelper.outCh(), SharedHelper.kernelSize(),
                             SharedHelper.kernelSize(), SharedHelper.inCh()});
                        auto weightType =
                            SharedHelper.op.getOperand(1).getType();
                        slicedWeight = builder
                                           .create<tosa::SliceOp>(
                                               Conv2DOp.getLoc(), weightType,
                                               Conv2DOp->getOperand(1),
                                               weightStart, weightSize)
                                           .output();
                      }

                      if (inChIt == 0) {
                        if (outChDiv <= 1) {
                          slicedBias = Conv2DOp->getOperand(2);
                        } else {
                          auto biasStart = builder.getI64ArrayAttr(
                              {outChIt * SharedHelper.outCh()});
                          auto biasSize =
                              builder.getI64ArrayAttr({SharedHelper.outCh()});
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
                            SharedHelper.outCh(), builder.getF32Type());
                        auto biasAttr = DenseFPElementsAttr::get(
                            biasTensor,
                            std::vector<float>(SharedHelper.outCh()));
                        auto biasType = SharedHelper.op.getOperand(2).getType();
                        slicedBias = builder.create<tosa::ConstOp>(
                            Conv2DOp.getLoc(), biasType, biasAttr);
                      }

                      auto operands = {slicedInput, slicedWeight, slicedBias};
                      slicedOutCols.push_back(
                          builder
                              .create<func::CallOp>(
                                  Conv2DOp.getLoc(), functionName,
                                  SharedHelper.op->getResultTypes(), operands)
                              .getODSResults(0)[0]);

                      auto count = newFuncOp->getAttr("count")
                                       .dyn_cast<IntegerAttr>()
                                       .getInt();
                      newFuncOp->setAttr("count",
                                         builder.getI64IntegerAttr(count + 1));
                    }
                    if (slicedOutCols.size() == 1) {
                      slicedOutRows.push_back(slicedOutCols[0]);
                    } else {
                      auto colResultShape = ArrayRef<int64_t>(
                          {1, SharedHelper.outSize(), CurrHelper.outSize(),
                           SharedHelper.outCh()});
                      auto colResultType = RankedTensorType::get(
                          (colResultShape), builder.getF32Type());
                      slicedOutRows.push_back(builder.create<tosa::ConcatOp>(
                          Conv2DOp.getLoc(), colResultType, slicedOutCols, 2));
                    }
                  }
                  if (slicedOutRows.size() == 1) {
                    slicedOutInCh.push_back(slicedOutRows[0]);
                  } else {
                    auto rowResultShape = ArrayRef<int64_t>(
                        {1, CurrHelper.outSize(), CurrHelper.outSize(),
                         SharedHelper.outCh()});
                    auto rowResultType = RankedTensorType::get(
                        (rowResultShape), builder.getF32Type());
                    slicedOutInCh.push_back(builder.create<tosa::ConcatOp>(
                        Conv2DOp.getLoc(), rowResultType, slicedOutRows, 1));
                  }
                }
                if (slicedOutInCh.size() == 1) {
                  slicedOutCh.push_back(slicedOutInCh[0]);
                } else {
                  auto inChResultType = slicedOutInCh[0].getType();
                  auto newAddOp = builder.create<tosa::AddOp>(
                      Conv2DOp.getLoc(), inChResultType,
                      ValueRange({slicedOutInCh[0], slicedOutInCh[1]}));
                  for (auto inChIt = 2; inChIt < inChDiv; inChIt++) {
                    newAddOp = builder.create<tosa::AddOp>(
                        Conv2DOp.getLoc(), inChResultType,
                        ValueRange({newAddOp, slicedOutInCh[inChIt]}));
                  }
                  slicedOutCh.push_back(newAddOp);
                }
              }
              if (slicedOutCh.size() == 1) {
                Conv2DOp.replaceAllUsesWith(slicedOutCh[0]);
              } else {
                Operation *newConcatOp = builder.create<tosa::ConcatOp>(
                    Conv2DOp.getLoc(), Conv2DOp->getResultTypes(), slicedOutCh,
                    3);
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

bool scalehls::applyShareTensorOperation(ModuleOp module, unsigned numTargets) {
  // Count the number of each shape of convolution.
  DenseMap<ConvHelper, std::pair<ConvHelper, unsigned>> countMap;

  // Traverse the entire module and count all the convolutions.
  auto funcs = module.getOps<FuncOp>();
  for (auto func : funcs) {
    func.walk([&](Operation *op) {
      if (auto Conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvHelper info = ConvHelper(Conv2DOp);
        if (!countMap.count(info)) {
          countMap[info] = std::pair<ConvHelper, unsigned>(info, 1);
        } else {
          info.takeSmallerDim(countMap[info].first);
          auto currCount = countMap[info].second;
          countMap.erase(info);
          countMap[info] = std::pair<ConvHelper, unsigned>(info, currCount + 1);
        }
      }
    });
  }

  // Find the types of convolutions that happen frequently.
  ConvHelper sharedHelper = ConvHelper();
  for (unsigned i = 0; i < numTargets; i++) {
    unsigned maxCount = 0;
    for (auto item : countMap) {
      if (item.second.second > maxCount) {
        maxCount = item.second.second;
        sharedHelper = item.first;
      }
    }
    if (maxCount > 0) {
      countMap.erase(sharedHelper);
      auto functionName = "shared_function_" + std::to_string(i);
      auto newFuncOp = createSharedFunction(module, sharedHelper, functionName);
      replaceFunction(module, sharedHelper.op, newFuncOp);
    }
  }

  return true;
}

namespace {
struct ShareTensorOperation
    : public ShareTensorOperationBase<ShareTensorOperation> {
  void runOnOperation() override {
    auto module = getOperation();
    applyShareTensorOperation(module, numTargets);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createShareTensorOperationPass() {
  return std::make_unique<ShareTensorOperation>();
}
