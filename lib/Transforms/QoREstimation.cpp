//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Transforms/INIReader.h"
#include "Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

/*
namespace {
class QoREstimator {
public:
  explicit QoREstimator(std::string toolConfigPath, std::string opLatencyPath) {
    INIReader toolConfig(toolConfigPath);
    if (toolConfig.ParseError())
      llvm::outs() << "error: Tool configuration file parse fail.\n";

    INIReader opLatency(opLatencyPath);
    if (opLatency.ParseError())
      llvm::outs() << "error: Op latency file parse fail.\n";

    auto freq = toolConfig.Get("config", "frequency", "200MHz");
    auto latency = opLatency.GetInteger(freq, "op", 0);
    llvm::outs() << latency << "\n";
  }

  void estimateLoop(AffineForOp loop);
  void estimateFunc(FuncOp func);
  void estimateModule(ModuleOp module);

private:
};
} // namespace

/// For now, estimation for unrolled loops are following the analytical model
/// of COMBA, which is suspected to be wrong. Meanwhile, we assume the absence
/// of function call in the loop body.
void QoREstimator::estimateLoop(AffineForOp loop) {
  auto &body = loop.getLoopBody();
  if (body.getBlocks().size() != 1)
    loop.emitError("has zero or more than one basic blocks.");

  auto paramOp = dyn_cast<hlscpp::LoopParamOp>(body.front().front());
  if (!paramOp) {
    loop.emitError("doesn't have parameter operations as front.");
    return;
  }

  // TODO: a simple AEAP scheduling.
  unsigned iterLatency = paramOp.getNonprocLatency();
  for (auto &op : body.front()) {
    if (auto subLoop = dyn_cast<mlir::AffineForOp>(op)) {
      estimateLoop(subLoop);
      auto subParamOp =
          dyn_cast<hlscpp::LoopParamOp>(subLoop.getLoopBody().front().front());
      iterLatency += subParamOp.getLatency();
    }
  }

  unsigned latency = iterLatency;
  // When loop is not completely unrolled.
  if (paramOp.getLoopBound() > 1)
    latency = iterLatency * paramOp.getLoopBound() * paramOp.getUnrollFactor();
  auto builder = Builder(paramOp.getContext());
  paramOp.setAttr("latency", builder.getUI32IntegerAttr(latency));
}

/// For now, function pipelining and task-level dataflow optimizations are not
/// considered for simplicity.
void QoREstimator::estimateFunc(FuncOp func) {
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  auto paramOp = dyn_cast<FuncParamOp>(func.front().front());
  if (!paramOp) {
    func.emitError("doesn't have parameter operations as front.");
    return;
  }

  // Recursively estimate latency of sub-elements, including functions and
  // loops. These sub-elements will be considered as a normal node in the CDFG
  // for function latency estimzation.
  for (auto &op : func.front()) {
    if (auto subFunc = dyn_cast<FuncOp>(op))
      estimateFunc(subFunc);
    else if (auto subLoop = dyn_cast<AffineForOp>(op))
      estimateLoop(subLoop);
  }

  // Estimate function latency.
  for (auto &op : func.front()) {
  }
}

void QoREstimator::estimateModule(ModuleOp module) {
  for (auto &op : module) {
    if (auto func = dyn_cast<FuncOp>(op))
      estimateFunc(func);
    else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("is unsupported operation.");
  }
}

*/

namespace {
struct QoREstimation : public QoREstimationBase<QoREstimation> {
  void runOnOperation() override {
    // QoREstimator(toolConfig, opLatency).estimateModule(getOperation());
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
