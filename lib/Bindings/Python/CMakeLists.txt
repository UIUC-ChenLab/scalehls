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
    CIRCTCAPIEmitHLSCpp
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
    scalehls/esi.py
    scalehls/support.py
    scalehls/dialects/_ods_common.py)

################################################################################
# Declare dialect-specific bindings.
################################################################################

# Ensure the build directory for generated Python files exists. Ninja is able to
# generate this, but make does not and the build fails.
file(MAKE_DIRECTORY ${CIRCT_BINARY_DIR}/lib/Bindings/Python/scalehls/dialects)

declare_mlir_python_sources(CIRCTBindingsPythonSources.Dialects
  ADD_TO_PARENT CIRCTBindingsPythonSources)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT CIRCTBindingsPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  TD_FILE scalehls/dialects/CombOps.td
  SOURCES
    scalehls/dialects/comb.py
    scalehls/dialects/_comb_ops_ext.py
  DIALECT_NAME comb)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT CIRCTBindingsPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  TD_FILE scalehls/dialects/ESIOps.td
  SOURCES scalehls/dialects/esi.py
  DIALECT_NAME esi)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT CIRCTBindingsPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  TD_FILE scalehls/dialects/HWOps.td
  SOURCES
    scalehls/dialects/hw.py
    scalehls/dialects/_hw_ops_ext.py
  DIALECT_NAME hw)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT CIRCTBindingsPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  TD_FILE scalehls/dialects/SeqOps.td
  SOURCES
    scalehls/dialects/seq.py
    scalehls/dialects/_seq_ops_ext.py
  DIALECT_NAME seq)

declare_mlir_dialect_python_bindings(
  ADD_TO_PARENT CIRCTBindingsPythonSources.Dialects
  ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  TD_FILE scalehls/dialects/SVOps.td
  SOURCES scalehls/dialects/sv.py
  DIALECT_NAME sv)

################################################################################
# Build composite binaries
################################################################################

# Bundle our own, self-contained CAPI library with all of our deps.
add_mlir_python_common_capi_library(CIRCTBindingsPythonCAPI
  INSTALL_COMPONENT CIRCTBindingsPythonModules
  INSTALL_DESTINATION python_packages/scalehls_core/mlir/_mlir_libs
  # NOTE: When the MLIR API is relocated under scalehls, this would change to
  # .../scalehls/_mlir_libs
  OUTPUT_DIRECTORY "${CIRCT_PYTHON_PACKAGES_DIR}/scalehls_core/mlir/_mlir_libs"
  RELATIVE_INSTALL_ROOT "../../../.."
  DECLARED_SOURCES
    MLIRPythonSources.Core
    CIRCTBindingsPythonSources
    ScaleHLSBindingsPythonExtension
)

# Bundle the MLIR python sources into our package.
# The MLIR API is position independent, so we explicitly output it to the mlir/
# folder as a temporary measure. It will eventually migrate under the scalehls/
# folder and be accessible under the unified "import scalehls..." namespace.
add_mlir_python_modules(CIRCTMLIRPythonModules
  ROOT_PREFIX "${CIRCT_PYTHON_PACKAGES_DIR}/scalehls_core/mlir"
  INSTALL_PREFIX "python_packages/scalehls_core/mlir"
  DECLARED_SOURCES
    MLIRPythonSources.Core
    # We need the scalehls extensions co-located with the MLIR extensions. When
    # the namespace is unified, this moves to the below.
    ScaleHLSBindingsPythonExtension
  COMMON_CAPI_LINK_LIBS
    CIRCTBindingsPythonCAPI
)

# Bundle the CIRCT python sources into our package.
add_mlir_python_modules(CIRCTPythonModules
  ROOT_PREFIX "${CIRCT_PYTHON_PACKAGES_DIR}/scalehls_core"
  INSTALL_PREFIX "python_packages/scalehls_core"
  DECLARED_SOURCES
    CIRCTBindingsPythonSources
  COMMON_CAPI_LINK_LIBS
    CIRCTBindingsPythonCAPI
)
