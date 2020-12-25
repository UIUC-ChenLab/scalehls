//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_HLSCPP_H
#define SCALEHLS_DIALECT_HLSCPP_HLSCPP_H

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/IR/Builders.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Dialect.h"

namespace mlir {
namespace scalehls {
namespace hlscpp {

#include "Dialect/HLSCpp/HLSCppInterfaces.h.inc"

} // namespace hlscpp
} // namespace scalehls
} // namespace mlir

#include "Dialect/HLSCpp/HLSCppEnums.h.inc"

#include "Dialect/HLSCpp/HLSCppDialect.h.inc"

#define GET_OP_CLASSES
#include "Dialect/HLSCpp/HLSCpp.h.inc"

#endif // SCALEHLS_DIALECT_HLSCPP_HLSCPP_H
