//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_OPS_TD
#define SCALEHLS_DIALECT_HLS_OPS_TD

include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/ControlFlowInterfaces.td"

//===----------------------------------------------------------------------===//
// Graph Operations
//===----------------------------------------------------------------------===//

def GraphNodeOp : HLSOp<"graph.node", [IsolatedFromAbove,
      SingleBlockImplicitTerminator<"GraphOutputOp">]> {
  let summary = "Represent a graph node";
  let description = [{
    This operation represents a node of tensor-level graph. It has a region,
    which is not isolated from above, to represent the tensor operations
    contained by the node. The node can return variadic number of outputs.
  }];

  let hasCanonicalizer = 1;
  let hasVerifier = 1;
  let arguments = (ins Variadic<AnyType>:$inputs);
  let results = (outs Variadic<AnyType>:$outputs);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = [{
    `(` $inputs `)` attr-dict `:` functional-type($inputs, $outputs) $body
  }];
  let extraClassDeclaration = [{
    /// Get the terminator output op.
    GraphOutputOp getOutputOp();
  }];
}

def GraphOutputOp : HLSOp<"graph.output", [ReturnLike, Terminator,
      HasParent<"GraphNodeOp">]> {
  let summary = "Output operation of a graph node";
  let description = [{
    The operation terminates a graph node region and outputs internal values
    to the outside.
  }];

  let hasVerifier = 1;
  let arguments = (ins Variadic<AnyType>:$outputs);
  let builders = [ OpBuilder<(ins), "build($_builder, $_state, llvm::None);"> ];

  let assemblyFormat = [{ $outputs attr-dict `:` type($outputs) }];
}

//===----------------------------------------------------------------------===//
// Dataflow Operations
//===----------------------------------------------------------------------===//

class StreamOf<list<Type> allowedTypes> : Type<And<[
  CPred<"$_self.isa<::mlir::scalehls::hls::StreamType>()">,
  Concat<"[](::mlir::Type elementType) { return ",
    SubstLeaves<"$_self", "elementType", AnyTypeOf<allowedTypes>.predicate>,
    "; }($_self.cast<::mlir::scalehls::hls::StreamType>().getElementType())">
]>>;

def AnyStream : StreamOf<[AnyType]>;
def AnyMemrefOrStream : Type<Or<[AnyMemRef.predicate, AnyStream.predicate]>>;

def NodeOp : HLSOp<"node", [NoTerminator, IsolatedFromAbove, SingleBlock,
      AttrSizedOperandSegments]> {
  let summary = "Represent a dataflow node";
  let description = [{
    This operation represents a node of dataflow. It has a region, which is
    isolated from above, to represent the operations contained by the node. The
    node can only take buffer or stream.channel as inputs or outputs.
  }];

  let hasVerifier = 1;
  let arguments = (ins Variadic<AnyMemrefOrStream>:$inputs,
                       Variadic<AnyMemrefOrStream>:$outputs,
                       OptionalAttr<I32Attr>:$level);
  let regions = (region SizedRegion<1>:$body);

  let builders = [
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs),
                   "build($_builder, $_state, inputs, outputs, nullptr);">
  ];

  let assemblyFormat = [{
    (`ins` `(` $inputs^ `)`)? (`outs` `(` $outputs^ `)`)? attr-dict
    `:` functional-type($inputs, $outputs) $body
  }];
  let extraClassDeclaration = [{
    /// Check whether the operand is an output memref.
    bool isOutput(unsigned operandIdx);
    bool isOutput(OpOperand &operand);

    /// Get the input and output arguments.
    iterator_range<Block::args_iterator> getInputArguments();
    iterator_range<Block::args_iterator> getOutputArguments();
  }];
}

def BufferOp : HLSOp<"buffer"> {
  let summary = "Represent a dataflow buffer";

  let arguments = (ins I32Attr:$depth);
  let results = (outs AnyMemRef:$memref);

  let assemblyFormat = [{ attr-dict `:` type($memref) }];
}

def ConstBufferOp : HLSOp<"const_buffer"> {
  let summary = "Represent a cosntant dataflow buffer";

  let hasVerifier = 1;
  let arguments = (ins ElementsAttr:$value);
  let results = (outs AnyMemRef:$memref);

  let assemblyFormat = [{ attr-dict `:` type($memref) }];
}

//===----------------------------------------------------------------------===//
// Stream Operations
//===----------------------------------------------------------------------===//

def DataflowNodeOp : HLSOp<"dataflow.node",
      [SingleBlockImplicitTerminator<"DataflowOutputOp">]> {
  let summary = "Dataflow node operation";
  let description = [{
    This operation represents a node of dataflow. It has a region, which is not
    isolated from above, to represent the operations contained by the node. The
    node can return variadic number of results.
  }];

  let hasCanonicalizer = 1;
  let hasVerifier = 1;
  let arguments = (ins OptionalAttr<I32Attr>:$level);
  let results = (outs Variadic<AnyType>:$outputs);
  let regions = (region SizedRegion<1>:$body);

  let builders = [OpBuilder<(ins "mlir::TypeRange":$outputs),
                            "build($_builder, $_state, outputs, nullptr);">];

  let assemblyFormat = [{
    `(` `)` (`->` qualified(type($outputs))^)? attr-dict-with-keyword $body
  }];
  let extraClassDeclaration = [{
    DataflowOutputOp getOutputOp();
    
    /// Collect output values of the dataflow node. Note that here we consider
    /// not only SSA outputs, but also memrefs that are updated.
    SmallVector<mlir::Value> getOutputValues();
    
    /// Collect uses of the dataflow node. A use is defined by a pair of value
    /// (the edge) and operation (the user).
    SmallVector<std::pair<mlir::Value, mlir::Operation *>> getDataflowUses();
  }];
}

