add_mlir_library(MLIRScaleHLSUtils
  Matchers.cpp
  Utils.cpp

  LINK_LIBS PUBLIC
  MLIRScaleHLSHLSDialect
)
