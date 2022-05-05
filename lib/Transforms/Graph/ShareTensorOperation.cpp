//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

struct ConvHelper {
  int64_t inCh;
  int64_t inSize;
  int64_t outCh;
  int64_t outSize;
  int64_t kernelSize;
  int64_t pad;
  int64_t stride;
  int64_t dilation;

  ConvHelper() {
    inCh = 0;
    inSize = 0;
    outCh = 0;
    outSize = 0;
    kernelSize = 0;
    pad = 0;
    stride = 0;
    dilation = 0;
  }

  ConvHelper(int64_t _inCh, int64_t _inSize, int64_t _outCh, int64_t _outSize,
             int64_t _kernelSize, int64_t _pad, int64_t _stride,
             int64_t _dilation) {
    inCh = _inCh;
    inSize = _inSize;
    outCh = _outCh;
    outSize = _outSize;
    kernelSize = _kernelSize;
    pad = _pad;
    stride = _stride;
    dilation = _dilation;
  }

  ConvHelper(tosa::Conv2DOp op) {
    auto inType = op.input().getType().cast<RankedTensorType>();
    inSize = inType.getShape()[1];
    auto weightType = op.weight().getType().cast<RankedTensorType>();
    inCh = weightType.getShape()[3];
    outCh = weightType.getShape()[0];
    auto outType = op.output().getType().cast<RankedTensorType>();
    outSize = outType.getShape()[1];
    kernelSize = weightType.getShape()[1];
    pad = op.pad()[0].dyn_cast<IntegerAttr>().getInt();
    stride = op.stride()[0].dyn_cast<IntegerAttr>().getInt();
    dilation = op.dilation()[0].dyn_cast<IntegerAttr>().getInt();
  }

  bool equalAttr(ConvHelper &rhs) {
    return (pad == rhs.pad) && (stride == rhs.stride) &&
           (dilation == rhs.dilation) && (kernelSize == rhs.kernelSize);
  }

  bool equalShape(ConvHelper &rhs) {
    return (inSize == rhs.inSize) && (outSize == rhs.outSize) &&
           (inCh == rhs.inCh) && (outCh == rhs.outCh) &&
           (kernelSize == rhs.kernelSize);
  }

  void takeSmallerDim(ConvHelper &rhs) {
    inCh = inCh < rhs.inCh ? inCh : rhs.inCh;
    outCh = outCh < rhs.outCh ? outCh : rhs.outCh;
    inSize = inSize < rhs.inSize ? inSize : rhs.inSize;
    outSize = inSize < rhs.inSize ? outSize : rhs.outSize;
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
    return this->equalAttr(rhs);
  }

  unsigned getHashValue() const {
    unsigned hash = inCh * 37U;
    hash = (hash + inSize) * 37U;
    hash = (hash + outCh) * 37U;
    hash = (hash + outSize) * 37U;
    hash = (hash + kernelSize) * 37U;
    hash = (hash + pad) * 37U;
    hash = (hash + stride) * 37U;
    hash = (hash + dilation) * 37U;
    return hash;
  }

  bool operator<(const ConvHelper &rhs) const {
    ConvHelper lhs = ConvHelper(*this);
    ConvHelper rhsCopy = ConvHelper(rhs);
    if (lhs == rhsCopy) {
      return false;
    } else {
      return (this->getHashValue() < rhs.getHashValue());
    }
  }
  bool isEmptyKey() {
    int64_t emptyKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL;
    return (inCh == emptyKey) && (inSize == emptyKey) && (outCh == emptyKey) &&
           (outSize == emptyKey) && (kernelSize == emptyKey) &&
           (pad == emptyKey) && (stride == emptyKey) && (dilation == emptyKey);
  }
  bool isTombstoneKey() {
    int64_t tombstoneKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL - 1L;
    return (inCh == tombstoneKey) && (inSize == tombstoneKey) &&
           (outCh == tombstoneKey) && (outSize == tombstoneKey) &&
           (kernelSize == tombstoneKey) && (pad == tombstoneKey) &&
           (stride == tombstoneKey) && (dilation == tombstoneKey);
  }
};

