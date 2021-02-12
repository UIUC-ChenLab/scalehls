//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/MultipleLevelDSE.h"
#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Support/FileUtilities.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ToolOutputFile.h"
#include <numeric>
#include <pthread.h>

#define DEBUG_TYPE "scalehls"

using namespace mlir;
using namespace scalehls;

using TileConfig = unsigned;

//===----------------------------------------------------------------------===//
// Helper Methods and Classes
//===----------------------------------------------------------------------===//

namespace {
struct DesignPoint {
public:
  explicit DesignPoint(int64_t latency, int64_t dspNum, TileConfig tileConfig,
                       unsigned targetII)
      : latency(latency), dspNum(dspNum), tileConfig(tileConfig),
        targetII(targetII) {}

  int64_t latency;
  int64_t dspNum;

  TileConfig tileConfig;
  unsigned targetII;
};
} // namespace

namespace {
class DesignSpace {
public:
  DesignSpace(FuncOp func, AffineLoopBand &band, ScaleHLSEstimator &estimator)
      : func(func), band(band), estimator(estimator) {
    // Initialize tile vector related members.
    validTileConfigNum = 1;
    for (auto loop : band) {
      auto optionalTripCount = getConstantTripCount(loop);
      if (!optionalTripCount)
        loop.emitError("has variable loop bound");

      auto tripCount = optionalTripCount.getValue();
      tripCountList.push_back(tripCount);

      SmallVector<unsigned, 8> validSizes;
      unsigned size = 1;
      while (size <= tripCount) {
        // Push back the current size.
        validSizes.push_back(size);

        // Find the next possible size.
        ++size;
        while (size <= tripCount && tripCount % size != 0)
          ++size;
      }

      validTileSizesList.push_back(validSizes);
      validTileConfigNum *= validSizes.size();
    }

    for (TileConfig config = 0; config < validTileConfigNum; ++config)
      unestimatedTileConfigs.insert(config);
  }

  /// Return the actual tile vector given a tile config.
  TileList getTileList(TileConfig config) {
    assert(config < validTileConfigNum && "invalid tile config");

    TileList tileList;
    unsigned factor = 1;
    for (auto validSizes : validTileSizesList) {
      auto idx = config / factor % validSizes.size();
      factor *= validSizes.size();

      auto size = validSizes[idx];
      tileList.push_back(size);
    }
    return tileList;
  }

  /// Calculate the Euclid distance of config a and config b.
  float getTileConfigDistance(TileConfig configA, TileConfig configB) {
    assert(configA < validTileConfigNum && configB < validTileConfigNum &&
           "invalid tile config");

    int64_t distanceSquare = 0;
    unsigned factor = 1;
    for (auto validSizes : validTileSizesList) {
      int64_t idxA = configA / factor % validSizes.size();
      int64_t idxB = configB / factor % validSizes.size();
      factor *= validSizes.size();

      auto idxDistance = idxA - idxB;
      distanceSquare += idxDistance * idxDistance;
    }

    return sqrtf(distanceSquare);
  }

  /// Update paretoPoints to remove design points that are not pareto frontiers.
  void updateParetoPoints() {
    // Sort the pareto points with in an ascending order of latency and the an
    // ascending order of dsp number.
    auto latencyThenDspNum = [&](const DesignPoint &a, const DesignPoint &b) {
      return (a.latency < b.latency ||
              (a.latency == b.latency && a.dspNum < b.dspNum));
    };
    std::sort(paretoPoints.begin(), paretoPoints.end(), latencyThenDspNum);

    // Find pareto frontiers. After the sorting, the first design point must be
    // a pareto point.
    auto paretoPoint = paretoPoints[0];
    auto paretoLatency = paretoPoint.latency;
    auto paretoDspNum = paretoPoint.dspNum;
    SmallVector<DesignPoint, 16> frontiers;

    for (auto point : paretoPoints) {
      auto tmpLatency = point.latency;
      auto tmpDspNum = point.dspNum;

      if (tmpDspNum < paretoDspNum) {
        frontiers.push_back(point);

        paretoPoint = point;
        paretoLatency = tmpLatency;
        paretoDspNum = tmpDspNum;

      } else if (tmpDspNum == paretoDspNum && tmpLatency == paretoLatency)
        frontiers.push_back(point);
    }

    paretoPoints = frontiers;
  }

