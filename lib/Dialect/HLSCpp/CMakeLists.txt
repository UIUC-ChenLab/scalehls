file(GLOB globbed *.cpp)

add_mlir_dialect_library(MLIRHLSCpp
  ${globbed}

  ADDITIONAL_HEADER_DIRS
  ${PROJECT_SOURCE_DIR}/include/Dialect/HLSCpp

  DEPENDS
  MLIRHLSCppIncGen

	LINK_LIBS PUBLIC
	MLIRIR
	)