namespace llvm {
template <> struct DenseMapInfo<ConvHelper> {
  static ConvHelper getEmptyKey() {
    int64_t emptyKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL;
    return ConvHelper{emptyKey, emptyKey, emptyKey, emptyKey,
                      emptyKey, emptyKey, emptyKey, emptyKey};
  }
  static ConvHelper getTombstoneKey() {
    int64_t tombstoneKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL - 1L;
    return ConvHelper{tombstoneKey, tombstoneKey, tombstoneKey, tombstoneKey,
                      tombstoneKey, tombstoneKey, tombstoneKey, tombstoneKey};
  }
  static unsigned getHashValue(ConvHelper Val) { return 0; }
  static bool isEqual(ConvHelper LHS, ConvHelper RHS) { return LHS == RHS; }
};
} // namespace llvm

static bool preProcess(ModuleOp module) {
  auto builder = OpBuilder(module);

  // Move all hidden features to off-chip buffer and remove paddings
  SmallVector<Operation *, 32> opToErase;
  bool firstConv = true;
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](tosa::Conv2DOp Conv2DOp) {
      auto loc = Conv2DOp.getLoc();
      ConvHelper helper = ConvHelper(Conv2DOp);

      // If first conv, create memref copy for future padding
      if (firstConv) {
        builder.setInsertionPoint(Conv2DOp);

        auto firstInput = Conv2DOp.input();

        // Create a new function argument
        auto inType = firstInput.getType().dyn_cast<RankedTensorType>();
        ArrayRef<int64_t> newInShape = {1, helper.outSize + 2 * helper.pad,
                                        helper.outSize + 2 * helper.pad,
                                        helper.outCh};
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(newInShape, inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        auto inMemref =
            builder
                .create<bufferization::ToMemrefOp>(
                    loc,
                    MemRefType::get(inType.getShape(), inType.getElementType()),
                    Conv2DOp.input())
                .memref();

        // Create a subview for the argument (copy to buffer)
        auto bufOffset =
            ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(0),
                                    builder.getI64IntegerAttr(helper.pad),
                                    builder.getI64IntegerAttr(helper.pad),
                                    builder.getI64IntegerAttr(0)});
        auto bufSize =
            ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(1),
                                    builder.getI64IntegerAttr(helper.inSize),
                                    builder.getI64IntegerAttr(helper.inSize),
                                    builder.getI64IntegerAttr(helper.inCh)});
        auto bufStride = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
             builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
        auto inSubview = builder.create<memref::SubViewOp>(
            loc, inMemrefArg, bufOffset, bufSize, bufStride);

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inMemref, inSubview);

        // Change the new input to tensor
        auto inTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg)
                .result();

        Conv2DOp.inputMutable().slice(0, 1).assign(inTensor);
        firstConv = false;
      }

      // Get the padding of next convolution if there is one
      auto nextPad = 0;
      for (auto user : Conv2DOp.output().getUsers()) {
        if (auto nextConv = dyn_cast<tosa::Conv2DOp>(user)) {
          nextPad = ConvHelper(nextConv).pad;
        }
      }

      // Move results to off-chip
      auto outType = Conv2DOp.output().getType().dyn_cast<RankedTensorType>();
      ArrayRef<int64_t> newOutShape = {1, helper.outSize + 2 * nextPad,
                                       helper.outSize + 2 * nextPad,
                                       helper.outCh};
      auto outMemrefArg = func.front().addArgument(
          MemRefType::get(newOutShape, outType.getElementType()), loc);
      func.setType(builder.getFunctionType(
          func.front().getArgumentTypes(),
          func.back().getTerminator()->getOperandTypes()));

      // Create a new convolution without padding
      builder.setInsertionPointAfter(Conv2DOp);
      auto newConv2DOp = builder.create<tosa::Conv2DOp>(
          loc, Conv2DOp.output().getType(), Conv2DOp.input(), Conv2DOp.weight(),
          Conv2DOp.bias(), builder.getI64ArrayAttr({0, 0, 0, 0}),
          Conv2DOp.stride(), Conv2DOp.dilation());

      // Bufferize result to memref
      auto outMemref = builder.create<bufferization::ToMemrefOp>(
          loc, MemRefType::get(outType.getShape(), outType.getElementType()),
          newConv2DOp.output());

      // Create a subview for the output argument if necessary
      auto bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), builder.getI64IntegerAttr(nextPad),
           builder.getI64IntegerAttr(nextPad), builder.getI64IntegerAttr(0)});
      auto bufSize =
          ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(1),
                                  builder.getI64IntegerAttr(helper.outSize),
                                  builder.getI64IntegerAttr(helper.outSize),
                                  builder.getI64IntegerAttr(helper.outCh)});
      auto bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto subview = builder.create<memref::SubViewOp>(
          loc, outMemrefArg, bufOffset, bufSize, bufStride);

      // Copy to sliced output
      builder.create<memref::CopyOp>(loc, outMemref, subview);

      // Create final output tensor
      auto outTensor =
          builder.create<bufferization::ToTensorOp>(loc, outMemrefArg).result();

      opToErase.push_back(Conv2DOp);
      Conv2DOp.replaceAllUsesWith(outTensor);
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

