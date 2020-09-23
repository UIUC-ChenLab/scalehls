file(GLOB globbed *.cpp)

add_mlir_library(MLIRScaleHLSTransforms
  ${globbed}

  DEPENDS
  MLIRScaleHLSTransformsIncGen

  LINK_LIBS PUBLIC
  MLIRHLSCpp
  )
