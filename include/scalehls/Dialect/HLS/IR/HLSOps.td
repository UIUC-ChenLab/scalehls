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

  let arguments = (ins AnyStream:$channel, Optional<AnyType>:$init);
  let results = (outs AnyType:$result);
  let assemblyFormat = [{
    $channel (`init` $init^)? attr-dict `:` functional-type(operands, $result)
  }];

  let hasVerifier = 1;
  let builders = [
    OpBuilder<(ins "mlir::Type":$result, "mlir::Value":$channel),
        "build($_builder, $_state, result, channel, nullptr);">
  ];
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

def StreamReassociateOp : HLSOp<"stream_reassociate", [Pure,
      DeclareOpInterfaceMethods<StreamViewLikeInterface>]> {
  let summary = "Reassociate the shape and/or iteration of a stream channel";

  let arguments = (ins AnyStream:$input, UnitAttr:$expandShape,
        IndexListArrayAttr:$shapeReassociation, UnitAttr:$expandIteration,
        IndexListArrayAttr:$iterationReassociation);
  let results = (outs AnyStream:$output);
  let assemblyFormat = [{
    $input (`expand` $expandShape^):(`collapse`)? `shape` $shapeReassociation
    (`expand` $expandIteration^):(`collapse`)? `iteration`
    $iterationReassociation attr-dict `:` functional-type($input, $output)
  }];

  let hasVerifier = 1;
  let hasFolder = 1;

  let extraClassDeclaration = [{
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

    StreamType getInputType() { return getInput().getType(); }
    StreamType getOutputType() { return getOutput().getType(); }
  }];
}

def StreamBufferOp : HLSOp<"stream_buffer", [Pure,
      DeclareOpInterfaceMethods<StreamViewLikeInterface>]> {
  let summary = "Buffer a stream channel at a specific position";

  let arguments = (ins AnyStream:$input, TypeAttr:$bufferElementType,
      DenseI64ArrayAttr:$bufferShape, SI64Attr:$loopIndex, SI64Attr:$dimIndex);
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
      return walk([&](TaskOp task) {
          return task != *this ? WalkResult::interrupt() : WalkResult::advance();
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
