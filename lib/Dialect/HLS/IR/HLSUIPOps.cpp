//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

//===----------------------------------------------------------------------===//
// DeclareOp
//===----------------------------------------------------------------------===//

LibraryOp DeclareOp::getLibraryOp() {
  return cast<LibraryOp>((*this)->getParentOp());
}
SemanticsOp DeclareOp::getSemanticsOp() {
  return cast<SemanticsOp>(getMeta().front().getTerminator());
}

//===----------------------------------------------------------------------===//
// InstanceOp
//===----------------------------------------------------------------------===//

LogicalResult InstanceOp::verifySymbolUses(mlir::SymbolTableCollection &table) {
  auto param = table.lookupNearestSymbolFrom<DeclareOp>(
      (*this)->getParentOfType<ModuleOp>(), getIpAttr());
  if (!param)
    return (*this)->emitOpError("unknown IP name ") << getIpAttr();
  return success(param);
}

/// Return the number of inputs, outputs, and params.
unsigned InstanceOp::getNumInputs() {
  return getODSOperandIndexAndLength(0).second;
}
unsigned InstanceOp::getNumOutputs() {
  return getODSOperandIndexAndLength(1).second;
}
unsigned InstanceOp::getNumParams() {
  return getODSOperandIndexAndLength(2).second;
}

/// Get the type of operand: input, output, or param.
PortKind InstanceOp::getPortKind(OpOperand &operand) {
  assert(operand.getOwner() == *this && "invalid operand");
  return getPortKind(operand.getOperandNumber());
}
PortKind InstanceOp::getPortKind(unsigned operandIdx) {
  if (operandIdx >= getODSOperandIndexAndLength(2).first)
    return PortKind::PARAM;
  else if (operandIdx >= getODSOperandIndexAndLength(1).first)
    return PortKind::OUTPUT;
  else
    return PortKind::INPUT;
}

OpResult InstanceOp::getTiedOpResult(OpOperand &operand) {
  assert(getPortKind(operand) == PortKind::OUTPUT && "invalid operand");
  return (*this)->getOpResult(operand.getOperandNumber() - getNumInputs());
}

//===----------------------------------------------------------------------===//
// SemanticsOp
//===----------------------------------------------------------------------===//

/// Initialize the block arguments. We create a tensor for each input and
/// output. The tensor type is determined by the corresponding port type.
void SemanticsOp::initializeBlockArguments() {
  SmallVector<Type> argTypes;
  SmallVector<Location> argLocs;

  auto appendTypesAndLocs = [&](ValueRange values) {
    for (auto value : values) {
      auto port = value.getDefiningOp<PortOp>();
      assert(port && "invalid semantics input/output");
      auto tensorType = RankedTensorType::get(
          SmallVector<int64_t>(port.getSizes().size(), ShapedType::kDynamic),
          /*port.getType().getType()*/ Builder(*this).getF32Type(), nullptr);
      argTypes.push_back(tensorType);
      argLocs.push_back(port.getLoc());
    }
  };
  appendTypesAndLocs(getInputs());
  appendTypesAndLocs(getOutputs());

  if (getBody().empty())
    getBody().emplaceBlock();
  getBody().addArguments(argTypes, argLocs);
}

/// Get the immediate included linalg op. Will return nullptr if there is no
/// such linalg op or more than one linalg op.
linalg::LinalgOp SemanticsOp::getSemanticsLinalgOp() {
  auto linalgOps = getOps<linalg::LinalgOp>();
  if (llvm::hasSingleElement(linalgOps))
    return *linalgOps.begin();
  return nullptr;
}

DeclareOp SemanticsOp::getDeclareOp() {
  return cast<DeclareOp>((*this)->getParentOp());
}
SemanticsOutputOp SemanticsOp::getSemanticsOutputOp() {
  return cast<SemanticsOutputOp>(getBody().front().getTerminator());
}

//===----------------------------------------------------------------------===//
// SemanticsOutputOp
//===----------------------------------------------------------------------===//

SemanticsOp SemanticsOutputOp::getSemanticsOp() {
  return cast<SemanticsOp>((*this)->getParentOp());
}