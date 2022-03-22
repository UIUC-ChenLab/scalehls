## Compiling PyTorch Model with New Flow

```sh
scalehls-opt resnet18.mlir \
  -scalehls-fake-quantize \
  -scalehls-simplify-tosa-graph \
  -scalehls-heuristic-node-fusion \
  -scalehls-create-token-flow \
  -tosa-to-linalg-named \
  -canonicalize \
  -scalehls-tosa-to-linalg-cleanup \
  -tosa-to-linalg \
  -tosa-to-standard \
  -scalehls-create-runtime-main="top-func=forward" \
  -linalg-generalize-named-ops \
  -linalg-bufferize \
  -func-bufferize \
  -buffer-results-to-out-params \
  -convert-linalg-to-affine-loops \
  -scalehls-convert-copy-to-affine-loops \
  -fold-memref-subview-ops \
  -affine-loop-normalize \
  -affine-simplify-structures \
  -canonicalize \
  -affine-loop-fusion="fusion-compute-tolerance=100" \
  -canonicalize \
  -affine-scalrep \
  -scalehls-raise-implicit-copy \
  -scalehls-convert-copy-to-affine-loops \
  -scalehls-func-dataflow="target-func=forward" \
  -scalehls-hoist-stream-channel \
  -scalehls-create-axi-interface \
  -scalehls-affine-loop-perfection \
  -affine-scalrep \
  -scalehls-remove-variable-bound \
  -scalehls-affine-loop-tile="tile-size=4" \
  -affine-loop-normalize \
  -affine-simplify-structures \
  -canonicalize \
  -scalehls-affine-loop-order-opt \
  -scalehls-create-memref-subview \
  -cse -canonicalize \
  -scalehls-promote-buffer \
  -buffer-loop-hoisting \
  -scalehls-convert-copy-to-affine-loops="intern-copy-only=false" \
  -fold-memref-subview-ops \
  -affine-loop-normalize \
  -affine-simplify-structures \
  -canonicalize \
  -scalehls-affine-loop-dataflow="balance=false" \
  -scalehls-affine-loop-unroll-jam="unroll-factor=2 point-loop-only" \
  -affine-loop-normalize \
  -affine-simplify-structures \
  -canonicalize \
  -scalehls-simplify-affine-if \
  -scalehls-affine-store-forward \
  -scalehls-simplify-memref-access \
  -scalehls-reduce-initial-interval \
  -cse -canonicalize \
  -scalehls-loop-pipelining \
  -scalehls-array-partition \
  > resnet18.opt.mlir

scalehls-translate resnet18.opt.mlir -emit-hlscpp > resnet18.opt.cpp
```
