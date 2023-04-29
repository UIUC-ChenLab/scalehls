//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSOPS_TD
#define SCALEHLS_DIALECT_HLS_HLSOPS_TD

include "scalehls/Dialect/HLS/IR/HLSInterfaces.td"
include "scalehls/Dialect/HLS/IR/HLSTypes.td"
include "mlir/Interfaces/ControlFlowInterfaces.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/ViewLikeInterface.td"
include "mlir/IR/BuiltinAttributeInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"

class HLSOp<string mnemonic, list<Trait> traits = []> :
    Op<HLSDialect, mnemonic, traits>;

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

def AnyBuffer : StaticShapeMemRefOf<[AnyType]>;
def AnyStream : StreamOf<[AnyType]>;
def AnyBufferOrStream : Type<Or<[AnyBuffer.predicate, AnyStream.predicate]>,
    "memref or stream values">;
def AnyAxi : AxiOf<[AnyType]>;

//===----------------------------------------------------------------------===//
// Functional Dataflow (FDF) Operations
//===----------------------------------------------------------------------===//

def DispatchOp : HLSOp<"fdf.dispatch", [RecursiveMemoryEffects,
      SingleBlockImplicitTerminator<"YieldOp">,
      ParentOneOf<["func::FuncOp", "affine::AffineForOp"]>]> {
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

def TaskOp : HLSOp<"fdf.task", [
      DeclareOpInterfaceMethods<StageLikeInterface>, RecursiveMemoryEffects,
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

    bool hasHierarchy() {
      return cast<StageLikeInterface>(this->getOperation()).hasHierarchy();
    }
  }];
}

def YieldOp : HLSOp<"fdf.yield", [NoMemoryEffect, ReturnLike, Terminator,
      ParentOneOf<["DispatchOp", "TaskOp"]>]> {
  let summary = "Terminate and yield results of a dispatch or task op";

  let arguments = (ins Variadic<AnyType>:$results);
  let assemblyFormat = "$results attr-dict `:` type($results)";

  let builders = [OpBuilder<(ins), "build($_builder, $_state, std::nullopt);">];
}

//===----------------------------------------------------------------------===//
// Structural Dataflow (SDF) Operations
//===----------------------------------------------------------------------===//

def ScheduleOp : HLSOp<"sdf.schedule", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>, IsolatedFromAbove,
      AffineScope, SingleBlock, NoTerminator,
      ParentOneOf<["func::FuncOp", "affine::AffineForOp"]>]> {
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

  let extraClassDeclaration = [{
    /// FIXME: Check whether the schedule is dependence free.
    bool isDependenceFree();

    /// Update the signature of the schedule op recursively.
    void updateSignatureRecursively();
  }];
}

def NodeOp : HLSOp<"sdf.node", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
      DeclareOpInterfaceMethods<StageLikeInterface>, IsolatedFromAbove,
      AffineScope, SingleBlock, NoTerminator, AttrSizedOperandSegments,
      HasParent<"ScheduleOp">]> {
  let summary = "Represent a dataflow node";
  let description = [{
    Node op has an isolated region to represent the ops contained by the node.
    The node can only take buffers or streams as inputs and outputs. Meanwhile,
    scalar values can be passed into a node as parameters, which will not be
    considered in the dataflow. An attribute "inputTaps" is used to represent
    the level of buffer or stream channel tap of each input.
  }];

  let arguments = (ins Variadic<AnyBufferOrStream>:$inputs,
      Variadic<AnyBufferOrStream>:$outputs, Variadic<AnyType>:$params,
      I32ArrayAttr:$inputTaps, OptionalAttr<I32Attr>:$level);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = [{
    `(` $inputs `)` `->` `(` $outputs `)` ( `[` $params^ `]` )? attr-dict `:`
    functional-type($inputs, $outputs) ( `[` type($params)^ `]` )? $body
  }];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;
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

    bool hasHierarchy() {
      return cast<StageLikeInterface>(this->getOperation()).hasHierarchy();
    }

    /// Update the signature of the node op recursively.
    void updateSignatureRecursively();
  }];
}

