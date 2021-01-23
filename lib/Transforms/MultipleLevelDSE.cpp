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

/// Clean up all attributes annotated for scheduling in the function for the
/// convenience of other transforms.
// static void cleanScheduleAttributes(FuncOp func) {
//   func.walk([&](Operation *op) {
//     op->removeAttr("schedule_begin");
//     op->removeAttr("schedule_end");
//     op->removeAttr("partition_index");
//   });
// }

//===----------------------------------------------------------------------===//
// Optimizer Class Declaration
//===----------------------------------------------------------------------===//

class HLSCppOptimizer : public HLSCppAnalysisBase {
public:
  explicit HLSCppOptimizer(FuncOp &func, LatencyMap &latencyMap, int64_t numDSP)
      : HLSCppAnalysisBase(OpBuilder(func)), func(func), latencyMap(latencyMap),
        numDSP(numDSP) {
    // TODO: only insert affine-related patterns.
    OwningRewritePatternList owningPatterns;
    for (auto *op : func.getContext()->getRegisteredOperations())
      op->getCanonicalizationPatterns(owningPatterns, func.getContext());
    patterns = std::move(owningPatterns);
  }

  using TileSizes = SmallVector<unsigned, 8>;

  void emitDebugInfo(FuncOp &targetFunc, StringRef message);
  void applyLoopTilingStrategy(FuncOp &targetFunc,
                               ArrayRef<TileSizes> tileSizesList);

  /// This is a temporary approach that does not scale.
  void applyMultipleLevelDSE();

  FuncOp &func;
  LatencyMap &latencyMap;
  int64_t numDSP;
  FrozenRewritePatternList patterns;
};

//===----------------------------------------------------------------------===//
// Optimizer Class Definition
//===----------------------------------------------------------------------===//

void HLSCppOptimizer::emitDebugInfo(FuncOp &targetFunc, StringRef message) {
  LLVM_DEBUG(auto latency = getIntAttrValue(targetFunc, "latency");
             auto dsp = getIntAttrValue(targetFunc, "dsp");

             llvm::dbgs() << message << "\n";
             llvm::dbgs() << "Current latency is " << Twine(latency)
                          << ", DSP utilization is " << Twine(dsp) << ".\n\n";);
}

void HLSCppOptimizer::applyLoopTilingStrategy(
    FuncOp &targetFunc, ArrayRef<TileSizes> tileSizesList) {
  AffineLoopBands targetBands;
  getLoopBands(targetFunc.front(), targetBands);

  // Apply loop tiling.
  unsigned idx = 0;
  for (auto &band : targetBands)
    applyPartialAffineLoopTiling(band, builder, tileSizesList[idx++]);
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  // Apply loop pipelining.
  for (auto band : targetBands) {
    auto pipelineLoop = band[band.size() / 2 - 1];
    applyLoopPipelining(pipelineLoop, builder);
  }
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  // Apply general optimizations and array partition.
  // applyMergeAffineIf(targetFunc);
  applyAffineStoreForward(targetFunc, builder);
  applySimplifyMemrefAccess(targetFunc);
  applyArrayPartition(targetFunc, builder);
  applyPatternsAndFoldGreedily(targetFunc, patterns);

  // Estimate performance and resource utilization.
  HLSCppEstimator(targetFunc, latencyMap).estimateFunc();
  emitDebugInfo(targetFunc, "Apply loop tiling and pipelining, general "
                            "optimizations, and array partition.");
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
  std::vector<TileSizes> targetTileSizesList;
  // Holding the current tiling sizes of each loop band.
  std::vector<TileSizes> currentTileSizesList;
  // Holding the current loop tiling location in each loop band.
  SmallVector<unsigned, 8> headLocationList;

  // Initialize all design vectors.
  for (auto band : targetBands) {
    TileSizes targetSizes;
    TileSizes baseSizes;
    for (auto loop : band) {
      targetSizes.push_back(getIntAttrValue(loop, "trip_count"));
      baseSizes.push_back(1);
    }
    targetTileSizesList.push_back(targetSizes);
    currentTileSizesList.push_back(baseSizes);
    headLocationList.push_back(0);
  }

  // For recording the minimum latency and best tiling strategy.
  unsigned minLatency = getIntAttrValue(func, "latency");
  std::vector<TileSizes> bestTileSizesList;

  // TODO: more fined grained and comprehensive dse.
  unsigned tolerantCount = 0;
  while (true) {
    // Clone the current function and apply the current tiling strategy.
    auto tmpFunc = func.clone();
    applyLoopTilingStrategy(tmpFunc, currentTileSizesList);

    // If the resource constaints are not met or the latency is not increased,
    // increase the tolerant counter by 1.
    auto latency = getIntAttrValue(tmpFunc, "latency");
    if (getIntAttrValue(tmpFunc, "dsp") <= numDSP) {
      if (latency < minLatency) {
        minLatency = latency;
        bestTileSizesList = currentTileSizesList;
        tolerantCount = 0;
      } else
        tolerantCount++;

      // If the tolerant counter is larger than a threshold, we'll stop to
      // increase the tiling size.
      if (tolerantCount > 1)
        break;
      // else
      //   currentTileSize *= 2;
    } else
      break;
  }

  // Finally, apply the best tiling strategy.
  LLVM_DEBUG(llvm::dbgs() << "Found the best tiling strategy.\n";);
  applyLoopTilingStrategy(func, bestTileSizesList);
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
