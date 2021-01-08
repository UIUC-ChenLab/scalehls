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

enum class MemoryKind {
  BRAM_1P = 0,
  BRAM_S2P = 1,
  BRAM_T2P = 2,

  // URAM_1P = 3,
  // URAM_S2P = 4,
  // URAM_T2P = 5,

  DRAM = 3
};

enum class PartitionKind { CYCLIC = 0, BLOCK = 1, NONE = 2 };

} // namespace hlscpp
} // namespace scalehls
} // namespace mlir

#include "Dialect/HLSCpp/HLSCppEnums.h.inc"

#include "Dialect/HLSCpp/HLSCppDialect.h.inc"

#define GET_OP_CLASSES
#include "Dialect/HLSCpp/HLSCpp.h.inc"

#endif // SCALEHLS_DIALECT_HLSCPP_HLSCPP_H