def DataflowOutputOp : HLSOp<"dataflow.output",
      [Terminator, HasParent<"DataflowNodeOp">, ReturnLike]> {
  let summary = "Output operation of a dataflow node";
  let description = [{
    The operation terminates a dataflow node region and outputs internal values
    to the outside.
  }];

  let hasVerifier = 1;
  let arguments = (ins Variadic<AnyType>:$outputs);
  let builders = [ OpBuilder<(ins), "build($_builder, $_state, llvm::None);"> ];
}

def DataflowSourceOp : HLSOp<"dataflow.source", [NoSideEffect]> {
  let summary = "Dataflow source operation";
  let description = [{
    The operation represents the source of a dataflow value.
  }];

  let results = (outs AnyType:$output);
}

def DataflowSinkOp : HLSOp<"dataflow.sink"> {
  let summary = "Dataflow sink operation";
  let description = [{
    The operation represents the sink of a dataflow value.
  }];

  let arguments = (ins AnyType:$input);
}

def DataflowBufferOp : HLSOp<"dataflow.buffer",
      [SameOperandsAndResultElementType, NoSideEffect]> {
  let summary = "Dataflow buffer operation";
  let description = [{
    The operation represents a buffer of a dataflow value.
  }];

  let hasCanonicalizer = 1;
  let hasVerifier = 1;
  let arguments = (ins AnyType:$input, I32Attr:$depth,
                       OptionalAttr<I32Attr>:$level);
  let results = (outs AnyType:$output);

  let builders = [OpBuilder<(ins "mlir::Type":$output, "mlir::Value":$input,
                   "uint32_t":$depth),
    "build($_builder, $_state, output, input, depth, nullptr);">];

  let extraClassDeclaration = [{ bool isExternal(); }];
}

def DeclaresStreamChannel : NativeOpTrait<"DeclaresStreamChannel">;

def StreamChannelOp : HLSOp<"stream.channel", [DeclaresStreamChannel]> {
  let summary = "Stream channel declaration operation";

  let hasVerifier = 1;
  let results = (outs StreamOf<[AnyType]>:$channel);
}

def StreamReadOp : HLSOp<"stream.read"> {
  let summary = "Stream channel read operation";
  let description = [{
    Read/pop a value from a stream channel. The absence of the result indicates
    the popped value is dropped. Each stream channel can be read multiple times.
  }];

  let hasVerifier = 1;
  let arguments = (ins StreamOf<[AnyType]>:$channel);
  let results = (outs Optional<AnyType>:$result);
}

def StreamWriteOp : HLSOp<"stream.write"> {
  let summary = "Stream channel write operation";
  let description = [{
    Write/push a value to a stream channel. Each stream channel can only be
    written once.
  }];

  let hasVerifier = 1;
  let arguments = (ins StreamOf<[AnyType]>:$channel, AnyType:$value);
}

//===----------------------------------------------------------------------===//
// Primitive Operations
//===----------------------------------------------------------------------===//

def PrimMulOp : HLSOp<"prim.mul", [NoSideEffect]> {
  let summary = "Multiplication primitive operation";
  let description = [{
    This primitive performs C = A * B, where A and B are 8-bits integers, while
    C is 16-bits integer. If C/A/B is vector, the length of vector must be two.
    There are 4 different cases on this:

    1) vec(C) = vec(A) * vec(B)
    2) vec(C) = vec(A) * B
    3) vec(C) = A * vec(B)
    4) C = A * B

    Note that case 2/3 could use the double pumping technique such that we can
    packing the two multiplications into one DSP instance. Please refer to
    "Xilinx WP486: Deep Learning with INT8 Optimization on Xilinx Devices" for
    more information.
  }];

  let hasVerifier = 1;
  let arguments = (ins AnyTypeOf<[I8, VectorOfLengthAndType<[2], [I8]>]>:$A,
                       AnyTypeOf<[I8, VectorOfLengthAndType<[2], [I8]>]>:$B);
  let results = (outs AnyTypeOf<[I16, VectorOfLengthAndType<[2], [I16]>]>:$C);

  let extraClassDeclaration = [{ bool isPackMul(); }];
}

def PrimBufferOp : HLSOp<"prim.buffer"> {
  let summary = "Represent a buffer primitive";

  let arguments = (ins I32Attr:$depth);
  let results = (outs AnyMemRef:$memref);
}

def PrimConstOp : HLSOp<"prim.const"> {
  let summary = "Represent a cosntant memref primitive";

  let hasVerifier = 1;
  let arguments = (ins ElementsAttr:$value);
  let results = (outs AnyMemRef:$memref);

  let extraClassDeclaration = [{
    mlir::Attribute getValue() { return value(); }
  }];
}

def PrimCastOp : HLSOp<"prim.cast",
    [SameOperandsAndResultShape, NoSideEffect]> {
  let summary = "Cast primitive operation";

  let hasCanonicalizer = 1;
  let arguments = (ins 
    AnyTypeOf<[I8, I16, I32,
               VectorOfLengthAndType<[2], [I8, I16, I32]>]>:$input
  );
  let results = (outs
    AnyTypeOf<[I8, I16, I32,
               VectorOfLengthAndType<[2], [I8, I16, I32]>]>:$output
  );
}

#endif // SCALEHLS_DIALECT_HLS_OPS_TD
