## Using Torch-MLIR front-end
If you have installed [Torch-MLIR](https://github.com/llvm/torch-mlir), you should be able to run the following test:
```sh
$ cd resnet18

$ # Parse PyTorch model to Linalg dialect (with mlir_venv activated).
$ python3 export_resnet18_mlir.py | torch-mlir-opt \
    -torchscript-module-to-torch-backend-pipeline="optimize=true" \
    -torch-backend-to-linalg-on-tensors-backend-pipeline="optimize=true" \
    -canonicalize > resnet18.mlir

$ # Optimize the model and emit C++ code (not working, will be fixed soon).
$ scalehls-opt resnet18.mlir \
    -linalg-comprehensive-module-bufferize="allow-return-memref allow-unknown-ops create-deallocs=false" \
    -scalehls-pipeline="top-func=main_graph opt-level=2 frontend=torch" \
    | scalehls-translate -emit-hlscpp > resnet18.cpp
```
