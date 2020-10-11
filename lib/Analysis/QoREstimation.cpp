//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Analysis/Passes.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/PatternMatch.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// HLSCppAnalyzer Class Definition
//===----------------------------------------------------------------------===//

bool HLSCppAnalyzer::visitOp(ArrayOp op) {
  unsigned factor = 1;
  if (getBoolAttrValue(op, "partition")) {
    for (unsigned i = 0, e = op.getType().cast<ShapedType>().getRank(); i < e;
         ++i)
      factor *= getPartitionFactor(op, i);
  }
  setAttrValue(op, "partition_num", factor);
  return true;
}

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

void HLSCppEstimator::getMemAccessInfo(Block &block, MemAccessDict &dict) {
  for (auto &op : block) {
    if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
      auto arrayOp = cast<ArrayOp>(loadOp.getMemRef().getDefiningOp());
      dict[arrayOp].push_back(loadOp);
      setAttrValue(loadOp, "partition_index",
                   getPartitionIdx(loadOp.getAffineMap(), arrayOp));
    } else if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
      auto arrayOp = cast<ArrayOp>(storeOp.getMemRef().getDefiningOp());
      dict[arrayOp].push_back(storeOp);
      setAttrValue(storeOp, "partition_index",
                   getPartitionIdx(storeOp.getAffineMap(), arrayOp));
    }
  }
}

unsigned HLSCppEstimator::getLoadStoreSchedule(Operation *op, ArrayOp arrayOp,
                                               MemPortDictList &list,
                                               unsigned begin) {
  auto partitionIdx = getIntAttrValue(op, "partition_index");
  auto partitionNum = getUIntAttrValue(arrayOp, "partition_num");
  auto storageType = getStrAttrValue(arrayOp, "storage_type");

  // Try to avoid memory port violation until a legal schedule is found.
  // Since an infinite length pipeline can be generated, this while loop can
  // be proofed to have an end.
  while (true) {
    auto memPort = list[begin][arrayOp];
    bool memPortEmpty = memPort.empty();

    // If the memory has not been occupied by the current stage, it should
    // be initialized according to its storage type. Note that each
    // partition should have one PortNum structure.
    if (memPortEmpty) {
      for (unsigned p = 0; p < partitionNum; ++p) {
        unsigned rdPort = 0;
        unsigned wrPort = 0;
        unsigned rdwrPort = 0;

        if (storageType == "ram_s2p")
          rdPort = 1, wrPort = 1;
        else if (storageType == "ram_2p" || storageType == "ram_t2p")
          rdwrPort = 2;
        else if (storageType == "ram_1p")
          rdwrPort = 1;
        else {
          rdwrPort = 2;
          arrayOp.emitError("unsupported storage type.");
        }
        PortInfo portInfo(rdPort, wrPort, rdwrPort);
        memPort.push_back(portInfo);
      }
    }

    // TODO: When partition index can't be determined, this operation will be
    // considered to occupy all ports.
    if (partitionIdx == -1) {
      if (memPortEmpty) {
        for (unsigned p = 0; p < partitionNum; ++p) {
          memPort[p].rdPort = 0;
          memPort[p].wrPort = 0;
          memPort[p].rdwrPort = 0;
        }
        list[begin][arrayOp] = memPort;
        break;
      } else {
        if (++begin >= list.size()) {
          MemPortDict memPortDict;
          list.push_back(memPortDict);
        }
      }
    }

    // Find whether the current schedule meets memory port limitation. If
    // not, the schedule will increase by 1.
    PortInfo portInfo = memPort[partitionIdx];
    if (isa<AffineLoadOp>(op) && portInfo.rdPort > 0) {
      memPort[partitionIdx].rdPort -= 1;
      list[begin][arrayOp] = memPort;
      break;
    } else if (isa<AffineStoreOp>(op) && portInfo.wrPort > 0) {
      memPort[partitionIdx].wrPort -= 1;
      list[begin][arrayOp] = memPort;
      break;
    } else if (portInfo.rdwrPort > 0) {
      memPort[partitionIdx].rdwrPort -= 1;
      list[begin][arrayOp] = memPort;
      break;
    } else {
      if (++begin >= list.size()) {
        MemPortDict memPortDict;
        list.push_back(memPortDict);
      }
    }
  }
  return begin;
}

