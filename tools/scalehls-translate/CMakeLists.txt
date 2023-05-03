get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(translation_libs GLOBAL PROPERTY MLIR_TRANSLATION_LIBS)

set(LLVM_LINK_COMPONENTS
  Support
  )

add_llvm_tool(scalehls-translate
  scalehls-translate.cpp
  )

llvm_update_compile_flags(scalehls-translate)

target_link_libraries(scalehls-translate
  PRIVATE
  ${dialect_libs}
  ${translation_libs}

  MLIRScaleHLSHLSDialect
  MLIRScaleHLSUtils
  MLIRScaleHLSEmitHLSCpp
  )
