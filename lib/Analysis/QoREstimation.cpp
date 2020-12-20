//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Passes.h"
#include "Analysis/Utils.h"
#include "Dialect/HLSCpp/Visitor.h"
#include "INIReader.h"
#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/AffineStructures.h"
#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Analysis/Utils.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

using LatencyMap = llvm::StringMap<unsigned>;

//===----------------------------------------------------------------------===//
// HLSCppEstimator Class
//===----------------------------------------------------------------------===//

namespace {
class HLSCppEstimator
    : public HLSCppVisitorBase<HLSCppEstimator, Optional<unsigned>, unsigned>,
      public HLSCppAnalysisBase {
public:
  explicit HLSCppEstimator(FuncOp &func, LatencyMap &latencyMap)
      : HLSCppAnalysisBase(OpBuilder(func)), func(func),
        latencyMap(latencyMap) {
    getFuncMemRefDepends();
  }

  // Indicate the unoccupied memory ports number.
  struct PortInfo {
    PortInfo(unsigned rdPort = 0, unsigned wrPort = 0, unsigned rdwrPort = 0)
        : rdPort(rdPort), wrPort(wrPort), rdwrPort(rdwrPort) {}

    unsigned rdPort;
    unsigned wrPort;
    unsigned rdwrPort;
  };

  // For storing ports number of all partitions indexed by the array (ArrayOp).
  using Ports = SmallVector<PortInfo, 16>;
  using PortsMap = DenseMap<Operation *, Ports>;

  // For storing PortsMap indexed by the scheduling level.
  using PortsMapDict = DenseMap<unsigned, PortsMap>;

  // For storing all dependent operations indexed by the source operation.
  using Depends = SmallVector<Operation *, 16>;
  using DependsMap = DenseMap<Operation *, Depends>;

  void getFuncMemRefDepends();

  void setScheduleValue(Operation *op, unsigned begin, unsigned end) {
    setAttrValue(op, "schedule_begin", begin);
    setAttrValue(op, "schedule_end", end);
  }

  using HLSCppVisitorBase::visitOp;
  Optional<unsigned> visitUnhandledOp(Operation *op, unsigned begin) {
    // Default latency of any unhandled operation is 1.
    setScheduleValue(op, begin, begin + 1);
    return begin + 1;
  }

  int32_t getPartitionIndex(Operation *op);
  unsigned getLoadStoreSchedule(Operation *op, unsigned begin);
  Optional<unsigned> visitOp(AffineLoadOp op, unsigned begin) {
    return getLoadStoreSchedule(op, begin);
  }
  Optional<unsigned> visitOp(AffineStoreOp op, unsigned begin) {
    return getLoadStoreSchedule(op, begin);
  }

  unsigned getOpMinII(AffineForOp forOp);
  unsigned getResMinII(LoadStoresMap &map);
  unsigned getDepMinII(AffineForOp forOp, LoadStoresMap &map);
  Optional<unsigned> visitOp(AffineForOp op, unsigned begin);

  Optional<unsigned> visitOp(AffineIfOp op, unsigned begin);
  Optional<unsigned> visitOp(ReturnOp op, unsigned begin);
  Optional<unsigned> visitOp(AffineYieldOp op, unsigned begin);
  Optional<unsigned> visitOp(ArrayOp op, unsigned begin);

  /// Handle operations with profiled latency.
#define HANDLE(OPTYPE, KEYNAME)                                                \
  Optional<unsigned> visitOp(OPTYPE op, unsigned begin) {                      \
    auto end = begin + latencyMap[KEYNAME] + 1;                                \
    setScheduleValue(op, begin, end);                                          \
    return end;                                                                \
  }
  HANDLE(AddFOp, "fadd");
  HANDLE(MulFOp, "fmul");
  HANDLE(DivFOp, "fdiv");
  HANDLE(CmpFOp, "fcmp");
  HANDLE(SelectOp, "fselect");
#undef HANDLE

  Optional<unsigned> estimateBlock(Block &block, unsigned begin);
  void estimateFunc();

  FuncOp &func;
  DependsMap dependsMap;
  PortsMapDict portsMapDict;
  LatencyMap &latencyMap;
};
} // namespace

