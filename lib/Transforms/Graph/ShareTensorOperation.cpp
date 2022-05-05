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

class OpHelper {
public:
  int64_t key = 0;

  OpHelper(){};
  OpHelper(int64_t _key) { key = _key; }

  bool operator==(const OpHelper &rhs) const { return this->key == rhs.key; }

  bool operator<(const OpHelper &rhs) const {
    if (*this == rhs) {
      return false;
    } else {
      return (this->key < rhs.key);
    }
  }

  bool isEmptyKey() const {
    int64_t emptyKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL;
    return key == emptyKey;
  }

  bool isTombstoneKey() const {
    int64_t tombstoneKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL - 1L;
    return key == tombstoneKey;
  }
};

namespace llvm {
template <> struct DenseMapInfo<OpHelper> {
  static OpHelper getEmptyKey() {
    int64_t emptyKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL;
    return OpHelper(emptyKey);
  }
  static OpHelper getTombstoneKey() {
    int64_t tombstoneKey = (1UL << (sizeof(int64_t) * 8 - 1)) - 1UL - 1L;
    return OpHelper(tombstoneKey);
  }
  static unsigned getHashValue(OpHelper Val) { return 0; }
  static bool isEqual(OpHelper LHS, OpHelper RHS) { return LHS == RHS; }
};
} // namespace llvm

class ConvOpHelper : public OpHelper {
public:
  int64_t batchSize;
  int64_t inCh;
  int64_t inSize;
  int64_t outCh;
  int64_t outSize;
  int64_t kernelSize;
  int64_t pad;
  int64_t stride;
  int64_t dilation;
  Type inputType;
  Type weightType;
  Type outputType;
  Type biasType;

  ConvOpHelper() {
    batchSize = 0;
    inCh = 0;
    inSize = 0;
    outCh = 0;
    outSize = 0;
    kernelSize = 0;
    pad = 0;
    stride = 0;
    dilation = 0;
  }

  ConvOpHelper(int64_t _batchSize, int64_t _inCh, int64_t _inSize,
               int64_t _outCh, int64_t _outSize, int64_t _kernelSize,
               int64_t _pad, int64_t _stride, int64_t _dilation)
      : OpHelper(getHashValue(_kernelSize, _pad, _stride, _dilation)) {
    batchSize = _batchSize;
    inCh = _inCh;
    inSize = _inSize;
    outCh = _outCh;
    outSize = _outSize;
    kernelSize = _kernelSize;
    pad = _pad;
    stride = _stride;
    dilation = _dilation;
  }

  ConvOpHelper(tosa::Conv2DOp op) : OpHelper(getHashValue(op)) {
    auto inType = op.input().getType().cast<RankedTensorType>();
    batchSize = inType.getShape()[0];
    inSize = inType.getShape()[1];
    inputType = inType.getElementType();
    auto wType = op.weight().getType().cast<RankedTensorType>();
    inCh = wType.getShape()[3];
    outCh = wType.getShape()[0];
    kernelSize = wType.getShape()[1];
    weightType = wType.getElementType();
    auto outType = op.output().getType().cast<RankedTensorType>();
    outSize = outType.getShape()[1];
    outputType = outType.getElementType();
    biasType = op.bias().getType().cast<RankedTensorType>().getElementType();
    pad = op.pad()[0].dyn_cast<IntegerAttr>().getInt();
    stride = op.stride()[0].dyn_cast<IntegerAttr>().getInt();
    dilation = op.dilation()[0].dyn_cast<IntegerAttr>().getInt();
  }

  bool operator==(ConvOpHelper &rhs) { return this->equalAttr(rhs); }

  bool equalAttr(ConvOpHelper &rhs) {
    return (pad == rhs.pad) && (stride == rhs.stride) &&
           (dilation == rhs.dilation) && (kernelSize == rhs.kernelSize);
  }

  void takeSmallerDim(ConvOpHelper &rhs) {
    inCh = inCh < rhs.inCh ? inCh : rhs.inCh;
    outCh = outCh < rhs.outCh ? outCh : rhs.outCh;
    inSize = inSize < rhs.inSize ? inSize : rhs.inSize;
    outSize = inSize < rhs.inSize ? outSize : rhs.outSize;
  }

