project(scalehls-lsp-server)

add_executable(${PROJECT_NAME}
    scalehls-lsp-server.cpp
)

# Link all standard MLIR dialect and conversion libs.
get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(conversion_libs GLOBAL PROPERTY MLIR_CONVERSION_LIBS)
get_property(circt_dialect_libs GLOBAL PROPERTY CIRCT_DIALECT_LIBS)
target_link_libraries(${PROJECT_NAME}
    PRIVATE
    MLIRLspServerLib

    ${circt_dialect_libs}

    ${dialect_libs}
    ${conversion_libs}
)