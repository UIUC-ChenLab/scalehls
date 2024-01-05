add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  LowerDataflow.cpp
  EliminateBufferYield.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
)
