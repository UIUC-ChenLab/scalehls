configure_lit_site_cfg(
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.site.cfg.py.in
  ${CMAKE_CURRENT_BINARY_DIR}/lit.site.cfg.py
  MAIN_CONFIG
  ${CMAKE_CURRENT_SOURCE_DIR}/lit.cfg.py
  )

set(HLSLD_TEST_DEPENDS
  FileCheck count not
  hlsld-translate
  )

add_lit_testsuite(check-hlsld "Running the hlsld regression tests"
  ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${HLSLD_TEST_DEPENDS}
  )
set_target_properties(check-hlsld PROPERTIES FOLDER "Tests")

add_lit_testsuites(HLSLD
  ${CMAKE_CURRENT_SOURCE_DIR}
  DEPENDS ${HLSLD_TEST_DEPENDS}
  )
