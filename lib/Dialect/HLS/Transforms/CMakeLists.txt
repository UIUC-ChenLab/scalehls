add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  Preprocess.cpp
  ReduceFullTensorToITensorBuffer.cpp
  MaterializeITensorDMA.cpp
  PackITensorDMA.cpp
  ScalarizeITensor.cpp
  LowerITensorToStream.cpp
  ScheduleDataflow.cpp
  ConvertTensorInitToTensorInstance.cpp
  ConvertDataflowToFunc.cpp
  TransformInterpreter.cpp
  ComprehensiveBufferize.cpp
  GenerateDataflowHierarchy.cpp
  RaiseSCFToAffine.cpp
  ApplyDirectives.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRLinalgTransforms
  MLIRAffineTransforms
)