static FuncOp createSharedFunction(ModuleOp module, ConvHelper sharedHelper,
                                   StringRef functionName) {
  auto builder = OpBuilder(module);

  // Create a shared function that contains sharedHelper's convolution
  SmallVector<Type, 16> inputTypes;
  auto inputShape = ArrayRef<int64_t>(
      {1, sharedHelper.inSize + sharedHelper.pad * 2,
       sharedHelper.inSize + sharedHelper.pad * 2, sharedHelper.inCh});
  auto inputType = MemRefType::get((inputShape), builder.getF32Type());
  inputTypes.push_back(inputType);

  auto weightShape =
      ArrayRef<int64_t>({sharedHelper.kernelSize, sharedHelper.kernelSize,
                         sharedHelper.inCh, sharedHelper.outCh});
  auto weightType = MemRefType::get((weightShape), builder.getF32Type());
  inputTypes.push_back(weightType);

  auto resultShape = ArrayRef<int64_t>(
      {1, sharedHelper.outSize, sharedHelper.outSize, sharedHelper.outCh});
  auto resultType = MemRefType::get((resultShape), builder.getF32Type());
  inputTypes.push_back(resultType);

  // Define function
  auto newType = builder.getFunctionType(inputTypes, TypeRange());
  builder.setInsertionPointToStart(module.getBody());
  auto newFuncOp =
      builder.create<FuncOp>(builder.getUnknownLoc(), functionName, newType);
  newFuncOp->setAttr("shared", UnitAttr::get(newFuncOp->getContext()));
  newFuncOp->setAttr("convolution", UnitAttr::get(newFuncOp->getContext()));
  newFuncOp->setAttr("name", builder.getStringAttr(functionName));
  newFuncOp->setAttr("count", builder.getI64IntegerAttr(0));
  auto entryBlock = newFuncOp.addEntryBlock();
  builder.setInsertionPointToStart(entryBlock);

  // Get parameters
  auto input = entryBlock->getArgument(0);
  auto weight = entryBlock->getArgument(1);
  auto output = entryBlock->getArgument(2);

  // Create a linalg convolution
  auto stride = NamedAttribute(
      builder.getStringAttr("stride"),
      builder.getI64TensorAttr({sharedHelper.stride, sharedHelper.stride}));
  auto dilation = NamedAttribute(
      builder.getStringAttr("dilation"),
      builder.getI64TensorAttr({sharedHelper.dilation, sharedHelper.dilation}));
  builder.create<linalg::Conv2DNhwcHwcfOp>(
      builder.getUnknownLoc(), ValueRange({input, weight}),
      ValueRange({output}), ArrayRef({stride, dilation}));

  builder.create<func::ReturnOp>(builder.getUnknownLoc());
  return newFuncOp;
}

