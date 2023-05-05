add_mlir_public_c_api_library(MLIRScaleHLSCAPIEmitHLSCpp
  EmitHLSCpp.cpp

  LINK_LIBS PUBLIC
  MLIRScaleHLSEmitHLSCpp
)
