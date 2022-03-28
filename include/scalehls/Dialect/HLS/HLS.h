//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLS_H
#define SCALEHLS_DIALECT_HLS_HLS_H

#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

#include "scalehls/Dialect/HLS/HLSDialect.h.inc"
#include "scalehls/Dialect/HLS/HLSEnums.h.inc"

#define GET_TYPEDEF_CLASSES
#include "scalehls/Dialect/HLS/HLSTypes.h.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLS/HLSAttributes.h.inc"

namespace mlir {

class PatternRewriter;

namespace scalehls {
namespace hls {

class DataflowNodeOp;

enum class MemoryKind { BRAM_S2P = 0, BRAM_T2P = 1, BRAM_1P = 2, DRAM = 3 };
enum class PartitionKind { CYCLIC = 0, BLOCK = 1, NONE = 2 };

/// Fuse the given operations into a new dataflow node. The fused node will be
/// created before the first operation and each operation will be inserted in
/// order. This method always succeeds.
DataflowNodeOp fuseOpsIntoNewNode(ArrayRef<Operation *> ops,
                                  PatternRewriter &rewriter);

/// Get the users of a stream channel. If the channel is used by a function
/// call, this method will recursively look into the corresponding sub-function.
/// If the channel is used by a function return, this method will recursively
/// look into each function that calls the parent function of the return.
void getStreamChannelUsers(Value channel, SmallVectorImpl<Operation *> &users);

/// Timing attribute utils.
TimingAttr getTiming(Operation *op);
void setTiming(Operation *op, TimingAttr timing);
void setTiming(Operation *op, int64_t begin, int64_t end, int64_t latency,
               int64_t interval);

/// Resource attribute utils.
ResourceAttr getResource(Operation *op);
void setResource(Operation *op, ResourceAttr resource);
void setResource(Operation *op, int64_t lut, int64_t dsp, int64_t bram);

/// Loop information attribute utils.
LoopInfoAttr getLoopInfo(Operation *op);
void setLoopInfo(Operation *op, LoopInfoAttr loopInfo);
void setLoopInfo(Operation *op, int64_t flattenTripCount, int64_t iterLatency,
                 int64_t minII);

/// Loop directives attribute utils.
LoopDirectiveAttr getLoopDirective(Operation *op);
void setLoopDirective(Operation *op, LoopDirectiveAttr loopDirective);
void setLoopDirective(Operation *op, bool pipeline, int64_t targetII,
                      bool dataflow, bool flatten);

/// Parrallel and point loop attribute utils.
bool hasParallelAttr(Operation *op);
void setParallelAttr(Operation *op);
bool hasPointAttr(Operation *op);
void setPointAttr(Operation *op);

/// Function directives attribute utils.
FuncDirectiveAttr getFuncDirective(Operation *op);
void setFuncDirective(Operation *op, FuncDirectiveAttr FuncDirective);
void setFuncDirective(Operation *op, bool pipeline, int64_t targetInterval,
                      bool dataflow);

/// Top and runtime function attribute utils.
bool hasTopFuncAttr(Operation *op);
void setTopFuncAttr(Operation *op);
bool hasRuntimeAttr(Operation *op);
void setRuntimeAttr(Operation *op);

} // namespace hls
} // namespace scalehls
} // namespace mlir

namespace mlir {
namespace OpTrait {
template <typename ConcreteType>
class DeclaresStreamChannel
    : public TraitBase<ConcreteType, DeclaresStreamChannel> {
public:
  static LogicalResult verifyTrait(Operation *op) {
    if (op->getNumResults() != 1 ||
        !op->getResult(0).getType().isa<scalehls::hls::StreamType>())
      return failure();
    return success();
  }

  /// Get all users of the channel.
  SmallVector<Operation *, 2> getChannelUsers() {
    SmallVector<Operation *, 2> users;
    scalehls::hls::getStreamChannelUsers(this->getOperation()->getResult(0),
                                         users);
    return users;
  }
};
} // namespace OpTrait
} // namespace mlir

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLS/HLS.h.inc"

#endif // SCALEHLS_DIALECT_HLS_HLS_H