static bool replaceFunction(ModuleOp module, ConvHelper sharedHelper,
                            FuncOp newFuncOp) {
  auto builder = OpBuilder(module);

  // Shared function name
  auto functionName = newFuncOp->getAttr("name").dyn_cast<StringAttr>();
  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Convert matching convolutions into CallOp to shared function.
  for (auto func : module.getOps<FuncOp>()) {
    if (func->getAttr("shared"))
      continue;

    // Instantiate a buffer for input of shared function
    builder.setInsertionPointToStart(&func.front());
    auto inputBuffer =
        builder
            .create<memref::AllocOp>(
                func.getLoc(),
                MemRefType::get({1, sharedHelper.inSize + 2 * sharedHelper.pad,
                                 sharedHelper.inSize + 2 * sharedHelper.pad,
                                 sharedHelper.inCh},
                                builder.getF32Type()))
            .memref();

    // Instantiate a buffer for output of shared function
    auto outputBuffer =
        builder
            .create<memref::AllocOp>(
                func.getLoc(),
                MemRefType::get({1, sharedHelper.outSize, sharedHelper.outSize,
                                 sharedHelper.outCh},
                                builder.getF32Type()))
            .memref();

    // Instantiate a buffer for weight of shared function
    auto weightBuffer =
        builder
            .create<memref::AllocOp>(
                func.getLoc(),
                MemRefType::get({sharedHelper.kernelSize,
                                 sharedHelper.kernelSize, sharedHelper.inCh,
                                 sharedHelper.outCh},
                                builder.getF32Type()))
            .memref();

    func.walk([&](tosa::Conv2DOp Conv2DOp) {
      auto loc = Conv2DOp.getLoc();
      ConvHelper currHelper = ConvHelper(Conv2DOp);

      if (!currHelper.equalAttr(sharedHelper))
        return;

      int64_t outChDiv =
          (currHelper.outCh + sharedHelper.outCh - 1) / sharedHelper.outCh;
      int64_t inChDiv =
          (currHelper.inCh + sharedHelper.inCh - 1) / sharedHelper.inCh;
      int64_t inSizeDiv =
          (currHelper.inSize + sharedHelper.inSize - 1) / sharedHelper.inSize;

      // Input MemRef object allocated off-chip
      Value inTensorValue = Conv2DOp.input();
      bufferization::ToTensorOp inTensor;
      if (Conv2DOp.input().getDefiningOp()) {
        if (auto tensor = dyn_cast<bufferization::ToTensorOp>(
                inTensorValue.getDefiningOp())) {
          inTensor = tensor;
        }
      }

      // Modify ToTensorOp of shape changes
      auto inArgument = inTensor.memref();

      // Output MemRef object allocated off-chip
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
      auto outSubview =
          dyn_cast<memref::SubViewOp>(outCopy.target().getDefiningOp());
      bufferization::ToTensorOp outTensor;
      for (auto user : outSubview.source().getUsers()) {
        if (auto tensor = dyn_cast<bufferization::ToTensorOp>(user)) {
          outTensor = tensor;
        }
      }

      // Find the padding of next convolution operation
      auto outArgument = outSubview.source();
      int64_t nextPad =
          (outArgument.getType().dyn_cast<MemRefType>().getShape()[1] -
           currHelper.outSize) /
          2;

      // Create linalg generic for setting up output as bias
      builder.setInsertionPoint(Conv2DOp);
      auto biasMemref = builder.create<bufferization::ToMemrefOp>(
          loc, MemRefType::get({currHelper.outCh}, builder.getF32Type()),
          Conv2DOp.bias());
      auto biasMap = AffineMap::get(4, 0, {builder.getAffineDimExpr(3)},
                                    builder.getContext());
      auto normalMap = AffineMap::get(
          4, 0,
          {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
           builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
          builder.getContext());
      auto parallel = StringRef("parallel");
      auto inputGeneric = builder.create<linalg::GenericOp>(
          loc, ValueRange({biasMemref}), ValueRange({outArgument}),
          ArrayRef({biasMap, normalMap}),
          ArrayRef({parallel, parallel, parallel, parallel}));
      auto inputGenericEntry =
          builder.createBlock(&inputGeneric.getBodyRegion());
      auto inputGenericArg0 =
          inputGenericEntry->addArgument(builder.getF32Type(), loc);
      inputGenericEntry->addArgument(builder.getF32Type(), loc);
      builder.setInsertionPointToEnd(inputGenericEntry);
      builder.create<linalg::YieldOp>(loc, inputGenericArg0);

      // Create output channel loop
      builder.setInsertionPointAfter(inputGeneric);
      auto outChLoop = builder.create<AffineForOp>(loc, 0, outChDiv, 1);
      builder.setInsertionPointToStart(outChLoop.getBody());
      auto outCh =
          builder
              .create<AffineApplyOp>(
                  loc,
                  AffineMap::get(
                      1, 0, builder.getAffineDimExpr(0) * sharedHelper.outCh),
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
                      1, 0, builder.getAffineDimExpr(0) * sharedHelper.inCh),
                  inChLoop.getInductionVar())
              .getODSResults(0)[0];

      // Create width loop
      auto widthLoop = builder.create<AffineForOp>(loc, 0, inSizeDiv, 1);
      builder.setInsertionPointToStart(widthLoop.getBody());
      auto inWidth =
          builder
              .create<AffineApplyOp>(
                  loc,
                  AffineMap::get(
                      1, 0, builder.getAffineDimExpr(0) * sharedHelper.inSize),
                  widthLoop.getInductionVar())
              .getODSResults(0)[0];
      auto outWidth = builder
                          .create<AffineApplyOp>(
                              loc,
                              AffineMap::get(1, 0,
                                             builder.getAffineDimExpr(0) *
                                                     sharedHelper.outSize +
                                                 nextPad),
                              widthLoop.getInductionVar())
                          .getODSResults(0)[0];

      // Create height loop
      auto heightLoop = builder.create<AffineForOp>(loc, 0, inSizeDiv, 1);
      builder.setInsertionPointToStart(heightLoop.getBody());
      auto inHeight =
          builder
              .create<AffineApplyOp>(
                  loc,
                  AffineMap::get(
                      1, 0, builder.getAffineDimExpr(0) * sharedHelper.inSize),
                  heightLoop.getInductionVar())
              .getODSResults(0)[0];
      auto outHeight = builder
                           .create<AffineApplyOp>(
                               loc,
                               AffineMap::get(1, 0,
                                              builder.getAffineDimExpr(0) *
                                                      sharedHelper.outSize +
                                                  nextPad),
                               heightLoop.getInductionVar())
                           .getODSResults(0)[0];

      // Slice inputs
      auto bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), inWidth, inHeight, inCh});
      auto bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(sharedHelper.inSize +
                                     sharedHelper.pad * 2),
           builder.getI64IntegerAttr(sharedHelper.inSize +
                                     sharedHelper.pad * 2),
           builder.getI64IntegerAttr(sharedHelper.inCh)});
      auto bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedInput = builder
                             .create<memref::SubViewOp>(
                                 loc, inArgument, bufOffset, bufSize, bufStride)
                             .result();
      builder.create<memref::CopyOp>(loc, slicedInput, inputBuffer);

      // Slice weights
      auto weightMemref = builder.create<bufferization::ToMemrefOp>(
          loc,
          MemRefType::get({currHelper.outCh, currHelper.kernelSize,
                           currHelper.kernelSize, currHelper.inCh},
                          builder.getF32Type()),
          Conv2DOp.weight());
      bufOffset = ArrayRef<OpFoldResult>({outCh, builder.getI64IntegerAttr(0),
                                          builder.getI64IntegerAttr(0), inCh});
      bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(sharedHelper.outCh),
           builder.getI64IntegerAttr(sharedHelper.kernelSize),
           builder.getI64IntegerAttr(sharedHelper.kernelSize),
           builder.getI64IntegerAttr(sharedHelper.inCh)});
      bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedWeight =
          builder
              .create<memref::SubViewOp>(loc, weightMemref, bufOffset, bufSize,
                                         bufStride)
              .result();

      // Reshape weight appropriately
      auto weightMap = AffineMap::get(
          4, 0,
          {builder.getAffineDimExpr(3), builder.getAffineDimExpr(0),
           builder.getAffineDimExpr(1), builder.getAffineDimExpr(2)},
          builder.getContext());
      auto weightGeneric = builder.create<linalg::GenericOp>(
          loc, ValueRange({slicedWeight}), ValueRange({weightBuffer}),
          ArrayRef({weightMap, normalMap}),
          ArrayRef({parallel, parallel, parallel, parallel}));
      auto weightGenericEntry =
          builder.createBlock(&weightGeneric.getBodyRegion());
      auto weightGenericArg0 =
          weightGenericEntry->addArgument(builder.getF32Type(), loc);
      weightGenericEntry->addArgument(builder.getF32Type(), loc);
      builder.setInsertionPointToEnd(weightGenericEntry);
      builder.create<linalg::YieldOp>(loc, weightGenericArg0);

      // Call function
      builder.setInsertionPointAfter(weightGeneric);
      auto operands = {inputBuffer, weightBuffer, outputBuffer};
      builder.create<func::CallOp>(loc, functionName, TypeRange(), operands);
      auto count = newFuncOp->getAttr("count").dyn_cast<IntegerAttr>().getInt();
      newFuncOp->setAttr(
          "count", builder.getI64IntegerAttr(
                       count + outChDiv * inChDiv * inSizeDiv * inSizeDiv));

      // Create a subview of the final output memref
      bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), outWidth, outHeight, outCh});
      bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(sharedHelper.outSize),
           builder.getI64IntegerAttr(sharedHelper.outSize),
           builder.getI64IntegerAttr(sharedHelper.outCh)});
      bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedOutput = builder.create<memref::SubViewOp>(
          loc, outSubview.source(), bufOffset, bufSize, bufStride);

      // Add to sliced output
      auto outputGeneric = builder.create<linalg::GenericOp>(
          loc, ValueRange({outputBuffer}), ValueRange({slicedOutput}),
          ArrayRef({normalMap, normalMap}),
          ArrayRef({parallel, parallel, parallel, parallel}));
      auto outputGenericEntry =
          builder.createBlock(&outputGeneric.getBodyRegion());
      auto outputGenericArg0 =
          outputGenericEntry->addArgument(builder.getF32Type(), loc);
      auto outputGenericArg1 =
          outputGenericEntry->addArgument(builder.getF32Type(), loc);
      builder.setInsertionPointToEnd(outputGenericEntry);
      auto outputGenericAdd = builder.create<arith::AddFOp>(
          loc, builder.getF32Type(), outputGenericArg0, outputGenericArg1);
      builder.create<linalg::YieldOp>(loc, outputGenericAdd.getResult());

      opToErase.push_back(outCopy);
      opToErase.push_back(outMemref);
      opToErase.push_back(Conv2DOp);
      opToErase.push_back(inTensor);
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

