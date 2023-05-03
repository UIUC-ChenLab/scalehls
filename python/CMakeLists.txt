get_property(dialect_libs GLOBAL PROPERTY MLIR_DIALECT_LIBS)
get_property(conversion_libs GLOBAL PROPERTY MLIR_CONVERSION_LIBS)
get_property(translation_libs GLOBAL PROPERTY MLIR_TRANSLATION_LIBS)

################################################################################
# Set up Python binding tools
################################################################################

include(AddMLIRPython)

################################################################################
# Declare native Python extension
################################################################################

declare_mlir_python_sources(ScaleHLSBindingsPythonExtension)

set(PYTHON_SOURCE_DIR "${SCALEHLS_SOURCE_DIR}/lib/Bindings/Python")
declare_mlir_python_extension(ScaleHLSBindingsPythonExtension.Core
  MODULE_NAME _scalehls
  ADD_TO_PARENT ScaleHLSBindingsPythonExtension
  ROOT_DIR "${PYTHON_SOURCE_DIR}"
  SOURCES
    ScaleHLSModule.cpp
  EMBED_CAPI_LINK_LIBS
    MLIRScaleHLSCAPIHLSDialect
    MLIRScaleHLSCAPITransforms
    MLIRScaleHLSCAPIEmitHLSCpp
    MLIRCAPITransforms
  PRIVATE_LINK_LIBS
    ${dialect_libs}
    ${conversion_libs}
    ${translation_libs}
    LLVMSupport
    MLIRScaleHLSHLSDialect
    MLIRScaleHLSTransforms
)

################################################################################
# Declare Python sources
################################################################################

declare_mlir_python_sources(ScaleHLSBindingsPythonSources
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  SOURCES
    scalehls/__init__.py
    scalehls/dialects/_ods_common.py
)

################################################################################
# Declare dialect-specific bindings.
################################################################################

# Ensure the build directory for generated Python files exists. Ninja is able to
# generate this, but make does not and the build fails.
file(MAKE_DIRECTORY ${SCALEHLS_BINARY_DIR}/lib/Bindings/Python/scalehls/dialects)

declare_mlir_python_sources(ScaleHLSBindingsPythonSources.Dialects
  ADD_TO_PARENT ScaleHLSBindingsPythonSources)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT ScaleHLSBindingsPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  TD_FILE scalehls/dialects/HLSOps.td
  SOURCES
    scalehls/dialects/hls.py
  DIALECT_NAME hls)

################################################################################
# Build composite binaries
################################################################################

# Bundle our own, self-contained CAPI library with all of our deps.
add_mlir_python_common_capi_library(ScaleHLSBindingsPythonCAPI
  INSTALL_COMPONENT ScaleHLSBindingsPythonModules
  INSTALL_DESTINATION python_packages/scalehls_core/mlir/_mlir_libs
  # NOTE: When the MLIR API is relocated under scalehls, this would change to
  # .../scalehls/_mlir_libs
  OUTPUT_DIRECTORY "${SCALEHLS_PYTHON_PACKAGES_DIR}/scalehls_core/mlir/_mlir_libs"
  RELATIVE_INSTALL_ROOT "../../../.."
  DECLARED_SOURCES
    MLIRPythonSources.Core
    MLIRPythonSources.Dialects
    MLIRPythonSources.ExecutionEngine
    ScaleHLSBindingsPythonSources
    ScaleHLSBindingsPythonExtension
)

# Bundle the MLIR python sources into our package.
# The MLIR API is position independent, so we explicitly output it to the mlir/
# folder as a temporary measure. It will eventually migrate under the scalehls/
# folder and be accessible under the unified "import scalehls..." namespace.
add_mlir_python_modules(ScaleHLSMLIRPythonModules
  ROOT_PREFIX "${SCALEHLS_PYTHON_PACKAGES_DIR}/scalehls_core/mlir"
  INSTALL_PREFIX "python_packages/scalehls_core/mlir"
  DECLARED_SOURCES
    MLIRPythonSources.Core
    MLIRPythonSources.Dialects
    MLIRPythonSources.ExecutionEngine
    # We need the scalehls extensions co-located with the MLIR extensions. When
    # the namespace is unified, this moves to the below.
    ScaleHLSBindingsPythonExtension
  COMMON_CAPI_LINK_LIBS
    ScaleHLSBindingsPythonCAPI
)

# Bundle the ScaleHLS python sources into our package.
add_mlir_python_modules(ScaleHLSPythonModules
  ROOT_PREFIX "${SCALEHLS_PYTHON_PACKAGES_DIR}/scalehls_core"
  INSTALL_PREFIX "python_packages/scalehls_core"
  DECLARED_SOURCES
    ScaleHLSBindingsPythonSources
  COMMON_CAPI_LINK_LIBS
    ScaleHLSBindingsPythonCAPI
)