/// Collect all dependencies detected in the function.
void HLSCppEstimator::getFuncMemRefDepends() {
  // TODO: This can be simplified by traversing each ArrayOp in the function.
  LoadStoresMap loadStoresMap;
  getLoadStoresMap(func.front(), loadStoresMap);

  // Walk through all ArrayOp - LoadOp/StoreOp pairs.
  for (auto &pair : loadStoresMap) {
    auto loadStores = pair.second;

    // Walk through each pair of source and destination. Note that for intra
    // iteration dependencies, srcOp is always before dstOp.
    unsigned srcIndex = 1;
    for (auto srcOp : loadStores) {
      MemRefAccess srcAccess(srcOp);
      for (auto dstOp : llvm::drop_begin(loadStores, srcIndex)) {
        MemRefAccess dstAccess(dstOp);

        bool dependFlag = false;
        auto commonLoopDepth = getNumCommonSurroundingLoops(*srcOp, *dstOp);
        for (unsigned depth = 1; depth <= commonLoopDepth + 1; ++depth) {
          // Initialize constraints.
          FlatAffineConstraints dependConstrs;

          // Check dependency.
          DependenceResult result = checkMemrefAccessDependence(
              srcAccess, dstAccess, depth, &dependConstrs,
              /*dependenceComponents=*/nullptr);
          dependFlag = hasDependence(result);
        }

        // All dependencies are pushed into the dependsMap output.
        if (dependFlag)
          dependsMap[srcOp].push_back(dstOp);
      }
      srcIndex++;
    }
  }
}

//===----------------------------------------------------------------------===//
// LoadOp and StoreOp Related Methods
//===----------------------------------------------------------------------===//

