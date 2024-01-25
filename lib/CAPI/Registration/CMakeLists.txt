add_mlir_public_c_api_library(MLIRScaleHLSCAPIRegistration
  Registration.cpp

  LINK_LIBS PUBLIC
  MLIRCAPIIR
  MLIRScaleHLSHLSDialect
  MLIRScaleHLSHLSTransforms
)
