//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Analysis/Passes.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/IR/PatternMatch.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// HLSCppAnalyzer Class Definition
//===----------------------------------------------------------------------===//

bool HLSCppAnalyzer::visitOp(AffineForOp op) {
  // If the current loop is annotated as unroll, all inner loops and itself are
  // automatically unrolled.
  if (getBoolAttrValue(op, "unroll")) {
    op.emitRemark("this loop and all inner loops are automatically unrolled.");
    op.walk([&](AffineForOp forOp) {
      if (forOp.getLoopBody().getBlocks().size() != 1)
        op.emitError("has zero or more than one basic blocks.");
      loopUnrollFull(forOp);
    });
    return true;
  }

  // If the current loop is annotated as pipeline, all intter loops are
  // automatically unrolled.
  if (getBoolAttrValue(op, "pipeline")) {
    op.emitRemark("all inner loops are automatically unrolled.");
    op.walk([&](AffineForOp forOp) {
      if (forOp != op) {
        if (forOp.getLoopBody().getBlocks().size() != 1)
          op.emitError("has zero or more than one basic blocks.");
        loopUnrollFull(forOp);
      }
    });
  }

  // We assume loop contains a single basic block.
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  // Recursively analyze all inner loops.
  analyzeBlock(body.front());

  // Set an attribute indicating the trip count. For now, we assume all loops
  // have static loop bound.
  if (!op.hasConstantLowerBound() || !op.hasConstantUpperBound())
    op.emitError("has variable upper or lower bound.");

  unsigned tripCount =
      (op.getConstantUpperBound() - op.getConstantLowerBound()) / op.getStep();
  setAttrValue(op, "trip_count", tripCount);

  // Set attributes indicating this loop can be flatten or not.
  unsigned opNum = 0;
  unsigned forNum = 0;
  bool innerFlatten = false;

  for (auto &bodyOp : body.front()) {
    if (!isa<AffineYieldOp>(bodyOp))
      opNum += 1;
    if (isa<AffineForOp>(bodyOp)) {
      forNum += 1;
      innerFlatten = getBoolAttrValue(&bodyOp, "flatten");
    }
  }

  if (forNum == 0 || (opNum == 1 && innerFlatten))
    setAttrValue(op, "flatten", true);
  else
    setAttrValue(op, "flatten", false);

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

/// Calculate the partition index according to the affine map of a memory access
/// operation, and store the results as attribute.
int32_t HLSCppEstimator::getPartitionIdx(AffineMap map, ArrayOp op) {
  int32_t partitionIdx = 0;
  unsigned accumFactor = 1;
  unsigned dim = 0;
  for (auto expr : map.getResults()) {
    auto idxExpr = getConstExpr(0);
    unsigned factor = 1;
    if (op.partition()) {
      auto type = getPartitionType(op, dim);
      factor = getPartitionFactor(op, dim);

      if (type == "cyclic")
        idxExpr = expr % getConstExpr(factor);
      else if (type == "block") {
        auto size = op.getType().cast<ShapedType>().getShape()[dim];
        idxExpr = expr.floorDiv(getConstExpr((size + factor - 1) / factor));
      }
    }
    if (auto constExpr = idxExpr.dyn_cast<AffineConstantExpr>()) {
      if (dim == 0)
        partitionIdx = constExpr.getValue();
      else
        partitionIdx += constExpr.getValue() * accumFactor;
    } else {
      partitionIdx = -1;
      break;
    }

    accumFactor *= factor;
    dim += 1;
  }
  return partitionIdx;
}

void HLSCppEstimator::getMemInfo(Block &block, MemInfo &info) {
  for (auto &op : block) {
    if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
      auto arrayOp = cast<ArrayOp>(loadOp.getMemRef().getDefiningOp());
      info.memLoadDict[arrayOp].push_back(loadOp);
      setAttrValue(loadOp, "partition_index",
                   getPartitionIdx(loadOp.getAffineMap(), arrayOp));
      // TODO: consider RAW, WAR, WAW dependency for scheduling.

    } else if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
      auto arrayOp = cast<ArrayOp>(storeOp.getMemRef().getDefiningOp());
      info.memLoadDict[arrayOp].push_back(storeOp);
      setAttrValue(storeOp, "partition_index",
                   getPartitionIdx(storeOp.getAffineMap(), arrayOp));
    }
  }
}

