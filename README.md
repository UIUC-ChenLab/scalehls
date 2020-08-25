# HLS Large Design Project (HLSLD)

## High Level Description of Project
This project aims to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. Out of all of the existing deep learning compiler related projects, TVM and MLIR present existing tools that we can leverage in our proposed framework. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, but it will incorporate a frontend for Sitao's powerful domain specific language (DSL) and a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parametrization and optimization of a tremendously large design space. So far, we are familiarizing ourselves with the existing MLIR flow using a toy example (simple neural network for MNIST digit classification) and figure out how to do this parametrization and optimization. 

## Quick Start
This setup assumes that you have built LLVM and MLIR in `$LLVM_BUILD_DIR`. To build and launch the tests, run
```sh
mkdir build && cd build
cmake -G Ninja .. -DMLIR_DIR=$LLVM_BUILD_DIR/lib/cmake/mlir -DLLVM_EXTERNAL_LIT=$LLVM_BUILD_DIR/bin/llvm-lit
cmake --build . --target check-hlsld
```

## Hanchen TODO List
1. Emitting HLS Cpp code from standard dialect.

## References
1. [MLIR Documents](https://mlir.llvm.org)
2. [github mlir-npcomp](https://github.com/llvm/mlir-npcomp)
3. [github circt](https://github.com/llvm/circt)
4. [github onnx-mlir](https://github.com/onnx/onnx-mlir)