  unsigned getHashValue() const {
    auto hash = kernelSize * 37U;
    hash = (hash + pad) * 37U;
    hash = (hash + stride) * 37U;
    hash = (hash + dilation) * 37U;
    return hash;
  }

  static unsigned getHashValue(int64_t _kernelSize, int64_t _pad,
                               int64_t _stride, int64_t _dilation) {
    auto hash = _kernelSize * 37U;
    hash = (hash + _pad) * 37U;
    hash = (hash + _stride) * 37U;
    hash = (hash + _dilation) * 37U;
    return hash;
  }

  static unsigned getHashValue(tosa::Conv2DOp op) {
    int64_t _kernelSize =
        op.weight().getType().cast<RankedTensorType>().getShape()[1];
    int64_t _pad = op.pad()[0].dyn_cast<IntegerAttr>().getInt();
    int64_t _stride = op.stride()[0].dyn_cast<IntegerAttr>().getInt();
    int64_t _dilation = op.dilation()[0].dyn_cast<IntegerAttr>().getInt();
    auto hash = _kernelSize * 37U;
    hash = (hash + _pad) * 37U;
    hash = (hash + _stride) * 37U;
    hash = (hash + _dilation) * 37U;
    return hash;
  }

  static bool classof(const OpHelper *op) { return true; }
};

