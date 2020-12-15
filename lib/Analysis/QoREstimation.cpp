//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/QoREstimation.h"
#include "Analysis/Passes.h"
#include "Dialect/HLSCpp/HLSCpp.h"
#include "mlir/Analysis/AffineAnalysis.h"
#include "mlir/Analysis/AffineStructures.h"
#include "mlir/Analysis/Liveness.h"
#include "mlir/Analysis/LoopAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/PatternMatch.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

//===----------------------------------------------------------------------===//
// HLSCppEstimator Class Definition
//===----------------------------------------------------------------------===//

/// Estimator constructor.
HLSCppEstimator::HLSCppEstimator(OpBuilder &builder, string targetSpecPath)
    : HLSCppToolBase(builder) {

  INIReader targetSpec(targetSpecPath);
  if (targetSpec.ParseError())
    llvm::outs() << "error: target spec file parse fail, please refer to "
                    "--help option and pass in correct file path\n";

  // TODO: Support estimator initiation from profiling data.
  auto freq = targetSpec.Get("spec", "frequency", "200MHz");
  auto latency = targetSpec.GetInteger(freq, "op", 0);
  llvm::outs() << latency << "\n";
}

/// Collect memory access information of the block.
void HLSCppEstimator::getBlockMemInfo(Block &block, LoadStoreDict &dict) {
  // Walk through all load/store operations in the current block.
  block.walk([&](Operation *op) {
    if (isa<mlir::AffineReadOpInterface, mlir::AffineWriteOpInterface>(op)) {
      auto memAccess = MemRefAccess(op);
      auto arrayOp = cast<ArrayOp>(memAccess.memref.getDefiningOp());

      AffineValueMap accessMap;
      memAccess.getAccessMap(&accessMap);

      dict[arrayOp].push_back(op);

      // Calculate the partition index of this load/store operation honoring the
      // partition strategy applied.
      int32_t partitionIdx = 0;
      unsigned accumFactor = 1;
      unsigned dim = 0;
      for (auto expr : accessMap.getAffineMap().getResults()) {
        auto idxExpr = getConstExpr(0);
        unsigned factor = 1;
        if (arrayOp.partition()) {
          auto type = getPartitionType(arrayOp, dim);
          factor = getPartitionFactor(arrayOp, dim);

          if (type == "cyclic")
            idxExpr = expr % getConstExpr(factor);
          else if (type == "block") {
            auto size = arrayOp.getType().cast<ShapedType>().getShape()[dim];
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
        dim++;
      }

      // Set partition index attribute.
      setAttrValue(op, "partition_index", partitionIdx);
    }
  });
}

/// Calculate load/store operation schedule honoring the memory ports number
/// limitation. This method will be called by getBlockSchedule method.
unsigned HLSCppEstimator::getLoadStoreSchedule(Operation *op, unsigned begin,
                                               MemPortDicts &dicts) {
  auto memAccess = MemRefAccess(op);
  auto arrayOp = cast<ArrayOp>(memAccess.memref.getDefiningOp());

  auto partitionIdx = getIntAttrValue(op, "partition_index");
  auto partitionNum = getUIntAttrValue(arrayOp, "partition_num");
  auto storageType = getStrAttrValue(arrayOp, "storage_type");

  // Try to avoid memory port violation until a legal schedule is found.
  // Since an infinite length pipeline can be generated, this while loop can
  // be proofed to have an end.
  while (true) {
    auto memPort = dicts[begin][arrayOp];
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
          // arrayOp.emitError("unsupported storage type.");
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
        dicts[begin][arrayOp] = memPort;
        break;
      } else {
        if (++begin >= dicts.size()) {
          MemPortDict memPortDict;
          dicts.push_back(memPortDict);
        }
      }
    }

    // Find whether the current schedule meets memory port limitation. If
    // not, the schedule will increase by 1.
    PortInfo portInfo = memPort[partitionIdx];
    if (isa<AffineLoadOp>(op) && portInfo.rdPort > 0) {
      memPort[partitionIdx].rdPort -= 1;
      dicts[begin][arrayOp] = memPort;
      break;
    } else if (isa<AffineStoreOp>(op) && portInfo.wrPort > 0) {
      memPort[partitionIdx].wrPort -= 1;
      dicts[begin][arrayOp] = memPort;
      break;
    } else if (portInfo.rdwrPort > 0) {
      memPort[partitionIdx].rdwrPort -= 1;
      dicts[begin][arrayOp] = memPort;
      break;
    } else {
      if (++begin >= dicts.size()) {
        MemPortDict memPortDict;
        dicts.push_back(memPortDict);
      }
    }
  }
  return begin;
}

