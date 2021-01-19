//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSKERNEL_HLSKERNEL_H
#define SCALEHLS_DIALECT_HLSKERNEL_HLSKERNEL_H

#include "mlir/IR/BuiltinAttributes.h"
#include "mlir/IR/BuiltinTypes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpDefinition.h"

namespace mlir {
namespace scalehls {
namespace hlskernel {

#include "scalehls/Dialect/HLSKernel/HLSKernelInterfaces.h.inc"

} // namespace hlskernel
} // namespace scalehls
} // namespace mlir

#include "scalehls/Dialect/HLSKernel/HLSKernelDialect.h.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLSKernel/HLSKernel.h.inc"

#endif // SCALEHLS_DIALECT_HLSKERNEL_HLSKERNEL_H
