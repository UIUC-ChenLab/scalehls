//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSOPS_TD
#define SCALEHLS_DIALECT_HLS_HLSOPS_TD

include "scalehls/Dialect/HLS/IR/HLSTypes.td"
include "mlir/Interfaces/ControlFlowInterfaces.td"
include "mlir/Interfaces/SideEffectInterfaces.td"
include "mlir/Interfaces/ViewLikeInterface.td"
include "mlir/IR/BuiltinAttributeInterfaces.td"
include "mlir/IR/SymbolInterfaces.td"

class HLSOp<string mnemonic, list<Trait> traits = []> :
    Op<HLSDialect, mnemonic, traits>;

//===----------------------------------------------------------------------===//
// Constraints
//===----------------------------------------------------------------------===//

class ContainerTypeOf<list<Type> allowedTypes, string summary,
                      string cppClassName> : Type<
    And<[CPred<"::llvm::isa<" # cppClassName # ">($_self)">, Concat<
      "[](::mlir::Type elementType) { return ",
      SubstLeaves<"$_self", "elementType",
      AnyTypeOf<allowedTypes>.predicate>,
      "; }(::llvm::cast<" # cppClassName # ">($_self).getElementType())"
    >]>,
    summary # " of " # AnyTypeOf<allowedTypes>.summary # " values",
    cppClassName
  >;

class SlidingTensorOf<list<Type> allowedTypes>
  : ContainerTypeOf<allowedTypes, "sliding tensor",
             "::mlir::scalehls::hls::SlidingTensorType">;
def AnySlidingTensor : SlidingTensorOf<[AnyType]>;

class SlidingMemrefOf<list<Type> allowedTypes>
  : ContainerTypeOf<allowedTypes, "sliding memref",
             "::mlir::scalehls::hls::SlidingMemrefType">;
def AnySlidingMemref : SlidingMemrefOf<[AnyType]>;

class StreamOf<list<Type> allowedTypes>
  : ContainerTypeOf<allowedTypes, "stream", "::mlir::scalehls::hls::StreamType">;
def AnyStream : StreamOf<[AnyType]>;

def AnyBuffer : StaticShapeMemRefOf<[AnyType]>;
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
// Sliding Tensor Operations
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

def TensorToSlidingTensorOp : HLSOp<"tensor_to_stensor",[Pure]> {
  let summary = "Convert a tensor to a sliding tensor";

  let arguments = (ins AnyRankedTensor:$tensor);
  let results = (outs AnySlidingTensor:$sTensor);
  let assemblyFormat = [{
    $tensor attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
    RankedTensorType getTensorType() { return getTensor().getType(); }
    SlidingTensorType getSTensorType() { return getSTensor().getType(); }
  }];
}

def SlidingTensorToTensorOp : HLSOp<"stensor_to_tensor", [Pure]> {
  let summary = "Convert a sliding tensor to a tensor";

  let arguments = (ins AnySlidingTensor:$sTensor);
  let results = (outs AnyRankedTensor:$tensor);
  let assemblyFormat = [{
    $sTensor attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    RankedTensorType getTensorType() { return getTensor().getType(); }
    SlidingTensorType getSTensorType() { return getSTensor().getType(); }
  }];
}

def SlidingTensorInitOp : HLSOp<"stensor_init", [Pure]> {
  let summary = "Initiate a sliding tensor";

  let results = (outs AnySlidingTensor:$sTensor);
  let assemblyFormat = "attr-dict `:` type(results)";
}

def SlidingTensorPullOp : HLSOp<"stensor_pull", [Pure]> {
  let summary = "Pull a sliding tensor";
  let description = [{
    This is a payload-carried operation, which means the status-updated sliding
    tensor is explicitly returned as the result of the operation.
  }];

  let arguments = (ins AnySlidingTensor:$sTensor);
  let results = (outs AnyRankedTensor:$window, AnySlidingTensor:$pulledSTensor);
  let assemblyFormat = [{
    $sTensor attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    SlidingTensorType getSTensorType() { return getSTensor().getType(); }
    RankedTensorType getWindowType() { return getWindow().getType(); }
  }];
}

