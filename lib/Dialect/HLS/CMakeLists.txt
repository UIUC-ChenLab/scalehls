add_mlir_dialect_library(MLIRHLS
  HLS.cpp
  HLSAttributes.cpp
  HLSOps.cpp
  Analysis.cpp
  Utils.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRHLSEnumsIncGen
  MLIRHLSAttributesIncGen
  MLIRHLSInterfacesIncGen
  )