static bool createBufferAndRemovePadding(ModuleOp module) {
  auto builder = OpBuilder(module);

  SmallVector<Operation *, 32> opToErase;
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](Operation *op) {
      auto loc = op->getLoc();

      if (auto conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvOpHelper helper = ConvOpHelper(conv2DOp);

        // Create a new function argument
        auto inType = conv2DOp.input().getType().dyn_cast<RankedTensorType>();
        ArrayRef<int64_t> newInShape = {
            helper.batchSize, helper.inSize + 2 * helper.pad,
            helper.inSize + 2 * helper.pad, helper.inCh};
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(newInShape, inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(conv2DOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            conv2DOp.input());

        // Create a subview for the argument (copy to buffer)
        auto offset =
            ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(0),
                                    builder.getI64IntegerAttr(helper.pad),
                                    builder.getI64IntegerAttr(helper.pad),
                                    builder.getI64IntegerAttr(0)});
        auto size =
            ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(helper.batchSize),
                                    builder.getI64IntegerAttr(helper.inSize),
                                    builder.getI64IntegerAttr(helper.inSize),
                                    builder.getI64IntegerAttr(helper.inCh)});
        auto stride = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
             builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
        auto inSubview = builder.create<memref::SubViewOp>(
            loc, inMemrefArg, offset, size, stride);

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inSubview);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new convolution without padding
        auto newConv2DOp = builder.create<tosa::Conv2DOp>(
            loc, conv2DOp.output().getType(), inToTensor.result(),
            conv2DOp.weight(), conv2DOp.bias(),
            builder.getI64ArrayAttr({0, 0, 0, 0}), conv2DOp.stride(),
            conv2DOp.dilation());

        conv2DOp.output().replaceAllUsesWith(newConv2DOp.output());
        opToErase.push_back(conv2DOp);
      }

      else if (auto reluNOp = dyn_cast<tosa::ReluNOp>(op)) {
        // Create a new function argument
        auto inType = reluNOp.input().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(reluNOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            reluNOp.input());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new relu
        auto newReluNOp = builder.create<tosa::ReluNOp>(
            loc, reluNOp.output().getType(), inToTensor.result(),
            reluNOp.max_int(), reluNOp.max_fp());

        reluNOp.output().replaceAllUsesWith(newReluNOp.output());
        opToErase.push_back(reluNOp);
      }

      else if (auto maxPool2dOp = dyn_cast<tosa::MaxPool2dOp>(op)) {
        // Create a new function argument
        auto inType =
            maxPool2dOp.input().getType().dyn_cast<RankedTensorType>();
        auto inShape = inType.getShape();
        auto pad = maxPool2dOp.pad()[0].dyn_cast<IntegerAttr>().getInt();
        ArrayRef<int64_t> newInShape = {inShape[0], inShape[1] + 2 * pad,
                                        inShape[2] + 2 * pad, inShape[3]};
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(newInShape, inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(maxPool2dOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            maxPool2dOp.input());

        // Create a subview for the argument (copy to buffer)
        auto offset = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(0), builder.getI64IntegerAttr(pad),
             builder.getI64IntegerAttr(pad), builder.getI64IntegerAttr(0)});
        auto size =
            ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(inShape[0]),
                                    builder.getI64IntegerAttr(inShape[1]),
                                    builder.getI64IntegerAttr(inShape[2]),
                                    builder.getI64IntegerAttr(inShape[3])});
        auto stride = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
             builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
        auto inSubview = builder.create<memref::SubViewOp>(
            loc, inMemrefArg, offset, size, stride);

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inSubview);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new maxpool without padding
        auto newMaxPool2dOp = builder.create<tosa::MaxPool2dOp>(
            loc, maxPool2dOp.output().getType(), inToTensor.result(),
            maxPool2dOp.kernel(), maxPool2dOp.stride(),
            builder.getI64ArrayAttr({0, 0, 0, 0}));

        maxPool2dOp.output().replaceAllUsesWith(newMaxPool2dOp.output());
        opToErase.push_back(maxPool2dOp);
      }

      else if (auto avgPool2dOp = dyn_cast<tosa::AvgPool2dOp>(op)) {
        // Create a new function argument
        auto inType =
            avgPool2dOp.input().getType().dyn_cast<RankedTensorType>();
        auto inShape = inType.getShape();
        auto pad = avgPool2dOp.pad()[0].dyn_cast<IntegerAttr>().getInt();
        ArrayRef<int64_t> newInShape = {inShape[0], inShape[1] + 2 * pad,
                                        inShape[2] + 2 * pad, inShape[3]};
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(newInShape, inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(avgPool2dOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            avgPool2dOp.input());

        // Create a subview for the argument (copy to buffer)
        auto offset = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(0), builder.getI64IntegerAttr(pad),
             builder.getI64IntegerAttr(pad), builder.getI64IntegerAttr(0)});
        auto size =
            ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(inShape[0]),
                                    builder.getI64IntegerAttr(inShape[1]),
                                    builder.getI64IntegerAttr(inShape[2]),
                                    builder.getI64IntegerAttr(inShape[3])});
        auto stride = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
             builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
        auto inSubview = builder.create<memref::SubViewOp>(
            loc, inMemrefArg, offset, size, stride);

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inSubview);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new avgpool without padding
        auto newAvgPool2dOp = builder.create<tosa::AvgPool2dOp>(
            loc, avgPool2dOp.output().getType(), inToTensor.result(),
            avgPool2dOp.kernel(), avgPool2dOp.stride(),
            builder.getI64ArrayAttr({0, 0, 0, 0}));

        avgPool2dOp.output().replaceAllUsesWith(newAvgPool2dOp.output());
        opToErase.push_back(avgPool2dOp);
      }

      else if (auto addOp = dyn_cast<tosa::AddOp>(op)) {
        // Create a new function argument for input 1
        auto in1Type = addOp.input1().getType().dyn_cast<RankedTensorType>();
        auto in1MemrefArg = func.front().addArgument(
            MemRefType::get(in1Type.getShape(), in1Type.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(addOp);
        auto in1ToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(in1Type.getShape(), in1Type.getElementType()),
            addOp.input1());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, in1ToMemref, in1MemrefArg);

        // Change the new input to tensor
        auto in1ToTensor =
            builder.create<bufferization::ToTensorOp>(loc, in1MemrefArg);

        // Create a new function argument for input 2
        auto in2Type = addOp.input2().getType().dyn_cast<RankedTensorType>();
        auto in2MemrefArg = func.front().addArgument(
            MemRefType::get(in2Type.getShape(), in2Type.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(addOp);
        auto in2ToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(in2Type.getShape(), in2Type.getElementType()),
            addOp.input2());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, in2ToMemref, in2MemrefArg);

        // Change the new input to tensor
        auto in2ToTensor =
            builder.create<bufferization::ToTensorOp>(loc, in2MemrefArg);

        // Create a new add
        auto newAddOp = builder.create<tosa::AddOp>(
            loc, addOp.output().getType(), in1ToTensor.result(),
            in2ToTensor.result());

        addOp.output().replaceAllUsesWith(newAddOp.output());
        opToErase.push_back(addOp);
      }

      else if (auto reshapeOp = dyn_cast<tosa::ReshapeOp>(op)) {
        // Create a new function argument
        auto inType = reshapeOp.input1().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(reshapeOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            reshapeOp.input1());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new reshape
        auto newReshapeOp = builder.create<tosa::ReshapeOp>(
            loc, reshapeOp.output().getType(), inToTensor.result(),
            reshapeOp.new_shape());

        reshapeOp.output().replaceAllUsesWith(newReshapeOp.output());
        opToErase.push_back(reshapeOp);
      }

      else if (auto fullyConnectedOp = dyn_cast<tosa::FullyConnectedOp>(op)) {
        // Create a new function argument
        auto inType =
            fullyConnectedOp.input().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(fullyConnectedOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            fullyConnectedOp.input());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new reshape
        auto newFullyConnectedOp = builder.create<tosa::FullyConnectedOp>(
            loc, fullyConnectedOp.output().getType(), inToTensor.result(),
            fullyConnectedOp.weight(), fullyConnectedOp.bias());

        fullyConnectedOp.output().replaceAllUsesWith(
            newFullyConnectedOp.output());
        opToErase.push_back(fullyConnectedOp);
      }

      else if (auto returnOp = dyn_cast<func::ReturnOp>(op)) {
        // Create a new function argument
        auto inType =
            returnOp.operands().front().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(returnOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            returnOp.operands().front());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Create a new return without a return value
        builder.create<func::ReturnOp>(loc);
        func.setType(builder.getFunctionType(func.front().getArgumentTypes(),
                                             TypeRange()));

        opToErase.push_back(returnOp);
      }

      else if (auto funcOp = dyn_cast<func::FuncOp>(op)) {
        return;
      }

      else {
        op->emitError("Unsupported operation");
      }
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

