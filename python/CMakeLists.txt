################################################################################
# Set up Python binding tools
################################################################################

include(AddMLIRPython)

add_compile_definitions("MLIR_PYTHON_PACKAGE_PREFIX=scalehls.")

################################################################################
# Declare Python sources
################################################################################

declare_mlir_python_sources(ScaleHLSPythonSources)

declare_mlir_python_sources(ScaleHLSPythonSources.Core
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/scalehls"
  ADD_TO_PARENT ScaleHLSPythonSources
  SOURCES
    transforms.py
    __init__.py
    _mlir_libs/_scalehls.pyi
)

################################################################################
# Declare dialect-specific bindings
################################################################################

# Ensure the build directory for generated Python files exists. Ninja is able to
# generate this, but make does not and the build fails.
file(MAKE_DIRECTORY ${SCALEHLS_BINARY_DIR}/python/scalehls/dialects)

declare_mlir_python_sources(ScaleHLSPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/scalehls"
  ADD_TO_PARENT ScaleHLSPythonSources
  SOURCES
    _mlir_libs/_hls_dialect.pyi
)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT ScaleHLSPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/scalehls"
  TD_FILE dialects/HLSOps.td
  SOURCES
    dialects/hls.py
    dialects/_hls_ops_ext.py
  DIALECT_NAME hls
)

declare_mlir_dialect_extension_python_bindings(
  ADD_TO_PARENT ScaleHLSPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/scalehls"
  TD_FILE dialects/HLSTransformOps.td
  SOURCES
    dialects/hls_transform.py
    dialects/_hls_transform_ops_ext.py
  DIALECT_NAME transform
  EXTENSION_NAME hls_transform
)

################################################################################
# Declare native Python extension
################################################################################

declare_mlir_python_extension(ScaleHLSPythonExtension.Core
  MODULE_NAME _scalehls
  ADD_TO_PARENT ScaleHLSPythonSources.Core
  ROOT_DIR "${SCALEHLS_SOURCE_DIR}/lib/Bindings/Python"
  SOURCES
    ScaleHLSModule.cpp
  EMBED_CAPI_LINK_LIBS
    MLIRCAPIIR
    MLIRScaleHLSCAPIHLSDialect
    MLIRScaleHLSCAPIRegistration
    MLIRScaleHLSCAPIEmitHLSCpp
  PRIVATE_LINK_LIBS
    LLVMSupport
)

declare_mlir_python_extension(ScaleHLSPythonExtension.Dialects.hls
  MODULE_NAME _hls_dialect
  ADD_TO_PARENT ScaleHLSPythonSources.Dialects.hls
  ROOT_DIR "${SCALEHLS_SOURCE_DIR}/lib/Bindings/Python"
  SOURCES
    HLSDialect.cpp
  EMBED_CAPI_LINK_LIBS
    MLIRCAPIIR
    MLIRScaleHLSCAPIHLSDialect
  PRIVATE_LINK_LIBS
    LLVMSupport
)

################################################################################
# Build composite binaries
################################################################################

add_mlir_python_common_capi_library(ScaleHLSPythonCAPI
  INSTALL_COMPONENT ScaleHLSPythonModules
  INSTALL_DESTINATION python_packages/scalehls_core/scalehls/_mlir_libs
  OUTPUT_DIRECTORY "${SCALEHLS_PYTHON_PACKAGES_DIR}/scalehls_core/scalehls/_mlir_libs"
  RELATIVE_INSTALL_ROOT "../../../.."
  DECLARED_HEADERS
    MLIRPythonCAPI.HeaderSources
  DECLARED_SOURCES
    MLIRPythonSources
    MLIRPythonExtension.RegisterEverything
    ScaleHLSPythonSources
)

add_mlir_python_modules(ScaleHLSPythonModules
  ROOT_PREFIX "${SCALEHLS_PYTHON_PACKAGES_DIR}/scalehls_core/scalehls"
  INSTALL_PREFIX "python_packages/scalehls_core/scalehls"
  DECLARED_SOURCES
    MLIRPythonSources
    MLIRPythonExtension.RegisterEverything
    ScaleHLSPythonSources
  COMMON_CAPI_LINK_LIBS
    ScaleHLSPythonCAPI
)
