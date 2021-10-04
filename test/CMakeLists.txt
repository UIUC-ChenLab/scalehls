llvm_canonicalize_cmake_booleans(
  SCALEHLS_ENABLE_BINDINGS_PYTHON
  )

configure_lit_site_cfg(
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.py.in
  ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg.py
  MAIN_CONFIG
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.cfg.py
  )

set(SCALEHLS_TEST_DEPENDS
  FileCheck count not
  pyscalehls
  scalehls-opt
  scalehls-translate
  )

if(SCALEHLS_ENABLE_BINDINGS_PYTHON)
  list(APPEND SCALEHLS_TEST_DEPENDS ScaleHLSMLIRPythonModules)
  list(APPEND SCALEHLS_TEST_DEPENDS ScaleHLSPythonModules)
endif()

add_lit_testsuite(check-scalehls "Running the scalehls regression tests"
  ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${SCALEHLS_TEST_DEPENDS}
  )
set_target_properties(check-scalehls PROPERTIES FOLDER "Tests")

add_lit_testsuites(SCALEHLS
  ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS ${SCALEHLS_TEST_DEPENDS}
  )
