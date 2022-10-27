add_mlir_dialect_library(MLIRHLS
  HLS.cpp
  Analysis.cpp
  Utils.cpp

  DEPENDS
  MLIRHLSIncGen
  MLIRHLSEnumsIncGen
  MLIRHLSAttributesIncGen
  MLIRHLSInterfacesIncGen
  )
