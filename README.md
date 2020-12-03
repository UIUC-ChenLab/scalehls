# ScaleHLS Project (scalehls)

This project aims to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, it will incorporate a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parametrization and optimization of a tremendously large design space.

## Quick Start
### 1. Install LLVM and MLIR
**IMPORTANT** This step assumes that you have cloned LLVM from (https://github.com/circt/llvm) to `$LLVM_DIR`. To build LLVM and MLIR, run
```sh
$ mkdir $LLVM_DIR/build
$ cd $LLVM_DIR/build
$ cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir" \
    -DLLVM_TARGETS_TO_BUILD="X86;RISCV" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG
$ ninja
$ ninja check-mlir
```

### 2. Install ScaleHLS
This step assumes this repository is cloned to `$SCALEHLS_DIR`. To build and launch the tests, run
```sh
$ mkdir $SCALEHLS_DIR/build
$ cd $SCALEHLS_DIR/build
$ cmake -G Ninja .. \
    -DMLIR_DIR=$LLVM_DIR/build/lib/cmake/mlir \
    -DLLVM_DIR=$LLVM_DIR/build/lib/cmake/llvm \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG
$ ninja check-scalehls
```

### 3. Test ScaleHLS
After the installation and test successfully completed, you should be able to play with
```sh
$ export PATH=$SCALEHLS_DIR/build/bin:$PATH
$ cd $SCALEHLS_DIR
$
$ benchmark-gen -type "cnn" -config "$SCALEHLS_DIR/config/cnn-config.ini" -number 1
$ scalehls-opt -hlskernel-to-affine test/Conversion/HLSKernelToAffine/test_*.mlir
$
$ scalehls-opt -convert-to-hlscpp test/Conversion/ConvertToHLSCpp/test_*.mlir
$ scalehls-opt -convert-to-hlscpp test/EmitHLSCpp/test_*.mlir | scalehls-translate -emit-hlscpp
$
$ scalehls-opt -qor-estimation test/Analysis/QoREstimation/test_for.mlir
```

If Vivado HLS (2019.1 tested) is installed on your machine, running the following script will report the HLS results for some benchmarks.
```sh
$ cd $SCALEHLS_DIR/sample
$ source ./test_run.sh rerun
```

## References
1. [MLIR documents](https://mlir.llvm.org)
2. [mlir-npcomp github](https://github.com/llvm/mlir-npcomp)
3. [onnx-mlir github](https://github.com/onnx/onnx-mlir)
4. [circt github](https://github.com/llvm/circt)
5. [comba github](https://github.com/zjru/COMBA)
6. [dahlia github](https://github.com/cucapra/dahlia)
