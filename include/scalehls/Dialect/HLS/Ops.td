//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_OPS_TD
#define SCALEHLS_DIALECT_HLS_OPS_TD

include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/ControlFlowInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"
include "scalehls/Dialect/HLS/Interfaces.td"

//===----------------------------------------------------------------------===//
// Traits and Type Constraints
//===----------------------------------------------------------------------===//

def DataflowBufferLike : NativeOpTrait<"DataflowBufferLike">;

class StreamOf<list<Type> allowedTypes> : Type<And<[
    CPred<"$_self.isa<mlir::scalehls::hls::StreamType>()">,
    Concat<"[](mlir::Type elementType) { return ",
      SubstLeaves<"$_self", "elementType", AnyTypeOf<allowedTypes>.predicate>,
      "; }($_self.cast<mlir::scalehls::hls::StreamType>().getElementType())">
  ]>,
  "stream of " # AnyTypeOf<allowedTypes>.summary # " values",
  "mlir::scalehls::hls::StreamType"
>;

class AxiOf<list<Type> allowedTypes> : Type<And<[
    CPred<"$_self.isa<mlir::scalehls::hls::AxiType>()">,
    Concat<"[](mlir::Type elementType) { return ",
      SubstLeaves<"$_self", "elementType", AnyTypeOf<allowedTypes>.predicate>,
      "; }($_self.cast<mlir::scalehls::hls::AxiType>().getElementType())">
  ]>,
  "axi of " # AnyTypeOf<allowedTypes>.summary # " values",
  "mlir::scalehls::hls::AxiType"
>;

def AnyStream : StreamOf<[AnyType]>;
def AnyMemrefOrStream : Type<Or<[AnyMemRef.predicate, AnyStream.predicate]>,
    "memref or stream values">;
def AnyAxi : AxiOf<[AnyType]>;

//===----------------------------------------------------------------------===//
// High Dataflow Operations
//===----------------------------------------------------------------------===//

def DispatchOp : HLSOp<"dataflow.dispatch", [AffineScope,
      AutomaticAllocationScope, SingleBlockImplicitTerminator<"YieldOp">,
      ParentOneOf<["func::FuncOp", "AffineForOp"]>]> {
  let summary = "Represent a dataflow dispatch";
  let description = [{
    Dispatch op has a transparent region that contains a list of task ops to be
    dispatched. This op is designed to organize and manipulate task ops at a
    high level and will be lowered to schedule op for dataflow scheduling.
  }];

  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "attr-dict-with-keyword ( `:` type($results)^ )? $body";

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// Get the terminator yield op.
    YieldOp getYieldOp();
  }];
}

def TaskOp : HLSOp<"dataflow.task", [AffineScope, AutomaticAllocationScope,
      SingleBlockImplicitTerminator<"YieldOp">, HasParent<"DispatchOp">]> {
  let summary = "Represent a dataflow task";
  let description = [{
    Task op has a transparent region that contains a list of ops to be executed
    in the task. This op is designed to represent the task partition at a high
    level and will be lowered to node op for dataflow scheduling.
  }];

  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "attr-dict-with-keyword ( `:` type($results)^ )? $body";

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// Get the parent dispatch op.
    DispatchOp getDispatchOp();

    /// Get the terminator yield op.
    YieldOp getYieldOp();
  }];
}

