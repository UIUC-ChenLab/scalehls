add_mlir_public_c_api_library(MLIRScaleHLSCAPITransformsUtils
  Utils.cpp

  ADDITIONAL_HEADER_DIRS
  ${MLIR_MAIN_INCLUDE_DIR}/mlir-c

  LINK_LIBS PUBLIC
  MLIRCAPIIR
  MLIRScaleHLSConversion
  MLIRScaleHLSTransforms
  )