def BufferOp : HLSOp<"sdf.buffer", [
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

def ConstBufferOp : HLSOp<"sdf.const_buffer", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
      DeclareOpInterfaceMethods<BufferLikeInterface>]> {
  let summary = "Represent a constant dataflow buffer";

  let arguments = (ins ElementsAttr:$value);
  let results = (outs AnyBuffer:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let hasVerifier = 1;
}

def StreamOp : HLSOp<"sdf.stream", [
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

def StreamReadOp : HLSOp<"sdf.stream_read", []> {
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

def StreamWriteOp : HLSOp<"sdf.stream_write", []> {
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

def AxiBundleOp : HLSOp<"axi.bundle", [NoMemoryEffect,
    HasParent<"func::FuncOp">]> {
  let summary = "Represent an bundle of axi ports";

  let arguments = (ins StrAttr:$name);
  let results = (outs BundleType:$bundle);
  let assemblyFormat = "$name attr-dict `:` type($bundle)";
}

def AxiPortOp : HLSOp<"axi.port", [NoMemoryEffect, HasParent<"func::FuncOp">]> {
  let summary = "Represent an axi port";

  let arguments = (ins BundleType:$bundle, AnyAxi:$axi);
  let results = (outs AnyType:$element);
  let assemblyFormat = [{
    $bundle `,` $axi attr-dict `:` type($bundle) `,`
    functional-type($axi, $element)
  }];

  let hasVerifier = 1;
  let extraClassDeclaration = [{
    AxiType getAxiType() {
      return getAxi().getType().cast<AxiType>();
    }
    BundleType getBundleType() {
      return getBundle().getType().cast<BundleType>();
    }
    StringRef getBundleName() {
      return getBundle().getDefiningOp<AxiBundleOp>().getName();
    }
  }];
}

def AxiPackOp : HLSOp<"axi.pack", [NoMemoryEffect, HasParent<"func::FuncOp">]> {
  let summary = "Pack a memref or scalar into an axi type";

  let arguments = (ins AnyType:$element);
  let results = (outs AnyAxi:$axi);
  let assemblyFormat = "$element attr-dict `:` functional-type($element, $axi)";

  let hasVerifier = 1;
  let extraClassDeclaration = [{
    AxiType getAxiType() {
      return getAxi().getType().cast<AxiType>();
    }
  }];
}

//===----------------------------------------------------------------------===//
// Primitive Operations
//===----------------------------------------------------------------------===//

def PrimMulOp : HLSOp<"prim.mul", [NoMemoryEffect]> {
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

def PrimCastOp : HLSOp<"prim.cast", [
      NoMemoryEffect, SameOperandsAndResultShape]> {
  let summary = "Cast primitive operation";
  let description = [{
    This operation is super exterimental and should be substituted by the new
    type casting operations in arith dialect.
  }];

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

def AffineSelectOp : HLSOp<"affine.select", [NoMemoryEffect]> {
  let summary = "if-then-else operation";

  let arguments = (ins Variadic<AnyType>:$args, AnyType:$true_value,
                       AnyType:$false_value);
  let results = (outs AnyType:$result);

  let skipDefaultBuilders = 1;
  let builders = [
    OpBuilder<(ins "IntegerSet":$set, "ValueRange":$args, "Value":$trueValue,
                   "Value":$falseValue)>
  ];

  let hasCanonicalizer = 1;
  let hasCustomAssemblyFormat = 1;
  let hasFolder = 1;
  let hasVerifier = 1;
  let extraClassDeclaration = [{
    static StringRef getConditionAttrStrName() { return "condition"; }

    IntegerSet getIntegerSet();
    void setIntegerSet(IntegerSet newSet);

    /// Sets the integer set with its operands.
    void setConditional(IntegerSet set, ValueRange operands);
  }];
}

def VectorInitOp : HLSOp<"vector.init", [NoMemoryEffect]> {
  let summary = "Initialize a vector";

  let results = (outs AnyVector:$output);
  let assemblyFormat = "attr-dict `:` type($output)";
}

def TileParameter : HLSOp<"tile_parameter", [NoMemoryEffect]> {
  let summary = "Return a tile parameter";

  let results = (outs I64:$param);
}

#endif // SCALEHLS_DIALECT_HLS_HLSOPS_TD
