add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  PreprocessDataflow.cpp
  CreateDataflow.cpp
  LowerDataflow.cpp
  ConvertDataflowToFunc.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
)
