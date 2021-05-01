add_mlir_dialect(HLSCpp hlscpp)

set(LLVM_TARGET_DEFINITIONS HLSCpp.td)
mlir_tablegen(HLSCppEnums.h.inc -gen-enum-decls)
mlir_tablegen(HLSCppEnums.cpp.inc -gen-enum-defs)
add_public_tablegen_target(MLIRHLSCppEnumsIncGen)

set(LLVM_TARGET_DEFINITIONS HLSCpp.td)
mlir_tablegen(HLSCppAttributes.h.inc -gen-attrdef-decls)
mlir_tablegen(HLSCppAttributes.cpp.inc -gen-attrdef-defs)
add_public_tablegen_target(MLIRHLSCppAttributesIncGen)
