//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD

include "scalehls/Dialect/HLS/IR/HLSDialect.td"
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/BuiltinAttributeInterfaces.td"
include "mlir/IR/EnumAttr.td"

class HLSAttr<string name, list<Trait> traits = []> :
    AttrDef<HLSDialect, name, traits>;

//===----------------------------------------------------------------------===//
// Enum attributes and parameters
//===----------------------------------------------------------------------===//

def AxiKind: I32EnumAttr<"AxiKind", "Kind of AXI port", [
    I32EnumAttrCase<"MM", 0, "mm">,
    I32EnumAttrCase<"LITE", 1, "lite">,
    I32EnumAttrCase<"STREAM", 2, "stream">
]> {
  let cppNamespace = "mlir::scalehls::hls";
  let genSpecializedAttr = 0;
}
def AxiKindParam: EnumParameter<AxiKind>;

def PartitionKind: I32EnumAttr<"PartitionKind", "Kind of array partition", [
    I32EnumAttrCase<"NONE", 0, "none">,
    I32EnumAttrCase<"CYCLIC", 1, "cyclic">,
    I32EnumAttrCase<"BLOCK", 2, "block">,
    I32EnumAttrCase<"COMPLETE", 3, "complete">
]> {
  let cppNamespace = "mlir::scalehls::hls";
  let genSpecializedAttr = 0;
}
def PartitionKindParam: EnumParameter<PartitionKind>;

def MemoryKind: I32EnumAttr<"MemoryKind", "Kind of memory", [
    I32EnumAttrCase<"UNKNOWN", 0, "unknown">,  
    I32EnumAttrCase<"LUTRAM_1P", 1, "lutram_1p">,
    I32EnumAttrCase<"LUTRAM_2P", 2, "lutram_2p">,
    I32EnumAttrCase<"LUTRAM_S2P", 3, "lutram_s2p">,
    I32EnumAttrCase<"BRAM_1P", 4, "bram_1p">,
    I32EnumAttrCase<"BRAM_2P", 5, "bram_2p">,
    I32EnumAttrCase<"BRAM_S2P", 6, "bram_s2p">,
    I32EnumAttrCase<"BRAM_T2P", 7, "bram_t2p">,
    I32EnumAttrCase<"URAM_1P", 8, "uram_1p">,
    I32EnumAttrCase<"URAM_2P", 9, "uram_2p">,
    I32EnumAttrCase<"URAM_S2P", 10, "uram_s2p">,
    I32EnumAttrCase<"URAM_T2P", 11, "uram_t2p">,
    I32EnumAttrCase<"DRAM", 12, "dram">
]> {
  let cppNamespace = "mlir::scalehls::hls";
  let genSpecializedAttr = 0;
}
def MemoryKindAttr: EnumAttr<HLSDialect, MemoryKind> {
  let mnemonic = "mem";
  let assemblyFormat = "`<` $value `>`";
}

//===----------------------------------------------------------------------===//
// Layout attributes
//===----------------------------------------------------------------------===//

def PartitionLayoutAttr : HLSAttr<"PartitionLayout",
    [DeclareAttrInterfaceMethods<MemRefLayoutAttrInterface,
                                 ["verifyLayout"]>]> {
  let summary = "Layout of array partition";
  let parameters = (ins
    ArrayRefParameter<"hls::PartitionKind">:$kinds,
    ArrayRefParameter<"int64_t">:$factors
  );

  let genVerifyDecl = 1;
  let mnemonic = "partition";
  let assemblyFormat = "`<` `[` $kinds `]` `,` `[` $factors `]` `>`";

  let extraClassDeclaration = [{
    /// The affine map of "block" partition needs array shape to be inferenced.
    /// For example, if the partition factor is [2] and the shape of the array
    /// is [16], the affine map should be (d0) -> (d0 / 8, d0 % 8), where 8 is
    /// equal to 16 / 2. However, as the shape information is not known at the
    /// time of attribute construction, we can only encode factor [8] in the
    /// attribute instead of the actual factor [2]. This method returns the
    /// actual partition factor with the given array shape.
    SmallVector<int64_t> getActualFactors(ArrayRef<int64_t> shape);

    /// This method construct a PartitionLayoutAttr with the given partition
    /// kinds, actual partition factors, and array shape.
    static PartitionLayoutAttr getWithActualFactors(MLIRContext *context,
        ArrayRef<PartitionKind> kinds, ArrayRef<int64_t> actualFactors,
        ArrayRef<int64_t> shape);
  }];
}