/// Calculate the overall partition index.
int32_t HLSCppEstimator::getPartitionIndex(Operation *op) {
  auto arrayOp = getArrayOp(op);
  AffineValueMap accessMap;
  MemRefAccess(op).getAccessMap(&accessMap);

  // Replace all dims in the memory access AffineMap with (step * dims). This
  // will ensure the "cyclic" array partition can be correctly detected.
  SmallVector<AffineExpr, 4> dimReplacements;
  SmallVector<AffineExpr, 4> symReplacements;
  unsigned operandIdx = 0;
  for (auto operand : accessMap.getOperands()) {
    if (operandIdx < accessMap.getNumDims()) {
      int64_t step = 1;
      if (isForInductionVar(operand))
        step = getForInductionVarOwner(operand).getStep();

      if (step == 1)
        dimReplacements.push_back(builder.getAffineDimExpr(operandIdx));
      else
        dimReplacements.push_back(builder.getAffineConstantExpr(step) *
                                  builder.getAffineDimExpr(operandIdx));
    } else {
      symReplacements.push_back(
          builder.getAffineSymbolExpr(operandIdx - accessMap.getNumDims()));
    }
    operandIdx++;
  }

  auto newMap = accessMap.getAffineMap().replaceDimsAndSymbols(
      dimReplacements, symReplacements, accessMap.getNumDims(),
      accessMap.getNumSymbols());

  // Calculate the partition index of this load/store operation honoring the
  // partition strategy applied.
  int32_t partitionIdx = 0;
  unsigned accumFactor = 1;
  unsigned dim = 0;

  for (auto expr : newMap.getResults()) {
    auto idxExpr = builder.getAffineConstantExpr(0);
    unsigned factor = 1;

    if (arrayOp.partition()) {
      auto type = getPartitionType(arrayOp, dim);
      factor = getPartitionFactor(arrayOp, dim);

      // TODO: detect the step size.
      // %i = 0 to 16 step 4
      // %i % 4 = 0
      if (type == "cyclic")
        idxExpr = expr % builder.getAffineConstantExpr(factor);
      else if (type == "block") {
        auto size = arrayOp.getShapedType().getShape()[dim];
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
  for (auto dstOp : dependsMap[op]) {
    auto sameLevelDstOp = getSameLevelDstOp(op, dstOp);
    begin = max(getUIntAttrValue(sameLevelDstOp, "schedule_end"), begin);
  }

  // Calculate partition index.
  auto partitionIdx = getPartitionIndex(op);
  setAttrValue(op, "partition_index", partitionIdx);

  auto arrayOp = getArrayOp(op);
  auto partitionNum =
      max((unsigned)1, getUIntAttrValue(arrayOp, "partition_num"));
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

  // Memory load consumes 2 clock cyles, while other memory access including
  // store consumes 1 clock cycle.
  unsigned end = begin;
  if (isa<AffineLoadOp>(op))
    end += 2;
  else
    end++;

  setScheduleValue(op, begin, end);
  return end;
}

//===----------------------------------------------------------------------===//
// AffineForOp Related Methods
//===----------------------------------------------------------------------===//

unsigned HLSCppEstimator::getOpMinII(AffineForOp forOp) {
  unsigned II = 1;
  forOp.walk([&](Operation *op) {
    unsigned minII = 0;
    if (auto latency = getUIntAttrValue(op, "latency"))
      minII = latency;
    else
      minII = getUIntAttrValue(op, "schedule_end") -
              getUIntAttrValue(op, "schedule_begin");

    II = max(II, minII);
  });
  return II;
}

/// Calculate the minimum resource II.
unsigned HLSCppEstimator::getResMinII(LoadStoresMap &map) {
  unsigned II = 1;

  for (auto &pair : map) {
    auto arrayOp = getArrayOp(pair.first);
    // Partition number should at least be 1.
    auto partitionNum =
        max((unsigned)1, getUIntAttrValue(arrayOp, "partition_num"));
    auto storageType = getStrAttrValue(arrayOp, "storage_type");

    SmallVector<unsigned, 16> readNum;
    SmallVector<unsigned, 16> writeNum;
    for (unsigned i = 0, e = partitionNum; i < e; ++i) {
      readNum.push_back(0);
      writeNum.push_back(0);
    }

    auto loadStores = pair.second;

    for (auto op : loadStores) {
      auto partitionIdx = getIntAttrValue(op, "partition_index");
      if (partitionIdx == -1) {
        unsigned accessNum = 2;
        if (storageType == "ram_s2p")
          accessNum = 1;
        else if (storageType == "ram_1p")
          accessNum = 1;
        else if (storageType == "ram_2p" || storageType == "ram_t2p" ||
                 storageType == "")
          accessNum = 2;

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
        readNum[partitionIdx]++;
      else if (isa<AffineStoreOp>(op))
        writeNum[partitionIdx]++;
    }

    unsigned minII = 1;
    if (storageType == "ram_s2p")
      minII = max({minII, *std::max_element(readNum.begin(), readNum.end()),
                   *std::max_element(writeNum.begin(), writeNum.end())});

    else if (storageType == "ram_1p")
      for (unsigned i = 0, e = partitionNum; i < e; ++i)
        minII = max(minII, readNum[i] + writeNum[i]);

    else if (storageType == "ram_2p" || storageType == "ram_t2p" ||
             storageType == "")
      for (unsigned i = 0, e = partitionNum; i < e; ++i)
        minII = max(minII, (readNum[i] + writeNum[i] + 1) / 2);

    II = max(II, minII);
  }
  return II;
}

/// Calculate the minimum dependency II.
unsigned HLSCppEstimator::getDepMinII(AffineForOp forOp, LoadStoresMap &map) {
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

  for (auto &pair : map) {
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

              if (dep.lb)
                distance += flattenTripCounts.back() * dep.lb.getValue();

              flattenTripCounts.push_back(flattenTripCounts.back() * tripCount);
            }

            unsigned delay = getUIntAttrValue(dstOp, "schedule_end") -
                             getUIntAttrValue(srcOp, "schedule_begin");

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
  // Set an attribute indicating the trip count. For now, we assume all loops
  // have static loop bound.
  if (auto tripCount = getConstantTripCount(op))
    setAttrValue(op, "trip_count", (unsigned)tripCount.getValue());
  else
    return Optional<unsigned>();

  unsigned end = begin;
  auto &loopBlock = op.getLoopBody().front();

  // Collect load and store operations in the loop block for solving possible
  // dependencies.
  LoadStoresMap map;
  getLoadStoresMap(loopBlock, map);

  // Check dependencies of all load/store operations and update schedule level.
  for (auto pair : map)
    for (auto srcOp : pair.second)
      for (auto dstOp : dependsMap[srcOp]) {
        auto sameLevelDstOp = getSameLevelDstOp(srcOp, dstOp);
        begin = max(getUIntAttrValue(sameLevelDstOp, "schedule_end"), begin);
      }

  // Estimate the loop block.
  if (auto schedule = estimateBlock(loopBlock, begin))
    end = max(end, schedule.getValue());
  else
    return Optional<unsigned>();

  // If the current loop is annotated as pipeline, extra dependency and
  // resource aware II analysis will be executed.
  if (getBoolAttrValue(op, "pipeline")) {
    // Calculate latency of each iteration.
    auto iterLatency = end - begin;
    setAttrValue(op, "iter_latency", iterLatency);

    // Calculate initial interval.
    auto II = max({getOpMinII(op), getResMinII(map), getDepMinII(op, map)});
    setAttrValue(op, "init_interval", II);

    auto tripCount = getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", tripCount);

    auto latency = iterLatency + II * (tripCount - 1);
    setAttrValue(op, "latency", latency);

    // Entering and leaving a loop will consume extra 2 clock cycles.
    setScheduleValue(op, begin, begin + latency + 2);
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
    setScheduleValue(op, begin, begin + latency);
    return begin + latency;
  }

  // Default case, calculate latency of each iteration.
  auto iterLatency = end - begin;
  setAttrValue(op, "iter_latency", iterLatency);

  unsigned latency = iterLatency * getUIntAttrValue(op, "trip_count");
  setAttrValue(op, "latency", latency);

  setScheduleValue(op, begin, begin + latency + 2);
  return begin + latency + 2;
}

//===----------------------------------------------------------------------===//
// Other Operation Handlers
//===----------------------------------------------------------------------===//

Optional<unsigned> HLSCppEstimator::visitOp(AffineIfOp op, unsigned begin) {
  unsigned end = begin;
  auto thenBlock = op.getThenBlock();

  // Estimate then block.
  if (auto schedule = estimateBlock(*thenBlock, begin))
    end = max(end, schedule.getValue());
  else
    return Optional<unsigned>();

  // Handle else block if required.
  if (op.hasElse()) {
    auto elseBlock = op.getElseBlock();

    if (auto schedule = estimateBlock(*elseBlock, begin))
      end = max(end, schedule.getValue());
    else
      return Optional<unsigned>();
  }

  // In our assumption, AffineIfOp is completely transparent. Therefore, we set
  // a dummy schedule begin here.
  setScheduleValue(op, end, end);
  return end;
}

Optional<unsigned> HLSCppEstimator::visitOp(ReturnOp op, unsigned begin) {
  setScheduleValue(op, begin, begin);
  return begin;
}

Optional<unsigned> HLSCppEstimator::visitOp(AffineYieldOp op, unsigned begin) {
  setScheduleValue(op, begin, begin);
  return begin;
}

Optional<unsigned> HLSCppEstimator::visitOp(ArrayOp op, unsigned begin) {
  for (auto user : op.getResult().getUsers()) {
    auto sameLevelDstOp = getSameLevelDstOp(op, user);
    begin = max(getUIntAttrValue(sameLevelDstOp, "schedule_end"), begin);
  }
  setScheduleValue(op, begin, begin);
  return begin;
}

//===----------------------------------------------------------------------===//
// Block Scheduler and Estimator
//===----------------------------------------------------------------------===//

/// Estimate the latency of a block with ALAP scheduling strategy, return the
/// end level of schedule.
Optional<unsigned> HLSCppEstimator::estimateBlock(Block &block,
                                                  unsigned begin) {
  unsigned blockEnd = begin;

  // Reversely walk through all operations in the block.
  for (auto it = block.rbegin(), e = block.rend(); it != e; ++it) {
    auto op = &*it;
    unsigned opBegin = begin;
    unsigned opEnd = begin;

    // Fine the latest arrived successor relying on the current operation.
    for (auto result : op->getResults())
      for (auto user : result.getUsers())
        opBegin = max(opBegin, getUIntAttrValue(user, "schedule_end"));

    // Estimate the current operation.
    if (auto scheduleEnd = dispatchVisitor(op, opBegin))
      opEnd = max(opEnd, scheduleEnd.getValue());
    else
      return Optional<unsigned>();

    // Update the block schedule end.
    blockEnd = max(blockEnd, opEnd);
  }
  return blockEnd;
}

void HLSCppEstimator::estimateFunc() {
  // Recursively estimate blocks in the function.
  if (auto schedule = estimateBlock(func.front(), 0)) {
    auto latency = schedule.getValue();
    setAttrValue(func, "latency", latency);

    // func.walk([&](Operation *op) {
    //  auto begin = getUIntAttrValue(op, "schedule_begin");
    //  auto end = getUIntAttrValue(op, "schedule_end");
    //  setScheduleValue(op, latency - end, latency - begin);
    // });
  } else
    setAttrValue(func, "latency", -1);
}

//===----------------------------------------------------------------------===//
// Entry of scalehls-opt
//===----------------------------------------------------------------------===//

static void getLatencyMap(INIReader &spec, std::string freq,
                          LatencyMap &latencyMap) {
  latencyMap["fadd"] = spec.GetInteger(freq, "fadd", 4);
  latencyMap["fmul"] = spec.GetInteger(freq, "fmul", 3);
  latencyMap["fdiv"] = spec.GetInteger(freq, "fdiv", 15);
  latencyMap["fcmp"] = spec.GetInteger(freq, "fcmp", 1);
  latencyMap["fselect"] = spec.GetInteger(freq, "fselect", 0);
}

namespace {
struct QoREstimation : public scalehls::QoREstimationBase<QoREstimation> {
  void runOnOperation() override {
    // Read configuration file.
    INIReader spec(targetSpec);
    if (spec.ParseError())
      emitError(getOperation().getLoc(),
                "error: target spec file parse fail, please refer to "
                "--help option and pass in correct file path\n");

    // Collect profiling latency data.
    auto freq = spec.Get("specification", "frequency", "100MHz");
    LatencyMap latencyMap;
    getLatencyMap(spec, freq, latencyMap);

    // Estimate performance and resource utilization.
    for (auto func : getOperation().getOps<FuncOp>()) {
      HLSCppEstimator estimator(func, latencyMap);
      estimator.estimateFunc();
    }
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
