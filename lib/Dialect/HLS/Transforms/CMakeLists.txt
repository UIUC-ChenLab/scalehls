add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  LowerDataflow.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
)
