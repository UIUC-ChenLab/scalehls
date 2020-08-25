set(LLVM_LINK_COMPONENTS
  Support
  )

get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(translation_libs GLOBAL PROPERTY MLIR_TRANSLATION_LIBS)

set(LIBS
  ${dialect_libs}
  ${translation_libs}
  MLIRIR
  MLIRParser
  MLIRPass
  MLIRTranslation
  MLIRSupport

  HLSLDEmitHLSCpp
  )

add_llvm_executable(hlsld-translate hlsld-translate.cpp)

llvm_update_compile_flags(hlsld-translate)
target_link_libraries(hlsld-translate PRIVATE ${LIBS})

mlir_check_link_libraries(hlsld-translate)