unsigned HLSCppEstimator::getLoadStoreSchedule(Operation *op, ArrayOp arrayOp,
                                               MemPortList &memPortList,
                                               unsigned begin) {
  auto partitionIdx = getIntAttrValue(op, "partition_index");

  // Try to avoid memory port violation until a legal schedule is found.
  // Since an infinite length pipeline can be generated, this while loop can
  // be proofed to have an end.
  while (true) {
    auto partitionPortNum = memPortList[begin][arrayOp];
    bool memEmpty = false;
    // Partition factor.
    unsigned factor = 1;

    // If the memory has not been occupied by the current stage, it should
    // be initialized according to its storage type. Note that each
    // partition should have one PortNum structure.
    if (partitionPortNum.empty()) {
      memEmpty = true;

      if (getBoolAttrValue(arrayOp, "partition")) {
        for (unsigned dim = 0;
             dim < arrayOp.getType().cast<ShapedType>().getRank(); ++dim)
          factor *= getPartitionFactor(arrayOp, dim);
      }

      auto storagetType = getStrAttrValue(arrayOp, "storage_type");
      for (unsigned p = 0; p < factor; ++p) {
        unsigned rdPort = 0;
        unsigned wrPort = 0;
        unsigned rdwrPort = 0;

        if (storagetType == "ram_s2p")
          rdPort = 1, wrPort = 1;
        else if (storagetType == "ram_2p" || storagetType == "ram_t2p")
          rdwrPort = 2;
        else if (storagetType == "ram_1p")
          rdwrPort = 1;
        else {
          rdwrPort = 2;
          arrayOp.emitError("unsupported storage type.");
        }
        PortNum portNum(rdPort, wrPort, rdwrPort);
        partitionPortNum.push_back(portNum);
      }
    }

    // TODO: When partition index can't be determined, this operation will be
    // considered to occupy all ports.
    if (partitionIdx == -1) {
      if (memEmpty) {
        for (unsigned p = 0; p < factor; ++p) {
          partitionPortNum[partitionIdx].rdPort = 0;
          partitionPortNum[partitionIdx].wrPort = 0;
          partitionPortNum[partitionIdx].rdwrPort = 0;
        }
        memPortList[begin][arrayOp] = partitionPortNum;
        break;
      } else {
        if (++begin >= memPortList.size()) {
          MemPort memPort;
          memPortList.push_back(memPort);
        }
      }
    }

    // Find whether the current schedule meets memory port limitation. If
    // not, the schedule will increase by 1.
    if (partitionPortNum[partitionIdx].rdPort > 0) {
      partitionPortNum[partitionIdx].rdPort -= 1;
      memPortList[begin][arrayOp] = partitionPortNum;
      break;
    } else if (partitionPortNum[partitionIdx].rdwrPort > 0) {
      partitionPortNum[partitionIdx].rdwrPort -= 1;
      memPortList[begin][arrayOp] = partitionPortNum;
      break;
    } else {
      if (++begin >= memPortList.size()) {
        MemPort memPort;
        memPortList.push_back(memPort);
      }
    }
  }
  return begin;
}

