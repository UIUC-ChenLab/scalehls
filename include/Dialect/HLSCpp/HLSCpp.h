//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_HLSCPP_H
#define SCALEHLS_DIALECT_HLSCPP_HLSCPP_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/Function.h"

namespace mlir {
namespace scalehls {
namespace hlscpp {

#include "Dialect/HLSCpp/HLSCppDialect.h.inc"
#include "Dialect/HLSCpp/HLSCppInterfaces.h.inc"

#define GET_OP_CLASSES
#include "Dialect/HLSCpp/HLSCpp.h.inc"

} // namespace hlscpp
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLSCPP_HLSCPP_H