static FuncOp createSharedConvolution(ModuleOp module, ConvOpHelper helper,
                                      StringRef functionName) {
  auto builder = OpBuilder(module);

  // Create a shared function that contains helper's convolution
  SmallVector<Type, 16> inputTypes;
  auto inputShape = ArrayRef<int64_t>(
      {helper.batchSize, helper.inSize, helper.inSize, helper.inCh});
  auto inputType = MemRefType::get((inputShape), helper.inputType);
  inputTypes.push_back(inputType);

  auto weightShape = ArrayRef<int64_t>(
      {helper.kernelSize, helper.kernelSize, helper.inCh, helper.outCh});
  auto weightType = MemRefType::get((weightShape), helper.weightType);
  inputTypes.push_back(weightType);

  auto resultShape = ArrayRef<int64_t>(
      {helper.batchSize, helper.outSize, helper.outSize, helper.outCh});
  auto resultType = MemRefType::get((resultShape), helper.outputType);
  inputTypes.push_back(resultType);

  // Define function
  auto newType = builder.getFunctionType(inputTypes, TypeRange());
  builder.setInsertionPointToStart(module.getBody());
  auto newFuncOp =
      builder.create<FuncOp>(builder.getUnknownLoc(), functionName, newType);
  newFuncOp->setAttr("shared", builder.getUnitAttr());
  newFuncOp->setAttr("type", builder.getStringAttr("convolution"));
  newFuncOp->setAttr("count", builder.getI64IntegerAttr(0));
  auto entryBlock = newFuncOp.addEntryBlock();
  builder.setInsertionPointToStart(entryBlock);

  // Get parameters
  auto input = entryBlock->getArgument(0);
  auto weight = entryBlock->getArgument(1);
  auto output = entryBlock->getArgument(2);

  // Create a linalg convolution
  auto stride =
      NamedAttribute(builder.getStringAttr("stride"),
                     builder.getI64TensorAttr({helper.stride, helper.stride}));
  auto dilation = NamedAttribute(
      builder.getStringAttr("dilation"),
      builder.getI64TensorAttr({helper.dilation, helper.dilation}));
  builder.create<linalg::Conv2DNhwcHwcfOp>(
      builder.getUnknownLoc(), ValueRange({input, weight}),
      ValueRange({output}), ArrayRef({stride, dilation}));

  builder.create<func::ReturnOp>(builder.getUnknownLoc());
  return newFuncOp;
}

