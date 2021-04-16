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
    resources, such as LUT, FF, DSP, BRAM, and URAM.
  }];
  let mnemonic = "res";

  let parameters = (ins
    "int64_t" : $lut,
    "int64_t" : $ff,
    "int64_t" : $dsp,
    "int64_t" : $bram
  );
}

def Schedule : HLSCppAttr<"Schedule"> {
  let summary = "Scheduling information";
  let description = [{
    This attribute indicates the scheduling begin and end of operations.
  }];
  let mnemonic = "sch";

  let parameters = (ins
    "int64_t" : $begin,
    "int64_t" : $end
  );
}

def ModuleInfo : HLSCppAttr<"ModuleInfo"> {
  let summary = "module information";
  let description = [{
    This attribute includes the module (function or loop) information, including
    the overall latency, initial interval, dsp utilization without sharing.
  }];
  let mnemonic = "mod";

  let parameters = (ins
    "int64_t" : $latency,
    "int64_t" : $minII,
    "int64_t" : $noshareDsp
  );
}

def LoopInfo : HLSCppAttr<"LoopInfo"> {
  let summary = "Loop information";
  let description = [{
    This attribute includes loop information used by estimator and optimizer,
    including loop trip count, flattened trip count, and iteration latency.
  }];
  let mnemonic = "loop";

  let parameters = (ins
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
