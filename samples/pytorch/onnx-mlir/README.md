## Using ONNX-MLIR front-end (deprecated, will be removed soon)
If you have installed [ONNX-MLIR](https://github.com/onnx/onnx-mlir) or established ONNX-MLIR docker, you should be able to run the following test:
```sh
$ cd resnet18

$ # Export PyTorch model to ONNX.
$ python3 export_resnet18.py

$ # Parse ONNX model to MLIR.
$ onnx-mlir -EmitMLIRIR resnet18.onnx

$ # Legalize the output of ONNX-MLIR, optimize and emit C++ code.
$ scalehls-opt resnet18.onnx.mlir -allow-unregistered-dialect \
    -scalehls-pipeline="top-func=main_graph opt-level=2 frontend=onnx" \
    | scalehls-translate -emit-hlscpp > resnet18.cpp
```
