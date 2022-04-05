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
// Dataflow Operations
//===----------------------------------------------------------------------===//

def DataflowNodeOp : HLSOp<"dataflow.node",
      [SingleBlockImplicitTerminator<"DataflowOutputOp">]> {
  let summary = "Dataflow node operation";
  let description = [{
    This operation represents a node of dataflow. It has a region, which is not
    isolated from above, to represent the operations contained by the node. The
    node can return variadic number of results.
  }];

  let results = (outs Variadic<AnyType>:$outputs);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = [{
    attr-dict `(` `)` (`->` qualified(type($outputs))^)? $body
  }];
  let extraClassDeclaration = [{ DataflowOutputOp getOutputOp(); }];
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
  let arguments = (ins AnyType:$input, I32Attr:$depth);
  let results = (outs AnyType:$output);
}

//===----------------------------------------------------------------------===//
// Stream Operations
//===----------------------------------------------------------------------===//

def DeclaresStreamChannel : NativeOpTrait<"DeclaresStreamChannel">;

class StreamOf<list<Type> allowedTypes> : Type<And<[
  CPred<"$_self.isa<::mlir::scalehls::hls::StreamType>()">,
  Concat<"[](::mlir::Type elementType) { return ",
    SubstLeaves<"$_self", "elementType", AnyTypeOf<allowedTypes>.predicate>,
    "; }($_self.cast<::mlir::scalehls::hls::StreamType>().getElementType())">
]>>;

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

//===----------------------------------------------------------------------===//
// Other Operations
//===----------------------------------------------------------------------===//

def IncludeOp : HLSOp<"include", [NoSideEffect]> {
  let summary = "C include library operation";
  let description = [{}];

  let arguments = (ins
    StrArrayAttr:$libraries);
}

def IPOp : HLSOp<"ip", [NoSideEffect]> {
  let summary = "General IP";
  let description = [{}];

  let arguments = (ins
    Variadic<AnyType>:$inputs,
    StrAttr:$path,
    StrAttr:$name
  );
}

#endif // SCALEHLS_DIALECT_HLS_OPS_TD
