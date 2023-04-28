add_mlir_library(MLIRScaleHLSTransforms
  ComprehensiveBufferize.cpp
  Passes.cpp
  Utils.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRHLS
  )
