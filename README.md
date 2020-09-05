# HLS Large Design Project (HLSLD)

This project aims to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, it will incorporate a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parametrization and optimization of a tremendously large design space.

## Quick Start
This setup assumes that you have built LLVM and MLIR in `$LLVM_BUILD_DIR`. To build and launch the tests, run
```sh
mkdir build && cd build
cmake -G Ninja .. -DMLIR_DIR=$LLVM_BUILD_DIR/lib/cmake/mlir -DLLVM_EXTERNAL_LIT=$LLVM_BUILD_DIR/bin/llvm-lit
cmake --build . --target check-hlsld
```

## Hanchen TODO List
1. Test HLS C++ emitter with some real benchmarks;
2. How to handle AXI4MM input/output with dynamic rank;
3. Support extract_element/tensor_from_elements/splat operations;
4. Support call operation;
5. Support memref/tensor cast/view/subview operations;
6. Support atomic/complex/extend -related operations.


## References
1. [MLIR Documents](https://mlir.llvm.org)
2. [mlir-npcomp github](https://github.com/llvm/mlir-npcomp)
3. [circt github](https://github.com/llvm/circt)
4. [onnx-mlir github](https://github.com/onnx/onnx-mlir)
