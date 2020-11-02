file(GLOB globbed *.cpp)

add_mlir_dialect_library(MLIRHLSKernel
  ${globbed}

  DEPENDS
  MLIRHLSKernelIncGen
  MLIRHLSKernelInterfacesIncGen
  )
