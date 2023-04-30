add_mlir_dialect_library(MLIRHLSTransforms
  BufferizableOpInterfaceImpl.cpp
  EliminateBufferYield.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSHLSTransformsIncGen
  )
