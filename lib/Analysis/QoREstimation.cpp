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
// HLSCppAnalyzer Class Definition
//===----------------------------------------------------------------------===//

bool HLSCppAnalyzer::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  // Recursively analyze all childs.
  analyzeBlock(body.front());

  // Set an attribute indicating trip count.
  if (!op.hasConstantLowerBound() || !op.hasConstantUpperBound())
    op.emitError("has variable upper or lower bound.");

  unsigned tripCount =
      (op.getConstantUpperBound() - op.getConstantLowerBound()) / op.getStep();
  setAttrValue(op, "trip_count", tripCount);

  // Set attributes indicating this loop is perfect or not.
  unsigned opNum = 0;
  unsigned childNum = 0;
  bool childPerfect = false;
  for (auto &bodyOp : body.front()) {
    if (!isa<AffineYieldOp>(bodyOp))
      opNum += 1;
    if (auto child = dyn_cast<AffineForOp>(bodyOp)) {
      childNum += 1;
      childPerfect = getBoolAttrValue(child, "perfect");
    }
  }

  if (opNum == 1 && childNum == 1 && childPerfect)
    setAttrValue(op, "perfect", true);
  else if (childNum == 0)
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

void HLSCppEstimator::setBlockSchedule(Block &block, unsigned opSchedule,
                                       OpScheduleMap &opScheduleMap) {
  for (auto &op : block) {
    if (auto child = dyn_cast<AffineForOp>(op))
      setBlockSchedule(child.getRegion().front(), opSchedule, opScheduleMap);
    opScheduleMap[&op] = opSchedule;
  }
}

unsigned HLSCppEstimator::getBlockSchedule(Block &block, bool innerUnroll,
                                           OpScheduleMap &opScheduleMap) {
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
    if (auto child = dyn_cast<AffineForOp>(op)) {
      if (innerUnroll) {
        setAttrValue(child, "unroll", true);
        setAttrValue(child, "flatten", false);
        childSchedule = getBlockSchedule(child.getRegion().front(),
                                         /*innerUnroll=*/true, opScheduleMap);
      } else {
        // Two extra clock cycles will be required to enter and exit child loop.
        opSchedule += getUIntAttrValue(child, "latency") + 2;
        setBlockSchedule(child.getRegion().front(), opSchedule, opScheduleMap);
      }
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

void HLSCppEstimator::getPipelineInfo(Block &block, PipelineInfo &info) {
  for (auto &op : block) {
    // Handle load operations and RAW dependencies.
    if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
      for (auto prevOp : info.memStoreDict[loadOp.getMemRef()]) {
        unsigned RAWLatency =
            info.opScheduleMap[loadOp] - info.opScheduleMap[prevOp];
        info.II = max(info.II, RAWLatency);
      }
      info.memLoadDict[loadOp.getMemRef()].push_back(loadOp);
    }

    // Handle Store operations and RAW/WAW dependencies.
    else if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
      for (auto prevOp : info.memLoadDict[storeOp.getMemRef()]) {
        unsigned WARLatency =
            info.opScheduleMap[storeOp] - info.opScheduleMap[prevOp];
        info.II = max(info.II, WARLatency);
      }
      for (auto prevOp : info.memStoreDict[storeOp.getMemRef()]) {
        unsigned WAWLatency =
            info.opScheduleMap[storeOp] - info.opScheduleMap[prevOp];
        info.II = max(info.II, WAWLatency);
      }
      info.memStoreDict[storeOp.getMemRef()].push_back(storeOp);
    }

    // Recursively handle child loops.
    else if (auto child = dyn_cast<AffineForOp>(op))
      getPipelineInfo(child.getRegion().front(), info);
  }
}

