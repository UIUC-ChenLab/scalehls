//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Analysis/QoREstimation.h"
#include "scalehls/Transforms/Passes.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "scalehls"

using namespace mlir;
using namespace scalehls;

//===----------------------------------------------------------------------===//
// Helper methods
//===----------------------------------------------------------------------===//

static int64_t getInnerParallelism(AffineForOp forOp) {
  int64_t count = 0;
  for (auto loop : forOp.getOps<AffineForOp>()) {
    auto innerCount = getInnerParallelism(loop);
    if (auto trip = getConstantTripCount(loop))
      count += trip.getValue() * innerCount;
    else
      count += innerCount;
  }

  // If the current loop is innermost loop, count should be one.
  return std::max(count, (int64_t)1);
}

//===----------------------------------------------------------------------===//
// Optimizer Class Declaration
//===----------------------------------------------------------------------===//

class HLSCppOptimizer : public HLSCppAnalysisBase {
public:
  explicit HLSCppOptimizer(FuncOp func, LatencyMap &latencyMap, int64_t numDSP)
      : HLSCppAnalysisBase(OpBuilder(func)), func(func), latencyMap(latencyMap),
        numDSP(numDSP) {
    // TODO: only insert affine-related patterns.
    OwningRewritePatternList owningPatterns;
    for (auto *op : func.getContext()->getRegisteredOperations())
      op->getCanonicalizationPatterns(owningPatterns, func.getContext());
    patterns = std::move(owningPatterns);
  }

  using TileSizes = SmallVector<unsigned, 8>;

  void emitDebugInfo(FuncOp targetFunc, StringRef message);
  void applyLoopTilingStrategy(FuncOp targetFunc,
                               ArrayRef<TileSizes> tileSizesList);
  void updateTileSizesAtHead(TileSizes &tileSizes, const TileSizes &tripCounts,
                             unsigned &head);

  /// This is a temporary approach that does not scale.
  void applyMultipleLevelDSE();

  FuncOp func;
  LatencyMap &latencyMap;
  int64_t numDSP;
  FrozenRewritePatternList patterns;
};

//===----------------------------------------------------------------------===//
// Optimizer Class Definition
//===----------------------------------------------------------------------===//

void HLSCppOptimizer::emitDebugInfo(FuncOp targetFunc, StringRef message) {
  LLVM_DEBUG(auto latency = getIntAttrValue(targetFunc, "latency");
             auto dsp = getIntAttrValue(targetFunc, "dsp");

             llvm::dbgs() << message << "\n";
             llvm::dbgs() << "Current latency is " << Twine(latency)
                          << ", DSP utilization is " << Twine(dsp) << ".\n\n";);
}

void HLSCppOptimizer::applyLoopTilingStrategy(
    FuncOp targetFunc, ArrayRef<TileSizes> tileSizesList) {
  AffineLoopBands targetBands;
  getLoopBands(targetFunc.front(), targetBands);

  // Apply loop tiling.
  unsigned idx = 0;
  for (auto &band : targetBands)
    applyPartialAffineLoopTiling(band, builder, tileSizesList[idx++]);
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  // Apply loop pipelining.
  for (auto &band : targetBands)
    applyLoopPipelining(band[band.size() / 2 - 1], builder);
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  // Apply general optimizations and array partition.
  // applyMergeAffineIf(targetFunc);
  applyAffineStoreForward(targetFunc, builder);
  applySimplifyMemrefAccess(targetFunc);
  applyArrayPartition(targetFunc, builder);
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  // Estimate performance and resource utilization.
  LLVM_DEBUG(llvm::dbgs() << "Current tiling strategy:\n"; idx = 0;
             for (auto tileSizes
                  : tileSizesList) {
               llvm::dbgs() << "Loop band " << Twine(idx++) << ":";
               for (auto size : tileSizes) {
                 llvm::dbgs() << " " << Twine(size);
               }
               llvm::dbgs() << "\n";
             });
  HLSCppEstimator(targetFunc, latencyMap).estimateFunc();
  emitDebugInfo(targetFunc, "Apply loop tiling and pipelining, general "
                            "optimizations, and array partition.");
}

