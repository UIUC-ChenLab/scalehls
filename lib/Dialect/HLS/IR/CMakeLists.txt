add_mlir_dialect_library(MLIRScaleHLSHLSDialect
  HLS.cpp
  HLSAttributes.cpp
  HLSOps.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRScaleHLSHLSEnumsIncGen
  MLIRScaleHLSHLSAttributesIncGen
  MLIRScaleHLSHLSInterfacesIncGen
)
