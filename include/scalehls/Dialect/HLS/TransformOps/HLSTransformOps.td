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
  let description = [{
    Convert a target `extract_slice` op to a `tensor_init` op, localizing the
    extracted tensor. This transform returns the handle of the new local
    `tensor_init` op.

    **This transform must be applied on the `init` operand of a linalg op.
    Meanwhile, the real producer of the source tensor must be an `tensor_init`
    op in the first place, otherwise a silenceable failure will be emitted.**
  }];

  let arguments = (ins
      Transform_ConcreteOpType<"tensor.extract_slice">:$extract_slice);
  let results = (outs Transform_ConcreteOpType<"hls.tensor_init">:$tensor_init);
  let assemblyFormat = [{
    $extract_slice attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::ExtractSliceOp extractSlice,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HLSConvertFillToTensorInitOp : Op<Transform_Dialect,
    "hls.convert_fill_to_tensor_init",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{
    Convert a target `fill` op to a `tensor_init` op. This transform returns the
    handle of the new `tensor_init` op.
  }];

  let arguments = (ins Transform_ConcreteOpType<"linalg.fill">:$fill);
  let results = (outs Transform_ConcreteOpType<"hls.tensor_init">:$tensor_init);
  let assemblyFormat = [{
    $fill attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::linalg::FillOp fill,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HLSMergeConsecutiveExtractSliceOp : Op<Transform_Dialect,
    "hls.merge_consecutive_extract_slice",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{
    Merge consecutive `extract_slice` ops to a single `extract_slice` op. This
    transform always return the handle of the resulting `extract_slice` op, no
    matter it has been merged or not.
  }];

  let arguments = (ins
      Transform_ConcreteOpType<"tensor.extract_slice">:$extract_slice);
  let results = (outs
      Transform_ConcreteOpType<"tensor.extract_slice">:$merged_extract_slice);
  let assemblyFormat = [{
    $extract_slice attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::ExtractSliceOp extractSlice,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HLSConvertInsertSliceToStreamOp : Op<Transform_Dialect,
    "hls.convert_insert_slice_to_stream",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{
    Convert a target `insert_slice` op to 1) a `stream` op, replacing the
    destination tensor with a stream channel, 2) a `stream_write` op, writing
    the slice tensor to the stream channel instead of inserting to the
    destination tensor, and 3) a `stream_to_tensor` op, converting the stream
    channel back to a new destination tensor and replace the original one.

    **This transform must be applied on the only user of an destination tensor,
    and the source slice tensor must be the `result` of a statically tiled
    linalg op, otherwise a silenceable failure will be emitted.** This can
    ensure there's no other operations having effects on the destination tensor.
  }];

  let arguments = (ins
      Transform_ConcreteOpType<"tensor.insert_slice">:$insert_slice);
  let results = (outs
      Transform_ConcreteOpType<"hls.stream">:$stream,
      Transform_ConcreteOpType<"hls.stream_write">:$stream_write,
      Transform_ConcreteOpType<"hls.stream_to_tensor">:$stream_to_tensor);
  let assemblyFormat = [{
    $insert_slice attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::InsertSliceOp insertSlice,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HLSConvertExtractSliceToStreamOp : Op<Transform_Dialect,
    "hls.convert_extract_slice_to_stream",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{
    Convert a target `extract_slice` op to 1) a `tensor_to_stream` op,
    converting the source tensor to a stream channel, and 2) a `stream_read` op,
    reading the destination slice tensor from the stream channel instead of
    extracting from the source tensor.

    **This transform must be applied on the `input` operand of a statically
    tiled linalg op, otherwise a silenceable failure will be emitted.**
  }];

  let arguments = (ins
      Transform_ConcreteOpType<"tensor.extract_slice">:$extract_slice);
  let results = (outs
      Transform_ConcreteOpType<"hls.tensor_to_stream">:$tensor_to_stream,
      Transform_ConcreteOpType<"hls.stream_read">:$stream_read);
  let assemblyFormat = [{
    $extract_slice attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::ExtractSliceOp extractSlice,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HLSConvertExpandShapeToStreamOp : Op<Transform_Dialect,
    "hls.convert_expand_shape_to_stream",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{}];

  let arguments = (ins
      Transform_ConcreteOpType<"tensor.expand_shape">:$expand_shape,
      DenseI64ArrayAttr:$source_element_shape,
      DenseI64ArrayAttr:$result_element_shape);
  let results = (outs
      Transform_ConcreteOpType<"hls.tensor_to_stream">:$tensor_to_stream,
      Transform_ConcreteOpType<"hls.stream_expand_shape">:$stream_expand_shape,
      Transform_ConcreteOpType<"hls.stream_to_tensor">:$stream_to_tensor);
  let assemblyFormat = [{
    $expand_shape attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::ExpandShapeOp expandShape,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HLSConvertCollapseShapeToStreamOp : Op<Transform_Dialect,
    "hls.convert_collapse_shape_to_stream",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{}];

  let arguments = (ins
      Transform_ConcreteOpType<"tensor.collapse_shape">:$collapse_shape,
      DenseI64ArrayAttr:$source_element_shape,
      DenseI64ArrayAttr:$result_element_shape);
  let results = (outs
      Transform_ConcreteOpType<"hls.tensor_to_stream">:$tensor_to_stream,
      Transform_ConcreteOpType<"hls.stream_collapse_shape">:$stream_collapse_shape,
      Transform_ConcreteOpType<"hls.stream_to_tensor">:$stream_to_tensor);
  let assemblyFormat = [{
    $collapse_shape attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::CollapseShapeOp collapseShape,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HLSEliminateIntermediateTensorOp : Op<Transform_Dialect,
    "hls.eliminate_intermediate_tensor",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{}];

  let arguments = (ins
      Transform_ConcreteOpType<"hls.tensor_to_stream">:$tensor_to_stream);
  let assemblyFormat = [{
    $tensor_to_stream attr-dict `:` type(operands)
  }];

  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::scalehls::hls::TensorToStreamOp tensorToStream,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMOPS_HLSTRANSFORMOPS_TD
