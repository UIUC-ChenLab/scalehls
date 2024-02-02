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
    initial tensor. This transform must be applied on the `init` operand of an
    linalg op. Meanwhile, the real producer of the `init` operand must be an
    `tensor_init` op in the first place, otherwise a silenceable failure will be
    emitted. This transform returns the handle of the new `tensor_init` op.
  }];
  let arguments = (ins
      Transform_ConcreteOpType<"tensor.extract_slice">:$extract_slice);
  let results = (outs
      Transform_ConcreteOpType<"hls.tensor_init">:$tensor_init);
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

def HLSDemoteExtractSliceOp : Op<Transform_Dialect, "hls.demote_extract_slice",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{
    Demote an `extract_slice` op to as outer as possible loop level, potentially
    increasing the resuability of the extracted tensor. The source of the target
    `extract_slice` op must not be an iteration argument of a loop, otherwise a
    silenceable failure will be emitted. This transform always returns the
    handle of the target `extract_slice` op, no matter it has been demoted or
    not.
  }];
  let arguments = (ins
      Transform_ConcreteOpType<"tensor.extract_slice">:$extract_slice);
  let results = (outs
      Transform_ConcreteOpType<"tensor.extract_slice">:$demoted_extract_slice);
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
  let description = [{}];
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
  let description = [{}];
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

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMOPS_HLSTRANSFORMOPS_TD
