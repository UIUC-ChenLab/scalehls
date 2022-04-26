add_mlir_dialect_library(MLIRHLS
  HLS.cpp

  DEPENDS
  MLIRHLSIncGen
  MLIRHLSEnumsIncGen
  MLIRHLSAttributesIncGen
  )
