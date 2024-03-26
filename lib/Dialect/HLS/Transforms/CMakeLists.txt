add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  Preprocess.cpp
  ReduceFullTensorToITensorBuffer.cpp
  MaterializeITensorDMA.cpp
  PackITensorDMA.cpp
  ScalarizeITensor.cpp
  LowerITensorToStream.cpp
  ScheduleDataflow.cpp
  ConvertDataflowToFunc.cpp
  TransformInterpreter.cpp
  ComprehensiveBufferize.cpp
  GenerateRuntimeFunc.cpp
  RaiseSCFToAffine.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRLinalgTransforms
  MLIRAffineTransforms
)
