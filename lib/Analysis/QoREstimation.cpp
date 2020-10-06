//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Analysis/Passes.h"
#include "Dialect/HLSCpp/HLSCpp.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// Utils
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// HLSCppAnalyzer Class Definition
//===----------------------------------------------------------------------===//

bool HLSCppAnalyzer::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  // Recursively analyze all childs.
  analyzeBlock(body.front());

  // Set an attribute indicating iteration number .
  if (!op.hasConstantLowerBound() || !op.hasConstantUpperBound())
    op.emitError("has variable upper or lower bound.");

  unsigned iterNumber =
      (op.getConstantUpperBound() - op.getConstantLowerBound()) /
      getUIntAttrValue(op, "unroll_factor") / op.getStep();

  setAttrValue(op, "iter_number", iterNumber);

  // Set an attribute indicating this loop is perfect or not.
  unsigned opNum = 0;
  unsigned loopNum = 0;
  bool childPerfect = false;
  for (auto &bodyOp : body.front()) {
    if (!isa<AffineYieldOp>(bodyOp))
      opNum += 1;

    if (auto child = dyn_cast<AffineForOp>(bodyOp)) {
      loopNum += 1;
      childPerfect = getBoolAttrValue(child, "perfect");
    }
  }

  if (opNum == 1 && loopNum == 1 && childPerfect)
    setAttrValue(op, "perfect", true);
  else if (loopNum == 0)
    setAttrValue(op, "perfect", true);
  else
    setAttrValue(op, "perfect", false);

  return true;
}

bool HLSCppAnalyzer::visitOp(AffineIfOp op) { return true; }

void HLSCppAnalyzer::analyzeBlock(Block &block) {
  for (auto &op : block) {
    if (dispatchVisitor(&op))
      continue;
    op.emitError("can't be correctly analyzed.");
  }
}

void HLSCppAnalyzer::analyzeFunc(FuncOp func) {
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  analyzeBlock(func.front());
}

void HLSCppAnalyzer::analyzeModule(ModuleOp module) {
  for (auto &op : module) {
    if (auto func = dyn_cast<FuncOp>(op)) {
      analyzeFunc(func);
    } else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("is unsupported operation.");
  }
}

//===----------------------------------------------------------------------===//
// HLSCppEstimator Class Definition
//===----------------------------------------------------------------------===//

/// Estimator constructor.
HLSCppEstimator::HLSCppEstimator(OpBuilder &builder, string targetSpecPath,
                                 string opLatencyPath)
    : HLSCppToolBase(builder) {

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

void HLSCppEstimator::alignBlockSchedule(Block &block,
                                         ScheduleMap &opScheduleMap,
                                         unsigned opSchedule) {
  for (auto &op : block) {
    if (auto child = dyn_cast<mlir::AffineForOp>(op))
      alignBlockSchedule(child.getRegion().front(), opScheduleMap, opSchedule);
    opScheduleMap[&op] = opSchedule;
  }
}

unsigned HLSCppEstimator::getBlockSchedule(Block &block,
                                           ScheduleMap &opScheduleMap) {
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
      opSchedule += getUIntAttrValue(child, "latency");
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

unsigned HLSCppEstimator::getBlockII(Block &block, ScheduleMap &opScheduleMap,
                                     MemAccessList &memLoadList,
                                     MemAccessList &memStoreList,
                                     unsigned initInterval) {
  for (auto &op : block) {

    // Handle load operations.
    if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
      for (auto memStore : memStoreList) {
        if (loadOp.getMemRef() == memStore.first) {
          // TODO: For now, we simply assume the distance between dependency
          // always takes 1. Thus the II is equal to the latency between
          // dependency.
          unsigned RAWLatency =
              opScheduleMap[loadOp] - opScheduleMap[memStore.second];
          initInterval = max(initInterval, RAWLatency);
        }
      }
      memLoadList.push_back(MemAccess(loadOp.getMemRef(), loadOp));
    }

    // Handle Store operations.
    else if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
      for (auto memStore : memStoreList) {
        if (loadOp.getMemRef() == memStore.first) {
          unsigned WAWLatency =
              opScheduleMap[storeOp] - opScheduleMap[memStore.second];
          initInterval = max(initInterval, WAWLatency);
        }
      }
      for (auto memLoad : memLoadList) {
        if (storeOp.getMemRef() == memLoad.first) {
          unsigned WARLatency =
              opScheduleMap[storeOp] - opScheduleMap[memLoad.second];
          initInterval = max(initInterval, WARLatency);
        }
      }
      memStoreList.push_back(MemAccess(storeOp.getMemRef(), storeOp));
    }

    else if (auto child = dyn_cast<AffineForOp>(op))
      initInterval = getBlockII(child.getRegion().front(), opScheduleMap,
                                memLoadList, memStoreList, initInterval);
  }

  return initInterval;
}

