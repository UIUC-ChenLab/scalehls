# ScaleHLS Project

ScaleHLS is a High-level Synthesis (HLS) framework on [MLIR](https://mlir.llvm.org). ScaleHLS can compile HLS C/C++ or PyTorch model to optimized HLS C/C++ in order to generate high-efficiency RTL design using downstream tools, such as Vivado HLS.

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

## Setting this up

### Prerequisites
- cmake
- ninja
- clang and lld (recommended)
- pybind11
- python3 with numpy

### Clone ScaleHLS
```sh
$ git clone --recursive git@github.com:hanchenye/scalehls.git
$ cd scalehls
```

### Build ScaleHLS
Run the following script to build ScaleHLS. Note that you can use `-j xx` to specify the number of parallel linking jobs.
```sh
$ ./build-scalehls.sh
```

After the build, we suggest to export the following paths.
```sh
$ export PATH=$PATH:$PWD/build/bin:$PWD/polygeist/build/bin
$ export PYTHONPATH=$PYTHONPATH:$PWD/build/tools/scalehls/python_packages/scalehls_core
```

## Compiling HLS C/C++ 
To launch the automatic kernel-level design space exploration, run:
```sh
$ mlir-clang samples/polybench/gemm/test_gemm.c -function=test_gemm -memref-fullrank -raise-scf-to-affine -S \
    | scalehls-opt -dse="top-func=test_gemm target-spec=samples/polybench/config.json" -debug-only=scalehls \
    | scalehls-translate -emit-hlscpp > test_gemm_dse.cpp

$ mlir-clang samples/rosetta/spam-filter/sgd_sw.c -function=SgdLR_sw -memref-fullrank -raise-scf-to-affine -S \
    | scalehls-opt -materialize-reduction -dse="top-func=SgdLR_sw target-spec=samples/rosetta/config.json" -debug-only=scalehls \
    | scalehls-translate -emit-hlscpp > sgd_sw_dse.cpp
```

Meanwhile, we provide a `pyscalehls` tool to showcase the `scalehls` Python library:
```sh
$ pyscalehls.py samples/polybench/syrk/test_syrk.c -f test_syrk
```

## Compiling PyTorch model
If you have installed [Torch-MLIR](https://github.com/llvm/torch-mlir), you should be able to run the following test:
```sh
$ cd resnet18

$ # Parse PyTorch model to TOSA dialect (with mlir_venv activated).
$ # This may take several minutes to compile due to the large amount of weights.
$ python3 export_resnet18_mlir.py | torch-mlir-opt \
    -torchscript-module-to-torch-backend-pipeline="optimize=true" \
    -torch-backend-to-tosa-backend-pipeline="optimize=true" \
    -canonicalize > resnet18.mlir

$ # Optimize the model and emit C++ code.
$ # This may take several minutes to compile due to the large amount of weights.
$ scalehls-opt resnet18.mlir \
    -scalehls-pipeline="top-func=forward opt-level=2 frontend=torch" \
    | scalehls-translate -emit-hlscpp > resnet18.cpp
```

## Repository Layout
The project follows the conventions of typical MLIR-based projects:
- `include/scalehls` and `lib` for C++ MLIR compiler dialects/passes.
- `polygeist` for the HLS C/C++ front-end.
- `samples` for example test cases.
- `test` for holding regression tests.
- `tools` for command line tools, such as `scalehls-opt` and `pyscalehls`.
