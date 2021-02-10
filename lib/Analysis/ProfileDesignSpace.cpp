//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Support/FileUtilities.h"
#include "scalehls/Analysis/Passes.h"
#include "scalehls/Analysis/QoREstimation.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/ToolOutputFile.h"

#define DEBUG_TYPE "scalehls"

using namespace mlir;
using namespace scalehls;

/// Currently only support single loop band profiling.
static void applyProfiling(FuncOp func, raw_ostream &os,
                           ScaleHLSEstimator &estimator, unsigned maxParallel) {
  if (!dyn_cast<AffineForOp>(func.front().front())) {
    func.emitError("first operation is not loop");
    return;
  }

  // Helper function for fetching the target loop band.
  auto getFirstBand = [&](FuncOp targetFunc) {
    // Get the first loop band as target.
    auto target = dyn_cast<AffineForOp>(targetFunc.front().front());
    AffineLoopBand band;
    getLoopBandFromOutermost(target, band);
    return band;
  };

  // Perfect and optimize loop order of the target loop band.
  auto band = getFirstBand(func);
  auto loopNum = band.size();
  applyAffineLoopPerfection(band);
  applyAffineLoopOrderOpt(band);
  applyRemoveVariableBound(band);

  // Initialize tile size and trip count vector.
  auto tileSizes = TileSizes(loopNum, 1);
  auto tripCounts = TileSizes();
  unsigned iterations = 1;
  for (unsigned loc = 0; loc < loopNum; ++loc) {
    auto tripCount = getConstantTripCount(band[loc]).getValue();
    tripCounts.push_back(tripCount);
    iterations *= (log2(tripCount) + 1);
    os << "l" << loc << ",";
  }
  os << "ii,cycle,dsp,pareto\n";

  // Storing all design points.
  using DesignPoint = SmallVector<int64_t, 8>;
  std::vector<DesignPoint> designPoints;

  // Traverse each tile size configuration.
  for (unsigned i = 0; i < iterations - 1; ++i) {
    for (unsigned loc = 0; loc < loopNum; ++loc) {
      auto &tileSize = tileSizes[loc];
      if (loc == 0)
        tileSize *= 2;
      else if (tileSizes[loc - 1] > tripCounts[loc - 1])
        tileSize *= 2;
    }

    unsigned iterNum = 1;
    unsigned parallel = 1;
    for (unsigned loc = 0; loc < loopNum; ++loc) {
      auto &tileSize = tileSizes[loc];
      if (tileSize > tripCounts[loc])
        tileSize = 1;
      iterNum *= tripCounts[loc] / tileSize;
      parallel *= tileSize;
      LLVM_DEBUG(llvm::dbgs() << tileSize << ", ";);
    }
    LLVM_DEBUG(llvm::dbgs() << "\n";);

    if (parallel > maxParallel)
      continue;

    // Apply tiling strategy.
    auto tmpFunc = func.clone();
    applyOptStrategy(tmpFunc, tileSizes, 1);
    estimator.estimateFunc(tmpFunc);
    auto tmpLoop = getFirstBand(tmpFunc).back();

    // Fetch latency and resource utilization.
    auto II = estimator.getIntAttrValue(tmpLoop, "ii");
    auto iterLatency = estimator.getIntAttrValue(tmpLoop, "iter_latency");
    auto shareDspNum = estimator.getIntAttrValue(tmpLoop, "share_dsp");
    auto noShareDspNum = estimator.getIntAttrValue(tmpLoop, "noshare_dsp");

    // Improve target II until II is equal to iteration latency.
    for (auto tmpII = II; tmpII <= iterLatency; ++tmpII) {
      auto tmpDspNum = std::max(shareDspNum, noShareDspNum / tmpII);
      auto tmpLatency = iterLatency + tmpII * (iterNum - 1);

      auto point = SmallVector<int64_t, 8>(tileSizes.begin(), tileSizes.end());
      point.append({tmpII, tmpLatency, tmpDspNum});
      designPoints.push_back(point);

      if (iterNum == 1)
        break;
    }
  }

  // Sort all design points by latency.
  auto compareLatency = [&](const DesignPoint &a, const DesignPoint &b) {
    return a[loopNum + 1] < b[loopNum + 1];
  };
  std::sort(designPoints.begin(), designPoints.end(), compareLatency);

  // Sort all design points with the same latency by dsp number.
  auto compareDspNum = [&](const DesignPoint &a, const DesignPoint &b) {
    return a[loopNum + 2] < b[loopNum + 2];
  };
  for (auto i = designPoints.begin(); i < designPoints.end();) {
    auto j = i;
    for (; j < designPoints.end(); ++j)
      if ((*i)[loopNum + 1] != (*j)[loopNum + 1])
        break;
    std::sort(i, j, compareDspNum);
    i = j;
  }

  // Find pareto frontiers. After the sorting, the first design point must be a
  // pareto point.
  auto paretoPoint = designPoints[0];
  auto paretoLatency = paretoPoint[loopNum + 1];
  auto paretoDspNum = paretoPoint[loopNum + 2];
  std::vector<DesignPoint> paretoPoints;

  for (auto point : designPoints) {
    auto tmpLatency = point[loopNum + 1];
    auto tmpDspNum = point[loopNum + 2];

    if (tmpDspNum < paretoDspNum) {
      paretoPoints.push_back(point);
      paretoPoint = point;
      paretoLatency = tmpLatency;
      paretoDspNum = tmpDspNum;
    } else if (tmpDspNum == paretoDspNum && tmpLatency == paretoLatency)
      paretoPoints.push_back(point);
  }

  // Print all pareto design points.
  for (auto point : paretoPoints) {
    for (auto element : point)
      os << element << ",";
    os << "pareto\n";
  }

  // Print all design points.
  for (auto point : designPoints) {
    for (auto element : point)
      os << element << ",";
    os << "non-pareto\n";
  }
}

namespace {
struct ProfileDesignSpace : public ProfileDesignSpaceBase<ProfileDesignSpace> {
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

    // Initialize an performance and resource estimator.
    auto estimator = ScaleHLSEstimator(builder, latencyMap);

    // Optimize the top function.
    for (auto func : module.getOps<FuncOp>())
      if (auto topFunction = func->getAttrOfType<BoolAttr>("top_function"))
        if (topFunction.getValue()) {
          std::string errorMessage;
          auto output = mlir::openOutputFile(profileFile, &errorMessage);
          if (!output)
            emitError(module.getLoc(), errorMessage);

          applyProfiling(func, output->os(), estimator, maxParallel);
          output->keep();
        }
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createProfileDesignSpacePass() {
  return std::make_unique<ProfileDesignSpace>();
}
