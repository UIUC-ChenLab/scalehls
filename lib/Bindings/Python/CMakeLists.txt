################################################################################
# Set up Python binding tools
################################################################################

include(AddMLIRPython)

################################################################################
# Declare native Python extension
################################################################################

declare_mlir_python_sources(ScaleHLSBindingsPythonExtension)

set(_depends LLVMSupport)

declare_mlir_python_extension(ScaleHLSBindingsPythonExtension.Core
  MODULE_NAME _scalehls
  ADD_TO_PARENT ScaleHLSBindingsPythonExtension
  SOURCES
    ScaleHLSModule.cpp
  EMBED_CAPI_LINK_LIBS
    MLIRScaleHLSCAPIEmitHLSCpp
  PRIVATE_LINK_LIBS
    ${_depends}
)

################################################################################
# Declare Python sources
################################################################################

declare_mlir_python_sources(ScaleHLSBindingsPythonSources
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  SOURCES
    scalehls/__init__.py
)

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
