add_mlir_library(MLIRScaleHLSTransforms
  ComprehensiveBufferize.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRHLSDialect
  )
