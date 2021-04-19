//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD

class HLSCppAttr<string name, string baseCppClass = "::mlir::Attribute">
    : AttrDef<HLSCppDialect, name, baseCppClass>;

def Resource : HLSCppAttr<"Resource"> {
  let summary = "Resource utilization information";
  let description = [{
    This attribute includes the utilization of several important on-chip
    resources, such as LUT, DSP, BRAM, URAM, and non-sharing DSP.
  }];
  let mnemonic = "r";

  let parameters = (ins
    "int64_t" : $lut,
    "int64_t" : $dsp,
    "int64_t" : $bram,
    "int64_t" : $nonShareDsp
  );
}

def Timing : HLSCppAttr<"Timing"> {
  let summary = "Timing information";
  let description = [{
    This attribute indicates the timing of operations, including scheduling
    begin and end cycles, latency, and minimum initial interval.
  }];
  let mnemonic = "t";

  let parameters = (ins
    "int64_t" : $begin,
    "int64_t" : $end,
    "int64_t" : $latency,
    "int64_t" : $minII
  );
}

def LoopInfo : HLSCppAttr<"LoopInfo"> {
  let summary = "Loop information";
  let description = [{
    This attribute includes loop information used by estimator and optimizer,
    including loop trip count, flattened trip count, iteration latency, and
    parallel predicate.
  }];
  let mnemonic = "l";

  let parameters = (ins
    "bool" : $parallel,
    "int64_t" : $tripCount,
    "int64_t" : $flattenTripCount,
    "int64_t" : $iterLatency
  );
}

def LoopDirective : HLSCppAttr<"LoopDirective"> {
  let summary = "Aggregation of loop directives";
  let description = [{
    This attribute includes all loop directives, including loop pipelining,
    target initial interval, and flattening).
  }];
  let mnemonic = "ld";

  let parameters = (ins
    "bool" : $pipeline,
    "int64_t" : $targetII,
    "bool" : $flatten
  );
}

def FuncDirective : HLSCppAttr<"FuncDirective"> {
  let summary = "Aggregation of function directives";
  let description = [{
    This attribute includes all function directives (function pipelining, target
    initial interval, dataflow, and top function predicate.
  }];
  let mnemonic = "fd";

  let parameters = (ins
    "bool" : $pipeline,
    "int64_t" : $targetII,
    "bool" : $dataflow,
    "bool" : $topFunc
  );
}

#endif // SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
