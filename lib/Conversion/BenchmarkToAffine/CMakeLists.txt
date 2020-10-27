file(GLOB globbed *.cpp)

add_mlir_library(MLIRBenchmarkToAffine
  ${globbed}
  )
