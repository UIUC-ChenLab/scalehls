//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSOPSUBUF_TD
#define SCALEHLS_DIALECT_HLS_HLSOPSUBUF_TD

//===----------------------------------------------------------------------===//
// Unified Buffer (UBUF) Operations
//===----------------------------------------------------------------------===//

def BufferOp : HLSOp<"ubuf.buffer", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
      DeclareOpInterfaceMethods<BufferLikeInterface>]> {
  let summary = "Represent a dataflow buffer";

  let arguments = (ins I32Attr:$depth,
                       OptionalAttr<TypedAttrInterface>:$init_value);
  let results = (outs AnyBuffer:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let hasVerifier = 1;
  let hasCanonicalizer = 1;
  let builders = [
    OpBuilder<(ins "mlir::Type":$memref),
        "build($_builder, $_state, memref, 1, nullptr);">
  ];
}

def ConstBufferOp : HLSOp<"ubuf.const_buffer", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
      DeclareOpInterfaceMethods<BufferLikeInterface>]> {
  let summary = "Represent a constant dataflow buffer";

  let arguments = (ins ElementsAttr:$value);
  let results = (outs AnyBuffer:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let hasVerifier = 1;
}

def StreamOp : HLSOp<"ubuf.stream", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Declare a stream channel";

  let arguments = (ins I32Attr:$depth);
  let results = (outs StreamOf<[AnyType]>:$channel);
  let assemblyFormat = "attr-dict `:` type($channel)";

  let hasVerifier = 1;
  let builders = [
    OpBuilder<(ins "mlir::Type":$channel),
        "build($_builder, $_state, channel, 1);">
  ];
}

def StreamReadOp : HLSOp<"ubuf.stream_read", []> {
  let summary = "Read a stream channel";
  let description = [{
    Read/pop a value from a stream channel. The absence of the result indicates
    the popped value is dropped. Each stream channel can be read multiple times.
  }];

  let arguments = (ins StreamOf<[AnyType]>:$channel);
  let results = (outs Optional<AnyType>:$result);
  let assemblyFormat = [{
    $channel attr-dict `:` functional-type($channel, $result)
  }];

  let hasVerifier = 1;
}

def StreamWriteOp : HLSOp<"ubuf.stream_write", []> {
  let summary = "Write a stream channel";
  let description = [{
    Write/push a value to a stream channel. Each stream channel can only be
    written once.
  }];

  let arguments = (ins StreamOf<[AnyType]>:$channel, AnyType:$value);
  let assemblyFormat = [{
    $channel `,` $value attr-dict `:` type($channel) `,` type($value)
  }];

  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// Vectorization-related Operations
//===----------------------------------------------------------------------===//

def BufferVectorizeOp : HLSOp<"buffer_vectorize", [ViewLikeOpInterface,
      NoMemoryEffect]> {
  let summary = "Vectorize a buffer from scalar element to vector element";

  let arguments = (ins AnyBuffer:$input);
  let results = (outs StaticShapeMemRefOf<[AnyVector]>:$output);
  let assemblyFormat = "$input attr-dict `:` type($input) `to` type($output)";

  let hasFolder = 1;
  let hasVerifier = 1;
  let extraClassDeclaration = [{
    Value getViewSource() { return getInput(); }
    MemRefType getInputType() {
      return getInput().getType().cast<MemRefType>();
    }
    VectorType getOutputVectorType() {
      return getType().getElementType().cast<VectorType>();
    }
  }];
}

def BufferDevectorizeOp : HLSOp<"buffer_devectorize", [ViewLikeOpInterface,
      NoMemoryEffect]> {
  let summary = "Devectorize a buffer from vector element to scalar element";

  let arguments = (ins StaticShapeMemRefOf<[AnyVector]>:$input);
  let results = (outs AnyBuffer:$output);
  let assemblyFormat = "$input attr-dict `:` type($input) `to` type($output)";

  let hasVerifier = 1;
  let extraClassDeclaration = [{
    Value getViewSource() { return getInput(); }
    MemRefType getInputType() {
      return getInput().getType().cast<MemRefType>();
    }
    VectorType getInputVectorType() {
      return getInputType().getElementType().cast<VectorType>();
    }
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSOPSUBUF_TD