def TileLayoutAttr : HLSAttr<"TileLayout",
    [DeclareAttrInterfaceMethods<MemRefLayoutAttrInterface,
                                 ["verifyLayout"]>]> {
  let summary = "Layout of tiled buffer";
  let parameters = (ins
    ArrayRefParameter<"int64_t">:$tileShape,
    ArrayRefParameter<"int64_t">:$vectorShape
  );

  let genVerifyDecl = 1;
  let mnemonic = "tile";
  let assemblyFormat = "`<` `[` $tileShape `]` `,` `[` $vectorShape `]` `>`";

  let builders = [
    AttrBuilder<(ins "ArrayRef<int64_t>":$tileShape), [{
      return $_get(context, tileShape,
                   SmallVector<int64_t>(tileShape.size(), 1));
    }]>
  ];

  let extraClassDeclaration = [{
    bool isTiled() {
      return llvm::any_of(getTileShape(), [](int64_t v) { return v > 1; });
    }
    bool isVectorized() {
      return llvm::any_of(getVectorShape(), [](int64_t v) { return v > 1; });
    }
  }];
}

//===----------------------------------------------------------------------===//
// HLS resource and timing attributes
//===----------------------------------------------------------------------===//

def ResourceAttr : HLSAttr<"Resource"> {
  let summary = "Resource utilization attributes";
  let parameters = (ins "int64_t":$lut, "int64_t":$dsp, "int64_t":$bram);

  let mnemonic = "res";
  let assemblyFormat = [{
    `<` `lut` `=` $lut `,` `dsp` `=` $dsp `,` `bram` `=` $bram `>`
  }];
}

def TimingAttr : HLSAttr<"Timing"> {
  let summary = "Timing attributes";
  let parameters = (ins "int64_t":$begin, "int64_t":$end, "int64_t":$latency,
                        "int64_t":$interval);

  let mnemonic = "time";
  let assemblyFormat = [{
    `<` $begin `->` $end `,` `latency` `=` $latency `,` `interval` `=`
    $interval `>`
  }];
}

def LoopInfoAttr : HLSAttr<"LoopInfo"> {
  let summary = "Loop information";
  let parameters = (ins "int64_t":$flattenTripCount, "int64_t":$iterLatency,
                        "int64_t":$minII);

  let mnemonic = "info";
  let assemblyFormat = [{
    `<` `flatten_trip_count` `=` $flattenTripCount `,` `iter_latency` `=`
    $iterLatency `,` `min_ii` `=` $minII `>`
  }];
}

//===----------------------------------------------------------------------===//
// HLS directive attributes
//===----------------------------------------------------------------------===//

def LoopDirectiveAttr : HLSAttr<"LoopDirective"> {
  let summary = "Aggregation of loop directives";
  let parameters = (ins "bool":$pipeline, "int64_t":$targetII, "bool":$dataflow,
                    "bool":$flatten);
  
  let mnemonic = "loop";
  let assemblyFormat = [{
    `<` `pipeline` `=` $pipeline `,` `target_ii` `=` $targetII `,` `dataflow`
    `=` $dataflow `,` `flatten` `=` $flatten `>`
  }];
}

def FuncDirectiveAttr : HLSAttr<"FuncDirective"> {
  let summary = "Aggregation of function directives";
  let parameters = (ins "bool":$pipeline, "int64_t":$targetInterval,
                        "bool":$dataflow);

  let mnemonic = "func";
  let assemblyFormat = [{
    `<` `pipeline` `=` $pipeline `,` `target_interval` `=` $targetInterval `,`
    `dataflow` `=` $dataflow `>`
  }];
}

#endif // SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD
