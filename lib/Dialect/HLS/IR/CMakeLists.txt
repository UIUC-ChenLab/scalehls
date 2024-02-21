add_mlir_dialect_library(MLIRScaleHLSHLSDialect
  HLS.cpp
  HLSAttributes.cpp
  HLSOps.cpp
  HLSTypes.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRScaleHLSHLSEnumsIncGen
  MLIRScaleHLSHLSAttributesIncGen
  MLIRScaleHLSHLSOpsInterfacesIncGen
  MLIRScaleHLSHLSTypesInterfacesIncGen
)