unsigned HLSCppEstimator::getBlockSchedule(Block &block, MemInfo memInfo) {
  unsigned blockEnd = 0;
  MemPortList memPortList;

  for (auto &op : block) {
    // Find the latest predecessor dominating the current operation. This should
    // be considered as the earliest stage that the current operation can be
    // scheduled.
    unsigned begin = 0;
    unsigned end = 0;
    for (auto operand : op.getOperands()) {
      if (operand.getKind() != Value::Kind::BlockArgument)
        begin = max(begin,
                    getUIntAttrValue(operand.getDefiningOp(), "schedule_end"));
    }

    // Insert new pipeline stages.
    while (begin >= memPortList.size()) {
      MemPort memPort;
      memPortList.push_back(memPort);
    }

    // Handle load operations, ensure the current schedule meets memory port
    // limitation.
    if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
      auto arrayOp = cast<ArrayOp>(loadOp.getMemRef().getDefiningOp());
      begin = getLoadStoreSchedule(loadOp, arrayOp, memPortList, begin);
      end = begin + 1;
    }
    // Handle store operations.
    else if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
      auto arrayOp = cast<ArrayOp>(storeOp.getMemRef().getDefiningOp());
      begin = getLoadStoreSchedule(storeOp, arrayOp, memPortList, begin);
      end = begin + 1;
    }
    // Handle loop operations.
    else if (auto forOp = dyn_cast<AffineForOp>(op)) {
      // Child loop is considered as a large node, and two extra clock cycles
      // will be required to enter and exit the child loop.
      end = begin + getUIntAttrValue(forOp, "latency") + 2;
    }
    // Default case. All normal expressions and operations will be handled by
    // this branch.
    else {
      // TODO: For now, we assume all operations take one clock cycle to
      // execute, should support to accept profiling data.
      end = begin + 1;
    }

    setAttrValue(&op, "schedule_begin", begin);
    setAttrValue(&op, "schedule_end", end);
    blockEnd = max(blockEnd, end);
  }
  return blockEnd;
}

bool HLSCppEstimator::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  // If the current loop is annotated as pipeline, extra dependency and II
  // analysis will be executed.
  if (getBoolAttrValue(op, "pipeline")) {
    MemInfo memInfo;
    getMemInfo(body.front(), memInfo);

    // Calculate latency of each iteration.
    auto iterLatency = getBlockSchedule(body.front(), memInfo);
    setAttrValue(op, "iter_latency", iterLatency);

    // For now we make a simple assumption that II is equal to 1.
    auto tripCount = getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", tripCount);

    setAttrValue(op, "init_interval", (unsigned)1);
    setAttrValue(op, "latency", iterLatency + 1 * (tripCount - 1));
    return true;
  }

  // Recursively estimate all inner loops.
  estimateBlock(body.front());

  // This simply means the current loop can be flattened into the child loop
  // pipeline. This will increase the flattened loop trip count without
  // changing the iteration latency. Note that this will be propogated above
  // until meeting an imperfect loop.
  if (getBoolAttrValue(op, "flatten")) {
    auto child = cast<AffineForOp>(op.getLoopBody().front().front());
    op.emitRemark("this loop is flattened into its inner loop.");

    auto II = getUIntAttrValue(child, "init_interval");
    auto iterLatency = getUIntAttrValue(child, "iter_latency");
    auto flattenTripCount = getUIntAttrValue(child, "flatten_trip_count") *
                            getUIntAttrValue(op, "trip_count");

    setAttrValue(op, "init_interval", II);
    setAttrValue(op, "iter_latency", iterLatency);
    setAttrValue(op, "flatten_trip_count", flattenTripCount);

    setAttrValue(op, "latency", iterLatency + II * (flattenTripCount - 1));
  }
  // Default case, aka !pipeline && !flatten.
  else {
    MemInfo memInfo;
    getMemInfo(body.front(), memInfo);

    auto iterLatency = getBlockSchedule(body.front(), memInfo);
    setAttrValue(op, "iter_latency", iterLatency);

    unsigned latency = iterLatency * getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "latency", latency);
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

  MemInfo memInfo;
  getMemInfo(func.front(), memInfo);

  auto latency = getBlockSchedule(func.front(), memInfo);
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

    // Canonicalize the analyzed IR.
    OwningRewritePatternList patterns;

    auto *context = &getContext();
    for (auto *op : context->getRegisteredOperations())
      op->getCanonicalizationPatterns(patterns, context);

    Operation *op = getOperation();
    applyPatternsAndFoldGreedily(op->getRegions(), patterns);

    // Estimate performance and resource utilization.
    HLSCppEstimator estimator(builder, targetSpec, opLatency);
    estimator.estimateModule(getOperation());
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
