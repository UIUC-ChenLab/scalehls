//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Transforms/INIReader.h"
#include "Transforms/Passes.h"

using namespace std;
using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

/// This class includes all possible parameters kind for "processes" (function,
/// for/parallel loop, and if).
enum class ProcParam {
  // Pragam configurations.
  EnablePipeline,
  InitialInterval,
  UnrollFactor,

  // Performance parameters.
  LoopBound,
  IterLatency,
  Latency,

  // Resource parameters.
  LUT,
  DSP,
  BRAM
};

/// This class includes all possible parameters kind for memories (memref,
/// tensor, and vector).
enum class MemParam {
  // Pragma configurations.
  StorageType,
  StorageImpl,
  PartitionType,
  PartitionFactor,
  InterfaceMode,

  // Performance parameters.
  ReadNum,
  WriteNum,
  ReadPorts,
  WritePorts,
  DepdcyLatency,
  DepdcyDistance,

  // Resource parameters.
  LUT,
  BRAM
};

namespace {
class QoREstimator {
public:
  explicit QoREstimator(std::string targetSpecPath, std::string opLatencyPath);

  /// Get parameters.
  unsigned getMemParam(Value *mem, MemParam kind) {
    return memParams[mem][(unsigned)kind];
  }
  unsigned getProcParam(Operation *proc, ProcParam kind) {
    return procParams[proc][(unsigned)kind];
  }

  /// These methods can extract static parameters and pragma configurations (if
  /// applicable) of the input CDFG, and update them in procParams or memParams.
  void analyzePragma(ModuleOp module);
  void analyzeModule(ModuleOp module);

  /// These methods can estimate the performance and resource utilization of a
  /// specific MLIR structure, and update them in procParams or memroyParams.
  void estimateAffineFor(AffineForOp affineFor);
  void estimateAffineParallel(AffineParallelOp affineParallel);
  void estimateAffineIf(AffineIfOp affineIf);
  void estimateFunc(FuncOp func);
  void estimateModule(ModuleOp module);

private:
  DenseMap<Operation *, SmallVector<unsigned, 9>> procParams;
  DenseMap<Value *, SmallVector<unsigned, 13>> memParams;

  // Set parameters.
  void setMemParam(Value *mem, unsigned kind, unsigned param) {
    memParams[mem][(unsigned)kind] = param;
  }
  void setProcParam(Operation *proc, MemParam kind, unsigned param) {
    procParams[proc][(unsigned)kind] = param;
  }
};
} // namespace

/// Estimator constructor.
QoREstimator::QoREstimator(std::string targetSpecPath,
                           std::string opLatencyPath) {
  INIReader targetSpec(targetSpecPath);
  if (targetSpec.ParseError())
    llvm::outs() << "error: target spec file parse fail, please refer to "
                    "--help option and pass in correct file path\n";

  INIReader opLatency(opLatencyPath);
  if (opLatency.ParseError())
    llvm::outs() << "error: Op latency file parse fail, please refer to "
                    "--help option and pass in correct file path\n";

  auto freq = targetSpec.Get("config", "frequency", "200MHz");
  auto latency = opLatency.GetInteger(freq, "op", 0);
  llvm::outs() << latency << "\n";
}

/// This method will search the longest path in a DAG block using a ASAP (As
/// Soon As Possible) manner. Loop, function, if, and other operation owning
/// regions will be considered as a whole.
unsigned searchLongestPath(Block &block) {
  DenseMap<Value, unsigned> valueReadyTime;
  unsigned blockReadyTime = 0;
  for (auto &op : block) {

    // Calculate ready time of all predecessors.
    unsigned allPredsReadyTime = 0;
    for (auto operand : op.getOperands()) {
      if (operand.getKind() == Value::Kind::BlockArgument)
        continue;
      else if (operand.getParentBlock() != &block)
        continue;
      else
        allPredsReadyTime = max(allPredsReadyTime, valueReadyTime[operand]);
    }

    // Calculate ready time of the current operation.
    unsigned opReadyTime = allPredsReadyTime + 1;
    for (auto result : op.getResults())
      valueReadyTime[result] = opReadyTime;

    // Update block ready time.
    blockReadyTime = max(blockReadyTime, opReadyTime);
  }
  return blockReadyTime;
}

/// For now, estimation for unrolled loops are following the analytical model
/// of COMBA, which is suspected to be wrong. Meanwhile, we assume the absence
/// of function call in the loop body.
void QoREstimator::estimateAffineFor(AffineForOp affineFor) {
  auto &body = affineFor.getLoopBody();
  if (body.getBlocks().size() != 1)
    affineFor.emitError("has zero or more than one basic blocks.");

  for (auto &op : body.front()) {
    if (auto subAffineFor = dyn_cast<mlir::AffineForOp>(op))
      estimateAffineFor(subAffineFor);
  }
}

/// For now, function pipelining and task-level dataflow optimizations are not
/// considered for simplicity.
void QoREstimator::estimateFunc(FuncOp func) {
  if (func.getBlocks().size() != 1)
    func.emitError("has zero or more than one basic blocks.");

  // Recursively estimate latency of sub-elements, including functions and
  // loops. These sub-elements will be considered as a normal node in the CDFG
  // for function latency estimzation.
  for (auto &op : func.front()) {
    if (auto subFunc = dyn_cast<FuncOp>(op))
      estimateFunc(subFunc);
    else if (auto subAffineFor = dyn_cast<AffineForOp>(op))
      estimateAffineFor(subAffineFor);
  }

  // Estimate function latency.
  llvm::outs() << searchLongestPath(func.front()) << "\n";
}

void QoREstimator::estimateModule(ModuleOp module) {
  for (auto &op : module) {
    if (auto func = dyn_cast<FuncOp>(op))
      estimateFunc(func);
    else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("is unsupported operation.");
  }
}

namespace {
struct QoREstimation : public QoREstimationBase<QoREstimation> {
  void runOnOperation() override {
    QoREstimator(targetSpec, opLatency).estimateModule(getOperation());
  }
};
} // namespace

std::unique_ptr<mlir::Pass> scalehls::createQoREstimationPass() {
  return std::make_unique<QoREstimation>();
}
