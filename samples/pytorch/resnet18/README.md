## Compiling PyTorch Model with New Flow

```sh
$ scalehls-opt resnet18.mlir \
    -scalehls-pytorch-pipeline-v2="top-func=forward loop-tile-size=4 loop-unroll-factor=2 fake-quantize" \
    > resnet18.opt.mlir

$ scalehls-translate resnet18.opt.mlir -emit-hlscpp > resnet18.opt.cpp
```
