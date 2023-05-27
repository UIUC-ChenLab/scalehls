add_mlir_dialect_library(MLIRScaleHLSHLSDialect
  HLS.cpp
  HLSAttributes.cpp
  HLSDSEOps.cpp
  HLSDataflowOps.cpp
  HLSUBUFOps.cpp
  HLSUIPOps.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRScaleHLSHLSEnumsIncGen
  MLIRScaleHLSHLSAttributesIncGen
  MLIRScaleHLSHLSInterfacesIncGen
)
