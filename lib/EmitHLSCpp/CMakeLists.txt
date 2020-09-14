file(GLOB globbed *.cpp)

add_mlir_library(MLIREmitHLSCpp
  ${globbed}

  LINK_LIBS PUBLIC
  MLIRHLSCpp
  )