bool HLSCppEstimator::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  if (getBoolAttrValue(op, "pipeline")) {
    inPipeline = true;

    ScheduleMap opScheduleMap;
    auto iterLatency = getBlockSchedule(body.front(), opScheduleMap);
    getUIntAttrValue(op, "iter_latency");

    // For now we make a simple assumption that II is equal to 1.
    auto iterNumber = getUIntAttrValue(op, "iter_number");
    setAttrValue(op, "pipeline_iter", iterNumber);

    // Calculate initial interval.
    MemAccessList memLoadList;
    MemAccessList memStoreList;
    unsigned initInterval = 1;
    initInterval = getBlockII(body.front(), opScheduleMap, memLoadList,
                              memStoreList, initInterval);

    // Calculate initial interval caused by limited memory ports. For now, we
    // just consider the memory access inside of the pipeline region, aks the
    // extra memory ports caused by unroll optimization out of the pipeline
    // region are not calculated.
    MemPortMap memLoadPortMap;
    MemPortMap memStorePortMap;
    for (auto &op : body.front()) {
    }

    setAttrValue(op, "pipeline_II", initInterval);
    setAttrValue(op, "latency", iterLatency + initInterval * (iterNumber - 1));
  }

  // If the loop is not pipelined, the estimation is much different and requires
  // to recursively enter each child loop for estimating the overall latency of
  // the current loop.
  else {
    // Recursively estimate each operation, mainly AffineFor operation will be
    // differently handled for now.
    estimateBlock(body.front());

    // This simply means the current loop can be merged into the child loop
    // pipeline. This will increase the total IterNumber without changing the
    // IterLatency.
    if (inPipeline && getBoolAttrValue(op, "perfect")) {
      if (auto child = dyn_cast<AffineForOp>(
              std::next(op.getLoopBody().front().begin()))) {
        auto initInterval = getUIntAttrValue(child, "pipeline_II");
        auto iterLatency = getUIntAttrValue(child, "iter_latency");
        auto pipeIterNumber = getUIntAttrValue(child, "pipeline_iter") *
                              getUIntAttrValue(op, "iter_number");

        setAttrValue(op, "pipeline_II", initInterval);
        setAttrValue(op, "iter_latency", iterLatency);
        setAttrValue(op, "pipeline_iter", pipeIterNumber);

        setAttrValue(op, "latency",
                     iterLatency + initInterval * (pipeIterNumber - 1));
      } else {
        inPipeline = false;
        op.emitError("is not a perfect loop.");
      }
    }

    // This branch take cares of all unpipelined or imperfect loops.
    else {
      inPipeline = false;

      ScheduleMap opScheduleMap;
      auto iterLatency = getBlockSchedule(body.front(), opScheduleMap);
      setAttrValue(op, "iter_latency", iterLatency);

      // For now we follow the COMBA approach for unrooled loops.
      unsigned latency = iterLatency;
      if (getUIntAttrValue(op, "iter_number") != 1)
        latency *= getUIntAttrValue(op, "iter_number") *
                   getUIntAttrValue(op, "unroll_factor");
      setAttrValue(op, "latency", latency);

      // TODO: Calculate initial interval.
      setAttrValue(op, "iter_latency", (unsigned)1);
    }
  }
  return true;
}

bool HLSCppEstimator::visitOp(AffineIfOp op) { return true; }

void HLSCppEstimator::estimateBlock(Block &block) {
  for (auto &op : block) {
    if (dispatchVisitor(&op))
      continue;
    op.emitError("can't be correctly analyzed.");
  }
}

void HLSCppEstimator::estimateFunc(FuncOp func) {
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  estimateBlock(func.front());

  ScheduleMap opScheduleMap;
  auto latency = getBlockSchedule(func.front(), opScheduleMap);
  setAttrValue(func, "latency", latency);
}

void HLSCppEstimator::estimateModule(ModuleOp module) {
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
    auto builder = OpBuilder(getOperation());

    // Extract all static parameters and current pragma configurations.
    HLSCppAnalyzer analyzer(builder);
    analyzer.analyzeModule(getOperation());

    // Estimate performance and resource utilization.
    HLSCppEstimator estimator(builder, targetSpec, opLatency);
    estimator.estimateModule(getOperation());
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
