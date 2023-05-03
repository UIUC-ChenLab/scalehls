get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(conversion_libs GLOBAL PROPERTY MLIR_CONVERSION_LIBS)

add_llvm_tool(scalehls-opt
  scalehls-opt.cpp
  )

llvm_update_compile_flags(scalehls-opt)

target_link_libraries(scalehls-opt
  PRIVATE
  ${dialect_libs}
  ${conversion_libs}
  MLIROptLib

  MLIRScaleHLSHLSDialect
  MLIRScaleHLSHLSAnalysis
  MLIRScaleHLSHLSTransforms
  MLIRScaleHLSHLSUtils

  MLIRScaleHLSAnalysis
  MLIRScaleHLSTransforms
  )
