add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  ReduceFullTensorToITensorBuffer.cpp
  MaterializeITensorDMA.cpp
  PackITensorDMA.cpp
  ScalarizeITensor.cpp
  LowerITensorToStream.cpp
  ScheduleDataflow.cpp
  ConvertEmptyToInstance.cpp
  ConvertDataflowToFunc.cpp
  TransformInterpreter.cpp
  ComprehensiveBufferize.cpp
  GenerateDataflowHierarchy.cpp
  RaiseSCFToAffine.cpp
  ApplyDirectives.cpp
  GenerateDirectives.cpp
  EnsureITensorSingleUse.cpp
  StripAnnotations.cpp
  FuseLinalgFill.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRLinalgTransforms
  MLIRAffineTransforms
)