template <typename OpType>
void HLSCppEstimator::getAccessNum(OpType op, ArrayOp arrayOp) {
  InductionInfoList inductionInfoList;
  SmallVector<AffineExpr, 8> replacements;
  SmallVector<unsigned, 8> unrollDims;
  unsigned unrollTripCount = 1;

  // Collect loop information, including induction & unroll information,
  // and etc. Note that we assume all operands are dims.
  unsigned operandIdx = 0;
  for (auto operand : op.getMapOperands()) {
    if (auto forOp = getForInductionVarOwner(operand)) {
      auto lowerBound = forOp.getConstantLowerBound();
      auto upperBound = forOp.getConstantUpperBound();
      auto step = forOp.getStep();
      inductionInfoList.push_back(InductionInfo(lowerBound, upperBound, step));

      auto unroll = getBoolAttrValue(forOp, "unroll");
      auto tripCount = getUIntAttrValue(forOp, "trip_count");
      if (unroll) {
        unrollDims.push_back(operandIdx);
        unrollTripCount *= tripCount;
      }

      if (unroll)
        replacements.push_back(getConstExpr(lowerBound));
      else
        replacements.push_back(getDimExpr(operandIdx));
    } else
      op.emitError("has index constructed by dynamic values.");
    operandIdx += 1;
  }

  // Initialize number of accesses for each partition of each array
  // dimension as zero.
  AccessNumList accessNumList;
  for (auto dim : unrollDims) {
    AccessNum accessNum;
    if (arrayOp.partition()) {
      for (unsigned i = 0; i < getPartitionFactor(&arrayOp, dim); ++i)
        accessNum.push_back(0);
    } else
      accessNum.push_back(0);
    accessNumList.push_back(accessNum);
  }

  // Trace all possible index to find potential violations regarding
  // memory ports number. Violations may cause increasement of iteration
  // latency or initial interval. This will update the accessNumList.
  for (unsigned i = 0; i < unrollTripCount; ++i) {

    // Calculate number of accesses for each partition of each array dimension.
    unsigned idx = 0;
    for (auto dim : unrollDims) {
      AffineExpr expr = op.getAffineMap().getResult(dim);
      auto indexExpr = expr.replaceDimsAndSymbols(replacements, {});

      // Calculate which partition is falled in.
      if (arrayOp.partition()) {
        auto type = getPartitionType(&arrayOp, dim);
        auto factor = getPartitionFactor(&arrayOp, dim);
        if (type == "cyclic")
          indexExpr = indexExpr % getConstExpr(factor);
        else if (type == "block") {
          auto dimSize = arrayOp.getType().cast<ShapedType>().getShape()[dim];
          indexExpr =
              indexExpr.floorDiv(getConstExpr((dimSize + factor - 1) / factor));
        }
      } else
        indexExpr = getConstExpr(0);

      // According to partition information.
      if (auto constExpr = indexExpr.dyn_cast<AffineConstantExpr>()) {
        auto partitionId = constExpr.getValue();
        accessNumList[idx][partitionId] += 1;
      } else {
      }
      idx += 1;
    }

    // Update replacement.
    unsigned order = 0;
    for (auto dim : unrollDims) {
      auto value = replacements[dim].cast<AffineConstantExpr>().getValue();

      // The little-end value will always increase with a stride of
      // step.
      if (order == 0)
        value += inductionInfoList[dim].step;

      // The value of the current dimension should return to lowerBound
      // if is greater or equal to upperBound.
      if (value >= inductionInfoList[dim].upperBound) {
        value = inductionInfoList[dim].lowerBound;

        // Update the value of the next dimension.
        if (order < unrollDims.size() - 1) {
          auto nextDim = unrollDims[order + 1];
          auto nextValue =
              replacements[nextDim].cast<AffineConstantExpr>().getValue();
          nextValue += inductionInfoList[nextDim].step;
          replacements[nextDim] = getConstExpr(nextValue);
        }
      }

      // Update the value of the current dimension.
      replacements[dim] = getConstExpr(value);
      order += 1;
    }
  }

  // update
  for (auto accessNum : accessNumList) {
    llvm::outs() << "new dim\n";
    for (auto num : accessNum) {
      llvm::outs() << num << "\n";
    }
  }
}

