add_mlir_public_c_api_library(MLIRScaleHLSCAPITransforms
  Passes.cpp
  Pipelines.cpp

  LINK_LIBS PUBLIC
  MLIRCAPIIR
  MLIRScaleHLSTransforms
)
