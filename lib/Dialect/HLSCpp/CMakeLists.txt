file(GLOB globbed *.cpp)

add_mlir_dialect_library(MLIRHLSCpp
  ${globbed}

  DEPENDS
  MLIRHLSCppIncGen
  MLIRHLSCppInterfacesIncGen
  MLIRHLSCppEnumsIncGen
  MLIRHLSCppAttributesIncGen
  )
