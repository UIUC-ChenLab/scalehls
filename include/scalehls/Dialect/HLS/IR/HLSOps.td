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
// StreamtType Predicates
//===----------------------------------------------------------------------===//

class StreamOf<list<Type> allowedTypes,
               string cppClassName = "::mlir::scalehls::hls::StreamType">
  : Type<
      And<[
        CPred<"::llvm::isa<" # cppClassName # ">($_self)">,
        Concat<
          "[](::mlir::Type elementType) { return ",
          SubstLeaves<"$_self", "elementType",
          AnyTypeOf<allowedTypes>.predicate>,
          "; }(::llvm::cast<" # cppClassName # ">($_self).getElementType())"
        >
      ]>,
      "stream of " # AnyTypeOf<allowedTypes>.summary # " values",
      cppClassName
    >;

def AnyBuffer : StaticShapeMemRefOf<[AnyType]>;
def AnyStream : StreamOf<[AnyType]>;
def AnyBufferOrStream : Type<Or<[AnyBuffer.predicate, AnyStream.predicate]>,
    "memref or stream values">;

//===----------------------------------------------------------------------===//
// Functional Dataflow (FDF) Operations
//===----------------------------------------------------------------------===//

def DispatchOp : HLSOp<"dispatch", [RecursiveMemoryEffects,
      SingleBlockImplicitTerminator<"YieldOp">,
      ParentOneOf<["func::FuncOp", "affine::AffineForOp", "scf::ForOp"]>]> {
  let summary = "Represent a dataflow dispatch";
  let description = [{
    Dispatch op has a transparent region that contains a list of task ops to be
    dispatched. This op is designed to organize and manipulate task ops at a
    high level and will be lowered to schedule op for dataflow scheduling.
  }];

  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "attr-dict-with-keyword (`:` type($results)^)? $body";

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    YieldOp getYieldOp();
  }];
}

def TaskOp : HLSOp<"task", [DeclareOpInterfaceMethods<ContainerLikeInterface>,
      RecursiveMemoryEffects, SingleBlockImplicitTerminator<"YieldOp">,
      HasParent<"DispatchOp">]> {
  let summary = "Represent a dataflow task";
  let description = [{
    Task op has a transparent region that contains a list of ops to be executed
    in the task. This op is designed to represent the task partition at a high
    level and will be lowered to node op for dataflow scheduling.
  }];

  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = [{
    attr-dict-with-keyword (`:` type($results)^)? $body
  }];

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// Return true if this task op contains nested sub-tasks.
    bool hasHierarchy() {
      return cast<ContainerLikeInterface>(this->getOperation()).hasHierarchy();
    }

    /// Get the immediate included linalg op. Will return nullptr if there is no
    /// such linalg op or more than one linalg op.
    linalg::LinalgOp getPayloadLinalgOp();

    DispatchOp getDispatchOp();
    YieldOp getYieldOp();
  }];
}

def YieldOp : HLSOp<"yield", [NoMemoryEffect, ReturnLike, Terminator,
      ParentOneOf<["DispatchOp", "TaskOp"]>]> {
  let summary = "Terminate and yield results of a dispatch or task op";

  let arguments = (ins Variadic<AnyType>:$results);
  let assemblyFormat = "$results attr-dict `:` type($results)";

  let builders = [OpBuilder<(ins), "build($_builder, $_state, std::nullopt);">];
}

//===----------------------------------------------------------------------===//
// Stream Operations
//===----------------------------------------------------------------------===//

def TensorInitOp : HLSOp<"tensor_init", [Pure]> {
  let summary = "Initiate a tensor with an optional initialization value";

  let arguments = (ins Optional<AnyType>:$init_value);
  let results = (outs AnyRankedTensor:$result);
  let assemblyFormat = [{
    ($init_value^)? attr-dict `:` `(` type($init_value) `)` `->` type($result)
  }];

  let hasVerifier = 1;
  let builders = [
    OpBuilder<(ins "mlir::Type":$result),
        "build($_builder, $_state, result, nullptr);">
  ];
}

