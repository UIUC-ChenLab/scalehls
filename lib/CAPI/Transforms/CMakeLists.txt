add_mlir_public_c_api_library(MLIRScaleHLSCAPITransforms
  Passes.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir-c

  PARTIAL_SOURCES_INTENDED
  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRCAPIIR
  MLIRScaleHLSTransforms
  )
