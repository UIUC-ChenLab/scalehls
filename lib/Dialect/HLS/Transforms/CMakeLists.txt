add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  Preprocess.cpp
  ReduceTensorToStream.cpp
  StripStreamIterInfo.cpp
  MaterializeStream.cpp
  ScalarizeStream.cpp
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