def TensorToStreamOp : HLSOp<"tensor_to_stream",[Pure]> {
  let summary = "Convert a tensor to a stream channel";

  let arguments = (ins AnyRankedTensor:$tensor);
  let results = (outs AnyStream:$stream);
  let assemblyFormat = [{
    $tensor attr-dict `:` functional-type($tensor, $stream)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;
}

def StreamToTensorOp : HLSOp<"stream_to_tensor", [Pure]> {
  let summary = "Convert a stream channel to a tensor";

  let arguments = (ins AnyStream:$stream);
  let results = (outs AnyRankedTensor:$tensor);
  let assemblyFormat = [{
    $stream attr-dict `:` functional-type($stream, $tensor)
  }];

  let hasVerifier = 1;
}

def StreamOp : HLSOp<"stream", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Declare a stream channel";

  let results = (outs AnyStream:$channel);
  let assemblyFormat = "attr-dict `:` type($channel)";

  let hasVerifier = 1;
}

def StreamReadOp : HLSOp<"stream_read", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Read a stream channel";
  let description = [{
    Read/pop a value from a stream channel. The absence of the result indicates
    the popped value is dropped. Each stream channel can be read multiple times.
  }];

  let arguments = (ins AnyStream:$channel);
  let results = (outs Optional<AnyType>:$result);
  let assemblyFormat = [{
    $channel attr-dict `:` functional-type($channel, $result)
  }];

  let hasVerifier = 1;
}

def StreamWriteOp : HLSOp<"stream_write", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Write a stream channel";
  let description = [{
    Write/push a value to a stream channel. Each stream channel can only be
    written once.
  }];

  let arguments = (ins AnyStream:$channel, AnyType:$value);
  let assemblyFormat = [{
    $value `to` $channel attr-dict `:` functional-type($value, $channel)
  }];

  let hasVerifier = 1;
}

