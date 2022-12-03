declare_mlir_python_sources(ScaleHLSPMLIRPythonSources
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  SOURCES
    pmlir/__init__.py
    pmlir/context.py
    pmlir/func.py
)

add_mlir_python_modules(ScaleHLSPMLIRPythonModules
  ROOT_PREFIX "${SCALEHLS_PYTHON_PACKAGES_DIR}/scalehls_core"
  INSTALL_PREFIX "python_packages/scalehls_core"
  DECLARED_SOURCES
    ScaleHLSPMLIRPythonSources
)
