//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD

include "scalehls/Dialect/HLS/HLSBase.td"
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
    SmallVector<int64_t> getActualFactors(ArrayRef<int64_t> shape);
    static PartitionLayoutAttr getWithActualFactors(MLIRContext *context,
        ArrayRef<PartitionKind> kinds, ArrayRef<int64_t> actualFactors,
        ArrayRef<int64_t> shape);
  }];
}

def ExtBufferLayoutAttr : HLSAttr<"ExtBufferLayout",
    [DeclareAttrInterfaceMethods<MemRefLayoutAttrInterface,
                                 ["verifyLayout"]>]> {
  let summary = "Layout of external buffer";
  let parameters = (ins
    "AffineMap":$map,
    OptionalArrayRefParameter<"int64_t">:$vectorShape
  );

  let skipDefaultBuilders = 1;
  let builders = [
    AttrBuilderWithInferredContext<(ins "AffineMap":$map,
                                        "ArrayRef<int64_t>":$vectorShape), [{
      return $_get(map.getContext(), map, vectorShape);
    }]>,
    AttrBuilderWithInferredContext<(ins "AffineMap":$map), [{
      return $_get(map.getContext(), map, SmallVector<int64_t>());
    }]>
  ];

  let genVerifyDecl = 1;
  let mnemonic = "layout";
  let assemblyFormat = "`<` $map (`,` `[` $vectorShape^ `]`)? `>`";
}

//===----------------------------------------------------------------------===//
// HLS resource and timing attributes
//===----------------------------------------------------------------------===//

def Resource : HLSAttr<"Resource"> {
  let summary = "Resource utilization attributes";
  let parameters = (ins "int64_t":$lut, "int64_t":$dsp, "int64_t":$bram);

  let mnemonic = "res";
  let assemblyFormat = [{
    `<` `lut` `=` $lut `,` `dsp` `=` $dsp `,` `bram` `=` $bram `>`
  }];
}

def Timing : HLSAttr<"Timing"> {
  let summary = "Timing attributes";
  let parameters = (ins "int64_t":$begin, "int64_t":$end, "int64_t":$latency,
                        "int64_t":$interval);

  let mnemonic = "time";
  let assemblyFormat = [{
    `<` $begin `->` $end `,` `latency` `=` $latency `,` `interval` `=`
    $interval `>`
  }];
}

def LoopInfo : HLSAttr<"LoopInfo"> {
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

def LoopDirective : HLSAttr<"LoopDirective"> {
  let summary = "Aggregation of loop directives";
  let parameters = (ins "bool":$pipeline, "int64_t":$targetII, "bool":$dataflow,
                    "bool":$flatten);
  
  let mnemonic = "loop";
  let assemblyFormat = [{
    `<` `pipeline` `=` $pipeline `,` `target_ii` `=` $targetII `,` `dataflow`
    `=` $dataflow `,` `flatten` `=` $flatten `>`
  }];
}

def FuncDirective : HLSAttr<"FuncDirective"> {
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
