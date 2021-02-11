//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/MultipleLevelDSE.h"
#include "mlir/Analysis/LoopAnalysis.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/Debug.h"
#include <pthread.h>

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

using TileConfig = SmallVector<int64_t, 8>;

namespace {
class TileSpace {
public:
  explicit TileSpace(AffineLoopBand &band) {
    tileConfigDimNum = band.size();

    for (unsigned i = 0; i < tileConfigDimNum; ++i) {
      auto loop = band[i];
      auto optionalTripCount = getConstantTripCount(loop);
      if (!optionalTripCount)
        loop.emitError("has variable loop bound");
      auto tripCount = optionalTripCount.getValue();

      SmallVector<unsigned, 8> factors;
      unsigned factor = 1;
      while (factor <= tripCount) {
        // Push back the current factor.
        factors.push_back(factor);

        // Find the next possible factor.
        ++factor;
        while (factor <= tripCount && tripCount % factor != 0)
          ++factor;
      }

      tileConfigMap.push_back(factors);
    }
  }

  /// Check whether a tile config is valid in the tile space.
  bool isValidTileConfig(TileConfig &tileConfig) {
    if (tileConfig.size() == tileConfigDimNum)
      return false;

    for (unsigned i = 0; i < tileConfigDimNum; ++i) {
      auto key = tileConfig[i];

      // The tile config must fall into the range of config map to be valid.
      if (key < 0 || key >= (int64_t)tileConfigMap[i].size())
        return false;
    }

    return true;
  }

  /// Check whether the tile config has been estimated. Assert the tile config
  /// is valid.
  bool isEstimatedTileConfig(TileConfig &tileConfig) {
    auto id = getTileConfigId(tileConfig);
    return estimatedTileConfigIds.count(id);
  }

  /// Add a new estimated tile config. Assert the tile config is valid.
  void addEstimatedTileConfig(TileConfig &tileConfig) {
    auto id = getTileConfigId(tileConfig);
    estimatedTileConfigIds.insert(id);
  }

  /// Get the tile sizes given a tile config. Assert the tile config is valid.
  TileSizes getTileSizes(TileConfig &tileConfig) {
    assert(isValidTileConfig(tileConfig) && "invalid tile config");

    TileSizes tileSizes;
    for (unsigned i = 0; i < tileConfigDimNum; ++i) {
      auto key = tileConfig[i];
      tileSizes.push_back(tileConfigMap[i][key]);
    }

    return tileSizes;
  }

  size_t tileConfigDimNum;
  std::vector<SmallVector<unsigned, 8>> tileConfigMap;
  std::set<int64_t> estimatedTileConfigIds;

  /// Get the unique tile config ID from tile config. Assert the tile config is
  /// valid.
  unsigned getTileConfigId(TileConfig &tileConfig) {
    assert(isValidTileConfig(tileConfig) && "invalid tile config");

    unsigned id = 0;
    unsigned accum = 1;
    for (unsigned i = 0; i < tileConfigDimNum; ++i) {
      id += accum * tileConfig[i];
      accum *= tileConfigMap[i].size();
    }

    return id;
  }
};
} // namespace

//===----------------------------------------------------------------------===//
// Optimizer Class Definition
//===----------------------------------------------------------------------===//

void ScaleHLSOptimizer::emitDebugInfo(FuncOp targetFunc, StringRef message) {
  LLVM_DEBUG(auto latency = getIntAttrValue(targetFunc, "latency");
             auto dsp = getIntAttrValue(targetFunc, "dsp");

             llvm::dbgs() << message << "\n";
             llvm::dbgs() << "Current latency is " << Twine(latency)
                          << ", DSP utilization is " << Twine(dsp) << ".\n\n";);
}

