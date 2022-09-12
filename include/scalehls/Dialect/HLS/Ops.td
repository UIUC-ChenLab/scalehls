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
// Traits and Type Constraints
//===----------------------------------------------------------------------===//

class StreamOf<list<Type> allowedTypes> : Type<And<[
    CPred<"$_self.isa<::mlir::scalehls::hls::StreamType>()">,
    Concat<"[](::mlir::Type elementType) { return ",
      SubstLeaves<"$_self", "elementType", AnyTypeOf<allowedTypes>.predicate>,
      "; }($_self.cast<::mlir::scalehls::hls::StreamType>().getElementType())">
  ]>,
  "stream of " # AnyTypeOf<allowedTypes>.summary # " values",
  "::mlir::scalehls::hls::StreamType"
>;

def AnyStream : StreamOf<[AnyType]>;
def AnyMemrefOrStream : Type<Or<[AnyMemRef.predicate, AnyStream.predicate]>,
    "memref or stream values">;

def DataflowBufferLike : NativeOpTrait<"DataflowBufferLike">;

//===----------------------------------------------------------------------===//
// Dataflow Schedule Operation
//===----------------------------------------------------------------------===//

def ScheduleOp : HLSOp<"dataflow.schedule", [AffineScope,
      AutomaticAllocationScope, SingleBlockImplicitTerminator<"ReturnOp">]> {
  let summary = "Represent a schedule of dataflow";
  let description = [{
    This operation represents a dataflow schedule that has a region to contain
    the dataflow tasks or nodes to be scheduled.
  }];

  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "attr-dict-with-keyword (`:` type($results)^ )? $body";

  let hasCanonicalizer = 1;
  let extraClassDeclaration = [{
    /// Get the terminator return op.
    ReturnOp getReturnOp();
  }];
}

def ReturnOp : HLSOp<"dataflow.return", [NoSideEffect, ReturnLike, Terminator,
      HasParent<"ScheduleOp">]> {
  let summary = "Terminate and return results of a schedule";

  let arguments = (ins Variadic<AnyType>:$results);
  let assemblyFormat = "$results attr-dict `:` type($results)";

  let builders = [ OpBuilder<(ins), "build($_builder, $_state, llvm::None);"> ];
  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// High Dataflow Operations
//===----------------------------------------------------------------------===//

def TaskOp : HLSOp<"dataflow.task", [IsolatedFromAbove, AffineScope,
      AutomaticAllocationScope, SingleBlockImplicitTerminator<"YieldOp">,
      HasParent<"ScheduleOp">]> {
  let summary = "Represent a high-level task";
  let description = [{
    This operation represents a task that has an isolated region to contain the
    operations to be executed in the task.
  }];

  let arguments = (ins Variadic<AnyType>:$inputs);
  let results = (outs Variadic<AnyType>:$outputs);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = [{
    `(` $inputs `)` attr-dict `:` functional-type($inputs, $outputs) $body
  }];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// Get the parent schedule op.
    ScheduleOp getScheduleOp();

    /// Get the terminator yield op.
    YieldOp getYieldOp();
  }];
}

def YieldOp : HLSOp<"dataflow.yield", [NoSideEffect, ReturnLike, Terminator,
      HasParent<"TaskOp">]> {
  let summary = "Terminate and yield results of a task";

  let arguments = (ins Variadic<AnyType>:$outputs);
  let assemblyFormat = "$outputs attr-dict `:` type($outputs)";

  let builders = [ OpBuilder<(ins), "build($_builder, $_state, llvm::None);"> ];
  let hasVerifier = 1;
}

def ToStreamOp : HLSOp<"dataflow.to_stream", [NoSideEffect]> {
  let summary = "Convert a scalar value to a stream channel";

  let arguments = (ins AnyType:$value);
  let results = (outs AnyStream:$stream);
  let assemblyFormat = "$value attr-dict `:` functional-type($value, $stream)";

  let hasVerifier = 1;
  let hasFolder = 1;
}

def ToValueOp : HLSOp<"dataflow.to_value", [NoSideEffect]> {
  let summary = "Convert a stream to a scalar value";

  let arguments = (ins AnyStream:$stream);
  let results = (outs AnyType:$value);
  let assemblyFormat = "$stream attr-dict `:` functional-type($stream, $value)";

  let hasVerifier = 1;
  let hasFolder = 1;
}

//===----------------------------------------------------------------------===//
// Low Dataflow Operations
//===----------------------------------------------------------------------===//

