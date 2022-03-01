//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Utils.h"
#include "mlir/Dialect/Affine/LoopUtils.h"
#include "mlir/Dialect/Affine/Passes.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Transforms/Passes.h"
#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// Directive transform utils
//===----------------------------------------------------------------------===//

/// Set timing attribute.
void scalehls::setTiming(Operation *op, TimingAttr timing) {
  assert(timing.getBegin() <= timing.getEnd() && "invalid timing attribute");
  op->setAttr("timing", timing);
}

void scalehls::setTiming(Operation *op, int64_t begin, int64_t end,
                         int64_t latency, int64_t minII) {
  auto timing = TimingAttr::get(op->getContext(), begin, end, latency, minII);
  setTiming(op, timing);
}

/// Set resource attribute.
void scalehls::setResource(Operation *op, ResourceAttr resource) {
  op->setAttr("resource", resource);
}

void scalehls::setResource(Operation *op, int64_t lut, int64_t dsp,
                           int64_t bram) {
  auto resource = ResourceAttr::get(op->getContext(), lut, dsp, bram);
  setResource(op, resource);
}

/// Set loop information attribute.
void scalehls::setLoopInfo(Operation *op, LoopInfoAttr loopInfo) {
  op->setAttr("loop_info", loopInfo);
}

void scalehls::setLoopInfo(Operation *op, int64_t flattenTripCount,
                           int64_t iterLatency, int64_t minII) {
  auto loopInfo =
      LoopInfoAttr::get(op->getContext(), flattenTripCount, iterLatency, minII);
  setLoopInfo(op, loopInfo);
}

/// Set loop directives.
void scalehls::setLoopDirective(Operation *op,
                                LoopDirectiveAttr loopDirective) {
  op->setAttr("loop_directive", loopDirective);
}

void scalehls::setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                                bool dataflow, bool flatten, bool parallel) {
  auto loopDirective = LoopDirectiveAttr::get(
      op->getContext(), pipeline, targetII, dataflow, flatten, parallel);
  setLoopDirective(op, loopDirective);
}

/// Set func directives.
void scalehls::setFuncDirective(Operation *op,
                                FuncDirectiveAttr funcDirective) {
  op->setAttr("func_directive", funcDirective);
}

void scalehls::setFuncDirective(Operation *op, bool pipeline,
                                int64_t targetInterval, bool dataflow,
                                bool topFunc) {
  auto funcDirective = FuncDirectiveAttr::get(
      op->getContext(), pipeline, targetInterval, dataflow, topFunc);
  setFuncDirective(op, funcDirective);
}

//===----------------------------------------------------------------------===//
// Loop transform utils
//===----------------------------------------------------------------------===//

static void addSimplificationPipeline(PassManager &pm) {
  // To factor out the redundant affine operations.
  pm.addPass(createAffineLoopNormalizePass());
  pm.addPass(createSimplifyAffineStructuresPass());
  pm.addPass(createCanonicalizerPass());
  pm.addPass(createSimplifyAffineIfPass());

  // To simplify the memory accessing. Note that the store forwarding is
  // non-trivial and has a worst case complexity of O(n^2).
  pm.addPass(createAffineStoreForwardPass());
  pm.addPass(createSimplifyMemrefAccessPass());

  // Generic common sub expression elimination.
  pm.addPass(createCSEPass());
  pm.addPass(createReduceInitialIntervalPass());
}

/// Apply simplification optimizations.
bool scalehls::applySimplificationOpts(FuncOp func) {
  // Apply general optimizations.
  PassManager optPM(func.getContext(), "builtin.func");
  addSimplificationPipeline(optPM);
  if (failed(optPM.run(func)))
    return false;
  return true;
}

/// Fully unroll all loops insides of a block.
bool scalehls::applyFullyLoopUnrolling(Block &block, unsigned maxIterNum) {
  for (unsigned i = 0; i < maxIterNum; ++i) {
    bool hasFullyUnrolled = true;
    block.walk([&](AffineForOp loop) {
      if (failed(loopUnrollFull(loop)))
        hasFullyUnrolled = false;
    });

    if (hasFullyUnrolled)
      break;

    if (i == 7)
      return false;
  }
  return true;
}

/// Apply optimization strategy to a loop band. The ancestor function is also
/// passed in because the post-tiling optimizations have to take function as
/// target, e.g. canonicalizer and array partition.
bool scalehls::applyOptStrategy(AffineLoopBand &band, FuncOp func,
                                TileList tileList, unsigned targetII) {
  // By design the input function must be the ancestor of the input loop band.
  if (!func->isProperAncestor(band.front()))
    return false;

  // Apply LegalizeToHLSCpp conversion.
  applyLegalizeToHLSCpp(func, /*isTopFunc=*/true);

  // Apply loop tiling.
  if (!applyLoopTiling(band, tileList, /*tileOrderOpt=*/false,
                       /*unrollPointLoops=*/true))
    return false;

  // Apply loop pipelining.
  if (!applyLoopPipelining(band, band.size() - 1, targetII))
    return false;

  // Apply memory access optimizations and the best suitable array partition
  // strategy to the function.
  applySimplificationOpts(func);
  applyAutoArrayPartition(func);
  return true;
}

/// Apply optimization strategy to a function.
bool scalehls::applyOptStrategy(FuncOp func, ArrayRef<TileList> tileLists,
                                ArrayRef<unsigned> targetIIs) {
  AffineLoopBands bands;
  getLoopBands(func.front(), bands);
  assert(bands.size() == tileLists.size() && bands.size() == targetIIs.size() &&
         "unexpected size of tile lists or target IIs");

  // Apply LegalizeToHLSCpp conversion.
  applyLegalizeToHLSCpp(func, /*isTopFunc=*/true);

  // Apply loop tiling to all loop bands.
  for (unsigned i = 0, e = bands.size(); i < e; ++i)
    if (!applyLoopTiling(bands[i], tileLists[i]))
      return false;

  for (unsigned i = 0, e = bands.size(); i < e; ++i)
    if (!applyLoopPipelining(bands[i], bands[i].size() - 1, targetIIs[i]))
      return false;

  // Apply memory access optimizations and the best suitable array partition
  // strategy to the function.
  applySimplificationOpts(func);
  applyAutoArrayPartition(func);
  return true;
}
