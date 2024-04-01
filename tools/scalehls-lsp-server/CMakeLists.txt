set(LLVM_OPTIONAL_SOURCES
  null.cpp
)

get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(conversion_libs GLOBAL PROPERTY MLIR_CONVERSION_LIBS)
set(LLVM_LINK_COMPONENTS
  Core
  Support
  AsmParser
)

if(MLIR_INCLUDE_TESTS)
  set(test_libs
    MLIRAffineTransformsTestPasses
    MLIRShapeTestPasses
    MLIRSPIRVTestPasses
    MLIRTestAnalysis
    MLIRTestDialect
    MLIRTestIR
    MLIRTestPass
    MLIRTestReducer
    MLIRTestRewrite
    MLIRTestTransforms
    )
endif()

add_llvm_tool(scalehls-lsp-server
  scalehls-lsp-server.cpp
)

llvm_update_compile_flags(scalehls-lsp-server)

target_link_libraries(scalehls-lsp-server
  PRIVATE
  ${dialect_libs}
  ${conversion_libs}
  ${test_libs}
  MLIRAnalysis
  MLIRDialect
  MLIRLspServerLib
  MLIRParser
  MLIRPass
  MLIRTransforms
  MLIRTransformUtils
  MLIRSupport
  MLIRIR

  MLIRScaleHLSHLSDialect
  MLIRScaleHLSHLSTransforms
  MLIRScaleHLSHLSTransformOps
  MLIRScaleHLSUtils
)

mlir_check_all_link_libraries(scalehls-lsp-server)
