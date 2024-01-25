//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
// TODO: For now, we also dispatch most tensor ops into separate tasks. We
// should come up with a better way to handle them.
struct DispatchFuncOp : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    auto dispatch = dispatchBlock(&func.front(), rewriter);
    if (!dispatch)
      return failure();

    unsigned taskId = 0;
    for (auto &op : llvm::make_early_inc_range(dispatch.getOps())) {
      if (auto linalgOp = dyn_cast<linalg::LinalgOp>(op)) {
        if (linalgOp.hasDynamicShape())
          return linalgOp.emitOpError("cannot handle dynamic shape yet");
        auto task = fuseOpsIntoTask({linalgOp}, rewriter);

        std::string taskName =
            func.getName().str() + "_" + std::to_string(taskId++);
        linalgOp.getOperation()->setAttr(taskName, rewriter.getUnitAttr());
        task->setAttr(taskName, rewriter.getUnitAttr());

      } else if (isa<tensor::TensorDialect>(op.getDialect())) {
        auto task = fuseOpsIntoTask({&op}, rewriter);

        std::string taskName =
            func.getName().str() + "_" + std::to_string(taskId++);
        op.setAttr(taskName, rewriter.getUnitAttr());
        task->setAttr(taskName, rewriter.getUnitAttr());
      }
    }
    return success();
  }
};
} // namespace

namespace {
struct CreateDataflow : public CreateDataflowBase<CreateDataflow> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    // Dispatch the current function to create the dataflow hierarchy.
    mlir::RewritePatternSet patterns(context);
    patterns.add<DispatchFuncOp>(context);
    (void)applyOpPatternsAndFold({func}, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createCreateDataflowPass() {
  return std::make_unique<CreateDataflow>();
}
