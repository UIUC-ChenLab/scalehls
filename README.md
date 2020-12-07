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

### 3. Try ScaleHLS
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

### 4. Ablation test
If Vivado HLS (2019.1 tested) is installed on your machine, running the following script will report the HLS results for some benchmarks (around 2 hours on AMD Ryzen7 3800X for all 16 tests). "-n" determines the number of tests to be processed, the maximum supported value of which is 16. "-c" determines whether to run Vivado HLS C synthesis. "-r" determines whether to run report generation. The generated C++ source code will be written to $SCALEHLS_DIR/sample/cpp_src; the Vivado HLS project will be established in $SCALEHLS_DIR/sample/hls_proj; the generated report will be written to $SCALEHLS_DIR/sample/test_results.
```sh
$ cd $SCALEHLS_DIR/sample
$ ./ablation_test_run.sh -n 16 -c true -r true
```

## References
1. [MLIR documents](https://mlir.llvm.org)
2. [mlir-npcomp github](https://github.com/llvm/mlir-npcomp)
3. [onnx-mlir github](https://github.com/onnx/onnx-mlir)
4. [circt github](https://github.com/llvm/circt)
5. [comba github](https://github.com/zjru/COMBA)
6. [dahlia github](https://github.com/cucapra/dahlia)