static bool postProcess(ModuleOp module) {
  auto builder = OpBuilder(module);

  // Remove padding for unshared convolutions
  SmallVector<Operation *, 32> opToErase;
  for (auto func : module.getOps<FuncOp>()) {
    if (!func->getAttr("shared")) {
      func.walk([&](tosa::Conv2DOp Conv2DOp) {
        // Create a new ToTensorOp with padding
        auto inTensor = dyn_cast<bufferization::ToTensorOp>(
            Conv2DOp.input().getDefiningOp());
        auto subview =
            dyn_cast<memref::SubViewOp>(inTensor.memref().getDefiningOp());
        auto memrefArg = subview.source();
        builder.setInsertionPointAfter(inTensor);
        auto newInTensor = builder.create<bufferization::ToTensorOp>(
            inTensor.getLoc(), memrefArg);
        inTensor.result().replaceAllUsesWith(newInTensor.result());
        opToErase.push_back(inTensor);

        // Create a new Conv2DOp without padding
        auto input = Conv2DOp.input();
        auto weight = Conv2DOp.weight();
        auto bias = Conv2DOp.bias();
        auto outputType = Conv2DOp.output().getType();
        auto pad = builder.getI64ArrayAttr({0, 0, 0, 0});
        auto stride = Conv2DOp.stride();
        auto dilation = Conv2DOp.dilation();
        auto newConvOp =
            builder.create<tosa::Conv2DOp>(Conv2DOp.getLoc(), outputType, input,
                                           weight, bias, pad, stride, dilation);
        Conv2DOp.output().replaceAllUsesWith(newConvOp.output());
        opToErase.push_back(Conv2DOp);
      });
    }
  }
  for (auto op : opToErase)
    op->erase();

  // Remove all unnecessary subviews
  opToErase = SmallVector<Operation *, 32>();
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](memref::SubViewOp subview) {
      if (subview.result().getUsers().empty()) {
        opToErase.push_back(subview);
      }
    });
  }
  for (auto op : opToErase)
    op->erase();

  return true;
}

