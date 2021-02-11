get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)

add_llvm_tool(benchmark-gen
  benchmark-gen.cpp
  )

llvm_update_compile_flags(benchmark-gen)

target_link_libraries(benchmark-gen
  PRIVATE
  ${dialect_libs}

  MLIRHLSKernel
  )