def SlidingTensorPushOp : HLSOp<"stensor_push", [Pure]> {
  let summary = "Push a sliding tensor and return the pushed sliding tensor";
  let description = [{
    This is a payload-carried operation, which means the status-updated sliding
    tensor is explicitly returned as the result of the operation.
  }];

  let arguments = (ins AnySlidingTensor:$sTensor, AnyRankedTensor:$window);
  let results = (outs AnySlidingTensor:$pushedSTensor);
  let assemblyFormat = [{
    $window `to` $sTensor attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    SlidingTensorType getSTensorType() { return getSTensor().getType(); }
    RankedTensorType getWindowType() { return getWindow().getType(); }
  }];
}

def SlidingTensorBufferOp : HLSOp<"stensor_buffer", [Pure]> {
  let summary = "Buffer a sliding tensor before the specified loop and dim";

  let arguments = (ins AnySlidingTensor:$inputSTensor, 
      AnySlidingTensor:$initSTensor, TypeAttr:$bufferElementType,
      DenseI64ArrayAttr:$bufferShape, SI64Attr:$loopIndex, SI64Attr:$dimIndex);
  let results = (outs AnySlidingTensor:$outputSTensor);
  let assemblyFormat = [{
    $inputSTensor `into` $initSTensor `,` $bufferElementType $bufferShape
    `before` `loop` $loopIndex `dim` $dimIndex attr-dict `:`
    functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
    SlidingTensorType getInputSTensorType() {
      return getInputSTensor().getType();
    }
    SlidingTensorType getOutputSTensorType() {
      return getOutputSTensor().getType();
    }
  }];
}

class ReassociateOp<string mnemonic, list<Trait> traits = []> :
    HLSOp<mnemonic, !listconcat(traits, [Pure])> {
  let description = [{
    This is a view-like operation, which means the status of the sliding tensor
    is not changed during the reassociation. The shape expand/collapse is
    similar to the regular tensor shape expand/collapse, while the iteration
    space expand/collapse can be considered as the loop split/merge of the
    iteration loop nest.
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  code commonExtraClassDeclaration = [{
    static SmallVector<ReassociationIndices, 4> 
    getReassociationIndices(ArrayAttr reassociationAttr) {
      SmallVector<ReassociationIndices, 4> reassociationIndices;
      for (auto attr : reassociationAttr)
        reassociationIndices.push_back(llvm::to_vector<2>(
            llvm::map_range(cast<ArrayAttr>(attr), [&](Attribute indexAttr) {
              return cast<IntegerAttr>(indexAttr).getInt();
            })));
      return reassociationIndices;
    }

    SmallVector<ReassociationIndices, 4> getShapeReassociationIndices() {
      return getReassociationIndices(getShapeReassociation());
    }
    SmallVector<ReassociationIndices, 4> getIterationReassociationIndices() {
      return getReassociationIndices(getIterationReassociation());
    }
  }];
}

def SlidingTensorReassociateOp : ReassociateOp<"stensor_reassociate"> {
  let summary = "Reassociate the shape and/or iteration of a sliding tensor";

  let arguments = (ins AnySlidingTensor:$inputSTensor, UnitAttr:$expandShape,
      IndexListArrayAttr:$shapeReassociation, UnitAttr:$expandIteration,
      IndexListArrayAttr:$iterationReassociation);
  let results = (outs AnySlidingTensor:$outputSTensor);

  let assemblyFormat = [{
    $inputSTensor (`expand` $expandShape^):(`collapse`)? `shape`
    $shapeReassociation (`expand` $expandIteration^):(`collapse`)? `iteration`
    $iterationReassociation attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = commonExtraClassDeclaration # [{
    SlidingTensorType getInputSTensorType() {
      return getInputSTensor().getType();
    }
    SlidingTensorType getOutputSTensorType() {
      return getOutputSTensor().getType();
    }
  }];
}

//===----------------------------------------------------------------------===//
// SlidingMemref Operations
//===----------------------------------------------------------------------===//

def SlidingTensorToSlidingMemrefOp : HLSOp<"stensor_to_smemref",[Pure]> {
  let summary = "Convert a sliding tensor to a sliding memref";

  let arguments = (ins AnySlidingTensor:$sTensor);
  let results = (outs AnySlidingMemref:$sMemref);
  let assemblyFormat = [{
    $sTensor attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
    SlidingMemrefType getSMemrefType() { return getSMemref().getType(); }
    SlidingTensorType getSTensorType() { return getSTensor().getType(); }
  }];
}

def SlidingMemrefToSlidingTensorOp : HLSOp<"smemref_to_stensor", [Pure]> {
  let summary = "Convert a sliding memref to a sliding tensor";

  let arguments = (ins AnySlidingMemref:$sMemref);
  let results = (outs AnySlidingTensor:$sTensor);
  let assemblyFormat = [{
    $sMemref attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    SlidingMemrefType getSMemrefType() { return getSMemref().getType(); }
    SlidingTensorType getSTensorType() { return getSTensor().getType(); }
  }];
}

def SlidingMemrefAllocOp : HLSOp<"smemref_alloc", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Allocate a sliding memref";

  let results = (outs AnySlidingMemref:$sMemref);
  let assemblyFormat = "attr-dict `:` type(results)";

  let hasVerifier = 1;
}

def SlidingMemrefPullOp : HLSOp<"smemref_pull", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Pull a sliding memref";
  let description = [{
    This is a memory-read effect operation on the sliding memref.
  }];

  let arguments = (ins AnySlidingMemref:$sMemref);
  let results = (outs AnyStaticShapeMemRef:$window);
  let assemblyFormat = [{
    $sMemref attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    SlidingMemrefType getSMemrefType() { return getSMemref().getType(); }
    MemRefType getWindowType() { return getWindow().getType(); }
  }];
}

