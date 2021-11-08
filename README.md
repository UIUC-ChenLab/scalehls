# ScaleHLS Project (scalehls)

High-level Synthesis (HLS) has been widely adopted as it significantly improves the hardware design productivity and enables efficient design space exploration (DSE). HLS tools can be used to deliver solutions for many different kinds of design problems, which are often better solved with different levels of abstraction. While existing HLS tools are built using compiler infrastructures largely based on a single-level abstraction (e.g., LLVM), we propose ScaleHLS, a next-generation HLS compilation flow, on top of a multi-level compiler infrastructure called MLIR, for the first time. By using an intermediate representation (IR) that can be better tuned to particular algorithms at different representation levels, we are able to build this new HLS tool that is more scalable and customizable towards various applications coming with intrinsic structural or functional hierarchies. ScaleHLS is able to represent and optimize HLS designs at multiple levels of abstraction and provides an HLS-dedicated transform and analysis library to solve the optimization problems at the suitable representation levels. On top of the library, we also build an automated DSE engine to explore the multi-dimensional design space efficiently. In addition, we develop an HLS C front-end and a C/C++ emission back-end to translate HLS designs into/from MLIR for enabling the end-to-end ScaleHLS flow. Experimental results show that, comparing to the baseline designs only optimized by Xilinx Vivado HLS, ScaleHLS improves the performances with amazing quality-of-results -- up to 768.1x better on computation kernel level programs and up to 3825.0x better on neural network models.

Please check out our [HPCA'22 paper](https://arxiv.org/abs/2107.11673) for more details.

## Quick Start

### 1. Install ScaleHLS
To enable the Python binding feature, please make sure the `pybind11` has been installed. To build MLIR and ScaleHLS, run (note that the `-DLLVM_PARALLEL_LINK_JOBS` option can be tuned to reduce the memory usage):
```sh
$ git clone --recursive git@github.com:hanchenye/scalehls.git

$ mkdir scalehls/build
$ cd scalehls/build
$ cmake -G Ninja ../polygeist/llvm-project/llvm \
    -DLLVM_ENABLE_PROJECTS="mlir;clang" \
    -DLLVM_EXTERNAL_PROJECTS="scalehls" \
    -DLLVM_EXTERNAL_SCALEHLS_SOURCE_DIR=$PWD/.. \
    -DLLVM_TARGETS_TO_BUILD="host" \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DMLIR_ENABLE_BINDINGS_PYTHON=ON \
    -DSCALEHLS_ENABLE_BINDINGS_PYTHON=ON \
    -DLLVM_PARALLEL_LINK_JOBS= \
    -DLLVM_USE_LINKER=lld \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++
$ ninja
$ ninja check-scalehls

$ export PATH=$PATH:$PWD/bin
$ export PYTHONPATH=$PYTHONPATH:$PWD/tools/scalehls/python_packages/scalehls_core
```

ScaleHLS uses the `mlir-clang` tool of Polygeist as the C front-end. To build Polygeist, run:
```sh
$ mkdir scalehls/polygeist/build
$ cd scalehls/polygeist/build
$ cmake -G Ninja .. \
    -DMLIR_DIR=$PWD/../../build/lib/cmake/mlir \
    -DCLANG_DIR=$PWD/../../build/lib/cmake/clang \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_BUILD_TYPE=DEBUG \
    -DLLVM_USE_LINKER=lld \
    -DCMAKE_C_COMPILER=clang \
    -DCMAKE_CXX_COMPILER=clang++
$ ninja check-mlir-clang

$ export PATH=$PATH:$PWD/mlir-clang
```

### 2. Try ScaleHLS
After the installation and regression test successfully completed, you should be able to play with:
```sh
$ cd scalehls

$ # HLS C programs parsing and automatic kernel-level design space exploration.
$ mlir-clang samples/polybench/gemm/gemm_32.c -function=gemm_32 -memref-fullrank -raise-scf-to-affine -S \
    | scalehls-opt -dse="top-func=gemm_32 output-path=./ target-spec=samples/polybench/target-spec.ini" \
    -debug-only=scalehls > /dev/null
$ scalehls-translate -emit-hlscpp gemm_32_pareto_0.mlir > gemm_32_pareto_0.cpp

$ # Loop and directive-level optimizations, QoR estimation, and C++ code generation.
$ mlir-clang samples/polybench/syrk/syrk_32.c -function=syrk_32 -memref-fullrank -raise-scf-to-affine -S \
    | scalehls-opt -affine-loop-perfection -affine-loop-order-opt -remove-variable-bound \
    -partial-affine-loop-tile="tile-size=2" -legalize-to-hlscpp="top-func=syrk_32" \
    -loop-pipelining="pipeline-level=3 target-ii=2" -canonicalize -simplify-affine-if \
    -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize \
    -qor-estimation="target-spec=samples/polybench/target-spec.ini" \
    | scalehls-translate -emit-hlscpp
```

If you have enabled the python binding feature, you should be able to run:
```sh
$ pyscalehls.py samples/polybench/syrk/syrk_32.c -f syrk_32
```

Note that you can use `help(any_module_or_class)` in Python to print the APIs of any Python module or class. For example, `help(scalehls)` can print the supported APIs in the `scalehls` module.

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
