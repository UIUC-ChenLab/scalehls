file(GLOB globbed *.cpp)

add_mlir_library(MLIRScaleHLSEmitHLSCpp
  ${globbed}

  LINK_LIBS PUBLIC
  MLIRHLSCpp
  )
