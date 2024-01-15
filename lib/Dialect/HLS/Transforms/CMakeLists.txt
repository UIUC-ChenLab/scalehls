add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  CreateDataflow.cpp
  ConvertEmptyTensorToAllocTensor.cpp
  ConvertDataflowToFunc.cpp
  LowerDataflow.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
)
