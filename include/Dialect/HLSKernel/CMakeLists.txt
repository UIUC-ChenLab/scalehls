add_mlir_dialect(HLSKernel hlskernel)

set(LLVM_TARGET_DEFINITIONS HLSKernel.td)
mlir_tablegen(HLSKernelInterfaces.h.inc -gen-op-interface-decls)
mlir_tablegen(HLSKernelInterfaces.cpp.inc -gen-op-interface-defs)
add_public_tablegen_target(MLIRHLSKernelInterfacesIncGen)