  /// Evaluate all design points under the given tile config.
  bool evaluateTileConfig(TileConfig config) {
    // If the current tile config is already estimated, return true.
    if (!unestimatedTileConfigs.count(config))
      return true;

    // Clone a temporary loop band by cloning the outermost loop.
    auto tmpOuterLoop = band.front().clone();
    AffineLoopBand tmpBand;
    getLoopBandFromOutermost(tmpOuterLoop, tmpBand);

    // Insert the clone loop band to the front of the original band for the
    // convenience of the estimation.
    auto builder = OpBuilder(func);
    builder.setInsertionPoint(band.front());
    builder.insert(tmpOuterLoop);

    // Apply the tile config and estimate the loop band.
    auto tileList = getTileList(config);
    unsigned iterNum = 1;
    for (unsigned i = 0, e = tileList.size(); i < e; ++i)
      iterNum *= tripCountList[i] / tileList[i];

    // We always don't fully unroll all loops in the loop band.
    if (iterNum == 1)
      return false;

    // Apply the current tiling config and start the estimation. Note that after
    // optimization, tmpBand is optimized in place and becomes a new loop band.
    if (!applyOptStrategy(tmpBand, func, tileList, (unsigned)1))
      return false;
    tmpOuterLoop = tmpBand.front();
    estimator.estimateLoop(tmpOuterLoop);

    // Fetch latency and resource utilization.
    auto tmpInnerLoop = tmpBand.back();
    auto II = estimator.getIntAttrValue(tmpInnerLoop, "ii");
    auto iterLatency = estimator.getIntAttrValue(tmpInnerLoop, "iter_latency");
    auto shareDspNum = estimator.getIntAttrValue(tmpInnerLoop, "share_dsp");
    auto noShareDspNum = estimator.getIntAttrValue(tmpInnerLoop, "noshare_dsp");

    // Improve target II until II is equal to iteration latency. Note that when
    // II equal to iteration latency, the pipeline pragma is similar to a region
    // fully unroll pragma which unrolls all contained loops.
    for (auto tmpII = II; tmpII <= iterLatency; ++tmpII) {
      auto tmpDspNum = std::max(shareDspNum, noShareDspNum / tmpII);
      auto tmpLatency = iterLatency + tmpII * (iterNum - 1);

      auto point = DesignPoint(tmpLatency, tmpDspNum, config, tmpII);
      allPoints.push_back(point);
      paretoPoints.push_back(point);
    }

    // Erase the temporary loop band and annotate the current tile config as
    // estimated.
    tmpOuterLoop.erase();
    unestimatedTileConfigs.erase(config);
    return true;
  }

  /// Initialize the design space.
  void initializeDesignSpace(unsigned maxInitializeParallel) {
    LLVM_DEBUG(llvm::dbgs() << "3.1 Initializing the design space...\n";);

    for (TileConfig config = 0; config < validTileConfigNum; ++config) {
      auto tileList = getTileList(config);

      // We only evaluate the design points whose overall parallelism is smaller
      // than the maxInitializeParallel to improve the efficiency.
      auto parallel = std::accumulate(tileList.begin(), tileList.end(),
                                      (unsigned)1, std::multiplies<unsigned>());
      if (parallel > maxInitializeParallel)
        continue;

      LLVM_DEBUG(llvm::dbgs() << config << ",");
      evaluateTileConfig(config);
    }

    LLVM_DEBUG(llvm::dbgs() << "\n\n");
    updateParetoPoints();
  }

