add_mlir_library(MLIRScaleHLSConversion
  LegalizeOnnx.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSConversionIncGen
  )
