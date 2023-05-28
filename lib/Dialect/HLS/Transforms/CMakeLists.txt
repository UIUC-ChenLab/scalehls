add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  LowerDataflow.cpp
  EliminateBufferYield.cpp
  GenerateTaskDesignSpace.cpp
  ImplementTaskDesignSpace.cpp
  SimplifyDesignSpace.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
)
