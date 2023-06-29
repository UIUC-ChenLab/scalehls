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
  return semantics.getPortKind(operandIdx);
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
    if (port.getDims().empty())
      argTypes.push_back(/*port.getType().getType()*/ builder.getF32Type());
    else
      argTypes.push_back(RankedTensorType::get(
          SmallVector<int64_t>(port.getDims().size(), ShapedType::kDynamic),
          /*port.getType().getType()*/ builder.getF32Type(), nullptr));
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

unsigned SemanticsOp::mapArgIndexToOperandIndex(unsigned argIndex) {
  return getArgsMap()[argIndex].cast<IntegerAttr>().getInt();
}
std::optional<unsigned>
SemanticsOp::mapOperandIndexToArgIndex(unsigned operandIndex) {
  auto argMap = getArgsMap();
  auto it = llvm::find_if(argMap, [&](auto attr) {
    return attr.template cast<IntegerAttr>().getInt() == operandIndex;
  });
  if (it == argMap.end())
    return std::nullopt;
  return std::distance(argMap.begin(), it);
}

/// Get the type of operand: input, output, or param.
PortKind SemanticsOp::getPortKind(OpOperand &operand) {
  assert(operand.getOwner() == *this && "invalid operand");
  return getPortKind(operand.getOperandNumber());
}
PortKind SemanticsOp::getPortKind(unsigned operandIdx) {
  return getPorts()[operandIdx].getDefiningOp<PortOp>().getKind();
}

DeclareOp SemanticsOp::getDeclareOp() {
  return cast<DeclareOp>((*this)->getParentOp());
}
SemanticsOutputOp SemanticsOp::getSemanticsOutputOp() {
  return cast<SemanticsOutputOp>(getBody().front().getTerminator());
}

/// The template of an IP could be recursively a struct type. This method
/// can recursively peel off all the structs and return the real templates,
/// which are gauranteed to be ParamOp.
SmallVector<Value> SemanticsOp::getStructPeeledTemplates() {
  SmallVector<Value> temps;
  SmallVector<StructOp> worklist;
  for (auto temp : getTemplates()) {
    if (auto structOp = temp.getDefiningOp<StructOp>())
      worklist.push_back(structOp);
    else
      temps.push_back(temp);
  }

  while (!worklist.empty()) {
    auto structOp = worklist.pop_back_val();
    for (auto temp : structOp.getParams()) {
      if (auto structOp = temp.getDefiningOp<StructOp>())
        worklist.push_back(structOp);
      else
        temps.push_back(temp);
    }
  }
  return temps;
}

//===----------------------------------------------------------------------===//
// SemanticsOutputOp
//===----------------------------------------------------------------------===//

SemanticsOp SemanticsOutputOp::getSemanticsOp() {
  return cast<SemanticsOp>((*this)->getParentOp());
}