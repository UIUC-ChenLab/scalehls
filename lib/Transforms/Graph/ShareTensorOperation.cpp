//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
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

  // Shared convolution
  ConvHelper SharedHelper = ConvHelper(sharedConv);
  // Shared function name
  auto functionName = newFuncOp->getAttr("name").dyn_cast<StringAttr>();
  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Convert matching convolutions into CallOp to shared function.
  for (auto func : module.getOps<FuncOp>()) {
    if (func->getAttr("shared"))
      continue;

    func.walk([&](tosa::Conv2DOp Conv2DOp) {
      auto loc = Conv2DOp.getLoc();
      ConvHelper CurrHelper = ConvHelper(Conv2DOp);
      int64_t outChDiv = (CurrHelper.outCh() + SharedHelper.outCh() - 1) /
                         SharedHelper.outCh();
      int64_t inChDiv =
          (CurrHelper.inCh() + SharedHelper.inCh() - 1) / SharedHelper.inCh();
      int64_t inSizeDiv = (CurrHelper.inSize() + SharedHelper.inSize() - 1) /
                          SharedHelper.inSize();

      // Define zero bias if more than 1 input channel divs
      builder.setInsertionPoint(Conv2DOp);
      Value zeroBias;
      if (inChDiv > 1) {
        auto biasTensor =
            RankedTensorType::get(SharedHelper.outCh(), builder.getF32Type());
        auto biasAttr = DenseFPElementsAttr::get(
            biasTensor, std::vector<float>(SharedHelper.outCh()));
        auto biasType = SharedHelper.op.getOperand(2).getType();
        zeroBias = builder.create<tosa::ConstOp>(loc, biasType, biasAttr);
      }

      // Output MemRef object allocated off-chip and original buffers
      bufferization::ToMemrefOp outMemref;
      for (auto user : Conv2DOp.output().getUsers()) {
        if (auto memref = dyn_cast<bufferization::ToMemrefOp>(user)) {
          outMemref = memref;
        }
      }
      memref::CopyOp outCopy;
      for (auto user : outMemref.memref().getUsers()) {
        if (auto copy = dyn_cast<memref::CopyOp>(user)) {
          outCopy = copy;
        }
      }
      bufferization::ToTensorOp outTensor;
      for (auto user : outCopy.target().getUsers()) {
        if (auto copy = dyn_cast<bufferization::ToTensorOp>(user)) {
          outTensor = copy;
        }
      }

      // Create output channel loop
      auto outChLoop = builder.create<AffineForOp>(loc, 0, outChDiv, 1);
      builder.setInsertionPointToStart(outChLoop.getBody());
      auto outCh =
          builder
              .create<AffineApplyOp>(
                  loc,
                  AffineMap::get(
                      1, 0, builder.getAffineDimExpr(0) * SharedHelper.outCh()),
                  outChLoop.getInductionVar())
              .getODSResults(0)[0];

      // Create input channel loop
      auto inChLoop = builder.create<AffineForOp>(loc, 0, inChDiv, 1);
      builder.setInsertionPointToStart(inChLoop.getBody());
      auto inCh =
          builder
              .create<AffineApplyOp>(
                  loc,
                  AffineMap::get(
                      1, 0, builder.getAffineDimExpr(0) * SharedHelper.inCh()),
                  inChLoop.getInductionVar())
              .getODSResults(0)[0];

      // Create width loop
      auto widthLoop = builder.create<AffineForOp>(loc, 0, inSizeDiv, 1);
      builder.setInsertionPointToStart(widthLoop.getBody());
      auto inWidth = builder
                         .create<AffineApplyOp>(
                             loc,
                             AffineMap::get(1, 0,
                                            builder.getAffineDimExpr(0) *
                                                SharedHelper.inSize()),
                             widthLoop.getInductionVar())
                         .getODSResults(0)[0];
      auto outWidth = builder
                          .create<AffineApplyOp>(
                              loc,
                              AffineMap::get(1, 0,
                                             builder.getAffineDimExpr(0) *
                                                 SharedHelper.outSize()),
                              widthLoop.getInductionVar())
                          .getODSResults(0)[0];

      // Create height loop
      auto heightLoop = builder.create<AffineForOp>(loc, 0, inSizeDiv, 1);
      builder.setInsertionPointToStart(heightLoop.getBody());
      auto inHeight = builder
                          .create<AffineApplyOp>(
                              loc,
                              AffineMap::get(1, 0,
                                             builder.getAffineDimExpr(0) *
                                                 SharedHelper.inSize()),
                              heightLoop.getInductionVar())
                          .getODSResults(0)[0];
      auto outHeight = builder
                           .create<AffineApplyOp>(
                               loc,
                               AffineMap::get(1, 0,
                                              builder.getAffineDimExpr(0) *
                                                  SharedHelper.outSize()),
                               heightLoop.getInductionVar())
                           .getODSResults(0)[0];

      // Slice inputs
      auto bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), inWidth, inHeight, inCh});
      auto bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(SharedHelper.inSize()),
           builder.getI64IntegerAttr(SharedHelper.inSize()),
           builder.getI64IntegerAttr(SharedHelper.inCh())});
      auto bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedInput =
          builder
              .create<tensor::ExtractSliceOp>(loc, Conv2DOp->getOperand(0),
                                              bufOffset, bufSize, bufStride)
              .result();

      // Slice weights
      bufOffset = ArrayRef<OpFoldResult>({outCh, builder.getI64IntegerAttr(0),
                                          builder.getI64IntegerAttr(0), inCh});
      bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(SharedHelper.outCh()),
           builder.getI64IntegerAttr(SharedHelper.kernelSize()),
           builder.getI64IntegerAttr(SharedHelper.kernelSize()),
           builder.getI64IntegerAttr(SharedHelper.inCh())});
      bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedWeight =
          builder
              .create<tensor::ExtractSliceOp>(loc, Conv2DOp->getOperand(1),
                                              bufOffset, bufSize, bufStride)
              .result();

      // Slice biases
      bufOffset = ArrayRef<OpFoldResult>({outCh});
      bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(SharedHelper.outCh())});
      bufStride = ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(1)});
      auto slicedBias =
          builder
              .create<tensor::ExtractSliceOp>(loc, Conv2DOp->getOperand(2),
                                              bufOffset, bufSize, bufStride)
              .result();

      // Call function
      auto operands = {slicedInput, slicedWeight, slicedBias};
      auto slicedOutTensor =
          builder
              .create<func::CallOp>(loc, functionName,
                                    SharedHelper.op->getResultTypes(), operands)
              .getODSResults(0)[0];
      auto count = newFuncOp->getAttr("count").dyn_cast<IntegerAttr>().getInt();
      newFuncOp->setAttr(
          "count", builder.getI64IntegerAttr(
                       count + outChDiv * inChDiv * inSizeDiv * inSizeDiv));

      // Bufferize result to memref
      auto slicedOutType =
          slicedOutTensor.getType().dyn_cast<RankedTensorType>();
      auto slicedOutMemref = builder.create<bufferization::ToMemrefOp>(
          loc,
          MemRefType::get(slicedOutType.getShape(),
                          slicedOutType.getElementType()),
          slicedOutTensor);

      // Create a subview of the final output memref
      bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), outWidth, outHeight, outCh});
      bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(SharedHelper.outSize()),
           builder.getI64IntegerAttr(SharedHelper.outSize()),
           builder.getI64IntegerAttr(SharedHelper.outCh())});
      bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto subviewOut = builder.create<memref::SubViewOp>(
          loc, outCopy.target(), bufOffset, bufSize, bufStride);

      // Copy to sliced output
      builder.create<memref::CopyOp>(loc, slicedOutMemref, subviewOut);

      opToErase.push_back(outCopy);
      opToErase.push_back(outMemref);
      opToErase.push_back(Conv2DOp);
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

