file(GLOB globbed *.cpp */*.cpp)

add_mlir_library(MLIRScaleHLSTransforms
  ${globbed}

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRHLSCpp
  MLIRHLSKernel
  )
