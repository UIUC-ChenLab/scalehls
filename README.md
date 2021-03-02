# ScaleHLS Project (scalehls)

This project aims to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, it will incorporate a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parameterization and optimization of a tremendously large design space.

## Quick Start
### 1. Install LLVM and MLIR
**IMPORTANT** This step assumes that you have cloned LLVM from (https://github.com/circt/llvm/tree/main) to `$LLVM_DIR` and checked out the `main` branch. To build LLVM and MLIR, run:
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
This step assumes this repository is cloned to `$SCALEHLS_DIR`. To build and launch the tests, run:
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
After the installation and test successfully completed, you should be able to play with:
```sh
$ export PATH=$SCALEHLS_DIR/build/bin:$PATH
$ cd $SCALEHLS_DIR

$ # Automatic kernel-level design space exploration.
$ scalehls-opt samples/polybench/gemm.mlir \
    -multiple-level-dse="target-spec=config/target-spec.ini dump-file=gemm_dse.csv top-func=test_gemm" \
    -debug-only=scalehls | scalehls-translate -emit-hlscpp

$ # Loop and pragma-level optimizations, performance estimation, and C++ code generation.
$ scalehls-opt samples/polybench/syrk.mlir \
    -affine-loop-perfection -affine-loop-order-opt -remove-variable-bound \
    -partial-affine-loop-tile="tile-size=2" -legalize-to-hlscpp="top-func=test_syrk" \
    -loop-pipelining="pipeline-level=3 target-ii=2" -canonicalize -simplify-affine-if \
    -affine-store-forward -simplify-memref-access -cse -array-partition \
    -qor-estimation="target-spec=config/target-spec.ini" \
    | scalehls-translate -emit-hlscpp

$ # Benchmark generation, dataflow-level optimization, HLSKernel lowering and bufferization.
$ benchmark-gen -type "cnn" -config "config/cnn-config.ini" -number 1 \
    | scalehls-opt -legalize-dataflow="min-gran=2 insert-copy=true" -split-function \
    -hlskernel-bufferize -hlskernel-to-affine -func-bufferize -canonicalize
```

## Integration with ONNX-MLIR
If you have installed ONNX-MLIR or established ONNX-MLIR docker to `$ONNXMLIR_DIR` following the instruction from (https://github.com/onnx/onnx-mlir), you should be able to run the following integration test:
```sh
$ cd $SCALEHLS_DIR/samples/onnx-mlir

$ # Export PyTorch model to ONNX.
$ python export_resnet18.py

$ # Parse ONNX model to MLIR.
$ $ONNXMLIR_DIR/build/bin/onnx-mlir -EmitONNXIR resnet18.onnx

$ # Lower from ONNX dialect to Affine dialect.
$ $ONNXMLIR_DIR/build/bin/onnx-mlir-opt resnet18.onnx.mlir \
    -shape-inference -convert-onnx-to-krnl -pack-krnl-constants \
    -convert-krnl-to-affine > resnet18.mlir

$ # (Optional) Print model graph.
$ scalehls-opt resnet18.tmp -print-op-graph 2> resnet18.gv
$ dot -Tpng resnet18.gv > resnet18.png

$ # Legalize the output of ONNX-MLIR, optimize and emit C++ code.
$ scalehls-opt resnet18.mlir -allow-unregistered-dialect \
    -legalize-onnx -affine-loop-normalize -canonicalize \
    -legalize-dataflow="min-gran=3 insert-copy=true" -split-function \
    -convert-linalg-to-affine-loops -affine-loop-order-opt \
    -legalize-to-hlscpp="top-func=main_graph" -loop-pipelining -canonicalize \
    | scalehls-translate -emit-hlscpp > resnet18.cpp
```

## References
1. [MLIR documents](https://mlir.llvm.org)
2. [mlir-npcomp github](https://github.com/llvm/mlir-npcomp)
3. [onnx-mlir github](https://github.com/onnx/onnx-mlir)
4. [circt github](https://github.com/llvm/circt)
5. [comba github](https://github.com/zjru/COMBA)
6. [dahlia github](https://github.com/cucapra/dahlia)
