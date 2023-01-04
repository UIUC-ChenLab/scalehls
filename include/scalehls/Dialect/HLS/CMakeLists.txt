add_mlir_dialect(HLSOps hls)

set(LLVM_TARGET_DEFINITIONS HLSAttributes.td)
mlir_tablegen(HLSOpsEnums.h.inc -gen-enum-decls)
mlir_tablegen(HLSOpsEnums.cpp.inc -gen-enum-defs)
add_public_tablegen_target(MLIRHLSEnumsIncGen)

set(LLVM_TARGET_DEFINITIONS HLSAttributes.td)
mlir_tablegen(HLSOpsAttributes.h.inc -gen-attrdef-decls)
mlir_tablegen(HLSOpsAttributes.cpp.inc -gen-attrdef-defs)
add_public_tablegen_target(MLIRHLSAttributesIncGen)

set(LLVM_TARGET_DEFINITIONS HLSInterfaces.td)
mlir_tablegen(HLSOpsInterfaces.h.inc -gen-op-interface-decls)
mlir_tablegen(HLSOpsInterfaces.cpp.inc -gen-op-interface-defs)
add_public_tablegen_target(MLIRHLSInterfacesIncGen)
