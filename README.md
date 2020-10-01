# ScaleHLS Project (scalehls)

This project aims to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, it will incorporate a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parametrization and optimization of a tremendously large design space.

## Quick Start
This setup assumes that you have built LLVM and MLIR in `$LLVM_BUILD_DIR` and this repository is cloned to `$SCALEHLS_DIR`. To build and launch the tests, run
```sh
mkdir $SCALEHLS_DIR/build
cd $SCALEHLS_DIR/build
cmake -G Ninja .. -DMLIR_DIR=$LLVM_BUILD_DIR/lib/cmake/mlir -DLLVM_DIR=$LLVM_BUILD_DIR/build/lib/cmake/llvm -DLLVM_ENABLE_ASSERTIONS=ON -DCMAKE_BUILD_TYPE=DEBUG
cmake --build . --target check-scalehls
export PATH=$SCALEHLS_DIR/build/bin:$PATH
```
After the installation and test successfully completed, you should be able to run
```sh
cd $SCALEHLS_DIR
scalehls-opt -convert-to-hlscpp test/Conversion/ConvertToHLSCpp/test_*.mlir
scalehls-opt -convert-to-hlscpp test/EmitHLSCpp/test_*.mlir | scalehls-translate -emit-hlscpp
```

## TODOs List
### HLSCpp Dialect
1. TODOs in HLSCpp/PragmaOps.td.

### QoREstimation Pass
1. **Performance estimator implementation.**

### PragmaDSE Pass

### EmitHLSCpp
1. TODOs in EmitHLSCpp.cpp;
2. Support memref/tensor cast/view/subview operations;
3. Support atomic/complex/extention -related operations.

## References
1. [MLIR Documents](https://mlir.llvm.org)
2. [mlir-npcomp github](https://github.com/llvm/mlir-npcomp)
3. [onnx-mlir github](https://github.com/onnx/onnx-mlir)
4. [circt github](https://github.com/llvm/circt)
5. [comba github](https://github.com/zjru/COMBA)
6. [dahlia github](https://github.com/cucapra/dahlia)
