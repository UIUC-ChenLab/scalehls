add_mlir_library(MLIRScaleHLSUtils
  Utils.cpp

  LINK_LIBS PUBLIC
  MLIRScaleHLSHLSDialect
  )
