add_mlir_dialect(HLS hls)

set(LLVM_TARGET_DEFINITIONS HLS.td)
mlir_tablegen(HLSEnums.h.inc -gen-enum-decls)
mlir_tablegen(HLSEnums.cpp.inc -gen-enum-defs)
add_public_tablegen_target(MLIRHLSEnumsIncGen)

set(LLVM_TARGET_DEFINITIONS HLS.td)
mlir_tablegen(HLSAttributes.h.inc -gen-attrdef-decls)
mlir_tablegen(HLSAttributes.cpp.inc -gen-attrdef-defs)
add_public_tablegen_target(MLIRHLSAttributesIncGen)
