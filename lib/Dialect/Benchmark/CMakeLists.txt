file(GLOB globbed *.cpp)

add_mlir_dialect_library(MLIRBenchmark
  ${globbed}

  DEPENDS
  MLIRBenchmarkIncGen
  )
