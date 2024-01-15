set(LLVM_TARGET_DEFINITIONS HLSTransformOps.td)
mlir_tablegen(HLSTransformOps.h.inc -gen-op-decls)
mlir_tablegen(HLSTransformOps.cpp.inc -gen-op-defs)
add_public_tablegen_target(MLIRScaleHLSHLSTransformOpsIncGen)
