add_mlir_dialect_library(MLIRHLSCpp
  HLSCpp.cpp

  DEPENDS
  MLIRHLSCppIncGen
  MLIRHLSCppEnumsIncGen
  MLIRHLSCppAttributesIncGen
  )
