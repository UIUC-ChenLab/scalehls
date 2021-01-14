//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "Transforms/Passes.h"
#include "mlir/Analysis/LoopAnalysis.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct MultipleLevelDSE : public MultipleLevelDSEBase<MultipleLevelDSE> {
  void runOnOperation() override;
};
} // namespace

static void getSeqLoopBand(AffineForOp forOp,
                           SmallVector<AffineForOp, 4> &loopBand) {
  auto currentLoop = forOp;
  while (true) {
    auto childLoopNum = getChildLoopNum(currentLoop);

    // Only if the current loop has zero or one child, it will be pushed back to
    // the loop band.
    if (childLoopNum == 1)
      loopBand.push_back(currentLoop);
    else {
      loopBand.push_back(currentLoop);
      break;
    }

    // Update the current loop.
    currentLoop = *currentLoop.getOps<AffineForOp>().begin();
  }
}

static int64_t getChildLoopsTripCount(AffineForOp forOp) {
  int64_t count = 0;
  for (auto loop : forOp.getOps<AffineForOp>()) {
    auto innerCount = getChildLoopsTripCount(loop);
    if (auto trip = getConstantTripCount(loop))
      count += trip.getValue() * innerCount;
    else
      count += innerCount;
  }

  // If the current loop is innermost loop, count should be one.
  return max(count, (int64_t)1);
}

/// This is a temporary approach.
static void applyMultipleLevelDSE(FuncOp func, OpBuilder &builder,
                                  LatencyMap &latencyMap, int64_t numDSP) {
  //===--------------------------------------------------------------------===//
  // Try function pipelining
  //===--------------------------------------------------------------------===//

  // HLSCppEstimator estimator(func, latencyMap);
  // estimator.estimateFunc();

  // builder.setInsertionPoint(func);

  //===--------------------------------------------------------------------===//
  //
  //===--------------------------------------------------------------------===//

  for (auto loop : func.getOps<AffineForOp>()) {
    SmallVector<AffineForOp, 4> loopBand;
    getSeqLoopBand(loop, loopBand);

    llvm::outs() << getChildLoopsTripCount(loopBand.back()) << "\n";
  }
}

void MultipleLevelDSE::runOnOperation() {
  auto module = getOperation();
  auto builder = OpBuilder(module);

  // Read configuration file.
  INIReader spec(targetSpec);
  if (spec.ParseError())
    module->emitError(
        "target spec file parse fail, please pass in correct file path\n");

  // Collect profiling data, where default values are based on PYNQ-Z1 board.
  LatencyMap latencyMap;
  getLatencyMap(spec, latencyMap);
  auto numDSP = spec.GetInteger("specification", "dsp", 220);

  for (auto func : module.getOps<FuncOp>())
    if (auto topFunction = func->getAttrOfType<BoolAttr>("top_function"))
      if (topFunction.getValue())
        applyMultipleLevelDSE(func, builder, latencyMap, numDSP);
}

std::unique_ptr<mlir::Pass> scalehls::createMultipleLevelDSEPass() {
  return std::make_unique<MultipleLevelDSE>();
}
