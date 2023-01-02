add_mlir_dialect_library(MLIRHLS
  HLS.cpp
  Analysis.cpp
  Utils.cpp

  DEPENDS
  MLIRHLSOpsIncGen
  MLIRHLSEnumsIncGen
  MLIRHLSAttributesIncGen
  MLIRHLSInterfacesIncGen
  )
