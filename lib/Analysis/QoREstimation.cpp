//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Analysis/Passes.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "INIReader.h"
#include "Visitor.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// HLSCppAnalyzer Class Definition
//===----------------------------------------------------------------------===//

bool HLSCppAnalyzer::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  if (procParam.Params[op].empty())
    procParam.init(op);

  // Recursively analyze all childs.
  analyzeBlock(body.front());

  // Pragma configurations.
  unsigned unrollFactor = 1;
  if (auto loopPragma = dyn_cast<LoopPragmaOp>(body.front().front())) {
    procParam.set(op, ProcParamKind::EnablePipeline, !loopPragma.off());
    procParam.set(op, ProcParamKind::UnrollFactor, loopPragma.factor());
    unrollFactor = loopPragma.factor();
  }

  // Loop statistics.
  if (!op.getUpperBoundMap().isSingleConstant() ||
      !op.getLowerBoundMap().isSingleConstant())
    op.emitError("has variable upper or lower bound.");

  unsigned upperBound = op.getUpperBoundMap().getSingleConstantResult();
  unsigned lowerBound = op.getLowerBoundMap().getSingleConstantResult();
  unsigned step = op.getStep();

  procParam.set(op, ProcParamKind::UpperBound, upperBound);
  procParam.set(op, ProcParamKind::LowerBound, lowerBound);
  procParam.set(op, ProcParamKind::IterNumber,
                (upperBound - lowerBound) / step / unrollFactor);

  unsigned opNum = 0;
  unsigned loopNum = 0;
  bool isPerfect = false;
  for (auto &bodyOp : op.getRegion().front()) {
    if (!isa<LoopPragmaOp>(bodyOp) && !isa<AffineYieldOp>(bodyOp)) {
      opNum += 1;
      if (auto forOp = dyn_cast<AffineForOp>(bodyOp)) {
        loopNum += 1;
        isPerfect = procParam.get(forOp, ProcParamKind::IsPerfect);
      }
    }
  }

  // Perfect nested loop.
  if (opNum == 1 && loopNum == 1 && isPerfect)
    procParam.set(op, ProcParamKind::IsPerfect, 1);
  // The inner loop.
  else if (loopNum == 0)
    procParam.set(op, ProcParamKind::IsPerfect, 1);
  else
    procParam.set(op, ProcParamKind::IsPerfect, 0);

  return true;
}

bool HLSCppAnalyzer::visitOp(AffineParallelOp op) { return true; }

bool HLSCppAnalyzer::visitOp(AffineIfOp op) { return true; }

/// This method will update all parameters except IterLatency, Latency, LUT,
/// BRAM, and DSP through static analysis.
void HLSCppAnalyzer::analyzeOperation(Operation *op) {
  if (dispatchVisitor(op))
    return;

  op->emitError("can't be correctly analyzed.");
}

void HLSCppAnalyzer::analyzeFunc(FuncOp func) {
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  procParam.init(func);

  analyzeBlock(func.front());
}

void HLSCppAnalyzer::analyzeBlock(Block &block) {
  for (auto &op : block)
    analyzeOperation(&op);
}

/// This method is a wrapper for recursively calling operation analyzer.
void HLSCppAnalyzer::analyzeModule(ModuleOp module) {
  for (auto &op : module) {
    if (auto func = dyn_cast<FuncOp>(op)) {
      analyzeFunc(func);
    } else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("is unsupported operation.");
  }
}

//===----------------------------------------------------------------------===//
// QoREstimator Class Definition
//===----------------------------------------------------------------------===//

/// Estimator constructor.
QoREstimator::QoREstimator(ProcParam &procParam, MemParam &memParam,
                           string targetSpecPath, string opLatencyPath)
    : procParam(procParam), memParam(memParam) {

  inPipeline = false;

  INIReader targetSpec(targetSpecPath);
  if (targetSpec.ParseError())
    llvm::outs() << "error: target spec file parse fail, please refer to "
                    "--help option and pass in correct file path\n";

  INIReader opLatency(opLatencyPath);
  if (opLatency.ParseError())
    llvm::outs() << "error: Op latency file parse fail, please refer to "
                    "--help option and pass in correct file path\n";

  // TODO: Support estimator initiation from profiling data.
  auto freq = targetSpec.Get("config", "frequency", "200MHz");
  auto latency = opLatency.GetInteger(freq, "op", 0);
  llvm::outs() << latency << "\n";
}

void QoREstimator::alignBlockSchedule(Block &block, OpDenseMap &opScheduleMap,
                                      unsigned opSchedule) {
  for (auto &op : block) {
    if (auto child = dyn_cast<mlir::AffineForOp>(op))
      alignBlockSchedule(child.getRegion().front(), opScheduleMap, opSchedule);
    opScheduleMap[&op] = opSchedule;
  }
}

unsigned QoREstimator::getBlockSchedule(Block &block,
                                        OpDenseMap &opScheduleMap) {
  unsigned blockSchedule = 0;

  for (auto &op : block) {
    unsigned opSchedule = 0;

    // Add the latest scheduled time among all predecessors.
    for (auto operand : op.getOperands()) {
      if (operand.getKind() != Value::Kind::BlockArgument)
        opSchedule = max(opSchedule, opScheduleMap[operand.getDefiningOp()]);
    }

    // Add latency of the current operation.
    unsigned childSchedule = 0;
    if (auto child = dyn_cast<mlir::AffineForOp>(op)) {
      opSchedule += procParam.get(child, ProcParamKind::Latency);
      if (inPipeline)
        childSchedule =
            getBlockSchedule(child.getRegion().front(), opScheduleMap);
      else
        alignBlockSchedule(child.getRegion().front(), opScheduleMap,
                           opSchedule);
    } else {
      // For now we make a simple assumption tha all standard operations has an
      // unit latency.
      // TODO: Support estimation from profiling data.
      opSchedule += 1;
    }

    opScheduleMap[&op] = opSchedule;
    blockSchedule = max({blockSchedule, childSchedule, opSchedule});
  }
  return blockSchedule;
}

