file(GLOB globbed *.cpp)

add_mlir_library(MLIRScaleHLSAnalysis
  ${globbed}

  DEPENDS
  MLIRScaleHLSAnalysisIncGen
  )