def SlidingMemrefPushOp : HLSOp<"smemref_push", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Push a sliding memref";
  let description = [{
    This is a memory-write effect operation on the sliding memref.
  }];

  let arguments = (ins AnySlidingMemref:$sMemref, AnyStaticShapeMemRef:$window);
  let assemblyFormat = [{
    $window `to` $sMemref attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    SlidingMemrefType getSMemrefType() { return getSMemref().getType(); }
    MemRefType getWindowType() { return getWindow().getType(); }
  }];
}

def SlidingMemrefReassociateOp : ReassociateOp<"smemref_reassociate"> {
  let summary = "Reassociate the shape and/or iteration of a sliding memref";

  let arguments = (ins AnySlidingMemref:$inputSMemref, UnitAttr:$expandShape,
      IndexListArrayAttr:$shapeReassociation, UnitAttr:$expandIteration,
      IndexListArrayAttr:$iterationReassociation);
  let results = (outs AnySlidingMemref:$outputSMemref);

  let assemblyFormat = [{
    $inputSMemref (`expand` $expandShape^):(`collapse`)? `shape`
    $shapeReassociation (`expand` $expandIteration^):(`collapse`)? `iteration`
    $iterationReassociation attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = commonExtraClassDeclaration # [{
    SlidingMemrefType getInputSMemrefType() {
      return getInputSMemref().getType();
    }
    SlidingMemrefType getOutputSMemrefType() {
      return getOutputSMemref().getType();
    }
  }];
}

//===----------------------------------------------------------------------===//
// Stream Operations
//===----------------------------------------------------------------------===//

def StreamOp : HLSOp<"stream", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Declare a stream channel";

  let results = (outs AnyStream:$stream);
  let assemblyFormat = "attr-dict `:` type(results)";

  let hasVerifier = 1;
}

def StreamPullOp : HLSOp<"stream_pull", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Pull a stream channel";
  let description = [{
    This is a memory-load effect operation on the stream channel.
  }];

  let arguments = (ins AnyStream:$stream);
  let results = (outs AnyType:$element);
  let assemblyFormat = [{
    $stream attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    StreamType getStreamType() { return getStream().getType(); }
    Type getElementType() { return getElement().getType(); }
  }];
}

def StreamPushOp : HLSOp<"stream_push", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Push a stream channel";
  let description = [{
    This is a memory-store effect operation on the stream channel.
  }];

  let arguments = (ins AnyStream:$stream, AnyType:$element);
  let assemblyFormat = [{
    $element `to` $stream attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    StreamType getStreamType() { return getStream().getType(); }
    Type getElementType() { return getElement().getType(); }
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
