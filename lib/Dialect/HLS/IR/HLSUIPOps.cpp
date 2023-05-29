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
  if (!getDeclareOp())
    return (*this)->emitOpError("unknown IP name ") << getNameAttr();
  return success();
}

/// Get the type of operand: input, output, or param.
PortKind InstanceOp::getPortKind(OpOperand &operand) {
  assert(operand.getOwner() == *this && "invalid operand");
  return getPortKind(operand.getOperandNumber());
}
PortKind InstanceOp::getPortKind(unsigned operandIdx) {
  auto semantics = getDeclareOp().getSemanticsOp();
  return semantics.getPorts()[operandIdx].getDefiningOp<PortOp>().getKind();
}

/// Get the tied op result of an output operand. Assert if the given operand is
/// not an output.
OpResult InstanceOp::getTiedOpResult(OpOperand &operand) {
  assert(getPortKind(operand) == PortKind::OUTPUT && "invalid operand");
  unsigned resultIdx = 0;
  for (unsigned i = 0; i < operand.getOperandNumber(); ++i)
    if (getPortKind(i) == PortKind::OUTPUT)
      ++resultIdx;
  return (*this)->getOpResult(resultIdx);
}

DeclareOp InstanceOp::getDeclareOp() {
  return SymbolTable::lookupNearestSymbolFrom<DeclareOp>(
      (*this)->getParentOfType<ModuleOp>(), getNameAttr());
}

//===----------------------------------------------------------------------===//
// SemanticsOp
//===----------------------------------------------------------------------===//

/// Initialize the block arguments. We create a tensor for each input and
/// output. The tensor type is determined by the corresponding port type.
void SemanticsOp::initializeBlockArguments(
    const SmallVectorImpl<Value> &ports) {
  Builder builder(getContext());
  SmallVector<Type> argTypes;
  SmallVector<Location> argLocs;
  SmallVector<int64_t> argMap;

  for (auto value : ports) {
    // Find the operand number of the given value to construct the argMap.
    auto opOperand = llvm::find_if((*this)->getOpOperands(),
                                   [&](auto &op) { return op.get() == value; });
    assert(opOperand != (*this)->getOpOperands().end() && "invalid port");
    argMap.push_back(opOperand->getOperandNumber());

    // Get the port type and location.
    // TODO: How to handle the element type of the tensor?
    // TODO: Handle constant sized port.
    auto port = value.getDefiningOp<PortOp>();
    assert(port && port.getKind() != PortKind::PARAM && "invalid port");
    auto tensorType = RankedTensorType::get(
        SmallVector<int64_t>(port.getSizes().size(), ShapedType::kDynamic),
        /*port.getType().getType()*/ builder.getF32Type(), nullptr);
    argTypes.push_back(tensorType);
    argLocs.push_back(port.getLoc());
  }

  if (getBody().empty())
    getBody().emplaceBlock();
  getBody().addArguments(argTypes, argLocs);
  setArgsMapAttr(builder.getIndexArrayAttr(argMap));
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