bool HLSCppEstimator::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  // If loop is unrolled, all inner loops will be unrolled accordingly.
  if (getBoolAttrValue(op, "unroll")) {
    setAttrValue(op, "pipeline", false);
    setAttrValue(op, "flatten", false);
    op.emitRemark("all inner loops are automatically unrolled.");

    OpScheduleMap opScheduleMap;
    auto latency =
        getBlockSchedule(body.front(), /*innerUnroll=*/true, opScheduleMap);
    setAttrValue(op, "latency", latency);
    return true;
  }

  // If loop is pipelined, the pipelined loop will be estimated as a whole since
  // all loops inside of a pipeline will be automatically fully unrolled.
  if (getBoolAttrValue(op, "pipeline")) {
    setAttrValue(op, "flatten", true);
    op.emitRemark("all inner loops are automatically unrolled.");

    // Calculate latency of each iteration.
    PipelineInfo pipelineInfo(/*baseII=*/1);
    auto iterLatency = getBlockSchedule(body.front(), /*innerUnroll=*/true,
                                        pipelineInfo.opScheduleMap);
    setAttrValue(op, "iter_latency", iterLatency);

    // For now we make a simple assumption that II is equal to 1.
    auto tripCount = getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", tripCount);

    // Collect pipeline information including II and memory access information.
    getPipelineInfo(body.front(), pipelineInfo);

    // Calculate latency and II considering memory ports violations.
    for (auto &memLoad : pipelineInfo.memLoadDict) {
      auto arrayOp = dyn_cast<ArrayOp>(memLoad.first.getDefiningOp());
      if (!arrayOp)
        op.emitError("is accessing an array that is not defined by ArrayOp.");

      for (auto loadOp : memLoad.second) {
        getAccessNum<AffineLoadOp>(cast<AffineLoadOp>(loadOp), arrayOp);
      }
    }

    setAttrValue(op, "init_interval", pipelineInfo.II);
    setAttrValue(op, "latency",
                 iterLatency + pipelineInfo.II * (tripCount - 1));
    return true;
  }

  // If the loop is not pipelined or unrolled, the estimation is different and
  // requires to recursively enter each child loop for estimating the overall
  // latency of the current loop.
  estimateBlock(body.front());

  // This simply means the current loop can be flattened into the child loop
  // pipeline. This will increase the flattened loop trip count without
  // changing the iteration latency. Note that this will be propogated above
  // until meeting an imperfect loop.
  if (getBoolAttrValue(op, "perfect")) {
    if (auto child = dyn_cast<AffineForOp>(op.getLoopBody().front().front())) {
      if (getBoolAttrValue(child, "flatten")) {
        setAttrValue(op, "flatten", true);
        op.emitRemark("this loop is flattened into its child loop.");

        auto II = getUIntAttrValue(child, "init_interval");
        auto iterLatency = getUIntAttrValue(child, "iter_latency");
        auto flattenTripCount = getUIntAttrValue(child, "flatten_trip_count") *
                                getUIntAttrValue(op, "trip_count");

        setAttrValue(op, "init_interval", II);
        setAttrValue(op, "iter_latency", iterLatency);
        setAttrValue(op, "flatten_trip_count", flattenTripCount);

        setAttrValue(op, "latency", iterLatency + II * (flattenTripCount - 1));
        return true;
      }
    }
  }

  // Default case, aka !unroll && !pipeline && !(perfect && child.flatten).
  setAttrValue(op, "flatten", false);

  OpScheduleMap opScheduleMap;
  auto iterLatency =
      getBlockSchedule(body.front(), /*innerUnroll=*/false, opScheduleMap);
  setAttrValue(op, "iter_latency", iterLatency);

  unsigned latency = iterLatency * getUIntAttrValue(op, "trip_count");
  setAttrValue(op, "latency", latency);
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

  OpScheduleMap opScheduleMap;
  auto latency =
      getBlockSchedule(func.front(), /*innerUnroll=*/false, opScheduleMap);
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
