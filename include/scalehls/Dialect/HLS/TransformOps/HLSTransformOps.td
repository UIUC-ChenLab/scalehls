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

def HLSConvertExtractSliceToTensorInitOp : Op<Transform_Dialect,
    "hls.convert_extract_slice_to_tensor_init",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{}];
  let arguments = (ins TransformHandleTypeInterface:$target);
  let results = (outs TransformHandleTypeInterface:$result);
  let assemblyFormat = [{
    $target attr-dict `:` functional-type($target, $result)
  }];
  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::ExtractSliceOp target,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMOPS_HLSTRANSFORMOPS_TD
