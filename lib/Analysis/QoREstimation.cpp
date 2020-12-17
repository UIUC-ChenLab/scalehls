//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Analysis/Passes.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/Analysis/AffineStructures.h"
#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/PatternMatch.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// Helpers
//===----------------------------------------------------------------------===//

// Check if the lhsOp and rhsOp is at the same scheduling level. In this check,
// AffineIfOp is transparent.
static bool checkSameLevel(Operation *lhsOp, Operation *rhsOp) {
  // If lhsOp and rhsOp are already at the same level, return true.
  if (lhsOp->getBlock() == rhsOp->getBlock())
    return true;

  // Get all nested parent AffineIfOps, include lhsOp and rhsOp.
  auto getNests = ([&](Operation *op, SmallVector<Operation *, 4> &nests) {
    nests.push_back(op);
    auto currentOp = op;
    while (true) {
      if (auto parentOp = currentOp->getParentOfType<AffineIfOp>()) {
        nests.push_back(parentOp);
        currentOp = parentOp;
      } else
        break;
    }
  });

  SmallVector<Operation *, 4> lhsNests;
  SmallVector<Operation *, 4> rhsNests;

  getNests(lhsOp, lhsNests);
  getNests(rhsOp, rhsNests);

  // If any parent of lhsOp and any parent of rhsOp are at the same level,
  // return true.
  for (auto lhs : lhsNests)
    for (auto rhs : rhsNests)
      if (lhs->getBlock() == rhs->getBlock())
        return true;

  return false;
}

/// Get all nested parent AffineForOps. Since AffineIfOps are transparent,
/// AffineIfOps are skipped during the procedure.
static void getLoopNests(Operation *op, SmallVector<Operation *, 4> &nests) {
  auto currentOp = op;
  while (true) {
    if (auto parentOp = currentOp->getParentOfType<AffineForOp>()) {
      nests.push_back(parentOp);
      currentOp = parentOp;
    } else if (auto parentOp = currentOp->getParentOfType<AffineIfOp>())
      currentOp = parentOp;
    else
      break;
  }
}

/// Get the definition ArrayOp given any memory access operation.
static ArrayOp getArrayOp(Operation *op) {
  auto defOp = MemRefAccess(op).memref.getDefiningOp();
  assert(defOp && "MemRef is block argument");

  auto arrayOp = dyn_cast<ArrayOp>(defOp);
  assert(arrayOp && "MemRef is not defined by ArrayOp");

  return arrayOp;
}

/// Collect all load and store operations in the block.
static void getLoadStoresMap(Block &block, LoadStoresMap &map) {
  block.walk([&](Operation *op) {
    if (isa<AffineReadOpInterface, AffineWriteOpInterface>(op))
      map[getArrayOp(op)].push_back(op);
  });
}

//===----------------------------------------------------------------------===//
// MemRef Dependency Collection Methods
//===----------------------------------------------------------------------===//

/// Get the common loop depth shared by lhsOp and rhsOp.
static unsigned getCommonLoopDepth(Operation *lhsOp, Operation *rhsOp) {
  // Collect all parent nested loops.
  SmallVector<Operation *, 4> lhsLoopNests;
  SmallVector<Operation *, 4> rhsLoopNests;

  getLoopNests(lhsOp, lhsLoopNests);
  getLoopNests(rhsOp, rhsLoopNests);

  // Calculate common loop depth.
  auto lhsDepth = lhsLoopNests.size();
  auto rhsDepth = rhsLoopNests.size();
  unsigned commonLoopDepth = 0;

  for (unsigned i = 0, e = min(lhsDepth, rhsDepth); i < e; ++i) {
    if (lhsLoopNests[lhsDepth - 1 - i] == rhsLoopNests[rhsDepth - 1 - i])
      commonLoopDepth++;
    else
      break;
  }

  return commonLoopDepth;
}

