add_mlir_library(MLIRScaleHLSTransforms
  ConvertLinalgToDataflow.cpp
  ConvertDataflowToFunc.cpp
  ComprehensiveBufferize.cpp
  GenerateRuntimeFunc.cpp
  LowerCopyToAffineLoops.cpp
  Pipelines.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRLinalgTransforms
  MLIRAffineTransforms
)
