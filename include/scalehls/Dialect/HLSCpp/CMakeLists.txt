add_mlir_dialect(HLSCpp hlscpp)

set(LLVM_TARGET_DEFINITIONS Interfaces.td)
mlir_tablegen(HLSCppInterfaces.h.inc -gen-op-interface-decls)
mlir_tablegen(HLSCppInterfaces.cpp.inc -gen-op-interface-defs)
add_public_tablegen_target(MLIRHLSCppInterfacesIncGen)

# set(LLVM_TARGET_DEFINITIONS HLSCpp.td)
# mlir_tablegen(HLSCppEnums.h.inc -gen-enum-decls)
# mlir_tablegen(HLSCppEnums.cpp.inc -gen-enum-defs)
# add_public_tablegen_target(MLIRHLSCppEnumsIncGen)
