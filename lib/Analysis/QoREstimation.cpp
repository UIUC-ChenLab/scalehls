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
    : public HLSCppVisitorBase<HLSCppEstimator, bool, unsigned>,
      public HLSCppAnalysisBase {
public:
  explicit HLSCppEstimator(FuncOp &func, LatencyMap &latencyMap)
      : HLSCppAnalysisBase(OpBuilder(func)), func(func),
        latencyMap(latencyMap) {
    getFuncDependencies();
  }

  // For storing all dependencies indexed by the dependency source operation.
  using Depends = SmallVector<Operation *, 16>;
  using DependsMap = DenseMap<Operation *, Depends>;

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

  // For storing the DSP resource utilization indexed by the schedule level.
  using ResourceMap = DenseMap<unsigned, unsigned>;

  /// Collect all dependencies detected in the function.
  void getFuncDependencies();

  void setScheduleValue(Operation *op, unsigned begin, unsigned end) {
    setAttrValue(op, "schedule_begin", begin);
    setAttrValue(op, "schedule_end", end);
  }

  using HLSCppVisitorBase::visitOp;
  bool visitUnhandledOp(Operation *op, unsigned begin) {
    // Default latency of any unhandled operation is 0.
    setScheduleValue(op, begin, begin);
    return true;
  }

  /// LoadOp and StoreOp related methods.
  int32_t getPartitionIndex(Operation *op);
  void estimateLoadStore(Operation *op, unsigned begin);
  bool visitOp(AffineLoadOp op, unsigned begin) {
    return estimateLoadStore(op, begin), true;
  }
  bool visitOp(AffineStoreOp op, unsigned begin) {
    return estimateLoadStore(op, begin), true;
  }
  bool visitOp(LoadOp op, unsigned begin) {
    setScheduleValue(op, begin, begin + 2);
    return true;
  }
  bool visitOp(StoreOp op, unsigned begin) {
    setScheduleValue(op, begin, begin + 1);
    return true;
  }

  /// AffineForOp related methods.
  // unsigned getOpMinII(AffineForOp forOp);
  unsigned getResMinII(MemAccessesMap &map);
  unsigned getDepMinII(AffineForOp forOp, MemAccessesMap &map);
  bool visitOp(AffineForOp op, unsigned begin);

  /// Other operation handlers.
  bool visitOp(AffineIfOp op, unsigned begin);
  bool visitOp(CallOp op, unsigned begin);

  /// Handle operations with profiled latency.
#define HANDLE(OPTYPE, KEYNAME)                                                \
  bool visitOp(OPTYPE op, unsigned begin) {                                    \
    setScheduleValue(op, begin, begin + latencyMap[KEYNAME] + 1);              \
    return true;                                                               \
  }
  HANDLE(AddFOp, "fadd");
  HANDLE(MulFOp, "fmul");
  HANDLE(DivFOp, "fdiv");
  HANDLE(CmpFOp, "fcmp");
#undef HANDLE

  /// Block scheduler and estimator.
  unsigned getResourceMap(Block &block, ResourceMap &addFMap,
                          ResourceMap &mulFMap);
  unsigned estimateResource(Block &block);
  Optional<std::pair<unsigned, unsigned>> estimateBlock(Block &block,
                                                        unsigned begin);
  void reverseSchedule();
  void estimateFunc();

  FuncOp &func;
  DependsMap dependsMap;
  PortsMapDict portsMapDict;
  LatencyMap &latencyMap;
};
} // namespace

