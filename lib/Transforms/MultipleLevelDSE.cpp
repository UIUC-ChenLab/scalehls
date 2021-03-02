//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/MultipleLevelDSE.h"
#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Support/FileUtilities.h"
#include "scalehls/Transforms/Passes.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/ToolOutputFile.h"
#include <numeric>
// #include <pthread.h>

#define DEBUG_TYPE "scalehls"

using namespace mlir;
using namespace scalehls;

/// Update paretoPoints to remove design points that are not pareto frontiers.
template <typename DesignPointType>
static void updateParetoPoints(SmallVector<DesignPointType, 16> &paretoPoints) {
  // Sort the pareto points with in an ascending order of latency and the an
  // ascending order of dsp number.
  auto latencyThenDspNum = [&](const DesignPointType &a,
                               const DesignPointType &b) {
    return (a.latency < b.latency ||
            (a.latency == b.latency && a.dspNum < b.dspNum));
  };
  std::sort(paretoPoints.begin(), paretoPoints.end(), latencyThenDspNum);

  // Find pareto frontiers. After the sorting, the first design point must be a
  // pareto point.
  auto paretoPoint = paretoPoints[0];
  auto paretoLatency = paretoPoint.latency;
  auto paretoDspNum = paretoPoint.dspNum;
  SmallVector<DesignPointType, 16> frontiers;

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

//===----------------------------------------------------------------------===//
// LoopDesignSpace Class Definition
//===----------------------------------------------------------------------===//

static void emitTileListDebugInfo(TileList tileList) {
  LLVM_DEBUG(llvm::dbgs() << "(";
             for (unsigned i = 0, e = tileList.size(); i < e; ++i) {
               llvm::dbgs() << tileList[i];
               if (i != e - 1)
                 llvm::dbgs() << ",";
               else
                 llvm::dbgs() << ") ";
             });
}

LoopDesignSpace::LoopDesignSpace(FuncOp func, AffineLoopBand &band,
                                 ScaleHLSEstimator &estimator,
                                 unsigned maxDspNum)
    : func(func), band(band), estimator(estimator), maxDspNum(maxDspNum) {
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

  // The last design point (all loops are fully unrolled) is removed.
  --validTileConfigNum;

  for (TileConfig config = 0; config < validTileConfigNum; ++config)
    unestimatedTileConfigs.insert(config);
}

/// Return the actual tile vector given a tile config.
TileList LoopDesignSpace::getTileList(TileConfig config) {
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
float LoopDesignSpace::getTileConfigDistance(TileConfig configA,
                                             TileConfig configB) {
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

/// Evaluate all design points under the given tile config.
bool LoopDesignSpace::evaluateTileConfig(TileConfig config) {
  // If the current tile config is already estimated, return true.
  if (!unestimatedTileConfigs.count(config))
    return true;

  // Clone a temporary loop band by cloning the outermost loop.
  auto outerLoop = band.front();
  auto tmpOuterLoop = outerLoop.clone();
  AffineLoopBand tmpBand;
  getLoopBandFromOutermost(tmpOuterLoop, tmpBand);

  // Insert the clone loop band to the front of the original band for the
  // convenience of the estimation.
  auto builder = OpBuilder(func);
  builder.setInsertionPoint(outerLoop);
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
  estimator.estimateLoop(tmpOuterLoop, func);

  // Fetch latency and resource utilization.
  auto tmpInnerLoop = tmpBand.back();
  auto II = estimator.getIntAttrValue(tmpInnerLoop, "ii");
  auto iterLatency = estimator.getIntAttrValue(tmpInnerLoop, "iter_latency");
  auto shareDspNum = estimator.getIntAttrValue(tmpInnerLoop, "share_dsp");
  auto noShareDspNum = estimator.getIntAttrValue(tmpInnerLoop, "noshare_dsp");

  // Improve target II until II is equal to iteration latency. Note that when II
  // equal to iteration latency, the pipeline pragma is similar to a region
  // fully unroll pragma which unrolls all contained loops.
  for (auto tmpII = II; tmpII <= iterLatency; ++tmpII) {
    auto tmpDspNum = std::max(shareDspNum, noShareDspNum / tmpII);
    auto tmpLatency = iterLatency + tmpII * (iterNum - 1);
    auto point = LoopDesignPoint(tmpLatency, tmpDspNum, config, tmpII);

    allPoints.push_back(point);
    if (tmpDspNum <= maxDspNum)
      paretoPoints.push_back(point);
  }

  // Erase the temporary loop band and annotate the current tile config as
  // estimated.
  tmpOuterLoop.erase();
  unestimatedTileConfigs.erase(config);
  return true;
}

/// Initialize the design space.
void LoopDesignSpace::initializeLoopDesignSpace(unsigned maxInitParallel) {
  LLVM_DEBUG(llvm::dbgs() << "Initialize the loop design space...\n";);

  for (TileConfig config = 0; config < validTileConfigNum; ++config) {
    auto tileList = getTileList(config);

    // We only evaluate the design points whose overall parallelism is smaller
    // than the maxInitParallel to improve the efficiency.
    auto parallel = std::accumulate(tileList.begin(), tileList.end(),
                                    (unsigned)1, std::multiplies<unsigned>());
    if (parallel > maxInitParallel)
      continue;

    // emitTileListDebugInfo(getTileList(config));
    evaluateTileConfig(config);
  }

  // LLVM_DEBUG(llvm::dbgs() << "\n\n");
  updateParetoPoints(paretoPoints);
}

/// Dump pareto and non-pareto points which have been evaluated in the design
/// space to a csv output file.
void LoopDesignSpace::dumpLoopDesignSpace(raw_ostream &os) {
  // Print header row.
  for (unsigned i = 0; i < tripCountList.size(); ++i)
    os << "l" << i << ",";
  os << "ii,cycle,dsp,type\n";

  // Print pareto design points.
  for (auto &point : paretoPoints) {
    for (auto size : getTileList(point.tileConfig))
      os << size << ",";
    os << point.targetII << "," << point.latency << "," << point.dspNum
       << ",pareto\n";
  }

  // Print all design points.
  for (auto &point : allPoints) {
    for (auto size : getTileList(point.tileConfig))
      os << size << ",";
    os << point.targetII << "," << point.latency << "," << point.dspNum
       << ",non-pareto\n";
  }

  LLVM_DEBUG(llvm::dbgs() << "Design space is dumped to output file.\n\n");
}

/// Get a random tile config which is one of the closest neighbors of "point".
Optional<TileConfig>
LoopDesignSpace::getRandomClosestNeighbor(LoopDesignPoint point,
                                          float maxDistance) {
  // Traverse all unestimated tile configs and collect all neighbors.
  SmallVector<std::pair<float, TileConfig>, 8> candidateConfigs;
  for (auto config : unestimatedTileConfigs) {
    auto distance = getTileConfigDistance(point.tileConfig, config);
    if (distance <= maxDistance)
      candidateConfigs.push_back(
          std::pair<float, TileConfig>(distance, config));
  }

  if (candidateConfigs.empty())
    return Optional<TileConfig>();

  // Sort candidate configs and collect the closest points.
  std::sort(candidateConfigs.begin(), candidateConfigs.end());
  SmallVector<TileConfig, 8> closestConfigs;
  float minDistance = maxDistance;

  for (auto configPair : candidateConfigs) {
    if (configPair.first <= minDistance) {
      closestConfigs.push_back(configPair.second);
      minDistance = configPair.first;
    } else
      break;
  }

  // Randomly pick one as the return point.
  std::srand(std::time(0));
  std::random_shuffle(closestConfigs.begin(), closestConfigs.end(),
                      [&](int i) { return std::rand() % i; });

  return closestConfigs.front();
}

void LoopDesignSpace::exploreLoopDesignSpace(unsigned maxIterNum,
                                             float maxDistance) {
  LLVM_DEBUG(llvm::dbgs() << "Explore the loop design space...\n";);

  // Exploration loop of the dse.
  for (unsigned i = 0; i < maxIterNum; ++i) {
    std::srand(std::time(0));
    std::random_shuffle(paretoPoints.begin(), paretoPoints.end(),
                        [&](int i) { return std::rand() % i; });

    bool foundValidNeighbor = false;
    for (auto &point : paretoPoints) {
      if (!point.isActive)
        continue;

      auto closestNeighbor = getRandomClosestNeighbor(point, maxDistance);
      if (!closestNeighbor) {
        point.isActive = false;
        continue;
      }

      foundValidNeighbor = true;
      auto config = closestNeighbor.getValue();

      emitTileListDebugInfo(getTileList(config));
      evaluateTileConfig(config);
      break;
    }

    // Early termination if no valid neighbor is found.
    if (!foundValidNeighbor)
      break;

    // Update pareto points after each dse iteration.
    updateParetoPoints(paretoPoints);
  }
  LLVM_DEBUG(llvm::dbgs() << "\n\n";);
}

//===----------------------------------------------------------------------===//
// FuncDesignSpace Class Definition
//===----------------------------------------------------------------------===//

void FuncDesignSpace::dumpFuncDesignSpace(raw_ostream &os) {
  // Print header row.
  for (unsigned i = 0, ei = loopDesignSpaces.size(); i < ei; ++i) {
    auto &loopSpace = loopDesignSpaces[i];

    for (unsigned j = 0, ej = loopSpace.tripCountList.size(); j < ej; ++j)
      os << "b" << i << "l" << j << ",";
    os << "b" << i << "ii,";
  }
  os << "cycle,dsp,type\n";

  // Print pareto design points.
  for (auto &funcPoint : paretoPoints) {
    for (unsigned i = 0, e = loopDesignSpaces.size(); i < e; ++i) {
      auto &loopPoint = funcPoint.loopDesignPoints[i];
      auto &loopSpace = loopDesignSpaces[i];

      for (auto size : loopSpace.getTileList(loopPoint.tileConfig))
        os << size << ",";
      os << loopPoint.targetII << ",";
    }
    os << funcPoint.latency << "," << funcPoint.dspNum << ",pareto\n";
  }

  LLVM_DEBUG(llvm::dbgs() << "Design space is dumped to output file.\n\n");
}

void FuncDesignSpace::combLoopDesignSpaces() {
  LLVM_DEBUG(llvm::dbgs() << "Combine the loop design spaces...\n";);

  // Initialize the function design space with the first loop design space.
  auto &firstLoopSpace = loopDesignSpaces[0];
  for (auto &loopPoint : firstLoopSpace.paretoPoints) {
    // Annotate the first loop.
    auto loop = targetLoops[0];
    estimator.setAttrValue(loop, "latency", loopPoint.latency);
    estimator.setAttrValue(loop, "dsp", loopPoint.dspNum);

    // Estimate the function and generate a new function design point.
    estimator.estimateFunc(func);
    auto latency = estimator.getIntAttrValue(func, "latency");
    auto dspNum = estimator.getIntAttrValue(func, "dsp");
    auto funcPoint = FuncDesignPoint(latency, dspNum, loopPoint);

    paretoPoints.push_back(funcPoint);
  }

  updateParetoPoints(paretoPoints);
  LLVM_DEBUG(llvm::dbgs() << "Iteration 0 pareto points number: "
                          << paretoPoints.size() << "\n";);

  // Combine other loop design spaces to the function design space one by one.
  for (unsigned i = 1, e = loopDesignSpaces.size(); i < e; ++i) {
    SmallVector<FuncDesignPoint, 16> newParetoPoints;
    auto &loopSpace = loopDesignSpaces[i];

    // Traverse all function design points.
    for (auto &funcPoint : paretoPoints) {
      // Annotate latency and dsp to all loops that are already included in the
      // function point, they are static for all design points of the new loop.
      for (unsigned ii = 0; ii < i; ++ii) {
        auto &oldLoopPoint = funcPoint.loopDesignPoints[ii];
        auto oldLoop = targetLoops[ii];
        estimator.setAttrValue(oldLoop, "latency", oldLoopPoint.latency);
        estimator.setAttrValue(oldLoop, "dsp", oldLoopPoint.dspNum);
      }

      // Traverse all design points of the NEW loop.
      for (auto &loopPoint : loopSpace.paretoPoints) {
        // Annotate the new loop,
        auto loop = targetLoops[i];
        estimator.setAttrValue(loop, "latency", loopPoint.latency);
        estimator.setAttrValue(loop, "dsp", loopPoint.dspNum);

        // Estimate the function and generate a new function design point.
        auto loopPoints = funcPoint.loopDesignPoints;
        loopPoints.push_back(loopPoint);

        estimator.estimateFunc(func);
        auto latency = estimator.getIntAttrValue(func, "latency");
        auto dspNum = estimator.getIntAttrValue(func, "dsp");
        auto funcPoint = FuncDesignPoint(latency, dspNum, loopPoints);

        newParetoPoints.push_back(funcPoint);
      }
    }

    // Update pareto points after each combination.
    updateParetoPoints(newParetoPoints);
    paretoPoints = newParetoPoints;
    LLVM_DEBUG(llvm::dbgs() << "Iteration " << i << " pareto points number: "
                            << paretoPoints.size() << "\n";);
  }
  LLVM_DEBUG(llvm::dbgs() << "\n";);
}

//===----------------------------------------------------------------------===//
// Optimizer Class Definition
//===----------------------------------------------------------------------===//

bool ScaleHLSOptimizer::emitQoRDebugInfo(FuncOp func, std::string message) {
  estimator.estimateFunc(func);
  auto latency = getIntAttrValue(func, "latency");
  auto dspNum = getIntAttrValue(func, "dsp");

  LLVM_DEBUG(llvm::dbgs() << message + "\n";
             llvm::dbgs() << "The clock cycle is " << Twine(latency)
                          << ", DSP usage is " << Twine(dspNum) << ".\n\n";);

  return dspNum <= maxDspNum;
}

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

/// DSE Stage1: Simplify loop nests by unrolling. If we take the following loops
/// as example, where each nodes represents one sequential loop nests (LN). In
/// the simplification, we'll first try to pipeline LN1 and LN6. Suppose
/// unrolling LN6's region meets the resource constaints while pipelining LN1
/// not, we'll unroll LN6's region (fully unroll LN7 and LN8) and keep LN1
/// untouched. In the next step, we'll look into LN1 and check whether LN2's
/// region can be unrolled. Suppose unrolling LN2's region meets the resource
/// constraints, we'll unrolling LN2's region (fully unroll LN7 and LN8). Note
/// that in this simplification, all LNs that don't contain any LNs will not be
/// touched, such as LN5. Their optimization will be explored later. This
/// procedure will recursively applied to inner LNs until no eligible LN exists.
///
///     LN1      LN6
///      |        |
///     / \      / \
///   LN2 LN5  LN7 LN8
///    |
///   / \
/// LN3 LN4
///
/// After the simplification, the loop becomes the following one, where LN1 has
/// been proved untouchable as region loop unrolling is the primary optimization
/// that consumes the least extra resources. Formally, in the simplified
/// function, all non-leaf LNs is untouchable (LN1) and only leaf LNs can be
/// further optimized (LN2, LN5, and LN6).
///
///     LN1      LN6
///      |
///     / \
///   LN2 LN5
///
/// TODO: there is a large design space in this simplification.
bool ScaleHLSOptimizer::simplifyLoopNests(FuncOp func) {
  LLVM_DEBUG(llvm::dbgs()
                 << "----------\nStage1: Simplify loop nests structure...\n";);

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
      if (getIntAttrValue(tmpFunc, "dsp") <= maxDspNum)
        applyFullyLoopUnrolling(*candidate.getBody());
      else {
        auto childForOps = candidate.getOps<AffineForOp>();
        targetLoops.append(childForOps.begin(), childForOps.end());
      }

      candidate.removeAttr("opt_flag");
    }
  }

  return emitQoRDebugInfo(func, "\nFinish Stage1.");
}

/// DSE Stage2: Optimize leaf loop nests. Different optimization conbinations
/// will be applied to each leaf LNs, and the best one which meets the resource
/// constraints will be picked as the final solution.
/// TODO: better handle variable bound kernels.
bool ScaleHLSOptimizer::optimizeLoopBands(FuncOp func) {
  LLVM_DEBUG(llvm::dbgs() << "----------\nStage2: Apply loop perfection, loop "
                             "order opt, and remove variable loop bound...\n";);

  AffineLoopBands targetBands;
  getLoopBands(func.front(), targetBands);
  unsigned targetNum = targetBands.size();

  // Loop perfection, remove variable bound, and loop order optimization are
  // always applied for the convenience of polyhedral optimizations.
  for (unsigned i = 0; i < targetNum; ++i) {
    auto &band = targetBands[i];
    LLVM_DEBUG(llvm::dbgs() << "Loop band " << i << ": ";);
    applyAffineLoopPerfection(band);
    applyAffineLoopOrderOpt(band);
    applyRemoveVariableBound(band);
  }

  return emitQoRDebugInfo(func, "\nFinish Stage2.");
}

/// DSE Stage3: Explore the function design space through dynamic programming.
bool ScaleHLSOptimizer::exploreDesignSpace(FuncOp func, raw_ostream &os) {
  LLVM_DEBUG(llvm::dbgs() << "----------\nStage3: Conduct top function design "
                             "space exploration...\n";);

  auto tmpFunc = func.clone();
  AffineLoopBands targetBands;
  getLoopBands(tmpFunc.front(), targetBands);
  unsigned targetNum = targetBands.size();

  // Search for the pareto frontiers of each target loop band.
  SmallVector<LoopDesignSpace, 4> loopSpaces;
  for (unsigned i = 0; i < targetNum; ++i) {
    auto space = LoopDesignSpace(tmpFunc, targetBands[i], estimator, maxDspNum);

    LLVM_DEBUG(llvm::dbgs() << "Loop band " << i << ": ";);
    space.initializeLoopDesignSpace(maxInitParallel);

    LLVM_DEBUG(llvm::dbgs() << "Loop band " << i << ": ";);
    space.exploreLoopDesignSpace(maxIterNum, maxDistance);
    loopSpaces.push_back(space);
    // space.dumpLoopDesignSpace(os);
  }

  // Combine all loop design spaces into a function design space.
  tmpFunc = func.clone();
  auto funcSpace = FuncDesignSpace(tmpFunc, loopSpaces, estimator, maxDspNum);
  funcSpace.combLoopDesignSpaces();
  funcSpace.dumpFuncDesignSpace(os);

  // Apply the best function design point under the constraints.
  for (auto &funcPoint : funcSpace.paretoPoints) {
    if (funcPoint.dspNum <= maxDspNum) {
      std::vector<TileList> tileLists;
      SmallVector<unsigned, 4> targetIIs;

      for (unsigned i = 0; i < targetNum; ++i) {
        auto &loopSpace = funcSpace.loopDesignSpaces[i];
        auto &loopPoint = funcPoint.loopDesignPoints[i];
        auto tileList = loopSpace.getTileList(loopPoint.tileConfig);
        auto targetII = loopPoint.targetII;

        LLVM_DEBUG(llvm::dbgs() << "Loop band " << i << ": "
                                << "Loop tiling & pipelining (";);
        LLVM_DEBUG(for (auto tile : tileList) { llvm::dbgs() << tile << ","; });
        LLVM_DEBUG(llvm::dbgs() << targetII << ")\n");

        tileLists.push_back(tileList);
        targetIIs.push_back(targetII);
      }

      applyOptStrategy(func, tileLists, targetIIs);
      break;
    }
  }

  return emitQoRDebugInfo(func, "\nFinish Stage3.");
}

//===----------------------------------------------------------------------===//
// MultipleLevelDSE Entry
//===----------------------------------------------------------------------===//

/// This is a temporary approach that does not scale.
void ScaleHLSOptimizer::applyMultipleLevelDSE(FuncOp func, raw_ostream &os) {
  emitQoRDebugInfo(func, "Start multiple level DSE.");

  // Simplify loop nests by unrolling.
  if (!simplifyLoopNests(func))
    return;

  // Optimize loop bands by loop perfection, loop order permutation, and loop
  // rectangularization.
  if (!optimizeLoopBands(func))
    return;

  // Explore the design space through a multiple level approach.
  if (!exploreDesignSpace(func, os))
    return;
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
    unsigned maxDspNum =
        ceil(spec.GetInteger("specification", "dsp", 220) * 1.1);

    unsigned maxInitParallel = spec.GetInteger("dse", "max_init_parallel", 16);
    unsigned maxIterNum = spec.GetInteger("dse", "max_iter_num", 16);
    unsigned maxDistance = spec.GetFloat("dse", "max_distance", 1.0);

    // Parse output file.
    std::string errorMessage;
    auto output = mlir::openOutputFile(dumpFile, &errorMessage);
    if (!output)
      emitError(module.getLoc(), errorMessage);

    // Initialize an performance and resource estimator.
    auto estimator = ScaleHLSEstimator(builder, latencyMap, depAnalysis);
    auto optimizer =
        ScaleHLSOptimizer(builder, estimator, maxDspNum, maxInitParallel,
                          maxIterNum, maxDistance);

    // Optimize the top function.
    // TODO: Handle sub-functions.
    for (auto func : module.getOps<FuncOp>())
      if (func.getName() == topFunc) {
        func->setAttr("top_function", builder.getBoolAttr(true));
        optimizer.applyMultipleLevelDSE(func, output->os());
      }

    output->keep();
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createMultipleLevelDSEPass() {
  return std::make_unique<MultipleLevelDSE>();
}
