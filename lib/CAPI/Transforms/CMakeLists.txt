add_mlir_public_c_api_library(MLIRScaleHLSCAPITransforms
  Passes.cpp

  LINK_LIBS PUBLIC
  MLIRCAPIIR
  MLIRScaleHLSTransforms
)
