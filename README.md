# ScaleHLS Project (scalehls)

This project aims to create a framework that ultimately converts an algorithm written in a high level language into an efficient hardware implementation. With multiple levels of intermediate representations (IRs), MLIR appears to be the ideal tool for exploring ways to optimize the eventual design at various levels of abstraction (e.g. various levels of parallelism). Our framework will be based on MLIR, it will incorporate a backend for high level synthesis (HLS) C/C++ code. However, the key contribution will be our parameterization and optimization of a tremendously large design space.

## Quick Start

### 0. Download ScaleHLS and LLVM

```
$ git clone git@github.com:hanchenye/scalehls.git
$ cd scalehls
$ git submodule init
$ git submodule update
```

### 1. Install LLVM and MLIR
To build LLVM and MLIR, run:
```sh
$ mkdir $SCALEHLS_DIR/llvm/build
$ cd $SCALEHLS_DIR/llvm/build
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
    -DMLIR_DIR=$SCALEHLS_DIR/llvm/build/lib/cmake/mlir \
    -DLLVM_DIR=$SCALEHLS_DIR/llvm/build/lib/cmake/llvm \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG
$ ninja check-scalehls
```

### 3. Try ScaleHLS
After the installation and test successfully completed, you should be able to play with:
```sh
$ export PATH=$SCALEHLS_DIR/build/bin:$PATH
$ cd $SCALEHLS_DIR

$ # Loop and directive-level optimizations, QoR estimation, and C++ code generation.
$ scalehls-opt samples/polybench/syrk/syrk_32.mlir \
    -affine-loop-perfection -affine-loop-order-opt -remove-variable-bound \
    -partial-affine-loop-tile="tile-size=2" -legalize-to-hlscpp="top-func=syrk_32" \
    -loop-pipelining="pipeline-level=3 target-ii=2" -canonicalize -simplify-affine-if \
    -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize \
    -qor-estimation="target-spec=config/target-spec.ini" \
    | scalehls-translate -emit-hlscpp

$ # Automatic kernel-level design space exploration.
$ scalehls-opt samples/polybench/gemm/gemm_32.mlir \
    -multiple-level-dse="top-func=gemm_32 output-path=./ target-spec=config/target-spec.ini" \
    -debug-only=scalehls > /dev/null
$ scalehls-translate -emit-hlscpp gemm_32_pareto_0.mlir > gemm_32_pareto_0.cpp

$ # Benchmark generation, dataflow-level optimization, HLSKernel lowering and bufferization.
$ benchmark-gen -type "cnn" -config "config/cnn-config.ini" -number 1 \
    | scalehls-opt -legalize-dataflow="insert-copy=true min-gran=2" -split-function \
    -hlskernel-bufferize -hlskernel-to-affine -func-bufferize -canonicalize
```

Please refer to the `samples/polybench` folder for more test cases.

## Integration with ONNX-MLIR
If you have installed ONNX-MLIR or established ONNX-MLIR docker to `$ONNXMLIR_DIR` following the instruction from (https://github.com/onnx/onnx-mlir), you should be able to run the following integration test:
```sh
$ cd $SCALEHLS_DIR/samples/onnx-mlir/resnet18

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
$ scalehls-opt resnet18.mlir -allow-unregistered-dialect -legalize-onnx \
    -affine-loop-normalize -canonicalize -legalize-dataflow="min-gran=3 insert-copy=true" \
    -split-function -convert-linalg-to-affine-loops -legalize-to-hlscpp="top-func=main_graph" \
    -affine-loop-perfection -affine-loop-order-opt -loop-pipelining -simplify-affine-if \
    -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize \
    | scalehls-translate -emit-hlscpp > resnet18.cpp
```

Please refer to the `samples/onnx-mlir` folder for more test cases, and `sample/onnx-mlir/ablation_int_test.sh` for how to conduct the graph, loop, and directive optimizations.

## References
1. [MLIR](https://mlir.llvm.org): Multi-Level Intermediate Representation
2. [NPComp](https://github.com/llvm/mlir-npcomp): MLIR based compiler toolkit for numerical python programs
3. [ONNX-MLIR](https://github.com/onnx/onnx-mlir): The Open Neural Network Exchange implementation in MLIR
4. [CIRCT](https://github.com/llvm/circt): Circuit IR Compilers and Tools
5. [COMBA](https://github.com/zjru/COMBA): A Model-Based Analysis Framework for High Level Synthesis on FPGAs
