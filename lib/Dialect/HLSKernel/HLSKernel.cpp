//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSKernel/HLSKernel.h"
#include "mlir/IR/StandardTypes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlskernel;

void HLSKernelDialect::initialize() {

  addOperations<
#define GET_OP_LIST
#include "Dialect/HLSKernel/HLSKernel.cpp.inc"
      >();
}

#include "Dialect/HLSCpp/HLSCppInterfaces.cpp.inc"

//===----------------------------------------------------------------------===//
// Utilities
//===----------------------------------------------------------------------===//

/// Verify that all memref operands of the operation have static shape.
static bool verifyStaticShape(Operation *op) {
  for (auto operand : op->getOperands()) {
    if (auto operandType = operand.getType().dyn_cast<MemRefType>()) {
      if (!operandType.hasStaticShape())
        return false;
    }
  }
  return true;
}

//===----------------------------------------------------------------------===//
// DenseOp
//===----------------------------------------------------------------------===//

static LogicalResult verify(DenseOp op) {
  if (!verifyStaticShape(op))
    return op.emitError("not all operands have static shape");

  auto IShape = op.getOperand(0).getType().cast<MemRefType>().getShape();
  auto KShape = op.getOperand(1).getType().cast<MemRefType>().getShape();
  auto BShape = op.getOperand(2).getType().cast<MemRefType>().getShape();
  auto OShape = op.getOperand(3).getType().cast<MemRefType>().getShape();

  if ((IShape.size() != 2 && IShape.size() != 4) ||
      (KShape.size() != 2 && KShape.size() != 4) || BShape.size() != 1 ||
      OShape.size() != 2 || IShape.size() != KShape.size())
    return op.emitError("incorrect operand shape, please refer to the op "
                        "description in include/Dialect/HLSKernel/CNNOps.td");

  if (IShape[0] != OShape[0])
    return op.emitError("incompatible shape on batch dimension");

  if (IShape[1] != KShape[1])
    return op.emitError("incompatible shape on channel dimension");

  if (KShape[0] != BShape[0] || KShape[0] != OShape[1])
    return op.emitError("incompatible shape on filter dimension");

  if (IShape.size() == 4) {
    if (IShape[2] != KShape[2] || IShape[3] != KShape[3])
      return op.emitError("incompatible shape on height or width dimension");
  }

  return success();
}

//===----------------------------------------------------------------------===//
// ConvOp
//===----------------------------------------------------------------------===//

static LogicalResult verify(ConvOp op) {
  if (!verifyStaticShape(op))
    return op.emitError("not all operands have static shape");

  auto IShape = op.getOperand(0).getType().cast<MemRefType>().getShape();
  auto KShape = op.getOperand(1).getType().cast<MemRefType>().getShape();
  auto BShape = op.getOperand(2).getType().cast<MemRefType>().getShape();
  auto OShape = op.getOperand(3).getType().cast<MemRefType>().getShape();

  SmallVector<int64_t, 2> padding;
  for (auto shape : op.getAttrOfType<ArrayAttr>("padding"))
    padding.push_back(shape.cast<IntegerAttr>().getInt());

  // TODO
  SmallVector<int64_t, 2> strides;
  for (auto shape : op.getAttrOfType<ArrayAttr>("strides")) {
    strides.push_back(shape.cast<IntegerAttr>().getInt());
    if (strides.back() != 1)
      return op.emitError("only stride 1 supported");
  }

  if (IShape.size() != 4 || KShape.size() != 4 || BShape.size() != 1 ||
      OShape.size() != 4)
    return op.emitError("incorrect operand shape, please refer to the op "
                        "description in include/Dialect/HLSKernel/CNNOps.td");

  if (IShape[0] != OShape[0])
    return op.emitError("incompatible shape on batch dimension");

  if (IShape[1] != KShape[1])
    return op.emitError("incompatible shape on channel dimension");

  if (KShape[0] != BShape[0] || KShape[0] != OShape[1])
    return op.emitError("incompatible shape on filter dimension");

  // TODO
  if (IShape[2] + padding[0] + padding[1] + 1 - KShape[2] != OShape[2] ||
      IShape[3] + padding[2] + padding[3] + 1 - KShape[3] != OShape[3])
    return op.emitError("incompatible shape on height and width dimension");

  return success();
}