bool scalehls::applyShareTensorOperation(ModuleOp module, unsigned numTargets) {
  preProcess(module);

  // Count the number of each shape of convolution.
  DenseMap<ConvHelper, std::pair<ConvHelper, unsigned>> countMap;
  // Traverse the entire module and count all the convolutions.
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](tosa::Conv2DOp Conv2DOp) {
      ConvHelper helper = ConvHelper(Conv2DOp);
      if (!countMap.count(helper)) {
        countMap[helper] = std::pair<ConvHelper, unsigned>(helper, 1);
      } else {
        helper.takeSmallerDim(countMap[helper].first);
        auto currCount = countMap[helper].second;
        countMap.erase(helper);
        countMap[helper] =
            std::pair<ConvHelper, unsigned>(helper, currCount + 1);
      }
    });
  }

  // Find the types of convolutions that happen frequently and replace it with
  // shared function
  ConvHelper sharedHelper;
  for (unsigned i = 0; i < numTargets || numTargets == 0; i++) {
    unsigned maxCount = 0;
    for (auto item : countMap) {
      if (item.second.second > maxCount) {
        maxCount = item.second.second;
        sharedHelper = item.first;
      }
    }
    if (maxCount == 0)
      break;
    else {
      countMap.erase(sharedHelper);
      auto functionName = "shared_function_" + std::to_string(i);
      auto newFuncOp = createSharedFunction(module, sharedHelper, functionName);
      replaceFunction(module, sharedHelper, newFuncOp);
    }
  }

  postProcess(module);

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
