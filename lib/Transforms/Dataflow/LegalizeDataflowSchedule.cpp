//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct FuseSameLevelNodes : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    llvm::SmallDenseMap<unsigned, SmallVector<NodeOp, 4>> worklist;
    for (auto node : schedule.getOps<NodeOp>()) {
      if (auto level = node.getLevel())
        worklist[level.value()].push_back(node);
      else
        return failure();
    }

    bool hasChanged = false;
    for (const auto &p : worklist)
      if (p.second.size() > 1) {
        auto node = fuseNodeOps(p.second, rewriter);
        node.setLevelAttr(rewriter.getI32IntegerAttr(p.first));
        hasChanged = true;
      }
    schedule.setIsLegalAttr(rewriter.getUnitAttr());
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct LegalizeDataflowSchedule
    : public LegalizeDataflowScheduleBase<LegalizeDataflowSchedule> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<FuseSameLevelNodes>(context);
    auto frozenPatterns = FrozenRewritePatternSet(std::move(patterns));
    func.walk([&](ScheduleOp schedule) {
      (void)applyOpPatternsAndFold(schedule, frozenPatterns);
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLegalizeDataflowSchedulePass() {
  return std::make_unique<LegalizeDataflowSchedule>();
}
