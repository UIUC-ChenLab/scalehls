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
// InstanceOp
//===----------------------------------------------------------------------===//

LogicalResult InstanceOp::verifySymbolUses(mlir::SymbolTableCollection &table) {
  auto param = table.lookupNearestSymbolFrom<DeclareOp>(
      (*this)->getParentOfType<ModuleOp>(), getIpAttr());
  if (!param)
    return (*this)->emitOpError("unknown IP name ") << getIpAttr();
  return success(param);
}

//===----------------------------------------------------------------------===//
// SemanticsOp
//===----------------------------------------------------------------------===//

/// Initialize the block arguments. We create a tensor for each input and
/// output. The tensor type is determined by the corresponding port type.
void SemanticsOp::initializeBlockArguments() {
  SmallVector<Type> argTypes;
  SmallVector<Location> argLocs;

  auto appendTypeAndLoc = [&](Value value) {
    auto port = value.getDefiningOp<PortOp>();
    assert(port && "invalid semantics input/output");
    auto tensorType = RankedTensorType::get(
        SmallVector<int64_t>(port.getIndices().size(), ShapedType::kDynamic),
        /*port.getType().getType()*/ Builder(*this).getF32Type(), nullptr);
    argTypes.push_back(tensorType);
    argLocs.push_back(port.getLoc());
  };

  for (auto input : getInputs())
    appendTypeAndLoc(input);
  for (auto output : getOutputs())
    appendTypeAndLoc(output);

  if (getBody().empty())
    getBody().emplaceBlock();
  getBody().addArguments(argTypes, argLocs);
}
