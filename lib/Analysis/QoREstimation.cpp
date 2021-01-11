//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Analysis/Passes.h"
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

//===----------------------------------------------------------------------===//
// Initialization Methods
//===----------------------------------------------------------------------===//

/// Collect all dependencies detected in the function.
void HLSCppEstimator::getFuncDependencies() {
  MemAccessesMap map;
  getMemAccessesMap(func.front(), map, /*includeCallOp=*/true);

  // Walk through all MemRef - LoadOp/StoreOp pairs, and find all memory
  // related dependencies.
  for (auto &pair : map) {
    auto memAccesses = pair.second;

    // Annotate partition index of all memory access operation for later use.
    for (auto op : memAccesses)
      getPartitionIndex(op);

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
          auto srcMuxSize = getIntAttrValue(srcOp, "mux_size");
          auto dstMuxSize = getIntAttrValue(dstOp, "mux_size");

          // In Vivado HLS, a memory access with undetermined partition index
          // will be implemented as a function call with a multiplexer. As
          // function call has dependency with any load/store operation, RAR
          // dependency is also considered here, but with a separate if
          // statement to check whether the current dependency really exists in
          // Vivado HLS.
          if (isa<AffineReadOpInterface>(dstOp) &&
              isa<AffineReadOpInterface>(srcOp)) {
            // TODO: refine this condition with more case studies.
            if (srcMuxSize <= 2 && dstMuxSize <= 2)
              continue;
          }

          MemRefAccess srcAccess(srcOp);
          MemRefAccess dstAccess(dstOp);

          auto commonLoopDepth = getNumCommonSurroundingLoops(*srcOp, *dstOp);
          for (unsigned depth = 1; depth <= commonLoopDepth + 1; ++depth) {
            // Initialize constraints.
            FlatAffineConstraints dependConstrs;

            // Check dependency.
            DependenceResult result = checkMemrefAccessDependence(
                srcAccess, dstAccess, depth, &dependConstrs,
                /*dependenceComponents=*/nullptr, /*allowRAR=*/true);

            // All solid dependencies are pushed into the dependsMap output.
            if (hasDependence(result)) {
              dependsMap[srcOp].push_back(dstOp);
              break;
            }
          }
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
void HLSCppEstimator::getPartitionIndex(Operation *op) {
  auto access = MemRefAccess(op);
  auto memrefType = access.memref.getType().cast<MemRefType>();

  AffineValueMap accessMap;
  access.getAccessMap(&accessMap);

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

  // Compose the access map with the layout map.
  auto layoutMap = getLayoutMap(memrefType, memrefType.getContext());
  if (layoutMap.isEmpty()) {
    setAttrValue(op, "partition_index", (int64_t)0);
    return;
  }
  auto composeMap = layoutMap.compose(newMap);

  // Collect partition factors.
  SmallVector<int64_t, 4> factors;
  getPartitionFactors(memrefType, &factors);

  // Calculate the partition index of this load/store operation honoring the
  // partition strategy applied.
  int64_t partitionIdx = 0;
  int64_t accumFactor = 1;
  int64_t muxSize = 1;

  for (int64_t dim = 0; dim < memrefType.getRank(); ++dim) {
    auto idxExpr = composeMap.getResult(dim);

    if (auto constExpr = idxExpr.dyn_cast<AffineConstantExpr>())
      partitionIdx += constExpr.getValue() * accumFactor;
    else {
      partitionIdx = -1;
      muxSize *= factors[dim];
    }

    accumFactor *= factors[dim];
  }

  setAttrValue(op, "partition_index", partitionIdx);
  if (partitionIdx == -1)
    setAttrValue(op, "mux_size", muxSize);
}

/// Schedule load/store operation honoring the memory ports number limitation.
void HLSCppEstimator::estimateLoadStore(Operation *op, int64_t begin) {
  auto access = MemRefAccess(op);
  auto memref = access.memref;
  auto memrefType = memref.getType().cast<MemRefType>();

  auto partitionIdx = getIntAttrValue(op, "partition_index");
  auto partitionNum = getPartitionFactors(memrefType);
  auto storageType = MemoryKind(memrefType.getMemorySpace());

  // Try to avoid memory port violation until a legal schedule is found. Since
  // an infinite length schedule cannot be generated, this while loop can be
  // proofed to have an end.
  while (true) {
    auto memPort = portsMapDict[begin][memref];
    bool memPortEmpty = memPort.empty();

    // If the memory has not been occupied by the current schedule level, it
    // should be initialized according to its storage type. Note that each
    // partition should have one PortInfo structure.
    if (memPortEmpty) {
      for (unsigned p = 0; p < partitionNum; ++p) {
        unsigned rdPort = 0;
        unsigned wrPort = 0;
        unsigned rdwrPort = 0;

        if (storageType == MemoryKind::BRAM_1P)
          rdwrPort = 1;
        else if (storageType == MemoryKind::BRAM_S2P)
          rdPort = 1, wrPort = 1;
        else if (storageType == MemoryKind::BRAM_T2P)
          rdwrPort = 2;
        else
          rdPort = 1, wrPort = 1;

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
      portsMapDict[begin][memref] = memPort;
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

/// Calculate the minimum resource II.
int64_t HLSCppEstimator::getResMinII(MemAccessesMap &map) {
  int64_t II = 1;

  for (auto &pair : map) {
    auto memrefType = pair.first.getType().cast<MemRefType>();
    auto partitionNum = getPartitionFactors(memrefType);
    auto storageType = MemoryKind(memrefType.getMemorySpace());

    SmallVector<int64_t, 16> readNum;
    SmallVector<int64_t, 16> writeNum;
    for (unsigned i = 0, e = partitionNum; i < e; ++i) {
      readNum.push_back(0);
      writeNum.push_back(0);
    }

    auto loadStores = pair.second;

    for (auto op : loadStores) {
      auto partitionIdx = getIntAttrValue(op, "partition_index");
      if (partitionIdx == -1) {
        int64_t accessNum = 1;
        if (storageType == MemoryKind::BRAM_1P ||
            storageType == MemoryKind::BRAM_S2P)
          accessNum = 1;
        else if (storageType == MemoryKind::BRAM_T2P)
          accessNum = 2;
        else
          accessNum = 1;

        // The rationale here is an undetermined partition access will introduce
        // a large mux which will avoid Vivado HLS to process any concurrent
        // data access among all partitions. This is equivalent to increase read
        // or write number for all partitions.
        // TODO: need to be further refined with more case studies.
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

    int64_t minII = 1;
    if (storageType == MemoryKind::BRAM_1P)
      for (unsigned i = 0, e = partitionNum; i < e; ++i)
        minII = max(minII, readNum[i] + writeNum[i]);

    else if (storageType == MemoryKind::BRAM_S2P)
      minII = max({minII, *std::max_element(readNum.begin(), readNum.end()),
                   *std::max_element(writeNum.begin(), writeNum.end())});

    // TODO: need to be further refined.
    else if (storageType == MemoryKind::BRAM_T2P)
      for (unsigned i = 0, e = partitionNum; i < e; ++i)
        minII = max(minII, (readNum[i] + writeNum[i] - 1) / 2 + 1);

    II = max(II, minII);
  }
  return II;
}

/// Calculate the minimum dependency II of function.
int64_t HLSCppEstimator::getDepMinII(FuncOp func, MemAccessesMap &map) {
  int64_t II = 1;

  for (auto &pair : map) {
    auto loadStores = pair.second;

    // Walk through each pair of source and destination. Note that here dstOp is
    // always before srcOp.
    int64_t dstIndex = 1;
    for (auto dstOp : loadStores) {
      for (auto srcOp : llvm::drop_begin(loadStores, dstIndex)) {
        auto srcMuxSize = getIntAttrValue(srcOp, "mux_size");
        auto dstMuxSize = getIntAttrValue(dstOp, "mux_size");

        // Similar to getFuncDependencies() method, we ignore RAR dependency
        // pairs in some cases.
        if (isa<AffineReadOpInterface>(dstOp) &&
            isa<AffineReadOpInterface>(srcOp)) {
          // TODO: refine this condition with more case studies.
          if (srcMuxSize <= 2 && dstMuxSize <= 2)
            continue;
        }

        if (MemRefAccess(dstOp) == MemRefAccess(srcOp)) {
          float delay = getIntAttrValue(dstOp, "schedule_end") -
                        getIntAttrValue(srcOp, "schedule_begin");

          // Distance is always 1. Therefore, the minimum II is equal to delay.
          int64_t minII = delay;
          II = max(II, minII);
        }
      }
      dstIndex++;
    }
  }
  return II;
}

/// Calculate the minimum dependency II of loop.
int64_t HLSCppEstimator::getDepMinII(AffineForOp forOp, MemAccessesMap &map) {
  int64_t II = 1;

  // Collect start and end level of the pipeline.
  int64_t endLevel = 1;
  int64_t startLevel = 1;
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
    // that are pipelined. Note that here dstOp is always before srcOp.
    for (unsigned loopDepth = startLevel; loopDepth <= endLevel; ++loopDepth) {
      int64_t dstIndex = 1;
      for (auto dstOp : loadStores) {
        for (auto srcOp : llvm::drop_begin(loadStores, dstIndex)) {
          auto srcMuxSize = getIntAttrValue(srcOp, "mux_size");
          auto dstMuxSize = getIntAttrValue(dstOp, "mux_size");

          // Similar to getFuncDependencies() method, in some cases RAR is not
          // considered as dependency in Vivado HLS.
          if (isa<AffineReadOpInterface>(srcOp) &&
              isa<AffineReadOpInterface>(dstOp)) {
            // TODO: refine this condition with more case studies.
            if (srcMuxSize <= 2 && dstMuxSize <= 2)
              continue;
          }

          MemRefAccess dstAccess(dstOp);
          MemRefAccess srcAccess(srcOp);

          FlatAffineConstraints depConstrs;
          SmallVector<DependenceComponent, 2> depComps;

          DependenceResult result = checkMemrefAccessDependence(
              srcAccess, dstAccess, loopDepth, &depConstrs, &depComps,
              /*allowRAR=*/true);

          if (hasDependence(result)) {
            int64_t distance = 0;

            // Call function will always have dependency with any other
            // load/store operations with a distance of 1.
            // TODO: This condition may not be correct. Need more case studies.
            if (srcMuxSize > 2 || dstMuxSize > 2)
              distance = 1;
            else {
              SmallVector<int64_t, 2> accumTripCounts;
              accumTripCounts.push_back(1);

              // Calculate the distance of this dependency.
              for (auto i = depComps.rbegin(); i < depComps.rend(); ++i) {
                auto dep = *i;
                auto tripCount = getIntAttrValue(dep.op, "trip_count");

                if (dep.lb)
                  distance += accumTripCounts.back() * dep.lb.getValue();

                accumTripCounts.push_back(accumTripCounts.back() * tripCount);
              }
            }

            // We will only consider intra-dependencies with positive distance.
            if (distance > 0) {
              float delay = getIntAttrValue(dstOp, "schedule_end") -
                            getIntAttrValue(srcOp, "schedule_begin");

              int64_t minII = ceil(delay / distance);
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

bool HLSCppEstimator::visitOp(AffineForOp op, int64_t begin) {
  auto end = begin;
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
    setAttrValue(op, "trip_count", (int64_t)tripCount.getValue());
  else {
    // TODO: how to handle unknown trip count.
    setAttrValue(op, "trip_count", (int64_t)1);
  }

  // If the current loop is annotated as pipelined loop, extra dependency and
  // resource aware II analysis will be executed.
  if (getBoolAttrValue(op, "pipeline")) {
    // Collect load and store operations in the loop block for solving possible
    // carried dependencies.
    // TODO: include CallOps, how? It seems dependencies always exist for all
    // CallOps not matter its access pattern.
    MemAccessesMap map;
    getMemAccessesMap(loopBlock, map);

    // Calculate initial interval.
    auto II = max(getResMinII(map), getDepMinII(op, map));
    setAttrValue(op, "init_interval", II);

    auto tripCount = getIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", tripCount);

    // Calculate latency of each iteration.
    auto iterLatency = end - begin;
    setAttrValue(op, "iter_latency", iterLatency);

    auto latency = iterLatency + II * (tripCount - 1);
    setAttrValue(op, "latency", latency);

    // Entering and leaving a loop will consume extra 2 clock cycles.
    setScheduleValue(op, begin, begin + latency + 2);

    // Estimate the loop block resource utilization.
    setResourceValue(op, estimateResource(loopBlock, II));
    return true;
  }

  // If the current loop is annotated as flatten, it will be flattened into the
  // child pipelined loop. This will increase the flattened loop trip count
  // without changing the iteration latency.
  if (getBoolAttrValue(op, "flatten")) {
    auto child = dyn_cast<AffineForOp>(op.getLoopBody().front().front());
    assert(child && "the first containing operation is not a loop");

    auto iterLatency = getIntAttrValue(child, "iter_latency");
    setAttrValue(op, "iter_latency", iterLatency);

    auto II = getIntAttrValue(child, "init_interval");
    setAttrValue(op, "init_interval", II);

    auto flattenTripCount = getIntAttrValue(child, "flatten_trip_count") *
                            getIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", flattenTripCount);

    auto latency = iterLatency + II * (flattenTripCount - 1);
    setAttrValue(op, "latency", latency);

    // Since the loop is flattened, it will no longer be entered and left.
    setScheduleValue(op, begin, begin + latency);

    // The resource utilization of flattened loop is equal to its child's.
    setAttrValue(op, "dsp", getIntAttrValue(child, "dsp"));
    return true;
  }

  // Default case (not flattend or pipelined), calculate latency and resource
  // utilization accordingly.
  auto iterLatency = end - begin;
  setAttrValue(op, "iter_latency", iterLatency);

  auto latency = iterLatency * getIntAttrValue(op, "trip_count");
  setAttrValue(op, "latency", latency);

  setScheduleValue(op, begin, begin + latency + 2);
  setResourceValue(op, estimateResource(loopBlock));
  return true;
}

//===----------------------------------------------------------------------===//
// Other Operation Handlers
//===----------------------------------------------------------------------===//

bool HLSCppEstimator::visitOp(AffineIfOp op, int64_t begin) {
  auto end = begin;
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

bool HLSCppEstimator::visitOp(mlir::CallOp op, int64_t begin) {
  auto callee = SymbolTable::lookupSymbolIn(func.getParentOp(), op.getCallee());
  auto subFunc = dyn_cast<FuncOp>(callee);
  assert(subFunc && "callable is not a function operation");

  HLSCppEstimator estimator(subFunc, latencyMap);
  estimator.estimateFunc();

  // We assume enter and leave the subfunction require extra 2 clock cycles.
  if (auto subLatency = getIntAttrValue(subFunc, "latency")) {
    setScheduleValue(op, begin, begin + subLatency + 2);
    return true;
  } else
    return false;
}

//===----------------------------------------------------------------------===//
// Block Scheduler and Estimator
//===----------------------------------------------------------------------===//

// TODO: name to change.
int64_t HLSCppEstimator::getResourceMap(Block &block, ResourceMap &addFMap,
                                        ResourceMap &mulFMap) {
  int64_t loopResource = 0;
  for (auto &op : block) {
    auto begin = getIntAttrValue(&op, "schedule_begin");
    auto end = getIntAttrValue(&op, "schedule_end");

    // Accumulate the resource utilization of each operation.
    if (isa<AddFOp, SubFOp>(op))
      for (unsigned i = begin; i < end; ++i)
        addFMap[i]++;

    else if (isa<MulFOp>(op))
      for (unsigned i = begin; i < end; ++i)
        mulFMap[i]++;

    else if (isa<AffineForOp>(op))
      loopResource += getIntAttrValue(&op, "dsp");

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

HLSCppEstimator::Resource HLSCppEstimator::estimateResource(Block &block,
                                                            int64_t interval) {
  ResourceMap addFMap;
  ResourceMap mulFMap;
  auto loopResource = getResourceMap(block, addFMap, mulFMap);

  // Find the max resource utilization across all schedule levels.
  int64_t maxAddF = 0;
  int64_t totalAddF = 0;
  for (auto level : addFMap) {
    maxAddF = max(maxAddF, level.second);
    totalAddF += level.second;
  }

  int64_t maxMulF = 0;
  int64_t totalMulF = 0;
  for (auto level : mulFMap) {
    maxMulF = max(maxMulF, level.second);
    totalMulF += level.second;
  }

  // Calculate the total fadd and fmul number as each operation will cover
  // {latency + 1} scheduling level.
  totalAddF /= (latencyMap["fadd"] + 1);
  totalMulF /= (latencyMap["fmul"] + 1);

  // We assume the loop resource utilization cannot be shared. Therefore, the
  // overall resource utilization is loops' plus other operstions'. According to
  // profiling, floating-point add and muliply will consume 2 and 3 DSP units,
  // respectively.
  auto dsp = loopResource + maxAddF * 2 + maxMulF * 3;

  // If the block is pipelined (interval is positive), the minimum resource
  // utilization is determined by interval.
  if (interval > 0) {
    auto minResource = (totalAddF * 2 + totalMulF * 3) / interval;
    dsp = loopResource + max(maxAddF * 2 + maxMulF * 3, minResource);
  }

  // TODO
  int64_t bram = 0;
  int64_t ff = 0;
  int64_t lut = 0;
  return Resource(bram, dsp, ff, lut);
}

/// Estimate the latency of a block with ALAP scheduling strategy, return the
/// end level of schedule. Meanwhile, the input begin will also be updated if
/// required (typically happens in AffineForOps).
Optional<std::pair<int64_t, int64_t>>
HLSCppEstimator::estimateBlock(Block &block, int64_t begin) {
  auto blockBegin = begin;
  auto blockEnd = begin;

  // Reversely walk through all operations in the block.
  for (auto i = block.rbegin(), e = block.rend(); i != e; ++i) {
    auto op = &*i;
    auto opBegin = begin;
    auto opEnd = begin;

    // Fine the latest arrived successor relying on the current operation.
    for (auto result : op->getResults())
      for (auto user : result.getUsers()) {
        auto sameLevelUser = getSameLevelDstOp(op, user);
        opBegin = max(opBegin, getIntAttrValue(sameLevelUser, "schedule_end"));
      }

    // Check dependencies of the operation and update schedule level.
    for (auto dstOp : dependsMap[op]) {
      auto sameLevelDstOp = getSameLevelDstOp(op, dstOp);
      opBegin = max(opBegin, getIntAttrValue(sameLevelDstOp, "schedule_end"));
    }

    // Estimate the current operation.
    if (dispatchVisitor(op, opBegin))
      opEnd = max(opEnd, getIntAttrValue(op, "schedule_end"));
    else
      return Optional<std::pair<int64_t, int64_t>>();

    // Update the block schedule end and begin.
    if (i == block.rbegin())
      blockBegin = opBegin;
    else
      blockBegin = min(blockBegin, opBegin);

    blockEnd = max(blockEnd, opEnd);
  }
  return std::pair<int64_t, int64_t>(blockBegin, blockEnd);
}

// Get the innermost surrounding operation, either an AffineForOp or a FuncOp.
// In this method, AffineIfOp is transparent as well.
static Operation *getSurroundingOp(Operation *op) {
  auto currentOp = op;
  while (true) {
    if (auto parentIfOp = currentOp->getParentOfType<AffineIfOp>())
      currentOp = parentIfOp;
    else if (auto parentForOp = currentOp->getParentOfType<AffineForOp>())
      return parentForOp;
    else if (auto parentFuncOp = currentOp->getParentOfType<FuncOp>())
      return parentFuncOp;
    else
      return nullptr;
  }
}

void HLSCppEstimator::reverseSchedule() {
  func.walk([&](Operation *op) {
    // Get schedule level.
    auto begin = getIntAttrValue(op, "schedule_begin");
    auto end = getIntAttrValue(op, "schedule_end");

    // Reverse schedule level.
    if (auto surOp = getSurroundingOp(op)) {
      if (isa<mlir::AffineForOp>(surOp)) {
        auto surOpBegin = getIntAttrValue(surOp, "schedule_begin");

        if (getBoolAttrValue(surOp, "flatten")) {
          // Handle flattened surrounding loops.
          setScheduleValue(op, surOpBegin, surOpBegin + end - begin);
        } else {
          // Handle normal cases.
          auto iterLatency = getIntAttrValue(surOp, "iter_latency");
          setScheduleValue(op, surOpBegin + iterLatency - end,
                           surOpBegin + iterLatency - begin);
        }
      } else if (isa<FuncOp>(surOp)) {
        auto latency = getIntAttrValue(surOp, "latency");
        setScheduleValue(op, latency - end, latency - begin);
      }
    }
  });
}

void HLSCppEstimator::estimateFunc() {
  // Collect all memory access operations for later use.
  MemAccessesMap map;
  getMemAccessesMap(func.front(), map);

  // Recursively estimate blocks in the function.
  if (auto schedule = estimateBlock(func.front(), 0)) {
    auto latency = schedule.getValue().second;
    setAttrValue(func, "latency", latency);

    if (getBoolAttrValue(func, "dataflow")) {
      // TODO: support dataflow interval estimation.
    }

    // TODO: support CallOp inside of the function.
    if (getBoolAttrValue(func, "pipeline")) {
      auto II = max(getResMinII(map), getDepMinII(func, map));
      setAttrValue(func, "interval", II);
    }

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
  auto interval = getIntAttrValue(func, "interval");
  auto resource = estimateResource(func.front(), interval);

  // Calculate the function memrefs BRAM utilization.
  int64_t numBram = 0;
  for (auto &pair : map) {
    auto memrefType = pair.first.getType().cast<MemRefType>();
    auto partitionNum = getPartitionFactors(memrefType);
    auto storageType = MemoryKind(memrefType.getMemorySpace());

    if (storageType == MemoryKind::BRAM_1P ||
        storageType == MemoryKind::BRAM_S2P ||
        storageType == MemoryKind::BRAM_T2P) {
      // Multiply bit width of type.
      // TODO: handle index types.
      int64_t memrefSize =
          memrefType.getElementTypeBitWidth() * memrefType.getNumElements();
      numBram += ((memrefSize + 18000 - 1) / 18000) * partitionNum;
    }
  }
  resource.bram += numBram;

  setResourceValue(func, resource);
  // TODO: estimate BRAM and LUT utilization.
}

//===----------------------------------------------------------------------===//
// Entry of scalehls-opt
//===----------------------------------------------------------------------===//

void scalehls::getLatencyMap(INIReader spec, LatencyMap &latencyMap) {
  auto freq = spec.Get("specification", "frequency", "100MHz");

  latencyMap["fadd"] = spec.GetInteger(freq, "fadd", 4);
  latencyMap["fmul"] = spec.GetInteger(freq, "fmul", 3);
  latencyMap["fdiv"] = spec.GetInteger(freq, "fdiv", 15);
  latencyMap["fcmp"] = spec.GetInteger(freq, "fcmp", 1);
}

namespace {
struct QoREstimation : public scalehls::QoREstimationBase<QoREstimation> {
  void runOnOperation() override {
    auto module = getOperation();

    // Read configuration file.
    INIReader spec(targetSpec);
    if (spec.ParseError())
      module.emitError(
          "target spec file parse fail, please pass in correct file path\n");

    // Collect profiling latency data.
    LatencyMap latencyMap;
    getLatencyMap(spec, latencyMap);

    // Estimate performance and resource utilization.
    for (auto func : module.getOps<FuncOp>())
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
