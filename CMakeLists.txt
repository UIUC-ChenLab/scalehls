cmake_minimum_required(VERSION 3.13.4)

if(POLICY CMP0068)
  cmake_policy(SET CMP0068 NEW)
  set(CMAKE_BUILD_WITH_INSTALL_NAME_DIR ON)
endif()

if(POLICY CMP0075)
  cmake_policy(SET CMP0075 NEW)
endif()

if(POLICY CMP0077)
  cmake_policy(SET CMP0077 NEW)
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED YES)

if (CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
  if (SCALEHLS_ENABLE_BINDINGS_PYTHON)
    message(FATAL_ERROR "ScaleHLS Python bindings require a unified build.")
  endif()

  project(scalehls LANGUAGES CXX C)

  set(LLVM_SOURCE_DIR ${CMAKE_SOURCE_DIR}/Polygeist/llvm-project/llvm)
  find_package(MLIR REQUIRED CONFIG)

  message(STATUS "Using MLIRConfig.cmake in: ${MLIR_DIR}")
  message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

  list(APPEND CMAKE_MODULE_PATH "${MLIR_CMAKE_DIR}")
  list(APPEND CMAKE_MODULE_PATH "${LLVM_CMAKE_DIR}")

  include(TableGen)
  include(AddLLVM)
  include(AddMLIR)
  include(HandleLLVMOptions)
else ()
  set(LLVM_SOURCE_DIR ${LLVM_MAIN_SRC_DIR})
  set(MLIR_MAIN_SRC_DIR ${LLVM_MAIN_SRC_DIR}/../mlir)
  set(MLIR_INCLUDE_DIRS ${MLIR_MAIN_SRC_DIR}/include)
  set(MLIR_CMAKE_DIR ${MLIR_MAIN_SRC_DIR}/cmake/modules)
  set(MLIR_TABLEGEN_EXE $<TARGET_FILE:mlir-tblgen>)
  set(MLIR_TABLEGEN_OUTPUT_DIR ${LLVM_BINARY_DIR}/tools/mlir/include)

  include_directories(SYSTEM ${MLIR_INCLUDE_DIR})
  include_directories(SYSTEM ${MLIR_TABLEGEN_OUTPUT_DIR})
endif()

set(LIT_ARGS_DEFAULT "-sv")
if (MSVC_IDE OR XCODE)
  set(LIT_ARGS_DEFAULT "${LIT_ARGS_DEFAULT} --no-progress-bar")
endif()
set(LLVM_LIT_ARGS "${LIT_ARGS_DEFAULT}" CACHE STRING "Default options for lit")

set(SCALEHLS_MAIN_SRC_DIR ${CMAKE_CURRENT_SOURCE_DIR} ) # --src-root
set(SCALEHLS_MAIN_INCLUDE_DIR ${SCALEHLS_MAIN_SRC_DIR}/include)

set(SCALEHLS_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR})
set(SCALEHLS_BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR})
set(SCALEHLS_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/include )
set(SCALEHLS_TOOLS_DIR ${CMAKE_BINARY_DIR}/bin)
set(SCALEHLS_UTILS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/utils)
set(SCALEHLS_PYTHON_PACKAGES_DIR ${SCALEHLS_BINARY_DIR}/python_packages)

list(APPEND CMAKE_MODULE_PATH "${MLIR_MAIN_SRC_DIR}/cmake/modules")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

include_directories(${LLVM_INCLUDE_DIRS})
include_directories(${MLIR_INCLUDE_DIRS})
include_directories(${SCALEHLS_MAIN_INCLUDE_DIR})
include_directories(${SCALEHLS_INCLUDE_DIR})
link_directories(${LLVM_BUILD_LIBRARY_DIR})
add_definitions(${LLVM_DEFINITIONS})

option(SCALEHLS_ENABLE_BINDINGS_PYTHON "Enables ScaleHLS Python bindings." OFF)

if(SCALEHLS_ENABLE_BINDINGS_PYTHON)
  message(STATUS "ScaleHLS Python bindings are enabled.")

  include(MLIRDetectPythonEnv)
  find_package(Python3 COMPONENTS Interpreter Development NumPy REQUIRED)
  message(STATUS "Found Python include dirs: ${Python3_INCLUDE_DIRS}")
  message(STATUS "Found Python libraries: ${Python3_LIBRARIES}")
  message(STATUS "Found Python executable: ${Python3_EXECUTABLE}")
  message(STATUS "Found numpy v${Python3_NumPy_VERSION}: ${Python3_NumPy_INCLUDE_DIRS}")
  include_directories(${Python3_NumPy_INCLUDE_DIRS})

  mlir_detect_pybind11_install()
  find_package(pybind11 2.6 CONFIG REQUIRED)
  message(STATUS "Found pybind11 v${pybind11_VERSION}: ${pybind11_INCLUDE_DIR}")
  message(STATUS "Python prefix = '${PYTHON_MODULE_PREFIX}', "
                 "suffix = '${PYTHON_MODULE_SUFFIX}', "
                 "extension = '${PYTHON_MODULE_EXTENSION}'")
else()
  message(STATUS "ScaleHLS Python bindings are disabled.")
endif()

add_subdirectory(include/scalehls)
add_subdirectory(lib)
add_subdirectory(test)
add_subdirectory(tools)
