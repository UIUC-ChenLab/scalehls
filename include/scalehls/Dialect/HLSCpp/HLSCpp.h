//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_HLSCPP_H
#define SCALEHLS_DIALECT_HLSCPP_HLSCPP_H

#include "mlir/IR/Dialect.h"
#include "mlir/IR/OpDefinition.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

namespace mlir {
namespace scalehls {
namespace hlscpp {

enum class MemoryKind { BRAM_1P = 0, BRAM_S2P = 1, BRAM_T2P = 2, DRAM = 3 };

enum class PartitionKind { CYCLIC = 0, BLOCK = 1, NONE = 2 };

} // namespace hlscpp
} // namespace scalehls
} // namespace mlir

#include "scalehls/Dialect/HLSCpp/HLSCppDialect.h.inc"
#include "scalehls/Dialect/HLSCpp/HLSCppEnums.h.inc"

#define GET_OP_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCpp.h.inc"

#define GET_ATTRDEF_CLASSES
#include "scalehls/Dialect/HLSCpp/HLSCppAttributes.h.inc"

#endif // SCALEHLS_DIALECT_HLSCPP_HLSCPP_H
