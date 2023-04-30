add_mlir_dialect_library(MLIRHLSDialect
  HLS.cpp
  HLSAttributes.cpp
  HLSOps.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRHLSEnumsIncGen
  MLIRHLSAttributesIncGen
  MLIRHLSInterfacesIncGen
  )
