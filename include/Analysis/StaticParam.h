//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_STATICPARAM_H
#define SCALEHLS_ANALYSIS_STATICPARAM_H

#include "mlir/IR/Operation.h"
#include "mlir/IR/Value.h"

namespace mlir {
namespace scalehls {

//===----------------------------------------------------------------------===//
// ParamBase class
//===----------------------------------------------------------------------===//

template <typename ParamKind, typename KeyType> class ParamBase {
public:
  void init(KeyType key) {
    for (unsigned i = 0; i < (unsigned)ParamKind::KindNum; ++i)
      Params[key].push_back(0);
  }

  unsigned get(KeyType key, ParamKind kind) {
    return Params[key][(unsigned)kind];
  }

  void set(KeyType key, ParamKind kind, unsigned param) {
    Params[key][(unsigned)kind] = param;
  }

  DenseMap<KeyType, SmallVector<unsigned, 16>> Params;
};

//===----------------------------------------------------------------------===//
// ProcParam and MemParam classes
//===----------------------------------------------------------------------===//

enum class ProcParamKind {
  // Process-related pragam configurations.
  EnablePipeline,
  UnrollFactor,

  // Process attributes.
  LowerBound,
  UpperBound,
  IterNumber,
  IsPerfect,

  // Performance parameters.
  InitInterval,
  IterLatency,
  PipeIterNumber,
  Latency,

  // Resource parameters.
  LUT,
  BRAM,
  DSP,

  KindNum = DSP + 1
};

enum class MemParamKind {
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

  // Resource parameters.
  LUT,
  BRAM,

  KindNum = BRAM + 1
};

/// This class includes all possible parameters kind for "processes" (function,
/// for/parallel loop, and if).
class ProcParam : public ParamBase<ProcParamKind, Operation *> {
  // Process-related pragam configurations.
  unsigned getEnablePipeline(Operation *op) {
    return get(op, ProcParamKind::EnablePipeline);
  }
  unsigned getUnrollFactor(Operation *op) {
    return get(op, ProcParamKind::UnrollFactor);
  }

  // Process attributes.
  unsigned getLowerBound(Operation *op) {
    return get(op, ProcParamKind::LowerBound);
  }
  unsigned getUpperBound(Operation *op) {
    return get(op, ProcParamKind::UpperBound);
  }
  unsigned getIterNumber(Operation *op) {
    return get(op, ProcParamKind::IterNumber);
  }
  unsigned getIsPerfect(Operation *op) {
    return get(op, ProcParamKind::IsPerfect);
  }

  // Performance parameters.
  unsigned getInitInterval(Operation *op) {
    return get(op, ProcParamKind::InitInterval);
  }
  unsigned getIterLatency(Operation *op) {
    return get(op, ProcParamKind::IterLatency);
  }
  unsigned getPipeIterNumber(Operation *op) {
    return get(op, ProcParamKind::PipeIterNumber);
  }
  unsigned getLatency(Operation *op) { return get(op, ProcParamKind::Latency); }

  // Resource parameters.
  unsigned getLUT(Operation *op) { return get(op, ProcParamKind::LUT); }
  unsigned getBRAM(Operation *op) { return get(op, ProcParamKind::BRAM); }
  unsigned getDSP(Operation *op) { return get(op, ProcParamKind::DSP); }
};

/// This class includes all possible parameters kind for memories (memref,
/// tensor, and vector).
class MemParam : public ParamBase<MemParamKind, Value> {};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_ANALYSIS_STATICPARAM_H
