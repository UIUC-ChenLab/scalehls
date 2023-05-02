add_mlir_library(MLIRScaleHLSConversions
  ConvertFDFToSDF.cpp
  ConvertLinalgToFDF.cpp
  ConvertSDFToFunc.cpp
  Passes.cpp

  DEPENDS
  MLIRScaleHLSConversionsIncGen

  LINK_LIBS PUBLIC
  MLIRScaleHLSHLSDialect
  )
