add_mlir_library(MLIRScaleHLSConversion
  ConvertOnnxToTosa.cpp
  LegalizeOnnx.cpp
  LegalizeToHLSCpp.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSConversionIncGen
  )
