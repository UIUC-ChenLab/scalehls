# ScaleHLS Project

[![Build and Test](https://github.com/hanchenye/scalehls/actions/workflows/buildAndTest.yml/badge.svg?branch=torch-hls)](https://github.com/hanchenye/scalehls/actions/workflows/buildAndTest.yml)

ScaleHLS is a High-level Synthesis (HLS) framework on [MLIR](https://mlir.llvm.org). ScaleHLS can compile HLS C/C++ or PyTorch model to optimized HLS C/C++ in order to generate high-efficiency RTL design using downstream tools, such as Xilinx Vivado HLS.

By using the MLIR framework that can be better tuned to particular algorithms at different representation levels, ScaleHLS is more scalable and customizable towards various applications coming with intrinsic structural or functional hierarchies. ScaleHLS represents HLS designs at multiple levels of abstraction and provides an HLS-dedicated analysis and transform library (in both C++ and Python) to solve the optimization problems at the suitable representation levels. Using this library, we've developed a design space exploration engine to generate optimized HLS designs automatically.

For more details, please see our [HPCA'22 paper](https://arxiv.org/abs/2107.11673):
```bibtex
@article{ye2021scalehls,
  title={ScaleHLS: A New Scalable High-Level Synthesis Framework on Multi-Level Intermediate Representation},
  author={Ye, Hanchen and Hao, Cong and Cheng, Jianyi and Jeong, Hyunmin and Huang, Jack and Neuendorffer, Stephen and Chen, Deming},
  journal={arXiv preprint arXiv:2107.11673},
  year={2021}
}
```

## Framework Architecture

<p align="center"><img src="docs/ScaleHLS.svg"/></p>

## Setting this up

### Prerequisites
- python3
- cmake
- ninja
- clang and lld

Optionally, the following packages are required for the Python binding.
- pybind11
- numpy

### Clone ScaleHLS
```sh
$ git clone --recursive git@github.com:hanchenye/scalehls.git
$ cd scalehls
```

### Build ScaleHLS
Run the following script to build ScaleHLS. Optionally, add `-p ON` to enable the Python binding and `-j xx` to specify the number of parallel linking jobs.
```sh
$ ./build-scalehls.sh
```

After the build, we suggest to export the following paths.
```sh
$ export PATH=$PATH:$PWD/build/bin:$PWD/polygeist/build/bin
$ export PYTHONPATH=$PYTHONPATH:$PWD/build/tools/scalehls/python_packages/scalehls_core
```

## Compiling HLS C/C++ 
To optimize C/C++ kernels with the design space exploration (DSE) engine, run:
```sh
$ cd samples/polybench/gemm

$ # Parse C/C++ kernel into MLIR.
$ mlir-clang test_gemm.c -function=test_gemm -S \
    -memref-fullrank -raise-scf-to-affine > test_gemm.mlir

$ # Launch the DSE and emit the optimized design as C++ code.
$ scalehls-opt test_gemm.mlir -debug-only=scalehls \
    -scalehls-dse-pipeline="top-func=test_gemm target-spec=../config.json" \
    | scalehls-translate -emit-hlscpp > test_gemm_dse.cpp
```

If Python binding is enabled, we provide a `pyscalehls` tool to showcase the `scalehls` Python library:
```sh
$ pyscalehls.py test_gemm.c -f test_gemm > test_gemm_pyscalehls.cpp
```

## Compiling PyTorch Model
If you have installed [Torch-MLIR](https://github.com/llvm/torch-mlir) with SHA [ea371a9](https://github.com/llvm/torch-mlir/tree/ea371a9bf2860cf5f0741b28b0bf68e9a9c3d08b), you should be able to run the following test:
```sh
$ cd samples/pytorch/resnet18

$ # Parse PyTorch model to TOSA dialect (with Torch-MLIR mlir_venv activated).
$ # This may take several minutes to compile due to the large amount of weights.
$ python3 export_resnet18_mlir.py | torch-mlir-opt \
    -torchscript-module-to-torch-backend-pipeline="optimize=true" \
    -torch-backend-to-tosa-backend-pipeline="optimize=true" > resnet18.mlir

$ # Optimize the model and emit C++ code.
$ scalehls-opt resnet18.mlir \
    -scalehls-pytorch-pipeline-v2="top-func=forward loop-tile-size=4 loop-unroll-factor=2" \
    | scalehls-translate -emit-hlscpp > resnet18.cpp
```

## Repository Layout
The project follows the conventions of typical MLIR-based projects:
- `include/scalehls` and `lib` for C++ MLIR dialects/passes.
- `polygeist` for the C/C++ front-end.
- `samples` for C/C++ and PyTorch examples.
- `test` for holding regression tests.
- `tools` for command line tools.
