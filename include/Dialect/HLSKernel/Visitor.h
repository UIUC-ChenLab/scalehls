//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_VISITOR_H
#define SCALEHLS_DIALECT_HLSKERNEL_VISITOR_H

#include "Dialect/HLSKernel/HLSKernel.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "llvm/ADT/TypeSwitch.h"

namespace mlir {
namespace scalehls {

using namespace hlskernel;

template <typename ConcreteType, typename ResultType, typename... ExtraArgs>
class HLSKernelVisitorBase {
public:
  ResultType dispatchVisitor(Operation *op, ExtraArgs... args) {
    auto *thisCast = static_cast<ConcreteType *>(this);
    return TypeSwitch<Operation *, ResultType>(op)
        .template Case<
            // CNN operations.
            DenseOp, ConvOp, MaxPoolOp, ReluOp, MergeOp, CopyOp,
            // ISP operations.
            CpOp, SobelOp, HarrisOp, DeblurOp, UpsampleOp, DownsampleOp,
            // BLAS operations.
            GemmOp, SymmOp, SyrkOp, Syr2kOp, TrmmOp>(
            [&](auto opNode) -> ResultType {
              return thisCast->visitOp(opNode, args...);
            })
        .Default([&](auto opNode) -> ResultType {
          return thisCast->visitInvalidOp(op, args...);
        });
  }

  /// This callback is invoked on any invalid operations.
  ResultType visitInvalidOp(Operation *op, ExtraArgs... args) {
    op->emitOpError("is unsupported operation.");
    abort();
  }

  /// This callback is invoked on any operations that are not handled by the
  /// concrete visitor.
  ResultType visitUnhandledOp(Operation *op, ExtraArgs... args) {
    return ResultType();
  }

#define HANDLE(OPTYPE)                                                         \
  ResultType visitOp(OPTYPE op, ExtraArgs... args) {                           \
    return static_cast<ConcreteType *>(this)->visitUnhandledOp(op, args...);   \
  }

  // CNN operations.
  HANDLE(DenseOp);
  HANDLE(ConvOp);
  HANDLE(MaxPoolOp);
  HANDLE(ReluOp);
  HANDLE(MergeOp);
  HANDLE(CopyOp);

  // ISP operations.
  HANDLE(CpOp);
  HANDLE(SobelOp);
  HANDLE(HarrisOp);
  HANDLE(DeblurOp);
  HANDLE(UpsampleOp);
  HANDLE(DownsampleOp);

  // BLAS operations.
  HANDLE(GemmOp);
  HANDLE(SymmOp);
  HANDLE(SyrkOp);
  HANDLE(Syr2kOp);
  HANDLE(TrmmOp);

#undef HANDLE
};
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLSKERNEL_VISITOR_H