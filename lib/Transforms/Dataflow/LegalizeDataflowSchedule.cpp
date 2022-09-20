//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static NodeOp fuseNodeOps(ArrayRef<NodeOp> nodes, PatternRewriter &rewriter) {
  assert((nodes.size() > 1) && "must fuse at least two nodes");

  // Collect inputs, outputs, and params of the new node.
  llvm::SetVector<Value> inputs;
  llvm::SmallVector<unsigned, 8> inputTaps;
  llvm::SmallVector<Location, 8> inputLocs;
  llvm::SetVector<Value> outputs;
  llvm::SmallVector<Location, 8> outputLocs;
  llvm::SetVector<Value> params;
  llvm::SmallVector<Location, 8> paramLocs;

  for (auto node : nodes) {
    for (auto input : llvm::enumerate(node.getInputs()))
      if (inputs.insert(input.value())) {
        inputLocs.push_back(input.value().getLoc());
        inputTaps.push_back(node.getInputTap(input.index()));
      }
    for (auto output : node.getOutputs())
      if (outputs.insert(output))
        outputLocs.push_back(output.getLoc());
    for (auto param : node.getParams())
      if (params.insert(param))
        paramLocs.push_back(param.getLoc());
  }

  // Construct the new node after the last node.
  rewriter.setInsertionPointAfter(nodes.back());
  auto newNode = rewriter.create<NodeOp>(
      rewriter.getUnknownLoc(), inputs.getArrayRef(), outputs.getArrayRef(),
      params.getArrayRef(), inputTaps);
  auto block = rewriter.createBlock(&newNode.getBody());
  block->addArguments(ValueRange(inputs.getArrayRef()), inputLocs);
  block->addArguments(ValueRange(outputs.getArrayRef()), outputLocs);
  block->addArguments(ValueRange(params.getArrayRef()), paramLocs);

  // Inline all nodes into the new node.
  for (auto node : nodes) {
    auto &nodeOps = node.getBody().front().getOperations();
    auto &newNodeOps = newNode.getBody().front().getOperations();
    newNodeOps.splice(newNode.end(), nodeOps);
    for (auto t : llvm::zip(node.getBody().getArguments(), node.getOperands()))
      std::get<0>(t).replaceAllUsesWith(std::get<1>(t));
    rewriter.eraseOp(node);
  }

  for (auto t : llvm::zip(newNode.getOperands(), block->getArguments()))
    std::get<0>(t).replaceUsesWithIf(std::get<1>(t), [&](OpOperand &use) {
      return newNode->isProperAncestor(use.getOwner());
    });
  return newNode;
}

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
