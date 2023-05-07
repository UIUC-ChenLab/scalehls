add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  EliminateBufferYield.cpp
  MatchIPCandidates.cpp
  ParameterizeDataflowTask.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
)
