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
                                bool dataflow, bool flatten) {
  auto loopDirective = LoopDirectiveAttr::get(op->getContext(), pipeline,
                                              targetII, dataflow, flatten);
  setLoopDirective(op, loopDirective);
}

void scalehls::setParallelAttr(AffineForOp loop) {
  loop->setAttr("parallel", UnitAttr::get(loop.getContext()));
}

void scalehls::setPointAttr(AffineForOp loop) {
  loop->setAttr("point", UnitAttr::get(loop.getContext()));
}

/// Set func directives.
void scalehls::setFuncDirective(Operation *op,
                                FuncDirectiveAttr funcDirective) {
  op->setAttr("func_directive", funcDirective);
}

void scalehls::setFuncDirective(Operation *op, bool pipeline,
                                int64_t targetInterval, bool dataflow) {
  auto funcDirective = FuncDirectiveAttr::get(op->getContext(), pipeline,
                                              targetInterval, dataflow);
  setFuncDirective(op, funcDirective);
}

void scalehls::setTopFuncAttr(FuncOp func) {
  func->setAttr("top_func", UnitAttr::get(func.getContext()));
}

void scalehls::setRuntimeAttr(FuncOp func) {
  func->setAttr("runtime", UnitAttr::get(func.getContext()));
}

//===----------------------------------------------------------------------===//
// Loop transform utils
//===----------------------------------------------------------------------===//

static void addMemoryOptsPipeline(PassManager &pm) {
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

/// Apply memory optimizations.
bool scalehls::applyMemoryOpts(FuncOp func) {
  PassManager optPM(func.getContext(), "builtin.func");
  addMemoryOptsPipeline(optPM);
  if (failed(optPM.run(func)))
    return false;
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

  // Apply loop tiling.
  if (!applyLoopTiling(band, tileList))
    return false;

  // Apply loop pipelining.
  if (!applyLoopPipelining(band, band.size() - 1, targetII))
    return false;

  // Apply memory access optimizations and the best suitable array partition
  // strategy to the function.
  applyMemoryOpts(func);
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

  // Apply loop tiling to all loop bands.
  for (unsigned i = 0, e = bands.size(); i < e; ++i)
    if (!applyLoopTiling(bands[i], tileLists[i]))
      return false;

  for (unsigned i = 0, e = bands.size(); i < e; ++i)
    if (!applyLoopPipelining(bands[i], bands[i].size() - 1, targetIIs[i]))
      return false;

  // Apply memory access optimizations and the best suitable array partition
  // strategy to the function.
  applyMemoryOpts(func);
  applyAutoArrayPartition(func);
  return true;
}
