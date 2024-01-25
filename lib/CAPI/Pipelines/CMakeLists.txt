add_mlir_public_c_api_library(MLIRScaleHLSCAPIPipelines
  Pipelines.cpp

  LINK_LIBS PUBLIC
  MLIRScaleHLSPipelines
)
