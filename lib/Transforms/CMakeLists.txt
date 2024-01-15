add_mlir_library(MLIRScaleHLSTransforms
  ApplyTransformPattern.cpp
  ComprehensiveBufferize.cpp
  GenerateRuntimeFunc.cpp
  LowerCopyToAffineLoops.cpp
  Pipelines.cpp
  RaiseSCFToAffine.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRLinalgTransforms
  MLIRAffineTransforms
)
