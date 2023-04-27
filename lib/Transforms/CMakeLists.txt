add_mlir_library(MLIRScaleHLSTransforms
  Passes.cpp
  Utils.cpp

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRHLS
  )
