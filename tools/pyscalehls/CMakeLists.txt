add_custom_target(pyscalehls ALL
  DEPENDS ${SCALEHLS_TOOLS_DIR}/pyscalehls.py)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/copy_pyscalehls.cmake"
  "file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/pyscalehls.py
    DESTINATION ${SCALEHLS_TOOLS_DIR}
    FILE_PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
    )"
  )

add_custom_command(
  OUTPUT ${SCALEHLS_TOOLS_DIR}/pyscalehls.py 
  COMMAND ${CMAKE_COMMAND} -P ${CMAKE_CURRENT_BINARY_DIR}/copy_pyscalehls.cmake
  DEPENDS pyscalehls.py
  )
