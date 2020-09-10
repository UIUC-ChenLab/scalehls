//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_DIALECT_H
#define SCALEHLS_DIALECT_HLSCPP_DIALECT_H

#include "mlir/IR/Dialect.h"

namespace mlir {
namespace scalehls {
namespace hlscpp {

#include "Dialect/HLSCpp/HLSCppDialect.h.inc"

} // namespace hlscpp
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLSCPP_DIALECT_H
