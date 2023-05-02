add_mlir_public_c_api_library(MLIRScaleHLSCAPIHLSDialect
  HLS.cpp
  Passes.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir-c

  PARTIAL_SOURCES_INTENDED
  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRCAPIIR
  MLIRScaleHLSHLSDialect
  MLIRScaleHLSHLSTransforms
  )
