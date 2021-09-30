file(GLOB globbed *.cpp)

add_mlir_library(MLIRScaleHLSSupport
  ${globbed}
  )
