add_mlir_library(MLIRScaleHLSTransforms
  ConvertFDFToSDF.cpp
  ConvertLinalgToFDF.cpp
  ConvertSDFToFunc.cpp
  ComprehensiveBufferize.cpp
  GenerateRuntimeFunc.cpp
  Pipelines.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen
)
