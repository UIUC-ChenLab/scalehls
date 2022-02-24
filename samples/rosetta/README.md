## Compiling spam-filter from Rosetta
```shell
$ mlir-clang spam-filter/sgd_sw.c -function=SgdLR_sw -memref-fullrank -raise-scf-to-affine -S \
    | scalehls-opt -materialize-reduction -dse="top-func=SgdLR_sw target-spec=config.json" -debug-only=scalehls \
    | scalehls-translate -emit-hlscpp > sgd_sw_dse.cpp
```
