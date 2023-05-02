add_mlir_public_c_api_library(MLIRScaleHLSCAPIConversions
  Passes.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir-c

  PARTIAL_SOURCES_INTENDED
  DEPENDS
  MLIRScaleHLSConversionsIncGen

  LINK_LIBS PUBLIC
  MLIRCAPIIR
  MLIRScaleHLSConversions
  )
