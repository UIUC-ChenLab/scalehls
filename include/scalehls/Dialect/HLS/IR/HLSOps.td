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
// Type Predicates
//===----------------------------------------------------------------------===//

class ContainerOf<list<Type> allowedTypes, string name, string cppClassName>
  : Type<And<[
      CPred<"::llvm::isa<" # cppClassName # ">($_self)">,
      Concat<
        "[](::mlir::Type elementType) { return ",
        SubstLeaves<"$_self", "elementType",
        AnyTypeOf<allowedTypes>.predicate>,
        "; }(::llvm::cast<" # cppClassName # ">($_self).getElementType())"
      >
    ]>,
    name # " of " # AnyTypeOf<allowedTypes>.summary # " values",
    cppClassName
  >;

class ITensorOf<list<Type> allowedTypes>
  : ContainerOf<allowedTypes, "itensor", "::mlir::scalehls::hls::ITensorType">;

class StreamOf<list<Type> allowedTypes>
  : ContainerOf<allowedTypes, "stream", "::mlir::scalehls::hls::StreamType">;

def AnyITensor : ITensorOf<[AnyType]>;
def AnyStream : StreamOf<[AnyType]>;
def AnyBuffer : StaticShapeMemRefOf<[AnyType]>;

//===----------------------------------------------------------------------===//
// Tensor Operations
//===----------------------------------------------------------------------===//

