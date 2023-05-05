add_mlir_dialect_library(MLIRScaleHLSHLSDialect
  HLS.cpp
  HLSAttributes.cpp
  HLSDSEOps.cpp
  HLSFDFOps.cpp
  HLSSDFOps.cpp
  HLSUBUFOps.cpp
  HLSUIPOps.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRScaleHLSHLSEnumsIncGen
  MLIRScaleHLSHLSAttributesIncGen
  MLIRScaleHLSHLSInterfacesIncGen
)