static bool replaceFunction(ModuleOp module, ConvOpHelper sharedHelper,
                            FuncOp funcOp) {
  auto builder = OpBuilder(module);

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Convert matching convolutions into CallOp to shared function.
  for (auto func : module.getOps<FuncOp>()) {
    if (func->getAttr("shared"))
      continue;

    // Instantiate a buffer for input of shared function
    builder.setInsertionPointToStart(&func.front());
    auto inputBufferAlloc = builder.create<memref::AllocOp>(
        func.getLoc(),
        MemRefType::get({sharedHelper.batchSize, sharedHelper.inSize,
                         sharedHelper.inSize, sharedHelper.inCh},
                        sharedHelper.inputType));
    auto inputBuffer = inputBufferAlloc.memref();

    // Instantiate a buffer for weight of shared function
    auto weightBufferAlloc = builder.create<memref::AllocOp>(
        func.getLoc(),
        MemRefType::get({sharedHelper.kernelSize, sharedHelper.kernelSize,
                         sharedHelper.inCh, sharedHelper.outCh},
                        sharedHelper.weightType));
    auto weightBuffer = weightBufferAlloc.memref();

    // Instantiate a buffer for output of shared function
    auto outputBufferAlloc = builder.create<memref::AllocOp>(
        func.getLoc(),
        MemRefType::get({sharedHelper.batchSize, sharedHelper.outSize,
                         sharedHelper.outSize, sharedHelper.outCh},
                        sharedHelper.outputType));
    auto outputBuffer = outputBufferAlloc.memref();

    func.walk([&](tosa::Conv2DOp conv2DOp) {
      auto loc = conv2DOp.getLoc();
      ConvOpHelper currHelper = ConvOpHelper(conv2DOp);

      if (!currHelper.equalAttr(sharedHelper))
        return;

      int64_t outChDiv =
          (currHelper.outCh + sharedHelper.outCh - 1) / sharedHelper.outCh;
      int64_t inChDiv =
          (currHelper.inCh + sharedHelper.inCh - 1) / sharedHelper.inCh;
      int64_t inSizeDiv =
          (currHelper.inSize + sharedHelper.inSize - 1) / sharedHelper.inSize;

      // Input MemRef object allocated off-chip
      bufferization::ToTensorOp inToTensor;
      if (conv2DOp.input().getDefiningOp()) {
        if (auto toTensor = dyn_cast<bufferization::ToTensorOp>(
                conv2DOp.input().getDefiningOp())) {
          inToTensor = toTensor;
        }
      }
      auto inMemref = inToTensor.memref();

      // Output MemRef object allocated off-chip
      bufferization::ToMemrefOp outToMemref;
      for (auto user : conv2DOp.output().getUsers()) {
        if (auto toMemref = dyn_cast<bufferization::ToMemrefOp>(user)) {
          outToMemref = toMemref;
        }
      }
      memref::CopyOp outCopy;
      for (auto user : outToMemref.memref().getUsers()) {
        if (auto copy = dyn_cast<memref::CopyOp>(user)) {
          outCopy = copy;
        }
      }
      Value outMemref = outCopy.target();
      Value outMemrefArg = outMemref;
      memref::SubViewOp outSubview;
      if (outMemref.getDefiningOp()) {
        auto subview = dyn_cast<memref::SubViewOp>(outMemref.getDefiningOp());
        outMemrefArg = subview.source();

        builder.setInsertionPoint(conv2DOp);
        auto outSubview =
            dyn_cast<memref::SubViewOp>(builder.insert(subview.clone()));
        subview.result().replaceAllUsesWith(outSubview.result());
        outMemref = outSubview.result();
        opToErase.push_back(subview);
      }

      // Create linalg generic for setting up output as bias
      builder.setInsertionPoint(conv2DOp);
      auto biasToMemref = builder.create<bufferization::ToMemrefOp>(
          loc, MemRefType::get({currHelper.outCh}, sharedHelper.biasType),
          conv2DOp.bias());
      auto biasMemref = biasToMemref.memref();
      auto biasMap = AffineMap::get(4, 0, {builder.getAffineDimExpr(3)},
                                    builder.getContext());
      auto normalMap = AffineMap::get(
          4, 0,
          {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
           builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
          builder.getContext());
      auto parallel = StringRef("parallel");
      auto biasGeneric = builder.create<linalg::GenericOp>(
          loc, ValueRange({biasMemref}), ValueRange({outMemref}),
          ArrayRef({biasMap, normalMap}),
          ArrayRef({parallel, parallel, parallel, parallel}));
      auto biasGenericEntry = builder.createBlock(&biasGeneric.getBodyRegion());
      auto biasGenericArg0 =
          biasGenericEntry->addArgument(builder.getF32Type(), loc);
      biasGenericEntry->addArgument(builder.getF32Type(), loc);
      builder.setInsertionPointToEnd(biasGenericEntry);
      builder.create<linalg::YieldOp>(loc, biasGenericArg0);

      // Create output channel loop
      builder.setInsertionPointAfter(biasGeneric);
      auto outChLoop = builder.create<AffineForOp>(loc, 0, outChDiv, 1);
      builder.setInsertionPointToStart(outChLoop.getBody());
      auto outChApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.outCh),
          outChLoop.getInductionVar());
      auto outCh = outChApply.getODSResults(0)[0];

      // Create input channel loop
      auto inChLoop = builder.create<AffineForOp>(loc, 0, inChDiv, 1);
      builder.setInsertionPointToStart(inChLoop.getBody());
      auto inChApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0, builder.getAffineDimExpr(0) * sharedHelper.inCh),
          inChLoop.getInductionVar());
      auto inCh = inChApply.getODSResults(0)[0];

      // Create width loop
      auto widthLoop = builder.create<AffineForOp>(loc, 0, inSizeDiv, 1);
      builder.setInsertionPointToStart(widthLoop.getBody());
      auto inWidthApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.inSize),
          widthLoop.getInductionVar());
      auto inWidth = inWidthApply.getODSResults(0)[0];
      auto outWidthApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.outSize),
          widthLoop.getInductionVar());
      auto outWidth = outWidthApply.getODSResults(0)[0];

      // Create height loop
      auto heightLoop = builder.create<AffineForOp>(loc, 0, inSizeDiv, 1);
      builder.setInsertionPointToStart(heightLoop.getBody());
      auto inHeightApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.inSize),
          heightLoop.getInductionVar());
      auto inHeight = inHeightApply.getODSResults(0)[0];
      auto outHeightApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.outSize),
          heightLoop.getInductionVar());
      auto outHeight = outHeightApply.getODSResults(0)[0];

      // Slice inputs
      auto bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), inWidth, inHeight, inCh});
      auto bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(sharedHelper.batchSize),
           builder.getI64IntegerAttr(sharedHelper.inSize +
                                     sharedHelper.pad * 2),
           builder.getI64IntegerAttr(sharedHelper.inSize +
                                     sharedHelper.pad * 2),
           builder.getI64IntegerAttr(sharedHelper.inCh)});
      auto bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedInputSubview = builder.create<memref::SubViewOp>(
          loc, inMemref, bufOffset, bufSize, bufStride);
      builder.create<memref::CopyOp>(loc, slicedInputSubview.result(),
                                     inputBuffer);

      // Slice weights
      auto weightToMemref = builder.create<bufferization::ToMemrefOp>(
          loc,
          MemRefType::get({currHelper.outCh, currHelper.kernelSize,
                           currHelper.kernelSize, currHelper.inCh},
                          currHelper.weightType),
          conv2DOp.weight());
      auto weightMemref = weightToMemref.memref();
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
      auto slicedWeightSubview = builder.create<memref::SubViewOp>(
          loc, weightMemref, bufOffset, bufSize, bufStride);
      auto slicedWeight = slicedWeightSubview.result();

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
      builder.create<func::CallOp>(loc, funcOp, operands);
      auto count = funcOp->getAttr("count").dyn_cast<IntegerAttr>().getInt();
      funcOp->setAttr("count",
                      builder.getI64IntegerAttr(
                          count + outChDiv * inChDiv * inSizeDiv * inSizeDiv));

      // Create a subview of the final output memref
      bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), outWidth, outHeight, outCh});
      bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(sharedHelper.batchSize),
           builder.getI64IntegerAttr(sharedHelper.outSize),
           builder.getI64IntegerAttr(sharedHelper.outSize),
           builder.getI64IntegerAttr(sharedHelper.outCh)});
      bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedOutput = builder.create<memref::SubViewOp>(
          loc, outMemref, bufOffset, bufSize, bufStride);

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
      opToErase.push_back(outToMemref);
      opToErase.push_back(conv2DOp);
      opToErase.push_back(inToTensor);
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

