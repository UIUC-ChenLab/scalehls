add_mlir_public_c_api_library(MLIRScaleHLSCAPIHLSDialect
  HLS.cpp
  Passes.cpp

  LINK_LIBS PUBLIC
  MLIRCAPIIR
  MLIRScaleHLSHLSDialect
  MLIRScaleHLSHLSTransforms
)
