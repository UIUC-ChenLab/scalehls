//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_OPS_TD
#define SCALEHLS_DIALECT_HLSCPP_OPS_TD

include "mlir/Interfaces/SideEffectInterfaces.td"

//===----------------------------------------------------------------------===//
// Stream Operations
//===----------------------------------------------------------------------===//

def DeclaresStreamChannel : NativeOpTrait<"DeclaresStreamChannel">;

class StreamOf<list<Type> allowedTypes> :
    Type<And<[CPred<"$_self.isa<::mlir::scalehls::hlscpp::StreamType>()">,
              Concat<"[](::mlir::Type elementType) { return ",
                     SubstLeaves<"$_self", "elementType",
                                 AnyTypeOf<allowedTypes>.predicate>,
                     "; }($_self.cast<::mlir::scalehls::hlscpp::StreamType>()"
                         ".getElementType())">]>>;

def StreamChannelOp : HLSCppOp<"stream.channel", [DeclaresStreamChannel]> {
  let summary = "Stream channel declaration operation";

  let results = (outs StreamOf<[AnyType]>:$channel);
  let verifier = "return ::verify(*this);";
}

def StreamReadOp : HLSCppOp<"stream.read"> {
  let summary = "Stream channel read operation";
  let description = [{
    Read/pop a value from a stream channel. The absence of the result indicates
    the popped value is dropped. Each stream channel can be read multiple times.
  }];

  let arguments = (ins StreamOf<[AnyType]>:$channel);
  let results = (outs Optional<AnyType>:$result);
  let verifier = "return ::verify(*this);";
}

def StreamWriteOp : HLSCppOp<"stream.write"> {
  let summary = "Stream channel write operation";
  let description = [{
    Write/push a value to a stream channel. Each stream channel can only be
    written once.
  }];

  let arguments = (ins StreamOf<[AnyType]>:$channel, AnyType:$value);
  let verifier = "return ::verify(*this);";
}

def StreamBufferOp : HLSCppOp<"stream.buffer", [DeclaresStreamChannel]> {
  let summary = "Stream channel buffer operation";

  let arguments = (ins StreamOf<[AnyType]>:$input);
  let results = (outs StreamOf<[AnyType]>:$output);
  let verifier = "return ::verify(*this);";
}

def StreamNodeOp : HLSCppOp<"stream.node",
      [SingleBlockImplicitTerminator<"StreamOutputOp">]> {
  let summary = "Stream node operation";
  let description = [{
    This operation represents a node of a streaming dataflow. It has a region,
    which is not isolated from above, to represent the operations contained by
    the node. The node can return variadic number of stream channels as results.
  }];

  let results = (outs Variadic<AnyType>:$outputs);
  let regions = (region SizedRegion<1>:$body);
}

def StreamOutputOp : HLSCppOp<"stream.output",
      [Terminator, HasParent<"StreamNodeOp">]> {
  let summary = "Output operation of a stream node";
  let description = [{
    The operation terminates a stream node region and outputs internal stream
    channels to the outside.
  }];

  let arguments = (ins Variadic<AnyType>:$outputs);
  let verifier = "return ::verify(*this);";
}

//===----------------------------------------------------------------------===//
// Primitive Operations
//===----------------------------------------------------------------------===//

def PrimMulOp : HLSCppOp<"prim.mul", [NoSideEffect]> {
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

  let verifier = "return ::verify(*this);";
  let extraClassDeclaration = [{ bool isPackMul(); }];
}

def PrimCastOp : HLSCppOp<"prim.cast",
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

def BufferOp : HLSCppOp<"buffer",
    [SameOperandsAndResultElementType, NoSideEffect]> {
  let summary = "Buffer the input value";

  let hasCanonicalizer = 1;
  let arguments = (ins AnyType:$input);
  let results = (outs AnyType:$output);
}

#endif // SCALEHLS_DIALECT_HLSCPP_OPS_TD
