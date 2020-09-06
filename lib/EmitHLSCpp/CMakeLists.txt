file(GLOB globbed *.cpp)

add_mlir_library(SCALEHLSEmitHLSCpp
  ${globbed}
  
  ADDITIONAL_HEADER_DIRS

  LINK_LIBS PUBLIC
  MLIRStandardOps
  )