/// Update tile sizes by a factor of 2 at the head location.
void HLSCppOptimizer::updateTileSizesAtHead(TileSizes &tileSizes,
                                            const TileSizes &tripCounts,
                                            unsigned &head) {
  assert(tileSizes.size() == tripCounts.size() &&
         "unexpected input tile sizes");

  for (unsigned e = tileSizes.size(); head < e; ++head) {
    auto size = tileSizes[head];
    auto tripCount = tripCounts[head];

    // At this stage, size must be 1 or a number which is divisible
    // by tripCount. We need to find the update factor now.
    if (size < tripCount) {
      unsigned factor = 2;
      while (tripCount % (size * factor) != 0)
        factor++;

      size *= factor;
      tileSizes[head] = size;
      break;
    }
  }
}

/// This is a temporary approach that does not scale.
void HLSCppOptimizer::applyMultipleLevelDSE() {
  HLSCppEstimator(func, latencyMap).estimateFunc();
  if (getIntAttrValue(func, "dsp") > numDSP)
    return;
  emitDebugInfo(func, "Start multiple level design space exploration.");

  //===--------------------------------------------------------------------===//
  // STAGE 0: Function Pipelining
  //===--------------------------------------------------------------------===//

  // Try function pipelining.
  // auto pipelineFunc = func.clone();
  // applyFuncPipelining(pipelineFunc, builder);
  // HLSCppEstimator(pipelineFunc, latencyMap).estimateFunc();

  // if (getIntAttrValue(pipelineFunc, "dsp") <= numDSP) {
  //   applyFuncPipelining(func, builder);
  //   return;
  // }

  //===--------------------------------------------------------------------===//
  // STAGE 1: Simplify Loop Nests Structure
  //===--------------------------------------------------------------------===//

  // Simplify loop nests by pipelining. If we take the following loops as
  // example, where each nodes represents one sequential loop nests (LN). In the
  // simplification, we'll first try to pipeline LN1 and LN6. Suppose pipelining
  // LN6 meets the resource constaints while pipelining LN1 not, we'll pipeline
  // LN6 (fully unroll LN7 and LN8) and keep LN1 untouched. In the next step,
  // we'll look into LN1 and check whether LN2 can be pipelined. Suppose
  // pipelining LN2 meets the resource constraints, we'll pipeling LN2 (fully
  // unroll LN7 and LN8). Note that in this simplification, all LNs that don't
  // contain any LNs will not be pipelined, such as LN5. Their optimization will
  // be explored later. This procedure will recursively applied to inner LNs
  // until no eligible LN exists.
  //
  //     LN1      LN6
  //      |        |
  //     / \      / \
  //   LN2 LN5  LN7 LN8
  //    |
  //   / \
  // LN3 LN4
  //
  // After the simplification, the loop becomes the following one, where LN1 has
  // been proved untouchable as loop pipelining is the primary optimization that
  // consumes the least extra resources. Formally, in the simplified function,
  // all non-leaf LNs is untouchable (LN1) and only leaf LNs can be further
  // optimized (LN2, LN5, and LN6).
  //
  //     LN1      LN6
  //      |
  //     / \
  //   LN2 LN5
  //
  // TODO: there is a large design space in this simplification.

  auto funcForOps = func.getOps<AffineForOp>();
  auto targetLoops =
      SmallVector<AffineForOp, 8>(funcForOps.begin(), funcForOps.end());

  while (!targetLoops.empty()) {
    SmallVector<AffineForOp, 8> candidateLoops;
    llvm::SmallDenseMap<Operation *, int64_t, 8> parallelismMap;

    // Collect all candidate loops. Here, only loops whose innermost loop has
    // more than one inner loops will be considered as a candidate.
    for (auto target : targetLoops) {
      AffineLoopBand loopBand;
      auto innermostLoop = getLoopBandFromRoot(target, loopBand);

      // Calculate the overall introduced parallelism if the innermost loop of
      // the current loop band is pipelined.
      auto parallelism = getInnerParallelism(innermostLoop);

      // Collect all candidate loops into an ordered vector. The loop indicating
      // the largest parallelism will show in the front.
      if (parallelism > 1) {
        parallelismMap[innermostLoop] = parallelism;

        for (auto it = candidateLoops.begin(); it <= candidateLoops.end(); ++it)
          if (it == candidateLoops.end()) {
            candidateLoops.push_back(innermostLoop);
            break;
          } else if (parallelism < parallelismMap[*it]) {
            candidateLoops.insert(it, innermostLoop);
            break;
          }
      }
    }

    // Since all target loops have been handled, clear the targetLoops vector.
    targetLoops.clear();

    // Traverse all candidates to check whether applying loop pipelining has
    // violation with the resource constraints. If so, add all inner loops into
    // targetLoops. Otherwise, pipeline the candidate.
    for (auto &candidate : candidateLoops) {
      // Create a temporary function.
      setAttrValue(candidate, "opt_flag", true);
      auto tmpFunc = func.clone();

      // Find the candidate loop in the temporary function and apply loop
      // pipelining to it.
      tmpFunc.walk([&](AffineForOp loop) {
        if (getIntAttrValue(loop, "opt_flag")) {
          applyLoopPipelining(loop, builder);
          return;
        }
      });

      // Estimate the temporary function.
      HLSCppEstimator(tmpFunc, latencyMap).estimateFunc();

      // Pipeline the candidate loop or delve into child loops.
      if (getIntAttrValue(tmpFunc, "dsp") <= numDSP)
        applyLoopPipelining(candidate, builder);
      else {
        auto childForOps = candidate.getOps<AffineForOp>();
        targetLoops.append(childForOps.begin(), childForOps.end());
      }

      candidate.removeAttr("opt_flag");
    }
  }

  HLSCppEstimator(func, latencyMap).estimateFunc();
  if (getIntAttrValue(func, "dsp") > numDSP)
    return;
  emitDebugInfo(func, "1. Simplify loop nests structure.");

  //===--------------------------------------------------------------------===//
  // STAGE 2: Loop Bands Optimization
  //===--------------------------------------------------------------------===//

  // Optimize leaf loop nests. Different optimization conbinations will be
  // applied to each leaf LNs, and the best one which meets the resource
  // constrains will be picked as the final solution.
  // TODO: better handle variable bound kernels.
  AffineLoopBands targetBands;
  getLoopBands(func.front(), targetBands);

  // Loop perfection, remove variable bound, and loop order optimization are
  // always applied for the convenience of polyhedral optimizations.
  for (auto &band : targetBands) {
    applyAffineLoopPerfection(band.back(), builder);
    applyAffineLoopOrderOpt(band);
    // applyRemoveVariableBound(band.front(), builder);
  }

  // Estimate the current latency.
  HLSCppEstimator(func, latencyMap).estimateFunc();
  if (getIntAttrValue(func, "dsp") > numDSP)
    return;
  emitDebugInfo(func, "2. Apply loop perfection and loop order optimization.");

  //===--------------------------------------------------------------------===//
  // STAGE 3: Loop Bands Tiling and Finalization
  //===--------------------------------------------------------------------===//

  // Holding trip counts of all loops in each loop band.
  std::vector<TileSizes> tripCountsList;
  // Holding the current tiling sizes of each loop band.
  std::vector<TileSizes> tileSizesList;
  // Holding the current loop tiling location in each loop band.
  SmallVector<unsigned, 8> headLocList;

  // Initialize all design vectors.
  for (auto band : targetBands) {
    TileSizes tripCounts;
    TileSizes sizes;
    for (auto loop : band) {
      tripCounts.push_back(getIntAttrValue(loop, "trip_count"));
      sizes.push_back(1);
    }
    tripCountsList.push_back(tripCounts);
    tileSizesList.push_back(sizes);
    headLocList.push_back(0);
  }

  LLVM_DEBUG(llvm::dbgs() << "3. Search for the best tiling strategy.\n";);
  applyLoopTilingStrategy(func, tileSizesList);

  // TODO: more fined grained and comprehensive dse.
  unsigned minLatency = getIntAttrValue(func, "latency");
  unsigned targetNum = targetBands.size();
  while (true) {
    // If there're more than one loop bands in the function, we'll first try to
    // update the tiling size of ALL target loop bands with a factor of 2. This
    // is for reducing the DSE complexity.
    if (targetNum > 1) {
      std::vector<TileSizes> newTileSizesList = tileSizesList;
      SmallVector<unsigned, 8> newHeadLocList = headLocList;

      for (unsigned i = 0; i < targetNum; ++i)
        updateTileSizesAtHead(newTileSizesList[i], tripCountsList[i],
                              newHeadLocList[i]);

      auto tmpFunc = func.clone();
      applyLoopTilingStrategy(tmpFunc, newTileSizesList);

      // If the resource constaints are not met or the latency is not increased,
      // we try more fine grained strategy. Otherwise, we accept the new tile
      // strategy and head location, and enter the next iteration. We set a
      // threshold 0.95 here to avoid glitches.
      // TODO: fine tune the exit condition.
      auto latency = getIntAttrValue(tmpFunc, "latency");
      auto dsp = getIntAttrValue(tmpFunc, "dsp");

      if (dsp <= numDSP && latency < minLatency * 0.95) {
        tileSizesList = newTileSizesList;
        headLocList = newHeadLocList;
        minLatency = latency;
        continue;
      }
    }

    // Walk through all loop bands in the function and update tiling strategy
    // one by one.
    bool hasUpdated = false;
    for (unsigned i = 0; i < targetNum; ++i) {
      // TODO: This is not efficient. As our estimation can be conducted in a
      // more structural way, we should only focus on the current loop rather
      // than the whole function. But for now this makes sense because we are
      // only focusing on computation kernel level algorithms that typcially
      // only have handy loop bands.
      for (unsigned head = headLocList[i], e = tileSizesList[i].size();
           head < e; ++head) {
        // Only update the tiling strategy and head location of the current
        // loop band.
        std::vector<TileSizes> newTileSizesList = tileSizesList;
        updateTileSizesAtHead(newTileSizesList[i], tripCountsList[i], head);

        auto tmpFunc = func.clone();
        applyLoopTilingStrategy(tmpFunc, newTileSizesList);

        auto latency = getIntAttrValue(tmpFunc, "latency");
        auto dsp = getIntAttrValue(tmpFunc, "dsp");

        if (dsp <= numDSP && latency < minLatency * 0.95) {
          tileSizesList = newTileSizesList;
          headLocList[i] = head;
          minLatency = latency;

          hasUpdated = true;
          break;
        }
      }
    }

    // If no loop band is updated, break the searching.
    if (!hasUpdated)
      break;
  }

  // Finally, we found the best tiling strategy.
  LLVM_DEBUG(llvm::dbgs() << "4. Apply the best tiling strategy.\n";);
  applyLoopTilingStrategy(func, tileSizesList);
}

namespace {
struct MultipleLevelDSE : public MultipleLevelDSEBase<MultipleLevelDSE> {
  void runOnOperation() override {
    auto module = getOperation();

    // Read configuration file.
    INIReader spec(targetSpec);
    if (spec.ParseError())
      emitError(module.getLoc(), "target spec file parse fail\n");

    // Collect profiling data, where default values are based on PYNQ-Z1 board.
    LatencyMap latencyMap;
    getLatencyMap(spec, latencyMap);
    auto numDSP = spec.GetInteger("specification", "dsp", 220);

    // Optimize the top function.
    for (auto func : module.getOps<FuncOp>())
      if (auto topFunction = func->getAttrOfType<BoolAttr>("top_function"))
        if (topFunction.getValue())
          HLSCppOptimizer(func, latencyMap, numDSP).applyMultipleLevelDSE();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createMultipleLevelDSEPass() {
  return std::make_unique<MultipleLevelDSE>();
}
