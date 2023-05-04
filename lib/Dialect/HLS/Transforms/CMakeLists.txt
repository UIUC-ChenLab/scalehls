add_mlir_dialect_library(MLIRScaleHLSHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  EliminateBufferYield.cpp
  ParameterizeDataflowTask.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
  )
