add_mlir_library(MLIRScaleHLSConversions
  Passes.cpp

  DEPENDS
  MLIRScaleHLSConversionsIncGen

  LINK_LIBS PUBLIC
  MLIRHLS
  )
