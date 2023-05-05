#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

# Script options.
while getopts 'j:p:' opt
do
  case $opt in
    j) JOBS="${OPTARG}";;
    p) PYBIND="${OPTARG}";;
  esac
done

# If ninja is available, use it.
CMAKE_GENERATOR="Unix Makefiles"
if which ninja &>/dev/null; then
  CMAKE_GENERATOR="Ninja"
fi

# The absolute path to the directory of this script.
SCALEHLS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Make sure polygeist submodule is up-to-date.
git submodule sync
git submodule update --init --recursive

echo ""
echo ">>> Unified MLIR and ScaleHLS build..."
echo ""

# Got to the build directory.
cd "${SCALEHLS_DIR}"
mkdir -p build
cd build

# Configure CMake.
if [ ! -f "CMakeCache.txt" ]; then
  cmake -G "${CMAKE_GENERATOR}" \
    ../llvm-project/llvm \
    -DLLVM_ENABLE_PROJECTS="mlir" \
    -DLLVM_EXTERNAL_PROJECTS="scalehls" \
    -DLLVM_EXTERNAL_SCALEHLS_SOURCE_DIR="${SCALEHLS_DIR}" \
    -DLLVM_TARGETS_TO_BUILD="host" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DMLIR_ENABLE_BINDINGS_PYTHON="${PYBIND:=OFF}" \
    -DSCALEHLS_ENABLE_BINDINGS_PYTHON="${PYBIND:=OFF}" \
    -DLLVM_PARALLEL_LINK_JOBS="${JOBS:=}" \
    -DLLVM_USE_LINKER=lld \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++
fi

# Run building.
if [ "${CMAKE_GENERATOR}" == "Ninja" ]; then
  ninja && ninja check-scalehls
else 
  make -j "$(nproc)" && make -j "$(nproc)" check-scalehls
fi
