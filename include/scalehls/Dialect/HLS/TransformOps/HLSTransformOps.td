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
  let description = [{}];
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
      Transform_ConcreteOpType<"hls.stream_read">:$stream_write);
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

def HLSFoldExpandShapeOp : Op<Transform_Dialect, "hls.fold_expand_shape",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{}];
  let arguments = (ins
      Transform_ConcreteOpType<"tensor.expand_shape">:$expand_shape);
  let assemblyFormat = "$expand_shape attr-dict `:` type(operands)";
  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::ExpandShapeOp expandShape,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

def HLSFoldCollapseShapeOp : Op<Transform_Dialect, "hls.fold_collapse_shape",
    [FunctionalStyleTransformOpTrait, TransformEachOpTrait,
     TransformOpInterface, MemoryEffectsOpInterface]> {
  let description = [{}];
  let arguments = (ins
      Transform_ConcreteOpType<"tensor.collapse_shape">:$collapse_shape);
  let assemblyFormat = "$collapse_shape attr-dict `:` type(operands)";
  let extraClassDeclaration = [{
    ::mlir::DiagnosedSilenceableFailure applyToOne(
        ::mlir::transform::TransformRewriter &rewriter,
        ::mlir::tensor::CollapseShapeOp collapseShape,
        ::mlir::transform::ApplyToEachResultList &results,
        ::mlir::transform::TransformState &state);
  }];
}

// def HLSFoldTensorToStreamOp : Op<Transform_Dialect, "hls.fold_tensor_to_stream",
//     [DeclareOpInterfaceMethods<TransformOpInterface>,
//      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
//   let description = [{}];
//   let arguments = (ins
//       Transform_ConcreteOpType<"hls.tensor_to_stream">:$tensor_to_stream,
//       Transform_ConcreteOpType<"hls.stream_read">:$stream_read);
//   let assemblyFormat = [{
//     `tensor_to_stream` $tensor_to_stream `,` `stream_read` $stream_read
//     attr-dict `:` type(operands)
//   }];
// }

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMOPS_HLSTRANSFORMOPS_TD
