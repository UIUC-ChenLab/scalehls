file(GLOB globbed *.cpp)

add_mlir_library(MLIRScaleHLSSupport
  ${globbed}

  LINK_LIBS PUBLIC
  MLIRHLSCpp
  )
