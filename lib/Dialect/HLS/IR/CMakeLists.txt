add_mlir_dialect_library(MLIRHLSDialect
  HLS.cpp
  HLSAttributes.cpp
  HLSDSEOps.cpp
  HLSFDFOps.cpp
  HLSSDFOps.cpp
  HLSUBUFOps.cpp
  HLSUIPOps.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRHLSEnumsIncGen
  MLIRHLSAttributesIncGen
  MLIRHLSInterfacesIncGen
  )
