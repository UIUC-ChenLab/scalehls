get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)

add_mlir_library(MLIRScaleHLSEmitHLSCpp
  EmitHLSCpp.cpp

  LINK_LIBS PUBLIC
  ${dialect_libs}
  MLIRScaleHLSHLSDialect
  MLIRScaleHLSAnalysis
  )
