//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "scalehls/Transforms/Passes.h"
#include <iostream>

using namespace mlir;
using namespace scalehls;

namespace {
struct PreserveUnoptimized : public PreserveUnoptimizedBase<PreserveUnoptimized> {
  void runOnOperation() override {
    auto module = getOperation();
    auto builder = OpBuilder(module);

    SmallVector<FuncOp, 16> clones;
    for (auto func : module.getOps<FuncOp>()) {
      auto clone = func.clone();
      auto cloneFunctionName = "__UNOPTIMIZED__" + func.sym_name().str();
      clone->setAttr("sym_name", builder.getStringAttr(cloneFunctionName));
      clone->setAttr("bypass", builder.getBoolAttr(true));
      clones.push_back(clone);
    }

    auto &lastOp = *--module.end();
    builder.setInsertionPointAfter(&lastOp);

    for (auto clone : clones) {
      builder.insert(clone);
      builder.setInsertionPointAfter(clone);
    }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createPreserveUnoptimizedPass() {
  return std::make_unique<PreserveUnoptimized>();
}
