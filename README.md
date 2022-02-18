# ScaleHLS Project

ScaleHLS is a High-level Synthesis (HLS) framework on [MLIR](https://mlir.llvm.org). ScaleHLS can compile HLS C/C++ or ONNX model to optimized HLS C/C++ in order to generate high-efficiency RTL design using downstream tools, such as Vivado HLS.

By using the MLIR framework that can be better tuned to particular algorithms at different representation levels, ScaleHLS is more scalable and customizable towards various applications coming with intrinsic structural or functional hierarchies. ScaleHLS represents HLS designs at multiple levels of abstraction and provides an HLS-dedicated analysis and transform library (in both C++ and Python) to solve the optimization problems at the suitable representation levels. Using this library, we've developed a design space exploration engine to generate optimized HLS designs automatically.

For more details, please see our [HPCA'22 paper](https://arxiv.org/abs/2107.11673).

## Quick Start

### Prerequisites
- cmake
- ninja
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

After the build, we suggest to export the following paths.
```sh
$ export PATH=$PATH:$PWD/build/bin:$PWD/polygeist/build/bin
$ export PYTHONPATH=$PYTHONPATH:$PWD/build/tools/scalehls/python_packages/scalehls_core
```

### Try ScaleHLS
To launch the automatic kernel-level design space exploration, run:
```sh
$ mlir-clang samples/polybench/gemm/test_gemm.c -function=test_gemm -memref-fullrank -raise-scf-to-affine -S \
    | scalehls-opt -dse="top-func=test_gemm target-spec=samples/polybench/config.json" -debug-only=scalehls > /dev/null \
    && scalehls-translate -emit-hlscpp test_gemm_pareto_0.mlir > test_gemm_pareto_0.cpp

$ mlir-clang samples/rosetta/spam-filter/sgd_sw.c -function=SgdLR_sw -memref-fullrank -raise-scf-to-affine -S \
    | scalehls-opt -materialize-reduction -dse="top-func=SgdLR_sw target-spec=samples/rosetta/config.json" -debug-only=scalehls > /dev/null \
    && scalehls-translate -emit-hlscpp SgdLR_sw_pareto_0.mlir > Sgd_sw_pareto_0.cpp
```

Meanwhile, we provide a `pyscalehls` tool to showcase the `scalehls` Python library:
```sh
$ pyscalehls.py samples/polybench/syrk/test_syrk.c -f test_syrk
```

## Integration with ONNX-MLIR
If you have installed [ONNX-MLIR](https://github.com/onnx/onnx-mlir) or established ONNX-MLIR docker to `$ONNXMLIR_DIR`, you should be able to run the following integration test:
```sh
$ cd samples/onnx-mlir/resnet18

$ # Export PyTorch model to ONNX.
$ python3 export_resnet18.py

$ # Parse ONNX model to MLIR.
$ $ONNXMLIR_DIR/build/bin/onnx-mlir -EmitMLIRIR resnet18.onnx

$ # Legalize the output of ONNX-MLIR, optimize and emit C++ code.
$ scalehls-opt resnet18.onnx.mlir -allow-unregistered-dialect
    -scalehls-pipeline="top-func=main_graph opt-level=2" \
    | scalehls-translate -emit-hlscpp > resnet18.cpp
```

Please refer to the `samples/onnx-mlir` folder for more test cases.

## References
- [CIRCT](https://github.com/llvm/circt): Circuit IR Compilers and Tools
- [CIRCT-HLS](https://github.com/circt-hls/circt-hls): A HLS flow around CIRCT project