def YieldOp : HLSOp<"dataflow.yield", [NoSideEffect, ReturnLike, Terminator,
      ParentOneOf<["DispatchOp", "TaskOp"]>]> {
  let summary = "Terminate and yield results of a dispatch or task op";

  let arguments = (ins Variadic<AnyType>:$results);
  let assemblyFormat = "$results attr-dict `:` type($results)";

  let builders = [OpBuilder<(ins), "build($_builder, $_state, llvm::None);">];
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

def ScheduleOp : HLSOp<"dataflow.schedule", [IsolatedFromAbove, AffineScope,
      AutomaticAllocationScope, SingleBlock, NoTerminator,
      ParentOneOf<["func::FuncOp", "AffineForOp"]>]> {
  let summary = "Represent a dataflow schedule";
  let description = [{
    Schedule op has an isolated region to contain a list of dataflow node ops to
    be scheduled. This op can be explicitly marked as legal when all the
    dataflow violations have been resolved and all the nodes has been scheduled.
  }];

  let arguments = (ins Variadic<AnyType>:$operands, UnitAttr:$isLegal);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = [{
    ( `legal` $isLegal^ )? ( `(` $operands^ `)` )? attr-dict-with-keyword
    ( `:` type($operands)^ )? $body
  }];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;
  let builders = [
    OpBuilder<(ins "mlir::ValueRange":$operands),
        "build($_builder, $_state, operands, false);">
  ];
}

def NodeOp : HLSOp<"dataflow.node", [IsolatedFromAbove, AffineScope,
      AutomaticAllocationScope, SingleBlock, NoTerminator,
      AttrSizedOperandSegments, HasParent<"ScheduleOp">]> {
  let summary = "Represent a dataflow node";
  let description = [{
    Node op has an isolated region to represent the ops contained by the node.
    The node can only take buffers or streams as inputs and outputs. Meanwhile,
    scalar values can be passed into a node as parameters, which will not be
    considered in the dataflow. An attribute "inputTaps" is used to represent
    the level of buffer or stream channel tap of each input.
  }];

  let arguments = (ins Variadic<AnyMemrefOrStream>:$inputs,
      Variadic<AnyMemrefOrStream>:$outputs, Variadic<AnyType>:$params,
      I32ArrayAttr:$inputTaps, OptionalAttr<I32Attr>:$level);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = [{
    `(` $inputs `)` `->` `(` $outputs `)` ( `[` $params^ `]` )? attr-dict `:`
    functional-type($inputs, $outputs) ( `[` type($params)^ `]` )? $body
  }];

  let builders = [
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
        "mlir::ValueRange":$params, "ArrayRef<unsigned>":$inputTaps,
        "mlir::IntegerAttr":$level), [{
          auto newInputTaps = SmallVector<int32_t>(
            llvm::map_range(inputTaps, [](unsigned a) { return (int32_t)a; }));
          build($_builder, $_state, inputs, outputs, params,
                $_builder.getI32ArrayAttr(newInputTaps), level);
        }]>,

    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
        "mlir::ValueRange":$params, "ArrayRef<unsigned>":$inputTaps), [{
          build($_builder, $_state, inputs, outputs, params, inputTaps, nullptr);
        }]>,
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
        "ArrayRef<unsigned>":$inputTaps), [{
          build($_builder, $_state, inputs, outputs, ValueRange(), inputTaps);
        }]>,

    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs,
        "mlir::ValueRange":$params), [{
          build($_builder, $_state, inputs, outputs, params,
                SmallVector<unsigned>(inputs.size(), 0));
        }]>,
    OpBuilder<(ins "mlir::ValueRange":$inputs, "mlir::ValueRange":$outputs),
        "build($_builder, $_state, inputs, outputs, ValueRange());">
  ];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// Get the parent schedule op.
    ScheduleOp getScheduleOp();

    /// Get input taps.
    void setInputTap(unsigned idx, unsigned tap);
    unsigned getInputTap(unsigned idx);
    SmallVector<unsigned> getInputTapsAsInt();

    /// Get the number of inputs, outputs, and params.
    unsigned getNumInputs();
    unsigned getNumOutputs();
    unsigned getNumParams();

    /// Get the type of operand: input, output, or param.
    OperandKind getOperandKind(OpOperand &operand);
    OperandKind getOperandKind(unsigned operandIdx);

    /// Get the input, output, and param arguments.
    iterator_range<Block::args_iterator> getInputArgs();
    iterator_range<Block::args_iterator> getOutputArgs();
    iterator_range<Block::args_iterator> getParamArgs();
  }];
}

def BufferOp : HLSOp<"dataflow.buffer", [
      DeclareOpInterfaceMethods<BufferLikeInterface>]> {
  let summary = "Represent a dataflow buffer";

  let arguments = (ins I32Attr:$depth);
  let results = (outs AnyMemRef:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let builders = [
    OpBuilder<(ins "mlir::Type":$memref),
        "build($_builder, $_state, memref, 1);">
  ];
}

def ConstBufferOp : HLSOp<"dataflow.const_buffer", [
      DeclareOpInterfaceMethods<BufferLikeInterface>]> {
  let summary = "Represent a constant dataflow buffer";

  let arguments = (ins ElementsAttr:$value);
  let results = (outs AnyMemRef:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let hasVerifier = 1;
}

def StreamOp : HLSOp<"dataflow.stream"> {
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
// AXI-related Operations
//===----------------------------------------------------------------------===//

def AxiBundleOp : HLSOp<"axi.bundle", [NoSideEffect,
    HasParent<"func::FuncOp">]> {
  let summary = "Represent an bundle of axi ports";

  let arguments = (ins StrAttr:$name);
  let results = (outs BundleType:$bundle);
  let assemblyFormat = "$name attr-dict `:` type($bundle)";
}

def AxiPortOp : HLSOp<"axi.port", [NoSideEffect, HasParent<"func::FuncOp">]> {
  let summary = "Represent an axi port";

  let arguments = (ins BundleType:$bundle, AnyAxi:$axi);
  let results = (outs AnyType:$value);
  let assemblyFormat = [{
    $bundle `,` $axi attr-dict `:` type($bundle) `,`
    functional-type($axi, $value)
  }];

  let hasVerifier = 1;
}

def AxiPackOp : HLSOp<"axi.pack", [NoSideEffect, HasParent<"func::FuncOp">]> {
  let summary = "Pack a memref or scalar into an axi type";

  let arguments = (ins AnyType:$value);
  let results = (outs AnyAxi:$axi);
  let assemblyFormat = "$value attr-dict `:` functional-type($value, $axi)";

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
