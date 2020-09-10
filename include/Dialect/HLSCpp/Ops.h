//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_OPS_H
#define SCALEHLS_DIALECT_HLSCPP_OPS_H

#include "Dialect/HLSCpp/Dialect.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

namespace mlir {
namespace scalehls {
namespace hlscpp {

#define GET_OP_CLASSES
#include "Dialect/HLSCpp/HLSCpp.h.inc"

} // namespace hlscpp
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLSCPP_OPS_H