/// This is a temporary approach that does not scale.
void ScaleHLSOptimizer::applyMultipleLevelDSE(FuncOp func) {
  estimator.estimateFunc(func);
  if (getIntAttrValue(func, "dsp") > numDSP)
    return;
  emitDebugInfo(func, "Start multiple level design space exploration.");

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
    SmallVector<std::pair<int64_t, AffineForOp>, 8> candidateLoops;

    // Collect all candidate loops. Here, only loops whose innermost loop has
    // more than one inner loops will be considered as a candidate.
    for (auto target : targetLoops) {
      AffineLoopBand loopBand;
      auto innermostLoop = getLoopBandFromOutermost(target, loopBand);

      // Calculate the overall introduced parallelism if the innermost loop of
      // the current loop band is pipelined.
      auto parallelism = getInnerParallelism(innermostLoop);

      // Collect all candidate loops into an vector.
      if (parallelism > 1)
        candidateLoops.push_back(
            std::pair<int64_t, AffineForOp>(parallelism, innermostLoop));
    }

    // Since all target loops have been handled, clear the targetLoops vector.
    targetLoops.clear();

    // Sort the candidate loops.
    std::sort(candidateLoops.begin(), candidateLoops.end());

    // Traverse all candidates to check whether applying loop pipelining has
    // violation with the resource constraints. If so, add all inner loops into
    // targetLoops. Otherwise, pipeline the candidate.
    for (auto pair : candidateLoops) {
      auto candidate = pair.second;

      // Create a temporary function.
      setAttrValue(candidate, "opt_flag", true);
      auto tmpFunc = func.clone();

      // Find the candidate loop in the temporary function and apply loop
      // pipelining to it.
      tmpFunc.walk([&](AffineForOp loop) {
        if (getIntAttrValue(loop, "opt_flag")) {
          applyFullyLoopUnrolling(*loop.getBody());
          return;
        }
      });

      // Estimate the temporary function.
      estimator.estimateFunc(tmpFunc);

      // Pipeline the candidate loop or delve into child loops.
      if (getIntAttrValue(tmpFunc, "dsp") <= numDSP)
        applyFullyLoopUnrolling(*candidate.getBody());
      else {
        auto childForOps = candidate.getOps<AffineForOp>();
        targetLoops.append(childForOps.begin(), childForOps.end());
      }

      candidate.removeAttr("opt_flag");
    }
  }

  estimator.estimateFunc(func);
  if (getIntAttrValue(func, "dsp") > numDSP)
    return;
  emitDebugInfo(func, "1. Simplify loop nests structure.");

  //===--------------------------------------------------------------------===//
  // STAGE 2: Loop Bands Optimization
  //===--------------------------------------------------------------------===//

  // Optimize leaf loop nests. Different optimization conbinations will be
  // applied to each leaf LNs, and the best one which meets the resource
  // constraints will be picked as the final solution.
  // TODO: better handle variable bound kernels.
  AffineLoopBands targetBands;
  getLoopBands(func.front(), targetBands);
  unsigned targetNum = targetBands.size();

  // Loop perfection, remove variable bound, and loop order optimization are
  // always applied for the convenience of polyhedral optimizations.
  for (auto &band : targetBands) {
    applyAffineLoopPerfection(band);
    applyAffineLoopOrderOpt(band);
    applyRemoveVariableBound(band);
  }

  // Estimate the current latency.
  estimator.estimateFunc(func);
  if (getIntAttrValue(func, "dsp") > numDSP)
    return;
  emitDebugInfo(func, "2. Apply loop perfection, remove variable bound, and "
                      "loop order opt.");

  //===--------------------------------------------------------------------===//
  // STAGE 3: Loop Bands Tiling and Finalization
  //===--------------------------------------------------------------------===//

  for (unsigned i = 0; i < targetNum; ++i) {
    auto tileSpace = TileSpace(targetBands[i]);
    for (auto configs : tileSpace.tileConfigMap) {
      for (auto config : configs)
        llvm::dbgs() << config << ", ";
      llvm::dbgs() << "\n";
    }
  }
}

namespace {
struct MultipleLevelDSE : public MultipleLevelDSEBase<MultipleLevelDSE> {
  void runOnOperation() override {
    auto module = getOperation();
    auto builder = Builder(module);

    // Read configuration file.
    INIReader spec(targetSpec);
    if (spec.ParseError())
      emitError(module.getLoc(), "target spec file parse fail\n");

    // Collect profiling latency data, where default values are based on Xilinx
    // PYNQ-Z1 board.
    LatencyMap latencyMap;
    getLatencyMap(spec, latencyMap);
    int64_t numDSP = ceil(spec.GetInteger("specification", "dsp", 220) * 1.1);

    // Initialize an performance and resource estimator.
    auto estimator = ScaleHLSEstimator(builder, latencyMap);
    auto optimizer = ScaleHLSOptimizer(builder, estimator, numDSP);

    // Optimize the top function.
    for (auto func : module.getOps<FuncOp>())
      if (auto topFunction = func->getAttrOfType<BoolAttr>("top_function"))
        if (topFunction.getValue())
          optimizer.applyMultipleLevelDSE(func);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createMultipleLevelDSEPass() {
  return std::make_unique<MultipleLevelDSE>();
}