//===----------------------------------------------------------------------===//
// MaxPoolOp
//===----------------------------------------------------------------------===//

static LogicalResult verify(MaxPoolOp op) {
  if (!verifyStaticShape(op))
    return op.emitError("not all operands have static shape");

  auto IShape = op.getOperand(0).getType().cast<MemRefType>().getShape();
  auto OShape = op.getOperand(1).getType().cast<MemRefType>().getShape();

  SmallVector<int64_t, 2> kernelShape;
  for (auto shape : op.getAttrOfType<ArrayAttr>("kernel_shape"))
    kernelShape.push_back(shape.cast<IntegerAttr>().getInt());

  // TODO
  SmallVector<int64_t, 2> padding;
  for (auto shape : op.getAttrOfType<ArrayAttr>("padding")) {
    padding.push_back(shape.cast<IntegerAttr>().getInt());
    if (padding.back() != 0)
      return op.emitError("only zero padding supported");
  }

  SmallVector<int64_t, 2> strides;
  for (auto shape : op.getAttrOfType<ArrayAttr>("strides"))
    strides.push_back(shape.cast<IntegerAttr>().getInt());

  // TODO
  if (kernelShape[0] != strides[0] || kernelShape[1] != strides[1])
    return op.emitError("only identical kernel shape and strides supported");

  if (IShape.size() != 4 || OShape.size() != 4)
    return op.emitError("incorrect operand shape, please refer to the op "
                        "description in include/Dialect/HLSKernel/CNNOps.td");

  if (IShape[0] != OShape[0])
    return op.emitError("incompatible shape on batch dimension");

  if (IShape[1] != OShape[1])
    return op.emitError("incompatible shape on channel dimension");

  if (IShape[0] != OShape[0])
    return op.emitError("incompatible shape on batch dimension");

  if (OShape[2] != IShape[2] / strides[0] ||
      OShape[3] != IShape[3] / strides[1])
    return op.emitError("incompatible shape on height and width dimension");

  return success();
}

//===----------------------------------------------------------------------===//
// ReluOp
//===----------------------------------------------------------------------===//

static LogicalResult verify(ReluOp op) {
  if (!verifyStaticShape(op))
    return op.emitError("not all operands have static shape");

  auto IShape = op.getOperand(0).getType().cast<MemRefType>().getShape();
  auto OShape = op.getOperand(1).getType().cast<MemRefType>().getShape();

  if (IShape != OShape)
    return op.emitError("incorrect operand shape, please refer to the op "
                        "description in include/Dialect/HLSKernel/CNNOps.td");

  return success();
}

//===----------------------------------------------------------------------===//
// MergeOp
//===----------------------------------------------------------------------===//

static LogicalResult verify(MergeOp op) {
  if (!verifyStaticShape(op))
    return op.emitError("not all operands have static shape");

  auto I0Shape = op.getOperand(0).getType().cast<MemRefType>().getShape();
  auto I1Shape = op.getOperand(1).getType().cast<MemRefType>().getShape();
  auto OShape = op.getOperand(2).getType().cast<MemRefType>().getShape();

  if (I0Shape != OShape || I1Shape != OShape)
    return op.emitError("incorrect operand shape, please refer to the op "
                        "description in include/Dialect/HLSKernel/CNNOps.td");

  return success();
}

//===----------------------------------------------------------------------===//
// Include Logics Generated from TableGen
//===----------------------------------------------------------------------===//

#define GET_OP_CLASSES
#include "Dialect/HLSKernel/HLSKernel.cpp.inc"
