add_mlir_library(MLIRScaleHLSConversion
  ConvertOnnxToTosa.cpp
  LegalizeOnnx.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSConversionIncGen
  )
