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
#include "scalehls/Utils/Matchers.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
struct ParameterizeIPCandidatePattern : public OpRewritePattern<TaskOp> {
  ParameterizeIPCandidatePattern(MLIRContext *context, Block *spaceBlock,
                                 StringRef spaceName, unsigned &taskIdx,
                                 const SmallVector<DeclareOp> &ipDeclares)
      : OpRewritePattern<TaskOp>(context), spaceBlock(spaceBlock),
        spaceName(spaceName), taskIdx(taskIdx), ipDeclares(ipDeclares) {}

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

    // Match IPs. Note that we assume the linalg op is in canonicalized format
    // to avoid unnecessary complexity in matching.
    for (auto declare : ipDeclares) {
      auto libraryName = declare.getLibraryOp().getName();
      auto ipName = declare.getName();
      auto ipLinalgOp = declare.getSemanticsOp().getSemanticsLinalgOp();

      // If the number of inputs, outputs, or loops are different, we skip the
      // matching process.
      if (linalgOp.getNumDpsInputs() != ipLinalgOp.getNumDpsInputs() ||
          linalgOp.getNumDpsInits() != ipLinalgOp.getNumDpsInits() ||
          linalgOp.getNumLoops() != ipLinalgOp.getNumLoops())
        continue;

      // Otherwise, match the two linalg ops with LinalgMatcher.
      if (succeeded(LinalgMatcher(ipLinalgOp, linalgOp).match()))
        ipCandidates.push_back(
            IPIdentifierAttr::get(rewriter.getContext(), libraryName, ipName));
    }

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
  unsigned &taskIdx;
  const SmallVector<DeclareOp> &ipDeclares;
};
} // namespace

namespace {
struct ParameterizeIPCandidate
    : public ParameterizeIPCandidateBase<ParameterizeIPCandidate> {
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

    // Parameterize each dataflow task in the module. Note we don't use the
    // greedy pattern driver here because the tiling will generated hierarchy,
    // which we don't want to recursively delve into.
    unsigned taskIdx = 0;
    mlir::RewritePatternSet patterns(context);
    patterns.add<ParameterizeIPCandidatePattern>(
        context, &space.getBody().front(), space.getName(), taskIdx,
        ipDeclares);
    FrozenRewritePatternSet frozenPatterns(std::move(patterns));
    for (auto task : tasks)
      if (failed(applyOpPatternsAndFold({task}, frozenPatterns)))
        return signalPassFailure();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createParameterizeIPCandidatePass() {
  return std::make_unique<ParameterizeIPCandidate>();
}