class StreamReassociativeOp<string mnemonic, list<Trait> traits = []> :
    HLSOp<mnemonic, !listconcat(traits, [Pure,
      DeclareOpInterfaceMethods<StreamViewLikeInterface>])>,
    Arguments<(ins AnyStream:$input, IndexListArrayAttr:$reassociation)>,
    Results<(outs AnyStream:$output)> {

  code commonExtraClassDeclaration = [{
    SmallVector<ReassociationIndices, 4> getReassociationIndices() {
      SmallVector<ReassociationIndices, 4> reassociationIndices;
      for (auto attr : getReassociation())
        reassociationIndices.push_back(llvm::to_vector<2>(
            llvm::map_range(::llvm::cast<ArrayAttr>(attr), [&](Attribute indexAttr) {
              return ::llvm::cast<IntegerAttr>(indexAttr).getInt();
            })));
      return reassociationIndices;
    }

    StreamType getInputType() { return getInput().getType(); }
    StreamType getOutputType() { return getOutput().getType(); }
  }];

  let assemblyFormat = [{
    $input $reassociation attr-dict `:` functional-type($input, $output)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;
}

def StreamSplitIterationOp : StreamReassociativeOp<"stream_split_iteration"> {
  let summary = "Split the iteration space of a stream channel";
  let extraClassDeclaration = commonExtraClassDeclaration;
}

def StreamMergeIterationOp : StreamReassociativeOp<"stream_merge_iteration"> {
  let summary = "Merge the iteration space of a stream channel";
  let extraClassDeclaration = commonExtraClassDeclaration;
}

def StreamExpandShapeOp : StreamReassociativeOp<"stream_expand_shape"> {
  let summary = "Expand the shape of the stream element";
  let extraClassDeclaration = commonExtraClassDeclaration;
}

def StreamCollapseShapeOp : StreamReassociativeOp<"stream_collapse_shape"> {
  let summary = "Collapse the shape of the stream element";
  let extraClassDeclaration = commonExtraClassDeclaration;
}

def StreamBufferOp : HLSOp<"stream_buffer", [Pure,
      DeclareOpInterfaceMethods<StreamViewLikeInterface>]> {
  let summary = "Buffer a stream channel at a specific position";

  let arguments = (ins AnyStream:$input, TypeAttr:$bufferElementType,
      DenseI64ArrayAttr:$bufferShape, I64Attr:$loopIndex, I64Attr:$dimIndex);
  let results = (outs AnyStream:$output);
  let assemblyFormat = [{
    $input `,` $bufferElementType $bufferShape `before` `loop` $loopIndex `dim`
    $dimIndex attr-dict `:` functional-type($input, $output)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
    StreamType getInputType() { return getInput().getType(); }
    StreamType getOutputType() { return getOutput().getType(); }
  }];
}

def StreamCastOp : HLSOp<"stream_cast", [Pure,
      DeclareOpInterfaceMethods<StreamViewLikeInterface>]> {
  let summary = "Cast a stream channel to a different type";

  let arguments = (ins AnyStream:$input);
  let results = (outs AnyStream:$output);
  let assemblyFormat = [{
    $input attr-dict `:` functional-type($input, $output)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
    StreamType getInputType() { return getInput().getType(); }
    StreamType getOutputType() { return getOutput().getType(); }
  }];
}

//===----------------------------------------------------------------------===//
// Structural Dataflow (SDF) Operations
//===----------------------------------------------------------------------===//

def ScheduleOp : HLSOp<"schedule", [
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>, IsolatedFromAbove,
      AffineScope, SingleBlock, NoTerminator,
      ParentOneOf<["func::FuncOp", "affine::AffineForOp", "scf::ForOp"]>]> {
  let summary = "Represent a dataflow schedule";
  let description = [{
    Schedule op has an isolated region to contain a list of dataflow node ops to
    be scheduled. This op can be explicitly marked as legal when all the
    dataflow violations have been resolved and all the nodes has been scheduled.
  }];

  let arguments = (ins Variadic<AnyType>:$operands, UnitAttr:$isLegal);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = [{
    (`legal` $isLegal^)? (`(` $operands^ `)`)? attr-dict-with-keyword
    (`:` type($operands)^)? $body
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

def NodeOp : HLSOp<"node", [DeclareOpInterfaceMethods<MemoryEffectsOpInterface>,
      DeclareOpInterfaceMethods<ContainerLikeInterface>, IsolatedFromAbove,
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
    `(` $inputs `)` `->` `(` $outputs `)` (`[` $params^ `]`)? attr-dict `:`
    functional-type($inputs, $outputs) (`[` type($params)^ `]`)? $body
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
    /// Get input taps.
    void setInputTap(unsigned idx, unsigned tap);
    unsigned getInputTap(unsigned idx);
    SmallVector<unsigned> getInputTapsAsInt();

    /// Get the number of inputs, outputs, and params.
    unsigned getNumInputs();
    unsigned getNumOutputs();
    unsigned getNumParams();

    /// Get the type of operand: input, output, or param.
    PortKind getPortKind(OpOperand &operand);
    PortKind getPortKind(unsigned operandIdx);

    /// Get the input, output, and param arguments.
    iterator_range<Block::args_iterator> getInputArgs();
    iterator_range<Block::args_iterator> getOutputArgs();
    iterator_range<Block::args_iterator> getParamArgs();

    bool hasHierarchy() {
      return cast<ContainerLikeInterface>(this->getOperation()).hasHierarchy();
    }

    /// Update the signature of the node op recursively.
    void updateSignatureRecursively();

    ScheduleOp getScheduleOp();
  }];
}

def BufferOp : HLSOp<"buffer", [DeclareOpInterfaceMethods<BufferLikeInterface>,
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
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

def ConstBufferOp : HLSOp<"const_buffer", [
      DeclareOpInterfaceMethods<BufferLikeInterface>,
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Represent a constant dataflow buffer";

  let arguments = (ins ElementsAttr:$value);
  let results = (outs AnyBuffer:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let hasVerifier = 1;
}

//===----------------------------------------------------------------------===//
// Affine Extension Operations
//===----------------------------------------------------------------------===//

def AffineSelectOp : HLSOp<"affine.select", [NoMemoryEffect]> {
  let summary = "Affine if-then-else operation";

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

#endif // SCALEHLS_DIALECT_HLS_HLSOPS_TD