static bool lowerRemainingTosaOp(ModuleOp module) {
  for (auto func : module.getOps<FuncOp>()) {
    if (func->getAttr("shared"))
      continue;

    func.walk([&](Operation *op) {
      if (auto conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
      } else if (auto reluNOp = dyn_cast<tosa::ReluNOp>(op)) {
        // Input MemRef object allocated off-chip
        /*bufferization::ToTensorOp inToTensor;
        if (reluNOp.input().getDefiningOp()) {
          if (auto toTensor = dyn_cast<bufferization::ToTensorOp>(
                  reluNOp.input().getDefiningOp())) {
            inToTensor = toTensor;
          }
        }
        auto inMemref = inToTensor.memref();

        // Output MemRef object allocated off-chip
        bufferization::ToMemrefOp outToMemref;
        for (auto user : reluNOp.output().getUsers()) {
          if (auto toMemref = dyn_cast<bufferization::ToMemrefOp>(user)) {
            outToMemref = toMemref;
          }
        }
        memref::CopyOp outCopy;
        for (auto user : outToMemref.memref().getUsers()) {
          if (auto copy = dyn_cast<memref::CopyOp>(user)) {
            outCopy = copy;
          }
        }
        Value outMemref = outCopy.target();
        memref::SubViewOp outSubview;
        if (outMemref.getDefiningOp()) {
          auto subview = dyn_cast<memref::SubViewOp>(outMemref.getDefiningOp());
          outMemref = subview.source();
          outSubview = subview;
        }

        // Find the padding of the output memref
        int64_t nextPad =
            (outMemref.getType().dyn_cast<MemRefType>().getShape()[1] -
             currHelper.outSize) /
            2;*/
      }
    });
  }

  return true;
}

