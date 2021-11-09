# ScaleHLS Project

High-level Synthesis (HLS) has been widely adopted as it significantly improves the hardware design productivity and enables efficient design space exploration (DSE). HLS tools can be used to deliver solutions for many different kinds of design problems, which are often better solved with different levels of abstraction. While existing HLS tools are built using compiler infrastructures largely based on a single-level abstraction (e.g., LLVM), we propose ScaleHLS, a next-generation HLS compilation flow, on top of a multi-level compiler infrastructure called MLIR, for the first time. By using an intermediate representation (IR) that can be better tuned to particular algorithms at different representation levels, we are able to build this new HLS tool that is more scalable and customizable towards various applications coming with intrinsic structural or functional hierarchies. ScaleHLS is able to represent and optimize HLS designs at multiple levels of abstraction and provides an HLS-dedicated transform and analysis library to solve the optimization problems at the suitable representation levels. On top of the library, we also build an automated DSE engine to explore the multi-dimensional design space efficiently. In addition, we develop an HLS C front-end and a C/C++ emission back-end to translate HLS designs into/from MLIR for enabling the end-to-end ScaleHLS flow. Experimental results show that, comparing to the baseline designs only optimized by Xilinx Vivado HLS, ScaleHLS improves the performances with amazing quality-of-results -- up to 768.1x better on computation kernel level programs and up to 3825.0x better on neural network models.

Please check out our [HPCA'22 paper](https://arxiv.org/abs/2107.11673) for more details.

## Quick Start

### Prerequisites
- cmake
- ninja (recommended)
- clang and lld (recommended)
- pybind11
- python3 with numpy

### Build ScaleHLS
First, make sure this repository has been cloned recursively.
```sh
$ git clone --recursive git@github.com:hanchenye/scalehls.git
$ cd scalehls
```

Then, run the following script to build ScaleHLS. Note that you can use `-j xx` to specify the number of parallel linking jobs.
```sh
$ ./build-scalehls.sh
```

After the building, we suggest to export the following paths.
```sh
$ export PATH=$PATH:$PWD/build/bin:$PWD/polygeist/build/mlir-clang
$ export PYTHONPATH=$PYTHONPATH:$PWD/build/tools/scalehls/python_packages/scalehls_core
```

### Try ScaleHLS
To launch the automatic kernel-level design space exploration, run:
```sh
$ mlir-clang samples/polybench/gemm/gemm_32.c -function=gemm_32 -memref-fullrank -raise-scf-to-affine -S \
    | scalehls-opt -dse="top-func=gemm_32 target-spec=samples/polybench/target-spec.ini" -debug-only=scalehls > /dev/null \
    && scalehls-translate -emit-hlscpp gemm_32_pareto_0.mlir > gemm_32_pareto_0.cpp
```

Meanwhile, we provide a `pyscalehls` tool to showcase the `scalehls` Python package:
```sh
$ pyscalehls.py samples/polybench/syrk/syrk_32.c -f syrk_32
```

## Integration with ONNX-MLIR
If you have installed [ONNX-MLIR](https://github.com/onnx/onnx-mlir) or established ONNX-MLIR docker to `$ONNXMLIR_DIR`, you should be able to run the following integration test:
```sh
$ cd samples/onnx-mlir/resnet18

$ # Export PyTorch model to ONNX.
$ python3 export_resnet18.py

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
- [MLIR](https://mlir.llvm.org): Multi-Level Intermediate Representation
- [ONNX-MLIR](https://github.com/onnx/onnx-mlir): The Open Neural Network Exchange implementation in MLIR
- [CIRCT](https://github.com/llvm/circt): Circuit IR Compilers and Tools
