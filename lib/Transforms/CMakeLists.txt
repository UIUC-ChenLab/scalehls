add_mlir_library(MLIRScaleHLSTransforms
  ConvertFDFToSDF.cpp
  ConvertLinalgToFDF.cpp
  ConvertSDFToFunc.cpp
  ComprehensiveBufferize.cpp
  GenerateRuntimeFunc.cpp
  Pipelines.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRScaleHLSHLSDialect
  )
