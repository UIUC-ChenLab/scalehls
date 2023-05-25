add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  LowerDataflow.cpp
  EliminateBufferYield.cpp
  ParameterizeIPCandidate.cpp
  ParameterizeTileParallelFactor.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
)
