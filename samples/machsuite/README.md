## backprop benchmark

The source code is slightly changed to make `mlir-clang -memref-fullrank` work:
- `RELU` function is duplicated to `RELU_output` and `RELU_hidden`.
- `add_bias_to_activations` function is duplicated to `add_bias_to_activations_output` and `add_bias_to_activations_hidden`.

```sh
$ mlir-clang backprop.c -function=backprop -S -memref-fullrank -raise-scf-to-affine -I /usr/lib/clang/10.0.0/include -O0 -subindex-to-subview  > backprop.mlir
$ scalehls-opt backprop.mlir -scalehls-materialize-reduction -scalehls-func-duplication -scalehls-func-preprocess="top-func=backprop" -buffer-loop-hoisting -affine-scalrep -scalehls-affine-loop-perfection >  base.mlir
```
