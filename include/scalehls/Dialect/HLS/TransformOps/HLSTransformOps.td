//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMOPS_HLSTRANSFORMOPS_TD
#define SCALEHLS_DIALECT_HLS_TRANSFORMOPS_HLSTRANSFORMOPS_TD

include "mlir/Dialect/Transform/IR/TransformDialect.td"
include "mlir/Dialect/Transform/IR/TransformInterfaces.td"
include "mlir/Dialect/Transform/IR/TransformTypes.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/IR/OpBase.td"

def HLSLinalgTileOp : Op<Transform_Dialect, "hls.linalg_tile",
       [FunctionalStyleTransformOpTrait, MemoryEffectsOpInterface,
        TransformEachOpTrait, TransformOpInterface,
        ReportTrackingListenerFailuresOpTrait]> {
  let description = [{
    Indicates that the given `target` op should be transformed with the
    `tileReduction` transformation with the tile size provided as attribute.

    This transformation tiles the `target` along the reduction dimensions. It
    creates a tensor initialized with the identity value. Then it creates nested
    loops with a parallel version of `target` op inside. The parallel op
    dimensions are less or equal to the tile size passed by user.
    After the loop a merge operation is created to do a final reduction with the
    partial reductions.
    The initial tensor always uses the tile size dimension. This may overallocate
    if the tile size is greater than the reduction dimension.

    #### Return modes

    Returns 4 handles associated with (in order):
      - the fill op used to initialize the neutral element,
      - the parallel tiled op and
      - the result-combining op,
      - the parent `for` op.

    #### Example:

    ```
      %red = linalg.generic {indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>,
                                              affine_map<(d0, d1) -> (d0)>],
      iterator_types = ["parallel", "reduction"]}
      ins(%arg0 : tensor<?x?xf32>)
      outs(%out : tensor<?xf32>) {
        ^bb0(%arg7: f32, %arg9: f32):
        %1 = arith.addf %arg7, %arg9 : f32
        linalg.yield %1 : f32
      } -> tensor<?xf32>
      return %red : tensor<?xf32>
    ```

    is transformed into:

    ```
      %0 = tensor.empty(%dim_1) : tensor<?x5xf32>
      %1 = linalg.fill ins(%cst : f32) outs(%0 : tensor<?x5xf32>) -> tensor<?x5xf32>
      %2 = scf.for %arg2 = %c0 to %dim_0 step %c5 iter_args(%arg3 = %1) -> (tensor<?x5xf32>) {
        %extracted_slice = tensor.extract_slice %1[0, 0] [%dim, 5] [1, 1] : tensor<?x5xf32> to tensor<?x5xf32>
        %extracted_slice_2 = tensor.extract_slice %arg0[0, %arg2] [%dim, 5] [1, 1] : tensor<?x?xf32> to tensor<?x5xf32>
        %4 = linalg.generic {indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>,
                                              affine_map<(d0, d1) -> (d0, d1)>],
        iterator_types = ["parallel", "parallel"]}
        ins(%extracted_slice_2 : tensor<?x5xf32>)
        outs(%extracted_slice : tensor<?x5xf32>) {
        ^bb0(%in: f32, %out: f32):
          %5 = arith.addf %in, %out : f32
          linalg.yield %5 : f32
        } -> tensor<?x5xf32>
        %dim_3 = tensor.dim %1, %c0 : tensor<?x5xf32>
        %inserted_slice = tensor.insert_slice %4 into %arg3[0, 0] [%dim_3, 5] [1, 1] : tensor<?x5xf32> into tensor<?x5xf32>
        scf.yield %inserted_slice : tensor<?x5xf32>
      }
      %3 = linalg.generic {indexing_maps = [affine_map<(d0, d1) -> (d0, d1)>,
                                            affine_map<(d0, d1) -> (d0)>],
      iterator_types = ["parallel", "reduction"]}
      ins(%2 : tensor<?x5xf32>)
      outs(%arg1 : tensor<?xf32>) {
      ^bb0(%in: f32, %out: f32):
        %4 = arith.addf %in, %out : f32
        linalg.yield %4 : f32
      } -> tensor<?xf32>
    ```
  }];

  // TODO: support mixed static-dynamic (see TileUsingForallOp).
  let arguments = (ins TransformHandleTypeInterface:$target,
                   DefaultValuedAttr<DenseI64ArrayAttr, "{}">:$tile_sizes);
  let results = (outs TransformHandleTypeInterface:$fill_op,
                      TransformHandleTypeInterface:$split_linalg_op,
                      TransformHandleTypeInterface:$combining_linalg_op,
                      TransformHandleTypeInterface:$for_op);

  let builders = [
    OpBuilder<(ins "Value":$target,
                   "ArrayRef<int64_t>":$staticTileSizes)>
  ];

  let assemblyFormat = [{
    $target `by` `tile_sizes` `=` $tile_sizes attr-dict `:`
    functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::linalg::LinalgOp target,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMOPS_HLSTRANSFORMOPS_TD
