# ScaleHLS Project (scalehls)

ScaleHLS is a next-generation HLS compilation flow, on top of a multi-level compiler infrastructure called MLIR. ScaleHLS is able to represent and optimize HLS designs at multiple levels of abstraction and provides an HLS-dedicated transform and analysis library to solve the optimization problems at the suitable representation levels. On top of the library, we also build an automated DSE engine to explore the multi-dimensional design space efficiently. In addition, we develop an HLS C front-end and a C/C++ emission back-end to translate HLS designs into/from MLIR for enabling the end-to-end ScaleHLS flow. Experimental results show that, comparing to the baseline designs only optimized by Xilinx Vivado HLS, ScaleHLS improves the performances with amazing quality-of-results – up to 768.1× better on computation kernel level programs and up to 3825.0× better on neural network models.

Please check out our [arXiv paper](https://arxiv.org/abs/2107.11673) for more details.

## Quick Start

### 0. Download ScaleHLS
```sh
$ git clone --recursive git@github.com:hanchenye/scalehls.git
$ cd scalehls
```

### 1. Install MLIR, Clang, Polygeist, and ScaleHLS
This step assumes this repository is cloned to `scalehls`. To build ScaleHLS, run:
```sh
$ cmake -G Ninja ../Polygeist/llvm-project/llvm \
    -DLLVM_ENABLE_PROJECTS="mlir;clang" \
    -DLLVM_EXTERNAL_PROJECTS="scalehls;polygeist" \
    -DLLVM_EXTERNAL_SCALEHLS_SOURCE_DIR=.. \
    -DLLVM_EXTERNAL_POLYGEIST_SOURCE_DIR=../Polygeist \
    -DLLVM_TARGETS_TO_BUILD="host" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG
$ ninja
$ ninja check-scalehls
$ export PATH=scalehls/build/bin:$PATH
```

### 2. Try ScaleHLS
After the installation and test successfully completed, you should be able to play with:
```sh
$ cd scalehls

$ # HLS C programs parsing and automatic kernel-level design space exploration.
$ scalehls-opt samples/polybench/gemm/gemm_32.mlir \
    -multiple-level-dse="top-func=gemm_32 output-path=./ target-spec=config/target-spec.ini" \
    -debug-only=scalehls > /dev/null
$ scalehls-translate -emit-hlscpp gemm_pareto_0.mlir > gemm_pareto_0.cpp
```
Note: We are currently refactoring the HLS C parsing feature, hence it is temporarily unavailable at present.

ScaleHLS transform passes and QoR estimator:
```sh
$ cd scalehls

$ # Loop and directive-level optimizations, QoR estimation, and C++ code generation.
$ scalehls-opt samples/polybench/syrk/syrk_32.mlir \
    -affine-loop-perfection -affine-loop-order-opt -remove-variable-bound \
    -partial-affine-loop-tile="tile-size=2" -legalize-to-hlscpp="top-func=syrk_32" \
    -loop-pipelining="pipeline-level=3 target-ii=2" -canonicalize -simplify-affine-if \
    -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize \
    -qor-estimation="target-spec=config/target-spec.ini" \
    | scalehls-translate -emit-hlscpp

$ # Benchmark generation, dataflow-level optimization, HLSKernel lowering and bufferization.
$ benchmark-gen -type "cnn" -config "config/cnn-config.ini" -number 1 \
    | scalehls-opt -legalize-dataflow="insert-copy=true min-gran=2" -split-function \
    -hlskernel-bufferize -hlskernel-to-affine -func-bufferize -canonicalize
```

## Integration with ONNX-MLIR
If you have installed ONNX-MLIR or established ONNX-MLIR docker to `$ONNXMLIR_DIR` following the instruction from (https://github.com/onnx/onnx-mlir), you should be able to run the following integration test:
```sh
$ cd scalehls/samples/onnx-mlir/resnet18

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
    -affine-loop-normalize -canonicalize -legalize-dataflow="insert-copy=true min-gran=3" \
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