/// Collect all dependencies detected in the function.
void HLSCppEstimator::getFuncDependencies() {
  // TODO: This can be simplified by traversing each ArrayOp in the function.
  MemAccessesMap map;
  getMemAccessesMap(func.front(), map, /*includeCallOp=*/true);

  // Walk through all ArrayOp - LoadOp/StoreOp pairs, and find all memory
  // related dependencies.
  for (auto &pair : map) {
    auto memAccesses = pair.second;

    // Walk through each pair of source and destination. Note that for intra
    // iteration dependencies, srcOp is always before dstOp.
    unsigned srcIndex = 1;
    for (auto srcOp : memAccesses) {
      for (auto dstOp : llvm::drop_begin(memAccesses, srcIndex)) {
        if (isa<mlir::CallOp>(srcOp) || isa<mlir::CallOp>(dstOp)) {
          // TODO: for now, all dstOps are considered to have dependencies to
          // the srcOp if either the dstOp or srcOp is a CallOp.
          dependsMap[srcOp].push_back(dstOp);
        } else {
          MemRefAccess srcAccess(srcOp);
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
      }
      srcIndex++;
    }
  }

  // Walk through all loops in the function and establish dependencies. The
  // rationale here is in Vivado HLS, a loop will always be dominated by another
  // loop before it, even if no actual dependencies exist between them.
  SmallVector<Operation *, 16> loops;
  func.walk([&](AffineForOp loop) { loops.push_back(loop); });

  unsigned loopIndex = 1;
  for (auto srcLoop : loops) {
    for (auto dstLoop : llvm::drop_begin(loops, loopIndex))
      if (checkSameLevel(srcLoop, dstLoop))
        dependsMap[srcLoop].push_back(dstLoop);
    loopIndex++;
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
void HLSCppEstimator::estimateLoadStore(Operation *op, unsigned begin) {
  // Calculate partition index.
  auto partitionIdx = getPartitionIndex(op);
  setAttrValue(op, "partition_index", partitionIdx);

  auto arrayOp = getArrayOp(op);
  auto partitionNum = arrayOp.partition_num();
  auto storageType = arrayOp.storage_type();

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

        if (storageType == "ram_1p_bram")
          rdwrPort = 1;
        else if (storageType == "ram_2p_bram")
          rdPort = 1, rdwrPort = 1;
        else if (storageType == "ram_s2p_bram")
          rdPort = 1, wrPort = 1;
        else if (storageType == "ram_t2p_bram")
          rdwrPort = 2;
        else
          rdwrPort = 2;

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

  if (isa<AffineReadOpInterface>(op))
    setScheduleValue(op, begin, begin + 2);
  else
    setScheduleValue(op, begin, begin + 1);
}

//===----------------------------------------------------------------------===//
// AffineForOp Related Methods
//===----------------------------------------------------------------------===//

// unsigned HLSCppEstimator::getOpMinII(AffineForOp forOp) {
//   unsigned II = 1;
//   forOp.walk([&](Operation *op) {
//     unsigned minII = 0;
//     if (auto latency = getUIntAttrValue(op, "latency"))
//       minII = latency;
//     else
//       minII = getUIntAttrValue(op, "schedule_end") -
//               getUIntAttrValue(op, "schedule_begin");
//     II = max(II, minII);
//   });
//   return II;
// }

/// Calculate the minimum resource II.
unsigned HLSCppEstimator::getResMinII(MemAccessesMap &map) {
  unsigned II = 1;

  for (auto &pair : map) {
    auto arrayOp = getArrayOp(pair.first);
    // Partition number should at least be 1.
    auto partitionNum = arrayOp.partition_num();
    auto storageType = arrayOp.storage_type();

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
        if (storageType == "ram_1p_bram" || storageType == "ram_s2p_bram")
          accessNum = 1;
        else if (storageType == "ram_2p_bram" || storageType == "ram_t2p_bram")
          accessNum = 2;
        else
          accessNum = 2;

        // The rationale here is an undetermined partition access will introduce
        // a large mux which will avoid Vivado HLS to process any concurrent
        // data access among all partitions. This is equivalent to increase read
        // or write number for all partitions.
        // TODO: need to be further refined.
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
    if (storageType == "ram_1p_bram")
      for (unsigned i = 0, e = partitionNum; i < e; ++i)
        minII = max(minII, readNum[i] + writeNum[i]);

    else if (storageType == "ram_s2p_bram")
      minII = max({minII, *std::max_element(readNum.begin(), readNum.end()),
                   *std::max_element(writeNum.begin(), writeNum.end())});

    // TODO: need to be further refined.
    else if (storageType == "ram_2p_bram" || storageType == "ram_t2p_bram")
      for (unsigned i = 0, e = partitionNum; i < e; ++i)
        minII = max(minII, (readNum[i] + writeNum[i] - 1) / 2 + 1);

    II = max(II, minII);
  }
  return II;
}

/// Calculate the minimum dependency II.
unsigned HLSCppEstimator::getDepMinII(AffineForOp forOp, MemAccessesMap &map) {
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

bool HLSCppEstimator::visitOp(AffineForOp op, unsigned begin) {
  unsigned end = begin;
  auto &loopBlock = op.getLoopBody().front();

  // Estimate the loop block.
  if (auto schedule = estimateBlock(loopBlock, begin)) {
    end = max(end, schedule.getValue().second);
    begin = max(begin, schedule.getValue().first);
  } else
    return false;

  // Set an attribute indicating the trip count. For now, we assume all loops
  // have static loop bound.
  if (auto tripCount = getConstantTripCount(op))
    setAttrValue(op, "trip_count", (unsigned)tripCount.getValue());
  else {
    // TODO: how to handle unknown trip count.
    setAttrValue(op, "trip_count", (unsigned)1);
  }

  // If the current loop is annotated as flatten, it will be flattened into the
  // child pipelined loop. This will increase the flattened loop trip count
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

    // The resource utilization of flattened loop is equal to its child's.
    setAttrValue(op, "dsp", getUIntAttrValue(child, "dsp"));
    return true;
  }

  // Estimate the loop block resource utilization.
  auto resource = estimateResource(loopBlock);

  // Calculate latency of each iteration.
  auto iterLatency = end - begin;
  setAttrValue(op, "iter_latency", iterLatency);

  // If the current loop is annotated as pipelined loop, extra dependency and
  // resource aware II analysis will be executed.
  if (getBoolAttrValue(op, "pipeline")) {
    // Collect load and store operations in the loop block for solving possible
    // carried dependencies.
    // TODO: include CallOps, how? Maybe we need to somehow analyze the memory
    // access behavior of the CallOp.
    MemAccessesMap map;
    getMemAccessesMap(loopBlock, map);

    // Calculate initial interval.
    auto II = max(getResMinII(map), getDepMinII(op, map));
    // auto II = max({getOpMinII(op), getResMinII(map), getDepMinII(op, map)});
    setAttrValue(op, "init_interval", II);

    auto tripCount = getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", tripCount);

    auto latency = iterLatency + II * (tripCount - 1);
    setAttrValue(op, "latency", latency);

    // Entering and leaving a loop will consume extra 2 clock cycles.
    setScheduleValue(op, begin, begin + latency + 2);

    // TODO: For pipelined loop, we also need to consider the II when estimating
    // resource utilization.
    setAttrValue(op, "dsp", resource);
    return true;
  }

  // Default case (not flattend or pipelined), calculate latency and resource
  // utilization accordingly.
  unsigned latency = iterLatency * getUIntAttrValue(op, "trip_count");
  setAttrValue(op, "latency", latency);

  setScheduleValue(op, begin, begin + latency + 2);
  setAttrValue(op, "dsp", resource);
  return true;
}

//===----------------------------------------------------------------------===//
// Other Operation Handlers
//===----------------------------------------------------------------------===//

bool HLSCppEstimator::visitOp(AffineIfOp op, unsigned begin) {
  unsigned end = begin;
  auto thenBlock = op.getThenBlock();

  // Estimate then block.
  if (auto schedule = estimateBlock(*thenBlock, begin))
    end = max(end, schedule.getValue().second);
  else
    return false;

  // Handle else block if required.
  if (op.hasElse()) {
    auto elseBlock = op.getElseBlock();

    if (auto schedule = estimateBlock(*elseBlock, begin))
      end = max(end, schedule.getValue().second);
    else
      return false;
  }

  // In our assumption, AffineIfOp is completely transparent. Therefore, we set
  // a dummy schedule begin here.
  setScheduleValue(op, end, end);
  return true;
}

bool HLSCppEstimator::visitOp(mlir::CallOp op, unsigned begin) {
  auto callee = SymbolTable::lookupSymbolIn(func.getParentOp(), op.getCallee());
  auto subFunc = dyn_cast<FuncOp>(callee);
  assert(subFunc && "callable is not a function operation");

  HLSCppEstimator estimator(subFunc, latencyMap);
  estimator.estimateFunc();

  // We assume enter and leave the subfunction require extra 2 clock cycles.
  if (auto subLatency = getUIntAttrValue(subFunc, "latency")) {
    setScheduleValue(op, begin, begin + subLatency + 2);
    return true;
  } else
    return false;
}

//===----------------------------------------------------------------------===//
// Block Scheduler and Estimator
//===----------------------------------------------------------------------===//

unsigned HLSCppEstimator::getResourceMap(Block &block, ResourceMap &addFMap,
                                         ResourceMap &mulFMap) {
  unsigned loopResource = 0;
  for (auto &op : block) {
    auto begin = getUIntAttrValue(&op, "schedule_begin");
    auto end = getUIntAttrValue(&op, "schedule_end");

    // Accumulate the resource utilization of each operation.
    if (isa<AddFOp>(op))
      for (unsigned i = begin; i < end; ++i)
        addFMap[i]++;

    else if (isa<MulFOp>(op))
      for (unsigned i = begin; i < end; ++i)
        mulFMap[i]++;

    else if (isa<AffineForOp>(op))
      loopResource += getUIntAttrValue(&op, "dsp");

    else if (auto ifOp = dyn_cast<AffineIfOp>(op)) {
      // AffineIfOp is transparent during scheduling, thus here we recursively
      // enter each if block.
      loopResource += getResourceMap(*ifOp.getThenBlock(), addFMap, mulFMap);
      if (ifOp.hasElse())
        loopResource += getResourceMap(*ifOp.getElseBlock(), addFMap, mulFMap);
    }
  }
  return loopResource;
}

unsigned HLSCppEstimator::estimateResource(Block &block) {
  ResourceMap addFMap;
  ResourceMap mulFMap;
  unsigned loopResource = getResourceMap(block, addFMap, mulFMap);

  // Find the max resource utilization across all schedule levels.
  unsigned maxAddF = 0;
  for (auto level : addFMap)
    maxAddF = max(maxAddF, level.second);

  unsigned maxMulF = 0;
  for (auto level : mulFMap)
    maxMulF = max(maxMulF, level.second);

  // We assume the loop resource utilization cannot be shared. Therefore, the
  // overall resource utilization is loops' plus other operstions'. According to
  // profiling, floating-point add and muliply will consume 2 and 3 DSP units,
  // respectively.
  return loopResource + maxAddF * 2 + maxMulF * 3;
}

/// Estimate the latency of a block with ALAP scheduling strategy, return the
/// end level of schedule. Meanwhile, the input begin will also be updated if
/// required (typically happens in AffineForOps).
Optional<std::pair<unsigned, unsigned>>
HLSCppEstimator::estimateBlock(Block &block, unsigned begin) {
  unsigned blockBegin = begin;
  unsigned blockEnd = begin;

  // Reversely walk through all operations in the block.
  for (auto it = block.rbegin(), e = block.rend(); it != e; ++it) {
    auto op = &*it;
    unsigned opBegin = begin;
    unsigned opEnd = begin;

    // Fine the latest arrived successor relying on the current operation.
    for (auto result : op->getResults())
      for (auto user : result.getUsers()) {
        auto sameLevelUser = getSameLevelDstOp(op, user);
        opBegin = max(opBegin, getUIntAttrValue(sameLevelUser, "schedule_end"));
      }

    // Check dependencies of the operation and update schedule level.
    for (auto dstOp : dependsMap[op]) {
      auto sameLevelDstOp = getSameLevelDstOp(op, dstOp);
      opBegin = max(opBegin, getUIntAttrValue(sameLevelDstOp, "schedule_end"));
    }

    // Estimate the current operation.
    if (dispatchVisitor(op, opBegin))
      opEnd = max(opEnd, getUIntAttrValue(op, "schedule_end"));
    else
      return Optional<std::pair<unsigned, unsigned>>();

    // Update the block schedule end and begin.
    if (it == block.rbegin())
      blockBegin = opBegin;
    else
      blockBegin = min(blockBegin, opBegin);

    blockEnd = max(blockEnd, opEnd);
  }
  return std::pair<unsigned, unsigned>(blockBegin, blockEnd);
}

void HLSCppEstimator::reverseSchedule() {
  func.walk([&](Operation *op) {
    // Get schedule level.
    auto begin = getUIntAttrValue(op, "schedule_begin");
    auto end = getUIntAttrValue(op, "schedule_end");

    // Reverse schedule level.
    if (auto surOp = getSurroundingOp(op)) {
      if (isa<mlir::AffineForOp>(surOp)) {
        auto surOpBegin = getUIntAttrValue(surOp, "schedule_begin");

        if (getBoolAttrValue(surOp, "flatten")) {
          // Handle flattened surrounding loops.
          setScheduleValue(op, surOpBegin, surOpBegin + end - begin);
        } else {
          // Handle normal cases.
          auto iterLatency = getUIntAttrValue(surOp, "iter_latency");
          setScheduleValue(op, surOpBegin + iterLatency - end,
                           surOpBegin + iterLatency - begin);
        }
      } else if (isa<FuncOp>(surOp)) {
        auto latency = getUIntAttrValue(surOp, "latency");
        setScheduleValue(op, latency - end, latency - begin);
      }
    }
  });
}

void HLSCppEstimator::estimateFunc() {
  // Recursively estimate blocks in the function.
  if (auto schedule = estimateBlock(func.front(), 0)) {
    auto latency = schedule.getValue().second;
    setAttrValue(func, "latency", latency);

    // Scheduled levels of all operations are reversed in this method, because
    // we have done the ALAP scheduling in a reverse order. Note that after the
    // reverse, the annotated scheduling level of each operation is a relative
    // level of the nearest surrounding AffineForOp or FuncOp.
    reverseSchedule();
  } else {
    // Scheduling failed due to early error.
    // TODO: further refinement and try the best to avoid failing, e.g. support
    // variable loop bound.
    setAttrValue(func, "latency", std::string("unknown"));
  }

  // Estimate the resource utilization of the function.
  setAttrValue(func, "dsp", estimateResource(func.front()));
  // TODO: estimate BRAM and LUT utilization.
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
    for (auto func : getOperation().getOps<FuncOp>())
      if (auto topFunction = func.getAttrOfType<BoolAttr>("top_function"))
        if (topFunction.getValue()) {
          // Estimate the top function. If any other functions are called by the
          // top function, it will be estimated in the procedure of estimating
          // the top function.
          HLSCppEstimator estimator(func, latencyMap);
          estimator.estimateFunc();
        }

    // TODO: Somehow print the estimation report?
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