unsigned HLSCppEstimator::getBlockSchedule(Block &block) {
  unsigned blockEnd = 0;
  MemPortDictList list;

  for (auto &op : block) {
    // Find the latest predecessor dominating the current operation. This should
    // be considered as the earliest stage that the current operation can be
    // scheduled.
    unsigned begin = 0;
    unsigned end = 0;
    for (auto operand : op.getOperands()) {
      if (operand.getKind() != Value::Kind::BlockArgument)
        begin = max(getUIntAttrValue(operand.getDefiningOp(), "schedule_end"),
                    begin);
    }

    // Insert new pipeline stages.
    while (begin >= list.size()) {
      MemPortDict memPortDict;
      list.push_back(memPortDict);
    }

    // Handle load operations, ensure the current schedule meets memory port
    // limitation.
    if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
      auto arrayOp = cast<ArrayOp>(loadOp.getMemRef().getDefiningOp());
      begin = getLoadStoreSchedule(loadOp, arrayOp, list, begin);
      end = begin + 1;
    }
    // Handle store operations.
    else if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
      auto arrayOp = cast<ArrayOp>(storeOp.getMemRef().getDefiningOp());
      begin = getLoadStoreSchedule(storeOp, arrayOp, list, begin);
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

static int32_t getDimId(Operation *op, Value value) {
  int32_t dimId = -1;
  if (auto loadOp = dyn_cast<AffineLoadOp>(op)) {
    auto operand = std::find(loadOp.getMapOperands().begin(),
                             loadOp.getMapOperands().end(), value);
    if (operand != loadOp.getMapOperands().end())
      dimId = operand.getIndex();
  } else if (auto storeOp = dyn_cast<AffineStoreOp>(op)) {
    auto operand = std::find(storeOp.getMapOperands().begin(),
                             storeOp.getMapOperands().end(), value);
    if (operand != storeOp.getMapOperands().end())
      dimId = operand.getIndex();
  }
  return dimId;
}

unsigned HLSCppEstimator::getMinII(AffineForOp forOp, MemAccessDict dict) {
  auto value = forOp.getInductionVar();
  unsigned II = 1;

  for (auto &pair : dict) {
    auto arrayOp = cast<ArrayOp>(pair.first);
    unsigned partitionNum = getUIntAttrValue(arrayOp, "partition_num");
    auto storageType = getStrAttrValue(arrayOp, "storage_type");

    SmallVector<unsigned, 16> readNum;
    SmallVector<unsigned, 16> writeNum;
    for (unsigned i = 0, e = partitionNum; i < e; ++i) {
      readNum.push_back(0);
      writeNum.push_back(0);
    }

    auto memAccess = pair.second;

    unsigned opIdx = 0;
    for (auto op : memAccess) {
      // Calculate resource-aware minimal II.
      auto partitionIdx = getIntAttrValue(op, "partition_index");
      if (partitionIdx == -1) {
        unsigned accessNum = 1;
        if (storageType == "ram_s2p")
          accessNum = 1;
        else if (storageType == "ram_2p" || "ram_t2p")
          accessNum = 2;
        else if (storageType == "ram_1p")
          accessNum = 1;

        // The rationale here is an undetermined partition access will introduce
        // a large mux which will avoid Vivado HLS to process any concurrent
        // data access among all partitions. This is equivalent to increase read
        // or write number for all partitions.
        for (unsigned p = 0, e = partitionNum; p < e; ++p) {
          if (isa<AffineLoadOp>(op))
            readNum[p] += accessNum;
          else if (isa<AffineStoreOp>(op))
            writeNum[p] += accessNum;
        }
      } else if (isa<AffineLoadOp>(op))
        readNum[partitionIdx] += 1;
      else if (isa<AffineStoreOp>(op))
        writeNum[partitionIdx] += 1;

      // TODO: Calculate dependency-aware II.
      auto dimId = getDimId(op, value);
      for (auto depOp : llvm::drop_begin(memAccess, ++opIdx)) {
        auto depDimId = getDimId(depOp, value);

        // This means both of the two memory operaions access static memory
        // address in different pipeline stage.
        if (dimId == -1 && depDimId == -1) {
        }
      }
    }

    unsigned minII = 1;
    if (storageType == "ram_s2p") {
      minII = max({minII, *std::max_element(readNum.begin(), readNum.end()),
                   *std::max_element(writeNum.begin(), writeNum.end())});
    } else if (storageType == "ram_2p" || storageType == "ram_t2p") {
      for (unsigned i = 0, e = partitionNum; i < e; ++i) {
        minII = max(minII, (readNum[i] + writeNum[i] + 1) / 2);
      }
    } else if (storageType == "ram_1p") {
      for (unsigned i = 0, e = partitionNum; i < e; ++i) {
        minII = max(minII, readNum[i] + writeNum[i]);
      }
    }

    II = max(II, minII);
  }
  return II;
}

bool HLSCppEstimator::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1)
    op.emitError("has zero or more than one basic blocks.");

  // If the current loop is annotated as pipeline, extra dependency and II
  // analysis will be executed.
  if (getBoolAttrValue(op, "pipeline")) {
    MemAccessDict dict;
    getMemAccessInfo(body.front(), dict);

    llvm::outs() << op << "\n";

    // Calculate latency of each iteration.
    auto iterLatency = getBlockSchedule(body.front());
    setAttrValue(op, "iter_latency", iterLatency);

    // Calculate initial interval.
    auto II = getMinII(op, dict);
    setAttrValue(op, "init_interval", II);

    auto tripCount = getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", tripCount);

    setAttrValue(op, "latency", iterLatency + II * (tripCount - 1));
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

    auto iterLatency = getUIntAttrValue(child, "iter_latency");
    setAttrValue(op, "iter_latency", iterLatency);

    auto II = getUIntAttrValue(child, "init_interval");
    setAttrValue(op, "init_interval", II);

    auto flattenTripCount = getUIntAttrValue(child, "flatten_trip_count") *
                            getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", flattenTripCount);

    setAttrValue(op, "latency", iterLatency + II * (flattenTripCount - 1));
  }
  // Default case, aka !pipeline && !flatten.
  else {
    MemAccessDict dict;
    getMemAccessInfo(body.front(), dict);

    auto iterLatency = getBlockSchedule(body.front());
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

  MemAccessDict dict;
  getMemAccessInfo(func.front(), dict);

  auto latency = getBlockSchedule(func.front());
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
