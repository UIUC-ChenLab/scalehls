add_mlir_library(MLIRScaleHLSSupport
  Utils.cpp

  LINK_LIBS PUBLIC
  MLIRHLSCpp
  )