void HLSCppEstimator::updateChildBlockSchedule(Block &block, unsigned begin) {
  for (auto &op : block) {
    unsigned newBegin = begin;
    unsigned newEnd = begin;

    // Update the schedule of all operations in the child block.
    if (getUIntAttrValue(&op, "schedule_end")) {
      newBegin += getUIntAttrValue(&op, "schedule_begin");
      newEnd += getUIntAttrValue(&op, "schedule_end");
      setAttrValue(&op, "schedule_begin", newBegin);
      setAttrValue(&op, "schedule_end", newEnd);
    }

    // Recursively apply to all child blocks.
    if (op.getNumRegions()) {
      for (auto &region : op.getRegions()) {
        for (auto &block : region.getBlocks())
          updateChildBlockSchedule(block, begin);
      }
    }
  }
}

/// Schedule the block with ASAP algorithm.
unsigned HLSCppEstimator::getBlockSchedule(Block &block) {
  unsigned blockEnd = 0;
  MemPortDicts dicts;

  for (auto &op : block) {
    // Find the latest predecessor dominating the current operation. This
    // should be considered as the earliest stage that the current operation
    // can be scheduled.
    unsigned begin = 0;
    unsigned end = 0;
    for (auto operand : op.getOperands()) {
      if (auto defOp = operand.getDefiningOp())
        begin = max(getUIntAttrValue(defOp, "schedule_end"), begin);
    }

    // Handle loop operations.
    if (auto forOp = dyn_cast<AffineForOp>(op)) {
      // Live ins of the for loop body will also impact the schedule begin.
      Liveness liveness(block.getParentOp());
      for (auto liveIn : liveness.getLiveIn(&forOp.getLoopBody().front())) {
        if (auto defOp = liveIn.getDefiningOp())
          begin = max(getUIntAttrValue(defOp, "schedule_end"), begin);
      }

      // Update the schedule of all operations in the loop body.
      updateChildBlockSchedule(forOp.getLoopBody().front(), begin);

      // Child loop is considered as a large node, and two extra clock cycles
      // will be required to enter and exit the child loop.
      end = begin + getUIntAttrValue(forOp, "latency") + 2;
    }

    // Handle if operations.
    else if (auto ifOp = dyn_cast<AffineIfOp>(op)) {
      // Live ins of the if body will also impact the schedule begin.
      Liveness liveness(block.getParentOp());
      for (auto liveIn : liveness.getLiveIn(ifOp.getThenBlock())) {
        if (auto defOp = liveIn.getDefiningOp())
          begin = max(getUIntAttrValue(defOp, "schedule_end"), begin);
      }

      if (ifOp.hasElse()) {
        for (auto liveIn : liveness.getLiveIn(ifOp.getElseBlock())) {
          if (auto defOp = liveIn.getDefiningOp())
            begin = max(getUIntAttrValue(defOp, "schedule_end"), begin);
        }
        // Update the schedule of all operations in the else block.
        updateChildBlockSchedule(*ifOp.getElseBlock(), begin);
      }

      // Update the schedule of all operations in the then block.
      updateChildBlockSchedule(*ifOp.getThenBlock(), begin);

      end = begin + getUIntAttrValue(ifOp, "latency");
    }

    // Handle load/store operations.
    else if (isa<AffineReadOpInterface, AffineWriteOpInterface>(op)) {
      // Insert new schedule level to the memory port dicts.
      while (begin >= dicts.size()) {
        MemPortDict memPortDict;
        dicts.push_back(memPortDict);
      }

      // Ensure the current schedule meets memory port limitation.
      begin = getLoadStoreSchedule(&op, begin, dicts);
      end = begin + 1;
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

/// Calculate the minimum resource II.
unsigned HLSCppEstimator::getResMinII(AffineForOp forOp, LoadStoreDict dict) {
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
unsigned HLSCppEstimator::getDepMinII(AffineForOp forOp, LoadStoreDict dict) {
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
    // that are pipelined.
    for (auto loopDepth = startLevel; loopDepth <= endLevel; ++loopDepth) {
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
            unsigned distance = 0;

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

            if (distance != 0) {
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

bool HLSCppEstimator::visitOp(AffineForOp op) {
  auto &body = op.getLoopBody();
  if (body.getBlocks().size() != 1) {
    op.emitError("has zero or more than one basic blocks.");
    return false;
  }

  // Recursively estimate all contained operations.
  if (!estimateBlock(body.front()))
    return false;

  // Set an attribute indicating the trip count. For now, we assume all
  // loops have static loop bound.
  if (auto tripCount = getConstantTripCount(op))
    setAttrValue(op, "trip_count", (unsigned)tripCount.getValue());
  else {
    setAttrValue(op, "trip_count", (unsigned)0);
    op.emitError("has undetermined trip count");
    return false;
  }

  // If the current loop is annotated as pipeline, extra dependency and II
  // analysis will be executed.
  if (getBoolAttrValue(op, "pipeline")) {
    LoadStoreDict dict;
    getBlockMemInfo(body.front(), dict);

    // Calculate latency of each iteration.
    auto iterLatency = getBlockSchedule(body.front());
    setAttrValue(op, "iter_latency", iterLatency);

    // Calculate initial interval.
    auto II = max(getResMinII(op, dict), getDepMinII(op, dict));
    setAttrValue(op, "init_interval", II);

    auto tripCount = getUIntAttrValue(op, "trip_count");
    setAttrValue(op, "flatten_trip_count", tripCount);

    setAttrValue(op, "latency", iterLatency + II * (tripCount - 1));
    return true;
  }

  // This means the current loop can be flattened into the child loop. If the
  // child loop is pipelined, this will increase the flattened loop trip count
  // without changing the iteration latency. Note that this will be propogated
  // above until meeting an imperfect loop.
  if (getBoolAttrValue(op, "flatten")) {
    if (auto child = dyn_cast<AffineForOp>(op.getLoopBody().front().front())) {
      // This means the inner loop is pipelined, because otherwise II will be
      // equal to zero. So that in this case, this loop will be flattened into
      // the inner pipelined loop.
      if (auto II = getUIntAttrValue(child, "init_interval")) {
        setAttrValue(op, "init_interval", II);

        auto iterLatency = getUIntAttrValue(child, "iter_latency");
        setAttrValue(op, "iter_latency", iterLatency);

        auto flattenTripCount = getUIntAttrValue(child, "flatten_trip_count") *
                                getUIntAttrValue(op, "trip_count");
        setAttrValue(op, "flatten_trip_count", flattenTripCount);

        setAttrValue(op, "latency", iterLatency + II * (flattenTripCount - 1));
      } else {
        auto iterLatency = getUIntAttrValue(child, "latency");
        setAttrValue(op, "iter_latency", iterLatency);

        unsigned latency = iterLatency * getUIntAttrValue(op, "trip_count");
        setAttrValue(op, "latency", latency);
      }
      return true;
    }
  }

  // Default case, aka !pipeline && !flatten.
  LoadStoreDict dict;
  getBlockMemInfo(body.front(), dict);

  auto iterLatency = getBlockSchedule(body.front());
  setAttrValue(op, "iter_latency", iterLatency);

  unsigned latency = iterLatency * getUIntAttrValue(op, "trip_count");
  setAttrValue(op, "latency", latency);
  return true;
}

bool HLSCppEstimator::visitOp(AffineIfOp op) {
  auto thenBlock = op.getThenBlock();
  if (!estimateBlock(*thenBlock))
    return false;

  LoadStoreDict dict;
  getBlockMemInfo(*thenBlock, dict);
  auto latency = getBlockSchedule(*thenBlock);

  // Handle else block if required.
  if (op.hasElse()) {
    auto elseBlock = op.getElseBlock();
    if (!estimateBlock(*elseBlock))
      return false;

    getBlockMemInfo(*elseBlock, dict);
    latency = max(latency, getBlockSchedule(*elseBlock));
  }

  setAttrValue(op, "latency", latency);
  return true;
}

bool HLSCppEstimator::visitOp(ArrayOp op) {
  unsigned partitionNum = 1;
  if (op.partition()) {
    auto rank = op.getType().cast<ShapedType>().getRank();
    for (unsigned i = 0; i < rank; ++i) {
      if (auto factor = getPartitionFactor(op, i))
        partitionNum *= factor;
    }
  }
  setAttrValue(op, "partition_num", partitionNum);
  return true;
}

bool HLSCppEstimator::estimateBlock(Block &block) {
  for (auto &op : block) {
    if (dispatchVisitor(&op))
      continue;
    else {
      op.emitError("can't be correctly estimated.");
      return false;
    }
  }
  return true;
}

bool HLSCppEstimator::estimateFunc(FuncOp func) {
  if (func.getBlocks().size() != 1) {
    func.emitError("has zero or more than one basic blocks.");
    return false;
  }

  // Recursively estimate all contained operations.
  if (!estimateBlock(func.front()))
    return false;

  LoadStoreDict dict;
  getBlockMemInfo(func.front(), dict);

  auto latency = getBlockSchedule(func.front());
  setAttrValue(func, "latency", latency);
  return true;
}

//===----------------------------------------------------------------------===//
// Entry of scalehls-opt
//===----------------------------------------------------------------------===//

namespace {
struct QoREstimation : public scalehls::QoREstimationBase<QoREstimation> {
  void runOnOperation() override {
    auto module = getOperation();
    auto builder = OpBuilder(module);

    // Estimate performance and resource utilization.
    HLSCppEstimator estimator(builder, targetSpec);
    for (auto func : module.getOps<FuncOp>())
      estimator.estimateFunc(func);
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
