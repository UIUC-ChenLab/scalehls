//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/IR/HLS.h"
#include "mlir/Dialect/Affine/Analysis/Utils.h"
#include "mlir/Dialect/Tensor/IR/Tensor.h"
#include "mlir/IR/DialectImplementation.h"
#include "mlir/IR/Dominance.h"
#include "mlir/IR/IntegerSet.h"
#include "scalehls/Utils/Utils.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;
using namespace affine;

//===----------------------------------------------------------------------===//
// HLS Dialect
//===----------------------------------------------------------------------===//

void HLSDialect::initialize() {
  addTypes<
#define GET_TYPEDEF_LIST
#include "scalehls/Dialect/HLS/IR/HLSOpsTypes.cpp.inc"
      >();

  addAttributes<
#define GET_ATTRDEF_LIST
#include "scalehls/Dialect/HLS/IR/HLSOpsAttributes.cpp.inc"
      >();

  addOperations<
#define GET_OP_LIST
#include "scalehls/Dialect/HLS/IR/HLSOps.cpp.inc"
      >();
}

//===----------------------------------------------------------------------===//
// Tablegen Classes
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/IR/HLSOpsDialect.cpp.inc"
#include "scalehls/Dialect/HLS/IR/HLSOpsEnums.cpp.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsAttributes.cpp.inc"

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOpsTypes.cpp.inc"

#include "scalehls/Dialect/HLS/IR/HLSOpsInterfaces.cpp.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/IR/HLSOps.cpp.inc"

//===----------------------------------------------------------------------===//
// Dialect Utils
//===----------------------------------------------------------------------===//

/// Get or check the memory kind of a type.
MemoryKind hls::getMemoryKind(MemRefType type) {
  if (auto memorySpace = type.getMemorySpace())
    if (auto kindAttr = memorySpace.dyn_cast<MemoryKindAttr>())
      return kindAttr.getValue();
  return MemoryKind::UNKNOWN;
}

bool hls::isFullyPartitioned(MemRefType memrefType) {
  if (memrefType.getRank() == 0)
    return true;

  bool fullyPartitioned = false;
  SmallVector<int64_t, 8> factors;
  getPartitionFactors(memrefType, &factors);

  auto shapes = memrefType.getShape();
  fullyPartitioned =
      factors == SmallVector<int64_t, 8>(shapes.begin(), shapes.end());

  return fullyPartitioned;
}

// Calculate partition factors through analyzing the "memrefType" and return
// them in "factors". Meanwhile, the overall partition number is calculated and
// returned as well.
int64_t hls::getPartitionFactors(MemRefType memrefType,
                                 SmallVectorImpl<int64_t> *factors) {
  int64_t accumFactor = 1;
  if (auto attr = memrefType.getLayout().dyn_cast<PartitionLayoutAttr>())
    for (auto factor : attr.getActualFactors(memrefType.getShape())) {
      accumFactor *= factor;
      if (factors)
        factors->push_back(factor);
    }
  else if (factors)
    factors->assign(memrefType.getRank(), 1);
  return accumFactor;
}

OpOperand *hls::getUntiledOperand(OpOperand *operand) {
  while (auto arg = dyn_cast<BlockArgument>(operand->get())) {
    if (auto loop = dyn_cast<scf::ForOp>(arg.getOwner()->getParentOp()))
      operand = loop.getTiedLoopInit(arg);
    else if (auto task = dyn_cast<hls::TaskOp>(arg.getOwner()->getParentOp()))
      operand = &task->getOpOperand(arg.getArgNumber());
    else
      break;
  }
  return operand;
}