def NodeOp : HLSOp<"dataflow.node", [IsolatedFromAbove, AffineScope,
      AutomaticAllocationScope, NoTerminator, SingleBlock,
      AttrSizedOperandSegments, HasParent<"ScheduleOp">]> {
  let summary = "Represent a dataflow node";
  let description = [{
    This operation represents a node of dataflow that has an isolated region to
    represent the operations contained by the node. The node can only take
    buffers or streams as inputs and outputs. Additionally, scalar values can be
    passed into a node as parameters, which will not be considered in the
    dataflow.
  }];

  let arguments = (ins Variadic<AnyMemrefOrStream>:$inputs,
                       Variadic<AnyMemrefOrStream>:$outputs,
                       Variadic<AnyType>:$params,
                       OptionalAttr<I32Attr>:$level);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = [{
    `(` $inputs `)` `->` `(` $outputs `)` ( `[` $params^ `]` )? attr-dict `:`
    functional-type($inputs, $outputs) ( ` ` `[` type($params)^ `]` )? $body
  }];

  let builders = [
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
                   "mlir::ValueRange":$params),
        "build($_builder, $_state, inputs, outputs, params, nullptr);">,
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs),
        "build($_builder, $_state, inputs, outputs, ValueRange());">
  ];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// Get the parent schedule op.
    ScheduleOp getScheduleOp();

    /// Return the number of inputs and outputs.
    unsigned getNumInputs();
    unsigned getNumOutputs();

    /// Check whether the operand is an output memref.
    bool isOutput(OpOperand &operand);
    bool isOutput(unsigned operandIdx);

    /// Get the input and output arguments.
    iterator_range<Block::args_iterator> getInputArguments();
    iterator_range<Block::args_iterator> getOutputArguments();
  }];
}

def BufferOp : HLSOp<"dataflow.buffer"> {
  let summary = "Represent a dataflow buffer";

  let arguments = (ins I32Attr:$depth);
  let results = (outs AnyMemRef:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let extraClassDeclaration = [{
    /// Get consumers or producers of the dataflow buffer.
    SmallVector<NodeOp, 4> getConsumersExcept(NodeOp exceptedOp);
    SmallVector<NodeOp, 4> getProducersExcept(NodeOp exceptedOp);
    SmallVector<NodeOp, 4> getConsumers();
    SmallVector<NodeOp, 4> getProducers();
  }];
}

def ConstBufferOp : HLSOp<"dataflow.const_buffer"> {
  let summary = "Represent a cosntant dataflow buffer";

  let arguments = (ins ElementsAttr:$value);
  let results = (outs AnyMemRef:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let hasVerifier = 1;
  let extraClassDeclaration = [{
    /// Get the terminator yield op.
    Attribute getValue() { return value(); }
  }];
}

def StreamOp : HLSOp<"dataflow.stream"> {
  let summary = "Declare a stream channel";

  let arguments = (ins I32Attr:$depth);
  let results = (outs StreamOf<[AnyType]>:$channel);
  let assemblyFormat = "attr-dict `:` type($channel)";

  let hasVerifier = 1;
}

def StreamReadOp : HLSOp<"dataflow.stream_read"> {
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

def StreamWriteOp : HLSOp<"dataflow.stream_write"> {
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

  let arguments = (ins AnyTypeOf<[I8, VectorOfLengthAndType<[2], [I8]>]>:$A,
                       AnyTypeOf<[I8, VectorOfLengthAndType<[2], [I8]>]>:$B);
  let results = (outs AnyTypeOf<[I16, VectorOfLengthAndType<[2], [I16]>]>:$C);

  let hasVerifier = 1;
  let extraClassDeclaration = [{
    /// Check whether is a packed multiplication.
    bool isPackMul();
  }];
}

def PrimCastOp : HLSOp<"prim.cast",
    [SameOperandsAndResultShape, NoSideEffect]> {
  let summary = "Cast primitive operation";

  let arguments = (ins 
    AnyTypeOf<[I8, I16, I32,
               VectorOfLengthAndType<[2], [I8, I16, I32]>]>:$input
  );
  let results = (outs
    AnyTypeOf<[I8, I16, I32,
               VectorOfLengthAndType<[2], [I8, I16, I32]>]>:$output
  );

  let hasCanonicalizer = 1;
}

#endif // SCALEHLS_DIALECT_HLS_OPS_TD