bool scalehls::applyShareTensorOperation(ModuleOp module, unsigned numTargets) {
  auto builder = OpBuilder(module);

  // Move all hidden features to off-chip buffer
  SmallVector<Operation *, 32> opToErase;
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](tosa::Conv2DOp Conv2DOp) {
      auto loc = Conv2DOp.getLoc();

      // Move results to off-chip
      auto outType = Conv2DOp.output().getType().dyn_cast<RankedTensorType>();
      auto outMemrefArg = func.front().addArgument(
          MemRefType::get(outType.getShape(), outType.getElementType()), loc);
      func.setType(builder.getFunctionType(
          func.front().getArgumentTypes(),
          func.back().getTerminator()->getOperandTypes()));

      builder.setInsertionPointAfter(Conv2DOp);
      auto newOp = builder.insert(Conv2DOp.clone());
      auto newConv2DOp = dyn_cast<tosa::Conv2DOp>(newOp);

      // Bufferize result to memref
      auto outMemref = builder.create<bufferization::ToMemrefOp>(
          loc, MemRefType::get(outType.getShape(), outType.getElementType()),
          newConv2DOp.output());

      // Copy to sliced output
      builder.create<memref::CopyOp>(loc, outMemref, outMemrefArg);

      // Create final output tensor
      auto outTensor =
          builder.create<bufferization::ToTensorOp>(loc, outType, outMemrefArg)
              .result();

      opToErase.push_back(Conv2DOp);
      Conv2DOp.replaceAllUsesWith(outTensor);
      return;
    });
  }
  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  // Count the number of each shape of convolution.
  DenseMap<ConvHelper, std::pair<ConvHelper, unsigned>> countMap;

  // Traverse the entire module and count all the convolutions.
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](tosa::Conv2DOp Conv2DOp) {
      ConvHelper info = ConvHelper(Conv2DOp);
      if (!countMap.count(info)) {
        countMap[info] = std::pair<ConvHelper, unsigned>(info, 1);
      } else {
        info.takeSmallerDim(countMap[info].first);
        auto currCount = countMap[info].second;
        countMap.erase(info);
        countMap[info] = std::pair<ConvHelper, unsigned>(info, currCount + 1);
      }
    });
  }

  // Find the types of convolutions that happen frequently and replace it with
  // shared function
  ConvHelper sharedHelper;
  for (unsigned i = 0; i < numTargets; i++) {
    unsigned maxCount = 0;
    for (auto item : countMap) {
      if (item.second.second > maxCount) {
        maxCount = item.second.second;
        sharedHelper = item.first;
      }
    }
    if (maxCount != 0) {
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
