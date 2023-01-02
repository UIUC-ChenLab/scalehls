//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD

include "scalehls/Dialect/HLS/HLSBase.td"
include "mlir/IR/AttrTypeBase.td"
include "mlir/IR/EnumAttr.td"

class HLSAttr<string name> : AttrDef<HLSDialect, name>;

// Enum parameter for different AXI kinds.
def AxiKind: I32EnumAttr<"AxiKind", "Kind of AXI Port", [
    I32EnumAttrCase<"MM", 0, "mm">,
    I32EnumAttrCase<"LITE", 1, "lite">,
    I32EnumAttrCase<"STREAM", 2, "stream">
]> {
  let cppNamespace = "mlir::scalehls::hls";
  let genSpecializedAttr = 0;
}
def AxiKindParam: EnumParameter<AxiKind>;

// Enum parameter for different array partition kinds.
def PartitionKind: I32EnumAttr<"PartitionKind", "Kind of Array Partition", [
    I32EnumAttrCase<"NONE", 0, "none">,
    I32EnumAttrCase<"CYCLIC", 1, "cyclic">,
    I32EnumAttrCase<"BLOCK", 2, "block">,
    I32EnumAttrCase<"COMPLETE", 3, "complete">
]> {
  let cppNamespace = "mlir::scalehls::hls";
  let genSpecializedAttr = 0;
}
def PartitionKindParam: EnumParameter<PartitionKind>;

// Enum attribute for different memory kinds.
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
def MemoryKindAttr: EnumAttr<HLSDialect, MemoryKind, "mem"> {
  let assemblyFormat = ?;
  let hasCustomAssemblyFormat = 1;
}

// HLS attributes.
def Resource : HLSAttr<"Resource"> {
  let summary = "Resource utilization information";
  let description = [{
    This attribute includes the utilization of several important on-chip
    resources, such as LUT, DSP, BRAM, and URAM.
  }];

  let hasCustomAssemblyFormat = 1;
  let mnemonic = "res";
  let parameters = (ins "int64_t":$lut, "int64_t":$dsp, "int64_t":$bram);
}

def Timing : HLSAttr<"Timing"> {
  let summary = "Timing information";
  let description = [{
    This attribute indicates the timing of operations, including scheduling
    begin and end cycles, latency, and interval.
  }];

  let hasCustomAssemblyFormat = 1;
  let mnemonic = "time";
  let parameters = (ins "int64_t":$begin, "int64_t":$end, "int64_t":$latency,
                        "int64_t":$interval);
}

def LoopInfo : HLSAttr<"LoopInfo"> {
  let summary = "Loop information";
  let description = [{
    This attribute includes loop information used by estimator and optimizer,
    including flattened trip count, iteration latency, and minimum initial
    interval (II).
  }];

  let hasCustomAssemblyFormat = 1;
  let mnemonic = "info";
  let parameters = (ins "int64_t":$flattenTripCount, "int64_t":$iterLatency,
                        "int64_t":$minII);
}

def LoopDirective : HLSAttr<"LoopDirective"> {
  let summary = "Aggregation of loop directives";
  let description = [{
    This attribute includes all loop directives, including loop pipelining,
    target initial interval (II), dataflow, and flattening.
  }];

  let hasCustomAssemblyFormat = 1;
  let mnemonic = "loop";
  let parameters = (ins "bool":$pipeline, "int64_t":$targetII, "bool":$dataflow,
                        "bool":$flatten);
}

def FuncDirective : HLSAttr<"FuncDirective"> {
  let summary = "Aggregation of function directives";
  let description = [{
    This attribute includes all function directives, including function
    pipelining, target interval, and dataflow.
  }];

  let hasCustomAssemblyFormat = 1;
  let mnemonic = "func";
  let parameters = (ins "bool":$pipeline, "int64_t":$targetInterval,
                        "bool":$dataflow);
}

#endif // SCALEHLS_DIALECT_HLS_HLSATTRIBUTES_TD
