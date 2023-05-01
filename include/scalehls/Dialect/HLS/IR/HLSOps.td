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

class StreamOf<list<Type> allowedTypes> : Type<And<[
    CPred<"$_self.isa<mlir::scalehls::hls::StreamType>()">,
    Concat<"[](mlir::Type elementType) { return ",
      SubstLeaves<"$_self", "elementType", AnyTypeOf<allowedTypes>.predicate>,
      "; }($_self.cast<mlir::scalehls::hls::StreamType>().getElementType())">
  ]>,
  "stream of " # AnyTypeOf<allowedTypes>.summary # " values",
  "mlir::scalehls::hls::StreamType"
>;

def AnyBuffer : StaticShapeMemRefOf<[AnyType]>;
def AnyStream : StreamOf<[AnyType]>;
def AnyBufferOrStream : Type<Or<[AnyBuffer.predicate, AnyStream.predicate]>,
    "memref or stream values">;

//===----------------------------------------------------------------------===//
// HLS Operations
//===----------------------------------------------------------------------===//

include "scalehls/Dialect/HLS/IR/HLSDSEOps.td"
include "scalehls/Dialect/HLS/IR/HLSFDFOps.td"
include "scalehls/Dialect/HLS/IR/HLSSDFOps.td"
include "scalehls/Dialect/HLS/IR/HLSUBUFOps.td"
include "scalehls/Dialect/HLS/IR/HLSUIPOps.td"

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
