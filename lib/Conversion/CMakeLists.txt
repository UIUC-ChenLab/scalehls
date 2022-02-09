add_mlir_library(MLIRScaleHLSConversion
  LegalizeOnnx.cpp
  LegalizeToHLSCpp.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSConversionIncGen
  )