/// Collect all dependencies detected in the function.
void HLSCppEstimator::getFuncMemRefDepends() {
  LoadStoresMap loadStoresMap;
  getLoadStoresMap(func.front(), loadStoresMap);

  // Walk through all ArrayOp - LoadOp/StoreOp pairs.
  for (auto &pair : loadStoresMap) {
    auto loadStores = pair.second;

    // Walk through each pair of source and destination. Note that for intra
    // dependencies, srcOp is always before dstOp.
    unsigned srcIndex = 1;
    for (auto srcOp : loadStores) {
      MemRefAccess srcAccess(srcOp);
      for (auto dstOp : llvm::drop_begin(loadStores, srcIndex)) {
        MemRefAccess dstAccess(dstOp);

        bool dependFlag = false;
        auto commonLoopDepth = getCommonLoopDepth(srcOp, dstOp);
        for (unsigned depth = 1; depth <= commonLoopDepth; ++depth) {
          // Initialize constraints and components.
          FlatAffineConstraints dependConstrs;
          SmallVector<DependenceComponent, 2> dependComps;

          // Check dependency.
          DependenceResult result = checkMemrefAccessDependence(
              srcAccess, dstAccess, depth, &dependConstrs, &dependComps);
          dependFlag = hasDependence(result);
        }

        // All dependencies are pushed into the dependsMap output.
        if (dependFlag)
          dependsMap[dstOp].push_back(srcOp);
      }
      srcIndex++;
    }
  }
}

//===----------------------------------------------------------------------===//
// LoadOp and StoreOp Related Methods
//===----------------------------------------------------------------------===//

// Get the pointer of the scrOp's parent loop, which should locate at the same
// level with dstOp's any parent loop.
static Operation *getSameLevelSourceOp(Operation *srcOp, Operation *dstOp) {
  // If srcOp and dstOp are already at the same level, return the srcOp.
  if (checkSameLevel(srcOp, dstOp))
    return srcOp;

  SmallVector<Operation *, 4> srcNests;
  SmallVector<Operation *, 4> dstNests;
  srcNests.push_back(srcOp);
  dstNests.push_back(dstOp);

  getLoopNests(srcOp, srcNests);
  getLoopNests(dstOp, dstNests);

  // If any parent of srcOp (or itself) and any parent of dstOp (or itself) are
  // at the same level, return the pointer.
  for (auto src : srcNests)
    for (auto dst : dstNests)
      if (checkSameLevel(src, dst))
        return src;

  return nullptr;
}

/// Calculate the overall partition index.
int32_t HLSCppEstimator::getPartitionIndex(Operation *op) {
  auto arrayOp = getArrayOp(op);
  AffineValueMap accessMap;
  MemRefAccess(op).getAccessMap(&accessMap);

  // Calculate the partition index of this load/store operation honoring the
  // partition strategy applied.
  int32_t partitionIdx = 0;
  unsigned accumFactor = 1;
  unsigned dim = 0;

  for (auto expr : accessMap.getAffineMap().getResults()) {
    auto idxExpr = builder.getAffineConstantExpr(0);
    unsigned factor = 1;

    if (arrayOp.partition()) {
      auto type = getPartitionType(arrayOp, dim);
      factor = getPartitionFactor(arrayOp, dim);

      if (type == "cyclic")
        idxExpr = expr % builder.getAffineConstantExpr(factor);
      else if (type == "block") {
        auto size = arrayOp.getType().cast<ShapedType>().getShape()[dim];
        idxExpr = expr.floorDiv(
            builder.getAffineConstantExpr((size + factor - 1) / factor));
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
    dim++;
  }
  return partitionIdx;
}

/// Schedule load/store operation honoring the memory ports number limitation.
unsigned HLSCppEstimator::getLoadStoreSchedule(Operation *op, unsigned begin) {
  // Check dependencies of the operation and update schedule level.
  for (auto srcOp : dependsMap[op]) {
    auto sameLevelSrcOp = getSameLevelSourceOp(srcOp, op);
    begin = max(getUIntAttrValue(sameLevelSrcOp, "schedule_end"), begin);
  }

  // Calculate partition index.
  auto partitionIdx = getPartitionIndex(op);
  setAttrValue(op, "partition_index", partitionIdx);

  auto arrayOp = getArrayOp(op);
  auto partitionNum = getUIntAttrValue(arrayOp, "partition_num");
  auto storageType = getStrAttrValue(arrayOp, "storage_type");

  // Try to avoid memory port violation until a legal schedule is found. Since
  // an infinite length schedule cannot be generated, this while loop can be
  // proofed to have an end.
  while (true) {
    auto memPort = portsMapDict[begin][arrayOp];
    bool memPortEmpty = memPort.empty();

    // If the memory has not been occupied by the current schedule level, it
    // should be initialized according to its storage type. Note that each
    // partition should have one PortInfo structure.
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
        }

        memPort.push_back(PortInfo(rdPort, wrPort, rdwrPort));
      }
    }

    // Indicate whether the operation is successfully scheduled in the current
    // schedule level.
    bool successFlag = false;

    if (partitionIdx == -1) {
      // When partition index can't be determined, this operation must occupy
      // all ports in the scheduled level.
      if (memPortEmpty) {
        for (unsigned p = 0; p < partitionNum; ++p) {
          memPort[p].rdPort = 0;
          memPort[p].wrPort = 0;
          memPort[p].rdwrPort = 0;
        }
        successFlag = true;
      }
    } else {
      // When partition index can be determined, figure out whether the current
      // schedule meets memory port limitation.
      PortInfo portInfo = memPort[partitionIdx];
      if (isa<AffineLoadOp>(op) && portInfo.rdPort > 0) {
        memPort[partitionIdx].rdPort -= 1;
        successFlag = true;

      } else if (isa<AffineStoreOp>(op) && portInfo.wrPort > 0) {
        memPort[partitionIdx].wrPort -= 1;
        successFlag = true;

      } else if (portInfo.rdwrPort > 0) {
        memPort[partitionIdx].rdwrPort -= 1;
        successFlag = true;
      }
    }

    // If successed, break the while loop. Otherwise increase the schedule level
    // by 1 and continue to try.
    if (successFlag) {
      portsMapDict[begin][arrayOp] = memPort;
      break;
    } else
      begin++;
  }

  // Memory load/store operation always consumes 1 clock cycle.
  return begin + 1;
}