def TensorInitOp : HLSOp<"tensor_init"> {
  let summary = "Initiate a tensor with an optional initialization value";

  let arguments = (ins Optional<AnyType>:$initValue);
  let results = (outs AnyRankedTensor:$result);
  let assemblyFormat = [{
    (`init` $initValue^)? attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let hasCanonicalizeMethod = 1;

  let builders = [
    OpBuilder<(ins "mlir::Type":$result),
        "build($_builder, $_state, result, nullptr);">
  ];
}

//===----------------------------------------------------------------------===//
// ITensor Operations
//===----------------------------------------------------------------------===//

def ITensorInitOp : HLSOp<"itensor_init", [Pure]> {
  let summary = "Initiate an iterative tensor";

  let arguments = (ins Optional<AnyType>:$initValue);
  let results = (outs AnyITensor:$result);
  let assemblyFormat = [{
    (`init` $initValue^)? attr-dict `:` functional-type(operands, results)
  }];

  let builders = [
    OpBuilder<(ins "mlir::Type":$result),
        "build($_builder, $_state, result, nullptr);">
  ];
}

def ITensorToTensorOp : HLSOp<"itensor_to_tensor", [Pure]> {
  let summary = "Convert an iterative tensor to a tensor";

  let arguments = (ins AnyITensor:$source);
  let results = (outs AnyRankedTensor:$result);
  let assemblyFormat = [{
    $source attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    ITensorType getSourceType() { return getSource().getType(); }
    RankedTensorType getResultType() { return getResult().getType(); }
  }];
}

def TensorToITensorOp : HLSOp<"tensor_to_itensor", [Pure]> {
  let summary = "Convert a tensor to an iterative tensor";

  let arguments = (ins AnyRankedTensor:$source);
  let results = (outs AnyITensor:$result);
  let assemblyFormat = [{
    $source attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
    RankedTensorType getSourceType() { return getSource().getType(); }
    ITensorType getResultType() { return getResult().getType(); }
  }];
}

def ITensorReadOp : HLSOp<"itensor_read", [Pure]> {
  let summary = "Read an element from an iterative tensor";

  let arguments = (ins AnyITensor:$source, Optional<AnyRankedTensor>:$init);
  let results = (outs AnyType:$value);
  let assemblyFormat = [{
    $source (`to` $init^)? attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let builders = [
    OpBuilder<(ins "mlir::Type":$value, "mlir::Value":$source),
        "build($_builder, $_state, value, source, nullptr);">
  ];

  let extraClassDeclaration = [{
    ITensorType getSourceType() { return getSource().getType(); }
    std::optional<RankedTensorType> getInitType() {
      if (getInit())
        return getInit().getType();
      return std::nullopt;
    }
    Type getValueType() { return getValue().getType(); }
  }];
}

def ITensorWriteOp : HLSOp<"itensor_write", [Pure]> {
  let summary = "Write an element to an iterative tensor";

  let arguments = (ins AnyType:$value, AnyITensor:$init);
  let results = (outs AnyITensor:$result);
  let assemblyFormat = [{
    $value `into` $init attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;

  let extraClassDeclaration = [{
    Type getValueType() { return getValue().getType(); }
    ITensorType getInitType() { return getInit().getType(); }
    ITensorType getResultType() { return getResult().getType(); }
  }];
}

def ITensorBufferOp : HLSOp<"itensor_buffer", [Pure,
      DeclareOpInterfaceMethods<ITensorViewLikeInterface>]> {
  let summary = "Buffer an iterative tensor at a specific position";

  let arguments = (ins AnyITensor:$source, TypeAttr:$bufferElementType,
      DenseI64ArrayAttr:$bufferShape, SI64Attr:$loopIndex, SI64Attr:$dimIndex);
  let results = (outs AnyITensor:$result);
  let assemblyFormat = [{
    $source `,` $bufferElementType $bufferShape `before` `loop`
    $loopIndex `dim` $dimIndex attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;
}

def ITensorReassociateOp : HLSOp<"itensor_reassociate", [Pure,
      DeclareOpInterfaceMethods<ITensorViewLikeInterface>]> {
  let summary = "Reassociate the shape and/or iteration of an iterative tensor";

  let arguments = (ins AnyITensor:$source, UnitAttr:$expandShape,
        IndexListArrayAttr:$shapeReassociation, UnitAttr:$expandIteration,
        IndexListArrayAttr:$iterationReassociation);
  let results = (outs AnyITensor:$result);
  let assemblyFormat = [{
    $source (`expand` $expandShape^):(`collapse`)? `shape` $shapeReassociation
    (`expand` $expandIteration^):(`collapse`)? `iteration`
    $iterationReassociation attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
    static SmallVector<ReassociationIndices> 
    getReassociationIndices(ArrayAttr reassociationAttr) {
      SmallVector<ReassociationIndices> indices;
      for (auto attr : reassociationAttr)
        indices.push_back(llvm::to_vector<2>(
            llvm::map_range(cast<ArrayAttr>(attr), [&](Attribute indexAttr) {
              return cast<IntegerAttr>(indexAttr).getInt();
            })));
      return indices;
    }

    SmallVector<ReassociationIndices> getShapeReassociationIndices() {
      return getReassociationIndices(getShapeReassociation());
    }
    SmallVector<ReassociationIndices> getIterationReassociationIndices() {
      return getReassociationIndices(getIterationReassociation());
    }
  }];
}

def ITensorCastOp : HLSOp<"itensor_cast", [Pure,
      DeclareOpInterfaceMethods<ITensorViewLikeInterface>]> {
  let summary = "Cast an iterative tensor to a different type";

  let arguments = (ins AnyITensor:$source);
  let results = (outs AnyITensor:$result);
  let assemblyFormat = [{
    $source attr-dict `:` functional-type(operands, results)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;
}

//===----------------------------------------------------------------------===//
// Streamerization Operations
//===----------------------------------------------------------------------===//

def ITensorAllocOp : HLSOp<"itensor_alloc"> {
  let summary = "Allocate an iterative tensor";

  let arguments = (ins Optional<AnyType>:$initValue);
  let results = (outs AnyITensor:$result);
  let assemblyFormat = [{
    (`init` $initValue^)? attr-dict `:` functional-type(operands, results)
  }];

  // let hasVerifier = 1;
  // let hasCanonicalizeMethod = 1;

  let builders = [
    OpBuilder<(ins "mlir::Type":$result),
        "build($_builder, $_state, result, nullptr);">
  ];
}

def StreamToITensorOp : HLSOp<"stream_to_itensor"> {
  let summary = "Convert a stream channel to a itensor";

  let arguments = (ins AnyStream:$stream);
  let results = (outs AnyITensor:$iTensor);
  let assemblyFormat = [{
    $stream attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    StreamType getStreamType() { return getStream().getType(); }
    ITensorType getITensorType() { return getITensor().getType(); }
  }];
}

def ITensorToStreamOp : HLSOp<"itensor_to_stream"> {
  let summary = "Convert an itensor to a stream channel";

  let arguments = (ins ITensorType:$iTensor);
  let results = (outs AnyStream:$stream);
  let assemblyFormat = [{
    $iTensor attr-dict `:` functional-type(operands, results)
  }];

  let hasFolder = 1;

  let extraClassDeclaration = [{
    ITensorType getITensorType() { return getITensor().getType(); }
    StreamType getStreamType() { return getStream().getType(); }
  }];
}

//===----------------------------------------------------------------------===//
// Stream Operations
//===----------------------------------------------------------------------===//

def StreamOp : HLSOp<"stream", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Instantiate a stream channel";

  let results = (outs AnyStream:$stream);
  let assemblyFormat = "attr-dict `:` type(results)";

  let hasVerifier = 1;
  let hasCanonicalizeMethod = 1;
}

def StreamReadOp : HLSOp<"stream_read", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Read an element from stream channel";
  let description = [{
    Read/pop a value from a stream channel.
  }];

  let arguments = (ins AnyStream:$source);
  let results = (outs AnyType:$value);
  let assemblyFormat = [{
    $source attr-dict `:` functional-type(operands, results)
  }];

  let extraClassDeclaration = [{
    StreamType getSourceType() { return getSource().getType(); }
    Type getValueType() { return getValue().getType(); }
  }];
}

def StreamWriteOp : HLSOp<"stream_write", [
    DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Write an element to stream channel";
  let description = [{
    Write/push a value to a stream channel. Each stream channel can only be
    written once.
  }];

  let arguments = (ins AnyType:$value, AnyStream:$dest);
  let assemblyFormat = [{
    $value `into` $dest attr-dict `:` type(operands)
  }];

  let extraClassDeclaration = [{
    StreamType getDestType() { return getDest().getType(); }
    Type getValueType() { return getValue().getType(); }
  }];
}

//===----------------------------------------------------------------------===//
// Functional Dataflow (FDF) Operations
//===----------------------------------------------------------------------===//

def ScheduleOp : HLSOp<"schedule", [RecursiveMemoryEffects,
      SingleBlockImplicitTerminator<"YieldOp">,
      ParentOneOf<["func::FuncOp", "affine::AffineForOp", "scf::ForOp"]>]> {
  let summary = "Represent a dataflow schedule";
  let description = [{
    Schedule op has a transparent region that contains a list of task ops to be
    scheduleed. This op is designed to organize and manipulate task ops at a
    high level and will be lowered to schedule op for dataflow scheduling.
  }];

  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);
  let assemblyFormat = "(`:` type($results)^)? $body attr-dict";

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    YieldOp getYieldOp();
  }];
}

def TaskOp : HLSOp<"task", [RecursiveMemoryEffects, HasParent<"ScheduleOp">,
      SingleBlockImplicitTerminator<"YieldOp">]> {
  let summary = "Represent a dataflow task";
  let description = [{
    Task op has a transparent region that contains a list of ops to be executed
    in the task. This op is designed to represent the task partition at a high
    level and will be lowered to node op for dataflow scheduling.
  }];

  let results = (outs Variadic<AnyType>:$results);
  let regions = (region SizedRegion<1>:$body);

  let assemblyFormat = "(`:` type($results)^)? $body attr-dict";

  let hasVerifier = 1;
  let hasCanonicalizer = 1;

  let extraClassDeclaration = [{
    /// Return true if this task op contains nested sub-tasks.
    bool hasHierarchy() {
      return walk([&](Operation *op) {
          if (isa<TaskOp, func::CallOp>(op) && op != *this)
            return WalkResult::interrupt();
          return WalkResult::advance();
        }).wasInterrupted();
    }

    ScheduleOp getScheduleOp();
    YieldOp getYieldOp();
  }];
}

def YieldOp : HLSOp<"yield", [Pure, ReturnLike, Terminator,
      ParentOneOf<["ScheduleOp", "TaskOp"]>]> {
  let summary = "Terminate and yield results of a schedule or task op";

  let arguments = (ins Variadic<AnyType>:$results);
  let assemblyFormat = "$results attr-dict `:` type($results)";

  let builders = [OpBuilder<(ins), "build($_builder, $_state, std::nullopt);">];
}

def BufferOp : HLSOp<"buffer", [DeclareOpInterfaceMethods<BufferLikeInterface>,
      DeclareOpInterfaceMethods<MemoryEffectsOpInterface>]> {
  let summary = "Represent a dataflow buffer";

  let arguments = (ins OptionalAttr<TypedAttrInterface>:$init_value);
  let results = (outs AnyBuffer:$memref);
  let assemblyFormat = "attr-dict `:` type($memref)";

  let hasVerifier = 1;
  let hasCanonicalizer = 1;
  let builders = [
    OpBuilder<(ins "mlir::Type":$memref),
        "build($_builder, $_state, memref, nullptr);">
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
