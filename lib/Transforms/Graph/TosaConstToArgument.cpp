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
          }
        }
      }
    }

    for (auto addOp : func.getOps<tosa::AddOp>()) {
      auto loc = addOp.getLoc();

      tosa::TransposeOp transposeOp1 =
          dyn_cast<tosa::TransposeOp>(addOp.input1().getDefiningOp());
      tosa::TransposeOp transposeOp2 =
          dyn_cast<tosa::TransposeOp>(addOp.input2().getDefiningOp());
      tosa::ClampOp clampOp2 =
          dyn_cast<tosa::ClampOp>(addOp.input2().getDefiningOp());
      if (transposeOp1 && transposeOp2) {
        for (auto addUser : addOp.output().getUsers()) {
          if (auto clampOp = dyn_cast<tosa::ClampOp>(addUser)) {
            for (auto clampUser : clampOp.output().getUsers()) {
              if (auto transposeOpLast =
                      dyn_cast<tosa::TransposeOp>(clampUser)) {
                builder.setInsertionPointAfter(addOp);
                auto newAddOp = builder.create<tosa::AddOp>(
                    loc, transposeOp1.input1().getType(), transposeOp1.input1(),
                    transposeOp2.input1());
                auto newClampOp = builder.create<tosa::ClampOp>(
                    loc, transposeOp1.input1().getType(), newAddOp.output(),
                    clampOp.min_int(), clampOp.max_int(), clampOp.min_fp(),
                    clampOp.max_fp());

                for (auto user : transposeOp1.output().getUsers()) {
                  if (auto transposeOp = dyn_cast<tosa::TransposeOp>(user)) {
                    transposeOp.output().replaceAllUsesWith(
                        transposeOp1.input1());
                    opToErase.push_back(transposeOp);
                  }
                }
                for (auto user : transposeOp2.output().getUsers()) {
                  if (auto transposeOp = dyn_cast<tosa::TransposeOp>(user)) {
                    transposeOp.output().replaceAllUsesWith(
                        transposeOp2.input1());
                    opToErase.push_back(transposeOp);
                  }
                }

                clampOp.output().replaceAllUsesWith(newClampOp.output());
                transposeOpLast.output().replaceAllUsesWith(
                    newClampOp.output());
                opToErase.push_back(transposeOpLast);
                opToErase.push_back(clampOp);
                opToErase.push_back(addOp);
                opToErase.push_back(transposeOp1);
                opToErase.push_back(transposeOp2);
              }
            }
          }
        }
      }

      else if (transposeOp1 && clampOp2) {
        for (auto addUser : addOp.output().getUsers()) {
          if (auto clampOp = dyn_cast<tosa::ClampOp>(addUser)) {
            for (auto clampUser : clampOp.output().getUsers()) {
              if (auto transposeOpLast =
                      dyn_cast<tosa::TransposeOp>(clampUser)) {
                builder.setInsertionPointAfter(addOp);
                auto newAddOp = builder.create<tosa::AddOp>(
                    loc, transposeOp1.input1().getType(), transposeOp1.input1(),
                    addOp.input2());
                auto newClampOp = builder.create<tosa::ClampOp>(
                    loc, transposeOp1.input1().getType(), newAddOp.output(),
                    clampOp.min_int(), clampOp.max_int(), clampOp.min_fp(),
                    clampOp.max_fp());

                clampOp.output().replaceAllUsesWith(newClampOp.output());
                transposeOpLast.output().replaceAllUsesWith(
                    newClampOp.output());
                opToErase.push_back(transposeOpLast);
                opToErase.push_back(clampOp);
                opToErase.push_back(addOp);
                opToErase.push_back(transposeOp1);
              }
            }
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
      if (!constOp.use_empty()) {
        auto constType =
            constOp.output().getType().dyn_cast<RankedTensorType>();
        auto constArg = func.front().addArgument(constType, loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        constOp.output().replaceAllUsesWith(constArg);
      }
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
