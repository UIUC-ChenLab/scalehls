//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Dialect/SCF/Transforms/Transforms.h"
#include "mlir/Dialect/SCF/Utils/Utils.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct MatchIPCandidatesPattern : public OpRewritePattern<TaskOp> {
  MatchIPCandidatesPattern(MLIRContext *context, Block *spaceBlock,
                           StringRef spaceName,
                           const SmallVector<DeclareOp> &ipDeclares,
                           unsigned &taskIdx)
      : OpRewritePattern<TaskOp>(context), spaceBlock(spaceBlock),
        spaceName(spaceName), ipDeclares(ipDeclares), taskIdx(taskIdx) {}

  LogicalResult matchAndRewrite(TaskOp task,
                                PatternRewriter &rewriter) const override {
    auto linalgOp = task.getPayloadLinalgOp();
    if (!linalgOp)
      return failure();

    // TODO: We should introduce a more systematic way to generate unique symbol
    // names for parameters.
    auto paramPrefix = "task" + std::to_string(taskIdx++);
    auto loc = task.getLoc();

    // We always push the default setting as the first candidate in case no
    // existing IP can be matched.
    SmallVector<Attribute> ipCandidates;
    ipCandidates.push_back(
        IPIdentifierAttr::get(rewriter.getContext(), "", ""));

    // Match IPs.

    // Generate the IP identifier parameter from all candidates.
    rewriter.setInsertionPointToEnd(spaceBlock);
    auto ipIdentifierName = paramPrefix + "_ip";
    auto ipIdentifierParamOp = rewriter.create<ParamOp>(
        loc, IPIdentifierType::get(rewriter.getContext()),
        rewriter.getArrayAttr(ipCandidates), ParamKind::IP_IDENTIFIER,
        paramPrefix + "_ip");

    // Update the current task op with the generated IP identifier parameter.
    rewriter.setInsertionPoint(task);
    task.getIpIdentifierMutable().assign(rewriter.create<GetParamOp>(
        loc, ipIdentifierParamOp.getType(), spaceName.str(), ipIdentifierName));
    return success();
  }

private:
  Block *spaceBlock;
  StringRef spaceName;
  const SmallVector<DeclareOp> &ipDeclares;
  unsigned &taskIdx;
};
} // namespace

namespace {
struct MatchIPCandidates : public MatchIPCandidatesBase<MatchIPCandidates> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    // Get the design space for holding parameters.
    auto space = getOrCreateGlobalSpaceOp(module);
    if (!space)
      return module.emitOpError("cannot find or create space op"),
             signalPassFailure();

    // Collect available IPs.
    auto ipDeclares = getIPDeclares(module);

    // Collect all tasks to be matched.
    SmallVector<TaskOp, 32> tasks;
    module.walk([&](TaskOp op) { tasks.push_back(op); });

    // Tile each task in the module. Note we don't use the greedy pattern driver
    // here because the tiling will generated hierarchy, which we don't want to
    // recursively delve into.
    unsigned taskIdx = 0;
    mlir::RewritePatternSet patterns(context);
    patterns.add<MatchIPCandidatesPattern>(context, &space.getBody().front(),
                                           space.getName(), ipDeclares,
                                           taskIdx);
    FrozenRewritePatternSet frozenPatterns(std::move(patterns));
    for (auto task : tasks)
      if (failed(applyOpPatternsAndFold({task}, frozenPatterns)))
        return signalPassFailure();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createMatchIPCandidatesPass() {
  return std::make_unique<MatchIPCandidates>();
}