Optional<unsigned> HLSCppEstimator::visitOp(AffineLoadOp op, unsigned begin) {
  return getLoadStoreSchedule(op, begin);
}

Optional<unsigned> HLSCppEstimator::visitOp(AffineStoreOp op, unsigned begin) {
  return getLoadStoreSchedule(op, begin);
}

//===----------------------------------------------------------------------===//
// AffineForOp Related Methods
//===----------------------------------------------------------------------===//

/// Calculate the minimum resource II.
unsigned HLSCppEstimator::getResMinII(AffineForOp forOp, LoadStoresMap &dict) {
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

    auto loadStores = pair.second;

    for (auto op : loadStores) {
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
        else {
          accessNum = 2;
          // arrayOp.emitError("unsupported storage type.");
        }

        // The rationale here is an undetermined partition access will
        // introduce a large mux which will avoid Vivado HLS to process any
        // concurrent data access among all partitions. This is equivalent to
        // increase read or write number for all partitions.
        for (unsigned p = 0, e = partitionNum; p < e; ++p) {
          if (isa<AffineLoadOp>(op))
            readNum[p] += accessNum;
          else if (isa<AffineStoreOp>(op))
            writeNum[p] += accessNum;
        }
      } else if (isa<AffineLoadOp>(op))
        readNum[partitionIdx]++;
      else if (isa<AffineStoreOp>(op))
        writeNum[partitionIdx]++;
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

/// Calculate the minimum dependency II.
unsigned HLSCppEstimator::getDepMinII(AffineForOp forOp, LoadStoresMap &dict) {
  unsigned II = 1;

  // Collect start and end level of the pipeline.
  unsigned endLevel = 1;
  unsigned startLevel = 1;
  auto currentLoop = forOp;
  while (true) {
    if (auto outerLoop = dyn_cast<AffineForOp>(currentLoop.getParentOp())) {
      currentLoop = outerLoop;
      endLevel++;
      if (!getBoolAttrValue(outerLoop, "flatten"))
        startLevel++;
    } else
      break;
  }

  for (auto &pair : dict) {
    auto loadStores = pair.second;

    // Walk through each pair of source and destination, and each loop level
    // that are pipelined. Note that for inter-dependency, dstOp is always
    // before srcOp.
    for (unsigned loopDepth = startLevel; loopDepth <= endLevel; ++loopDepth) {
      unsigned dstIndex = 1;
      for (auto dstOp : loadStores) {
        MemRefAccess dstAccess(dstOp);

        for (auto srcOp : llvm::drop_begin(loadStores, dstIndex)) {
          MemRefAccess srcAccess(srcOp);

          FlatAffineConstraints depConstrs;
          SmallVector<DependenceComponent, 2> depComps;

          DependenceResult result = checkMemrefAccessDependence(
              srcAccess, dstAccess, loopDepth, &depConstrs, &depComps);

          if (hasDependence(result)) {
            SmallVector<unsigned, 2> flattenTripCounts;
            flattenTripCounts.push_back(1);
            int64_t distance = 0;

            // Calculate the distance of this dependency.
            for (auto it = depComps.rbegin(); it < depComps.rend(); ++it) {
              auto dep = *it;
              auto tripCount = getUIntAttrValue(dep.op, "trip_count");

              if (dep.ub)
                distance += flattenTripCounts.back() * dep.ub.getValue();
              else if (dep.lb)
                distance += flattenTripCounts.back() * dep.lb.getValue();
              else
                distance += flattenTripCounts.back() * tripCount;

              flattenTripCounts.push_back(flattenTripCounts.back() * tripCount);
            }

            unsigned delay = getUIntAttrValue(srcOp, "schedule_begin") -
                             getUIntAttrValue(dstOp, "schedule_begin");

            if (distance > 0) {
              unsigned minII = ceil((float)delay / distance);
              II = max(II, minII);
            }
          }
        }
        dstIndex++;
      }
    }
  }
  return II;
}

Optional<unsigned> HLSCppEstimator::visitOp(AffineForOp op, unsigned begin) {
  if (op.getLoopBody().getBlocks().size() != 1) {
    op.emitError("has zero or more than one basic blocks.");
    return Optional<unsigned>();
  }

  // Set an attribute indicating the trip count. For now, we assume all loops
  // have static loop bound.
  if (auto tripCount = getConstantTripCount(op))
    setAttrValue(op, "trip_count", (unsigned)tripCount.getValue());
  else {
    setAttrValue(op, "trip_count", (unsigned)0);
    op.emitError("has undetermined trip count");
    return Optional<unsigned>();
  }

  unsigned end = begin;
  auto &loopBlock = op.getLoopBody().front();

  // Live ins will impact the scheduling.
  for (auto liveIn : liveness.getLiveIn(&loopBlock))
    if (auto defOp = liveIn.getDefiningOp())
      begin = max(begin, getUIntAttrValue(defOp, "schedule_end"));

  // Estimate the loop block.
  if (auto esti = estimateBlock(loopBlock, begin))
    end = max(end, esti.getValue());
  else
    return Optional<unsigned>();

  // If the current loop is annotated as pipeline, extra dependency and
  // resource aware II analysis will be executed.
  if (getBoolAttrValue(op, "pipeline")) {
    // Calculate latency of each iteration.
    auto iterLatency = end - begin;
    setAttrValue(op, "iter_latency", iterLatency);

    // Collect load and store operations in the loop block for estimating the
    // achievable initial interval.
    LoadStoresMap dict;
    getLoadStoresMap(loopBlock, dict);

    // Calculate initial interval.
    auto II = max(getResMinII(op, dict), getDepMinII(op, dict));
    setAttrValue(op, "init_interval", II);

    auto tripCount = getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", tripCount);

    auto latency = iterLatency + II * (tripCount - 1);
    setAttrValue(op, "latency", latency);

    // Entering and leaving a loop will consume extra 2 clock cycles.
    return begin + latency + 2;
  }

  // If the current loop is annotated as flatten, it will be flattened into
  // the child pipelined loop. This will increase the flattened loop trip count
  // without changing the iteration latency.
  if (getBoolAttrValue(op, "flatten")) {
    auto child = dyn_cast<AffineForOp>(op.getLoopBody().front().front());
    assert(child && "the first containing operation is not a loop");

    auto iterLatency = getUIntAttrValue(child, "iter_latency");
    setAttrValue(op, "iter_latency", iterLatency);

    auto II = getUIntAttrValue(child, "init_interval");
    setAttrValue(op, "init_interval", II);

    auto flattenTripCount = getUIntAttrValue(child, "flatten_trip_count") *
                            getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", flattenTripCount);

    auto latency = iterLatency + II * (flattenTripCount - 1);
    setAttrValue(op, "latency", latency);

    // Since the loop is flattened, it will no longer be entered and left.
    return begin + latency;
  }

  // Default case, calculate latency of each iteration.
  auto iterLatency = end - begin;
  setAttrValue(op, "iter_latency", iterLatency);

  unsigned latency = iterLatency * getUIntAttrValue(op, "trip_count");
  setAttrValue(op, "latency", latency);

  return begin + latency + 2;
}

//===----------------------------------------------------------------------===//
// Other Operation Handlers
//===----------------------------------------------------------------------===//

Optional<unsigned> HLSCppEstimator::visitOp(AffineIfOp op, unsigned begin) {
  unsigned end = begin;
  auto thenBlock = op.getThenBlock();

  // Live ins will impact the scheduling.
  for (auto liveIn : liveness.getLiveIn(thenBlock))
    if (auto defOp = liveIn.getDefiningOp())
      begin = max(begin, getUIntAttrValue(defOp, "schedule_end"));

  // Estimate then block.
  if (auto esti = estimateBlock(*thenBlock, begin))
    end = max(end, esti.getValue());
  else
    return Optional<unsigned>();

  // Handle else block if required.
  if (op.hasElse()) {
    auto elseBlock = op.getElseBlock();

    for (auto liveIn : liveness.getLiveIn(elseBlock))
      if (auto defOp = liveIn.getDefiningOp())
        begin = max(begin, getUIntAttrValue(defOp, "schedule_end"));

    if (auto esti = estimateBlock(*elseBlock, begin))
      end = max(end, esti.getValue());
    else
      return Optional<unsigned>();
  }

  return end;
}

Optional<unsigned> HLSCppEstimator::visitOp(ArrayOp op, unsigned begin) {
  // Annotate the total parition number of the array.
  unsigned partitionNum = 1;
  if (op.partition()) {
    auto rank = op.getType().cast<ShapedType>().getRank();
    for (unsigned dim = 0; dim < rank; ++dim) {
      if (auto factor = getPartitionFactor(op, dim))
        partitionNum *= factor;
    }
  }
  setAttrValue(op, "partition_num", partitionNum);

  // ArrayOp is a dummy memory instance which does not consume any clock
  // cycles.
  return begin;
}

//===----------------------------------------------------------------------===//
// Block Scheduler and Estimator
//===----------------------------------------------------------------------===//

/// Estimate the latency of a block with ASAP scheduling strategy.
Optional<unsigned> HLSCppEstimator::estimateBlock(Block &block,
                                                  unsigned blockBegin) {
  unsigned blockEnd = blockBegin;

  for (auto &op : block) {
    unsigned begin = blockBegin;
    unsigned end = blockBegin;

    // Find the latest arrived predecessor dominating the current operation.
    // This should be considered as the earliest possible scheduling level
    // that the current operation can be scheduled.
    for (auto operand : op.getOperands())
      if (auto defOp = operand.getDefiningOp())
        begin = max(begin, getUIntAttrValue(defOp, "schedule_end"));

    // Estimate the current operation.
    if (auto esti = dispatchVisitor(&op, begin))
      end = max(end, esti.getValue());
    else
      return Optional<unsigned>();

    setAttrValue(&op, "schedule_begin", begin);
    setAttrValue(&op, "schedule_end", end);

    blockEnd = max(blockEnd, end);
  }
  return blockEnd;
}

void HLSCppEstimator::estimateFunc() {
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  // Recursively estimate blocks in the function.
  if (auto esti = estimateBlock(func.front(), 0))
    setAttrValue(func, "latency", esti.getValue());
  else
    setAttrValue(func, "latency", "unknown");
}

//===----------------------------------------------------------------------===//
// Entry of scalehls-opt
//===----------------------------------------------------------------------===//

namespace {
struct QoREstimation : public scalehls::QoREstimationBase<QoREstimation> {
  void runOnOperation() override {
    // Read configuration file.
    INIReader spec(targetSpec);
    if (spec.ParseError())
      llvm::outs() << "error: target spec file parse fail, please refer to "
                      "--help option and pass in correct file path\n";

    // TODO: Support estimator initiation from profiling data, constructing a
    // unique data structure for holding latency and resource information.
    auto freq = spec.Get("spec", "frequency", "200MHz");
    auto latency = spec.GetInteger(freq, "op", 0);

    // Estimate performance and resource utilization.
    for (auto func : getOperation().getOps<FuncOp>()) {
      HLSCppEstimator estimator(func);
      estimator.estimateFunc();
    }
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