bool QoREstimator::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  if (procParam.get(op, ProcParamKind::EnablePipeline)) {
    inPipeline = true;

    OpDenseMap opScheduleMap;
    auto iterLatency = getBlockSchedule(body.front(), opScheduleMap);
    procParam.set(op, ProcParamKind::IterLatency, iterLatency);

    // For now we make a simple assumption that II is equal to 1.
    auto iterNumber = procParam.get(op, ProcParamKind::IterNumber);
    procParam.set(op, ProcParamKind::PipeIterNumber, iterNumber);
    procParam.set(op, ProcParamKind::Latency, iterLatency + iterNumber - 1);

    // TODO: Calculate initial interval.
    procParam.set(op, ProcParamKind::InitInterval, 1);

  } else {
    // Recursively estimate each operation, mainly AffineFor operation for now.
    estimateBlock(body.front());

    // This simply means the current loop can be merged into the child loop
    // pipeline. This will increase the total IterNumber without changing the
    // IterLatency.
    if (inPipeline && procParam.get(op, ProcParamKind::IsPerfect)) {
      if (auto child = dyn_cast<AffineForOp>(
              std::next(op.getLoopBody().front().begin()))) {
        auto initInterval = procParam.get(child, ProcParamKind::InitInterval);
        auto iterLatency = procParam.get(child, ProcParamKind::IterLatency);
        auto pipeIterNumber =
            procParam.get(child, ProcParamKind::PipeIterNumber) *
            procParam.get(op, ProcParamKind::IterNumber);

        procParam.set(op, ProcParamKind::InitInterval, initInterval);
        procParam.set(op, ProcParamKind::IterLatency, iterLatency);
        procParam.set(op, ProcParamKind::PipeIterNumber, pipeIterNumber);
        procParam.set(op, ProcParamKind::Latency,
                      iterLatency + initInterval * (pipeIterNumber - 1));
      } else {
        inPipeline = false;
        op.emitError("is not a perfect loop.");
      }
    }

    // This branch take cares of all unpipelined or imperfect loops.
    else {
      inPipeline = false;

      OpDenseMap opScheduleMap;
      auto iterLatency = getBlockSchedule(body.front(), opScheduleMap);
      procParam.set(op, ProcParamKind::IterLatency, iterLatency);

      // For now we follow the COMBA approach for unrooled loops.
      unsigned latency = iterLatency;
      if (procParam.get(op, ProcParamKind::IterNumber) != 1)
        latency *= procParam.get(op, ProcParamKind::IterNumber) *
                   procParam.get(op, ProcParamKind::UnrollFactor);
      procParam.set(op, ProcParamKind::Latency, latency);

      // TODO: Calculate initial interval.
      procParam.set(op, ProcParamKind::InitInterval, 1);
    }
  }
  return true;
}

bool QoREstimator::visitOp(AffineParallelOp op) { return true; }

bool QoREstimator::visitOp(AffineIfOp op) { return true; }

void QoREstimator::estimateOperation(Operation *op) {
  if (dispatchVisitor(op))
    return;

  op->emitError("can't be correctly estimated.");
}

void QoREstimator::estimateFunc(FuncOp func) {
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  estimateBlock(func.front());

  OpDenseMap opScheduleMap;
  auto latency = getBlockSchedule(func.front(), opScheduleMap);
  procParam.set(func, ProcParamKind::Latency, latency);
}

void QoREstimator::estimateBlock(Block &block) {
  for (auto &op : block)
    estimateOperation(&op);
}

void QoREstimator::estimateModule(ModuleOp module) {
  for (auto &op : module) {
    if (auto func = dyn_cast<FuncOp>(op)) {
      estimateFunc(func);
    } else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("is unsupported operation.");
  }
}

//===----------------------------------------------------------------------===//
// Entry of scalehls-opt
//===----------------------------------------------------------------------===//

namespace {
struct QoREstimation : public scalehls::QoREstimationBase<QoREstimation> {
  void runOnOperation() override {
    ProcParam procParam;
    MemParam memParam;

    // Extract all static parameters and current pragma configurations.
    HLSCppAnalyzer analyzer(procParam, memParam);
    analyzer.analyzeModule(getOperation());

    // Estimate performance and resource utilization.
    QoREstimator estimator(analyzer.procParam, analyzer.memParam, targetSpec,
                           opLatency);
    estimator.estimateModule(getOperation());

    for (auto item : procParam.Params) {
      llvm::outs() << "EnablePipeline:"
                   << item.second[(unsigned)ProcParamKind::EnablePipeline]
                   << "\nUnrollFactor:"
                   << item.second[(unsigned)ProcParamKind::UnrollFactor]
                   << "\nIterNumber:"
                   << item.second[(unsigned)ProcParamKind::IterNumber]
                   << "\nIsPerfect:"
                   << item.second[(unsigned)ProcParamKind::IsPerfect]
                   << "\nInitInterval:"
                   << item.second[(unsigned)ProcParamKind::InitInterval]
                   << "\nIterLatency:"
                   << item.second[(unsigned)ProcParamKind::IterLatency]
                   << "\nPipeIterNumber:"
                   << item.second[(unsigned)ProcParamKind::PipeIterNumber]
                   << "\nLatency:"
                   << item.second[(unsigned)ProcParamKind::Latency] << "\n";
      llvm::outs() << *item.first << "\n";
    }
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
