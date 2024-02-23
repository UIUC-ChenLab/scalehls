//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_C_DIALECT_HLS_HLS_H
#define SCALEHLS_C_DIALECT_HLS_HLS_H

#include "mlir-c/RegisterEverything.h"
#include <vector>

#ifdef __cplusplus
extern "C" {
#endif

//===----------------------------------------------------------------------===//
// HLS Dialect Operations
//===----------------------------------------------------------------------===//

MLIR_DECLARE_CAPI_DIALECT_REGISTRATION(HLS, hls);

MLIR_CAPI_EXPORTED void
mlirSemanticsInitializeBlockArguments(MlirOperation semantics,
                                      const std::vector<MlirValue> &ports);

//===----------------------------------------------------------------------===//
// HLS Dialect Attributes
//===----------------------------------------------------------------------===//

enum class MlirMemoryKind : uint32_t {
  UNKNOWN = 0,
  LUTRAM_1P = 1,
  LUTRAM_2P = 2,
  LUTRAM_S2P = 3,
  BRAM_1P = 4,
  BRAM_2P = 5,
  BRAM_S2P = 6,
  BRAM_T2P = 7,
  URAM_1P = 8,
  URAM_2P = 9,
  URAM_S2P = 10,
  URAM_T2P = 11,
  DRAM = 12
};

MLIR_CAPI_EXPORTED bool mlirAttrIsHLSMemoryKindAttr(MlirAttribute attr);
MLIR_CAPI_EXPORTED MlirAttribute mlirHLSMemoryKindAttrGet(MlirContext ctx,
                                                          MlirMemoryKind kind);
MLIR_CAPI_EXPORTED MlirMemoryKind
mlirHLSMemoryKindAttrGetValue(MlirAttribute attr);

#ifdef __cplusplus
}
#endif

#endif // SCALEHLS_C_DIALECT_HLS_HLS_H
