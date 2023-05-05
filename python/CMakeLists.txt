################################################################################
# Set up Python binding tools
################################################################################

include(AddMLIRPython)

add_compile_definitions("MLIR_PYTHON_PACKAGE_PREFIX=scalehls.")

################################################################################
# Declare Python sources
################################################################################

declare_mlir_python_sources(ScaleHLSPythonSources
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  SOURCES
    __init__.py
    uip.py
)

################################################################################
# Declare dialect-specific bindings.
################################################################################

# Ensure the build directory for generated Python files exists. Ninja is able to
# generate this, but make does not and the build fails.
file(MAKE_DIRECTORY ${SCALEHLS_BINARY_DIR}/python/dialects)

declare_mlir_python_sources(ScaleHLSPythonSources.Dialects
  ADD_TO_PARENT ScaleHLSPythonSources)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT ScaleHLSPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  TD_FILE dialects/HLSOps.td
  SOURCES
    dialects/hls.py
  DIALECT_NAME hls
)

################################################################################
# Declare native Python extension
################################################################################

declare_mlir_python_sources(ScaleHLSPythonExtension)

set(PYTHON_SOURCE_DIR "${SCALEHLS_SOURCE_DIR}/lib/Bindings/Python")
declare_mlir_python_extension(ScaleHLSPythonExtension.Core
  MODULE_NAME _scalehls
  ADD_TO_PARENT ScaleHLSPythonExtension
  ROOT_DIR "${PYTHON_SOURCE_DIR}"
  SOURCES
    ScaleHLSModule.cpp
  EMBED_CAPI_LINK_LIBS
    MLIRScaleHLSCAPIHLSDialect
    MLIRScaleHLSCAPITransforms
    MLIRScaleHLSCAPIEmitHLSCpp
  PRIVATE_LINK_LIBS
    LLVMSupport
)

################################################################################
# Build composite binaries
################################################################################

# Bundle our own, self-contained CAPI library with all of our deps.
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
    ScaleHLSPythonExtension
)

# Bundle the ScaleHLS python sources into our package.
add_mlir_python_modules(ScaleHLSPythonModules
  ROOT_PREFIX "${SCALEHLS_PYTHON_PACKAGES_DIR}/scalehls_core/scalehls"
  INSTALL_PREFIX "python_packages/scalehls_core/scalehls"
  DECLARED_SOURCES
    MLIRPythonSources
    MLIRPythonExtension.RegisterEverything
    ScaleHLSPythonSources
    ScaleHLSPythonExtension
  COMMON_CAPI_LINK_LIBS
    ScaleHLSPythonCAPI
)
