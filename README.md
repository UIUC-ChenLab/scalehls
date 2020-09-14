# ScaleHLS Project (scalehls)

This project aims to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, it will incorporate a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parametrization and optimization of a tremendously large design space.

## Quick Start
This setup assumes that you have built LLVM and MLIR in `$LLVM_BUILD_DIR`. To build and launch the tests, run
```sh
mkdir build && cd build
cmake -G Ninja .. -DMLIR_DIR=$LLVM_BUILD_DIR/lib/cmake/mlir -DLLVM_EXTERNAL_LIT=$LLVM_BUILD_DIR/bin/llvm-lit
cmake --build . --target check-scalehls
```
After the installation and test successfully completed, you should be able to run
```sh
bin/scalehls-translate -emit-hlscpp ../test/EmitHLSCpp/test_*.mlir
```
## TODO List
### scalehls-estimator: EstimateQoR
1. **Tooling initial implementation.**

### scalehls-translate: EmitHLSCpp
1. **Test HLS C++ emitter with some real benchmarks;**
2. **TODOs in EmitHLSCpp.cpp;**
4. Support memref/tensor cast/view/subview operations;
5. Support atomic/complex/extention -related operations.

### scalehls-opt: PragmaInsertion

### HLSCpp Dialect
1. **TODOs in HLSCpp/Ops.td.**

## References
1. [MLIR Documents](https://mlir.llvm.org)
2. [mlir-npcomp github](https://github.com/llvm/mlir-npcomp)
3. [circt github](https://github.com/llvm/circt)
4. [onnx-mlir github](https://github.com/onnx/onnx-mlir)
