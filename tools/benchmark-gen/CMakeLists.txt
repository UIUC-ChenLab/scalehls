get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)

set(LIBS
  ${dialect_libs}

  MLIRHLSKernel
  )

add_llvm_executable(benchmark-gen benchmark-gen.cpp)

llvm_update_compile_flags(benchmark-gen)
target_link_libraries(benchmark-gen PRIVATE ${LIBS})
