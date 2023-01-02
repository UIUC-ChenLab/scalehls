add_mlir_dialect(HLSOps hls)

set(LLVM_TARGET_DEFINITIONS HLSAttributes.td)
mlir_tablegen(HLSEnums.h.inc -gen-enum-decls)
mlir_tablegen(HLSEnums.cpp.inc -gen-enum-defs)
add_public_tablegen_target(MLIRHLSEnumsIncGen)

set(LLVM_TARGET_DEFINITIONS HLSAttributes.td)
mlir_tablegen(HLSAttributes.h.inc -gen-attrdef-decls)
mlir_tablegen(HLSAttributes.cpp.inc -gen-attrdef-defs)
add_public_tablegen_target(MLIRHLSAttributesIncGen)

set(LLVM_TARGET_DEFINITIONS HLSInterfaces.td)
mlir_tablegen(HLSInterfaces.h.inc -gen-op-interface-decls)
mlir_tablegen(HLSInterfaces.cpp.inc -gen-op-interface-defs)
add_public_tablegen_target(MLIRHLSInterfacesIncGen)
