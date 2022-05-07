//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Pass/PassManager.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static bool applyTosaConstToArgument(ModuleOp module) {
  auto builder = OpBuilder(module);

  // Simplify redundant transposes
  for (auto func : module.getOps<FuncOp>()) {
    PassManager pm(func.getContext(), "func.func");
    pm.addPass(createTosaSimplifyGraphPass());
    if (failed(pm.run(func)))
      return false;
  }

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Remove remaining transposes
  for (auto func : module.getOps<FuncOp>()) {
    for (auto transposeOp : func.getOps<tosa::TransposeOp>()) {
      auto loc = transposeOp.getLoc();

      if (!transposeOp.input1().getDefiningOp()) {
        auto idx = 0;
        Value transposeArg;
        for (auto arg : func.front().getArguments()) {
          if (arg == transposeOp.input1()) {
            transposeArg =
                func.front().addArgument(transposeOp.output().getType(), loc);
            transposeOp.input1().replaceAllUsesWith(transposeArg);
            func.front().eraseArgument(idx);
            break;
          }
          idx++;
        }

        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        transposeOp.output().replaceAllUsesWith(transposeArg);
        opToErase.push_back(transposeOp);
        opToErase.push_back(transposeOp.perms().getDefiningOp());
      } else {
        for (auto user : transposeOp.output().getUsers()) {
          if (auto reshapeOp = dyn_cast<tosa::ReshapeOp>(user)) {
            builder.setInsertionPointAfter(transposeOp);
            auto newReshapeOp = builder.create<tosa::ReshapeOp>(
                loc, reshapeOp.output().getType(), transposeOp.input1(),
                reshapeOp.new_shape());

            reshapeOp.output().replaceAllUsesWith(newReshapeOp.output());
            opToErase.push_back(reshapeOp);
            opToErase.push_back(transposeOp);
            opToErase.push_back(transposeOp.perms().getDefiningOp());
          }
        }
      }
    }
  }
  for (auto op : opToErase)
    op->erase();

  // Remove constants
  opToErase = SmallVector<Operation *, 32>();
  for (auto func : module.getOps<FuncOp>()) {
    for (auto constOp : func.getOps<tosa::ConstOp>()) {
      auto loc = constOp.getLoc();

      // Create a new function argument
      auto constType = constOp.output().getType().dyn_cast<RankedTensorType>();
      auto constArg = func.front().addArgument(constType, loc);
      func.setType(builder.getFunctionType(
          func.front().getArgumentTypes(),
          func.back().getTerminator()->getOperandTypes()));

      constOp.output().replaceAllUsesWith(constArg);
      opToErase.push_back(constOp);
    }
  }
  for (auto op : opToErase)
    op->erase();

  // Order function arguments
  for (auto func : module.getOps<FuncOp>()) {
    auto numArguments = func.getNumArguments();

    func.walk([&](Operation *op) {
      for (auto operand : op->getOperands()) {
        if (!operand.getDefiningOp()) {
          auto newArgument =
              func.front().addArgument(operand.getType(), func.getLoc());
          operand.replaceAllUsesWith(newArgument);
        }
      }
    });

    for (unsigned idx = 0; idx < numArguments; idx++) {
      func.front().eraseArgument(0);
    }

    func.setType(builder.getFunctionType(
        func.front().getArgumentTypes(),
        func.back().getTerminator()->getOperandTypes()));
  }

  return true;
}

namespace {
struct TosaConstToArgument
    : public TosaConstToArgumentBase<TosaConstToArgument> {
  void runOnOperation() override {
    auto module = getOperation();
    applyTosaConstToArgument(module);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createTosaConstToArgumentPass() {
  return std::make_unique<TosaConstToArgument>();
}
