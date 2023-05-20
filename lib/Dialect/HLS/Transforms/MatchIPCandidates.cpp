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
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "scalehls-match-ip-canidates"

using namespace mlir;
using namespace scalehls;
using namespace hls;

/// A map holding the possible equivalences between a value in a dataflow and a
/// set of values in another dataflow.
using MaybeEquivalenceMap =
    llvm::SmallDenseMap<Value, llvm::SmallDenseSet<Value>>;

/// Recursively check the equivalence between two values. Note we don't consider
/// associativity in the current implementation.
static bool checkEquivalence(Value a, Value b, MaybeEquivalenceMap &map) {
  // If a and b are both block argument, they may be equivalent. If only one of
  // a and b is block argument, they cannot be equivalent.
  if (a.isa<BlockArgument>() && b.isa<BlockArgument>())
    return map[a].insert(b), true;
  else if ((a.isa<BlockArgument>() && !b.isa<BlockArgument>()) ||
           (!a.isa<BlockArgument>() && b.isa<BlockArgument>()))
    return false;

  // Otherwise, both a and b must have defining operations.
  auto opA = a.getDefiningOp();
  auto opB = b.getDefiningOp();

  // If a and b are both constant and have the same value, they are equivalent.
  // If only one of a and b is constant, they cannot be equivalent.
  if (isa<arith::ConstantOp>(opA) && isa<arith::ConstantOp>(opB)) {
    auto constA = cast<arith::ConstantOp>(opA).getValue();
    auto constB = cast<arith::ConstantOp>(opB).getValue();
    if (constA == constB)
      return map[a].insert(b), true;
    return false;
  } else if ((isa<arith::ConstantOp>(opA) && !isa<arith::ConstantOp>(opB)) ||
             (!isa<arith::ConstantOp>(opA) && isa<arith::ConstantOp>(opB)))
    return false;

  // If the defining operation of a and b has the same name and same predicate
  // (for comparison operations), we recursively check the equivalence of their
  // operands. Otherwise, they cannot be equivalent.
  if (opA->getName() == opB->getName()) {
    // TODO: Consider the reversed semantics of comparison operations.
    if (isa<arith::CmpIOp>(opA))
      if (cast<arith::CmpIOp>(opA).getPredicate() !=
          cast<arith::CmpIOp>(opB).getPredicate())
        return false;
    if (isa<arith::CmpFOp>(opA))
      if (cast<arith::CmpFOp>(opA).getPredicate() !=
          cast<arith::CmpFOp>(opB).getPredicate())
        return false;

    // We have checked the equivalence of the semantics of the defining ops of a
    // and b. Now we can recursively check the equivalence of their operands.
    if (opA->getNumOperands() == 1) {
      if (checkEquivalence(opA->getOperand(0), opB->getOperand(0), map))
        return map[a].insert(b), true;
      return false;
    } else if (opA->getNumOperands() == 2) {
      if (checkEquivalence(opA->getOperand(0), opB->getOperand(0), map) &&
          checkEquivalence(opA->getOperand(1), opB->getOperand(1), map))
        return map[a].insert(b), true;

      // Here, we take communitivity into consideration.
      if (opA->hasTrait<OpTrait::IsCommutative>() &&
          checkEquivalence(opA->getOperand(0), opB->getOperand(1), map) &&
          checkEquivalence(opA->getOperand(1), opB->getOperand(0), map))
        return map[a].insert(b), true;
      return false;
    }

    // The only operation with no operand and we can handle is constant op.
    return llvm::llvm_unreachable_internal("unknown op type"), false;
  }
  return false;
}

/// Match the input output numbers of two linalg ops.
static LogicalResult matchLinalgNumPorts(linalg::LinalgOp a,
                                         linalg::LinalgOp b) {
  if (a.getNumDpsInputs() != b.getNumDpsInputs() ||
      a.getNumDpsInits() != b.getNumDpsInits() ||
      a->getNumResults() != b->getNumResults())
    return failure();
  return success();
}

/// Match the payloads of two linalg ops and record matched values in the map.
static LogicalResult matchLinalgPayloads(linalg::LinalgOp a,
                                         linalg::LinalgOp b) {
  assert(succeeded(matchLinalgNumPorts(a, b)) &&
         "invalid input or output port number");

  MaybeEquivalenceMap valueMap;
  for (auto resultA : a.getBlock()->getTerminator()->getOperands()) {
    unsigned numMatched = 0;
    for (auto resultB : b.getBlock()->getTerminator()->getOperands())
      numMatched += checkEquivalence(resultA, resultB, valueMap);
    if (!numMatched)
      return failure();
  }
  return success();
}

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

    // Match IPs. Note that we assume the linalg op is in canonicalized format
    // to avoid unnecessary complexity in matching.
    for (auto declare : ipDeclares) {
      auto ipLinalgOp = declare.getSemanticsOp().getSemanticsLinalgOp();

      LLVM_DEBUG(llvm::dbgs() << "\n----- match begin -----\n");
      LLVM_DEBUG(llvm::dbgs() << "ip semantics: " << ipLinalgOp << "\n");
      LLVM_DEBUG(llvm::dbgs() << "computation: " << linalgOp << "\n");

      // We first check if the number of input and output ports match.
      if (failed(matchLinalgNumPorts(ipLinalgOp, linalgOp))) {
        LLVM_DEBUG(llvm::dbgs() << "failed: number of ports mismatch\n");
        continue;
      }

      // We create a valueMap here to record possible equivalent value pairs.
      // This map will be pruned in the following steps until we find a match or
      // fail the process.

      // We then check if the payloads match.
      if (failed(matchLinalgPayloads(ipLinalgOp, linalgOp))) {
        LLVM_DEBUG(llvm::dbgs() << "failed: payload mismatch\n");
        continue;
      }

      LLVM_DEBUG(llvm::dbgs() << "----- match end -----\n");
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