bool scalehls::applyShareTensorOperation(ModuleOp module, unsigned numTargets) {
  createBufferAndRemovePadding(module);

  // Count the number of each shape of convolution.
  DenseMap<OpHelper, std::pair<OpHelper *, unsigned>> countMap;
  // Traverse the entire module and count all the convolutions.
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](Operation *op) {
      if (auto conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvOpHelper *helper = new ConvOpHelper(conv2DOp);
        if (!countMap.count(*helper)) {
          countMap[*helper] = std::pair<OpHelper *, unsigned>(helper, 1);
        } else {
          ConvOpHelper *originalHelper =
              dyn_cast<ConvOpHelper>(countMap[*helper].first);
          helper->takeSmallerDim(*originalHelper);
          delete (originalHelper);
          auto currCount = countMap[*helper].second;
          countMap.erase(*helper);
          countMap[*helper] =
              std::pair<OpHelper *, unsigned>(helper, currCount + 1);
        }
      }
    });
  }

  // Find the types of convolutions that happen frequently and replace it with
  // shared function
  OpHelper *opHelper;
  for (unsigned i = 0; i < numTargets || numTargets == 0; i++) {
    unsigned maxCount = 0;
    for (auto item : countMap) {
      if (item.second.second > maxCount) {
        opHelper = item.second.first;
        maxCount = item.second.second;
      }
    }
    if (maxCount == 0)
      break;
    else {
      if (isa<ConvOpHelper>(opHelper)) {
        ConvOpHelper convOpHelper = *dyn_cast<ConvOpHelper>(opHelper);
        countMap.erase(*opHelper);
        auto functionName = "shared_function_" + std::to_string(i);
        auto newFuncOp =
            createSharedConvolution(module, convOpHelper, functionName);
        replaceFunction(module, convOpHelper, newFuncOp);
      }
    }
  }

  lowerRemainingTosaOp(module);
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
