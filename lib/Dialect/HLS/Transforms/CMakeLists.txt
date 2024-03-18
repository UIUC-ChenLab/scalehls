add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  Preprocess.cpp
  ReduceFullTensorToITensor.cpp
  MaterializeITensor.cpp
  ScalarizeITensor.cpp
  LowerITensorToStream.cpp
  ScheduleDataflow.cpp
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
