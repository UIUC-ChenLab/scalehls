add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  PreprocessDataflow.cpp
  ConvertTensorToStream.cpp
  CreateDataflow.cpp
  LowerDataflow.cpp
  ConvertDataflowToFunc.cpp
  ApplyTransformPattern.cpp
  ComprehensiveBufferize.cpp
  GenerateRuntimeFunc.cpp
  LowerCopyToAffineLoops.cpp
  RaiseSCFToAffine.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRLinalgTransforms
  MLIRAffineTransforms
)