  /// Dump pareto and non-pareto points which have been evaluated in the design
  /// space to a csv output file.
  void dumpDesignSpace(raw_ostream &os) {
    // Print header row.
    for (unsigned i = 0; i < tripCountList.size(); ++i)
      os << "l" << i << ",";
    os << "ii,cycle,dsp,type\n";

    // Print pareto design points.
    for (auto point : paretoPoints) {
      for (auto size : getTileList(point.tileConfig))
        os << size << ",";
      os << point.targetII << "," << point.latency << "," << point.dspNum
         << ",pareto\n";
    }

    // Print all design points.
    for (auto point : allPoints) {
      for (auto size : getTileList(point.tileConfig))
        os << size << ",";
      os << point.targetII << "," << point.latency << "," << point.dspNum
         << ",non-pareto\n";
    }

    LLVM_DEBUG(llvm::dbgs() << "Design space is dumped to output file.\n\n");
  }

  /// Stores current pareto frontiers and all evaluated design points.
  SmallVector<DesignPoint, 16> paretoPoints;
  SmallVector<DesignPoint, 16> allPoints;

  /// Associated function, loop band, and estimator.
  FuncOp func;
  AffineLoopBand &band;
  ScaleHLSEstimator &estimator;

  /// Records the trip count of each loop level.
  SmallVector<unsigned, 8> tripCountList;

  /// The dimension of this list is same to the number of loops in the loop
  /// band. The n-th element of this list stores all valid tile sizes of the
  /// n-th loop in the loop band.
  SmallVector<SmallVector<unsigned, 8>, 8> validTileSizesList;

  /// Holds the total number of valid tile size combinations.
  unsigned validTileConfigNum;

  /// Holds all tile configs that have not been estimated.
  std::set<TileConfig> unestimatedTileConfigs;
};
} // namespace

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
// Optimizer Class Definition
//===----------------------------------------------------------------------===//

/// This is a temporary approach that does not scale.
void ScaleHLSOptimizer::applyMultipleLevelDSE(FuncOp func, raw_ostream &os,
                                              unsigned maxInitializeParallel) {
  estimator.estimateFunc(func);
  if (getIntAttrValue(func, "dsp") > numDSP)
    return;

  LLVM_DEBUG(auto latency = getIntAttrValue(func, "latency");
             auto dspNum = getIntAttrValue(func, "dsp");

             llvm::dbgs() << "\nStart the design space exploration.\n";
             llvm::dbgs() << "Initial clock cycle is " << Twine(latency)
                          << ", DSP usage is " << Twine(dspNum) << ".\n\n";);

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
  LLVM_DEBUG(llvm::dbgs() << "1. Simplify loop nests structure.\n\n");

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
  LLVM_DEBUG(llvm::dbgs() << "2. Apply loop perfection, loop order opt, and "
                             "remove variable loop bound.\n\n");

  //===--------------------------------------------------------------------===//
  // STAGE 3: Search for pareto frontiers
  //===--------------------------------------------------------------------===//

  LLVM_DEBUG(llvm::dbgs() << "3. Search for pareto design points...\n\n";);

  for (unsigned i = 0; i < targetNum; ++i) {
    auto space = DesignSpace(func, targetBands[i], estimator);
    space.initializeDesignSpace(maxInitializeParallel);
    space.dumpDesignSpace(os);
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

    // Parse output file.
    std::string errorMessage;
    auto output = mlir::openOutputFile(outputFile, &errorMessage);
    if (!output)
      emitError(module.getLoc(), errorMessage);

    // Initialize an performance and resource estimator.
    auto estimator = ScaleHLSEstimator(builder, latencyMap);
    auto optimizer = ScaleHLSOptimizer(builder, estimator, numDSP);

    // Optimize the top function.
    for (auto func : module.getOps<FuncOp>())
      if (auto topFunction = func->getAttrOfType<BoolAttr>("top_function"))
        if (topFunction.getValue())
          optimizer.applyMultipleLevelDSE(func, output->os(), maxParallel);

    output->keep();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createMultipleLevelDSEPass() {
  return std::make_unique<MultipleLevelDSE>();
}
