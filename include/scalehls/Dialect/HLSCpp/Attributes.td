//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
#define SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD

include "HLSCpp.td"
include "mlir/IR/OpBase.td"

class HLSCppAttr<string name, string baseCppClass = "::mlir::Attribute">
    : AttrDef<HLSCppDialect, name, baseCppClass>;

def ResourceAttr : HLSCppAttr<"ResourceAttr"> {
  let summary = "Resource utilization information";
  let description = [{
    This attribute includes several important on-chip resources of FPGA targets,
    such as LUT, FF, DSP, BRAM, and URAM.
  }];
  let mnemonic = "resource_attr";

  let parameters = (ins
    "int64_t" : $lut,
    "int64_t" : $ff,
    "int64_t" : $dsp,
    "int64_t" : $bram,
    "int64_t" : $uram
  );
}

def ScheduleAttr : HLSCppAttr<"ScheduleAttr"> {
  let summary = "Scheduling information";
  let description = [{
    This attribute indicates the scheduling begin and end of operations.
  }];
  let mnemonic = "schedule_attr";

  let parameters = (ins
    "int64_t" : $begin,
    "int64_t" : $end
  );
}

def LoopAttr : HLSCppAttr<"LoopAttr"> {
  let summary = "The aggregation of loop directives and attributes";
  let description = [{
    This attribute includes all loop directives (loop pipelining, target initial
    interval, and flattening) and attributes (loop trip count, iteration
    latency, overall latency, and minimum initial interval).
  }];
  let mnemonic = "loop_attr";

  let parameters = (ins
    // Directives.
    "bool" : $pipeline,
    "int64_t" : $targetII,
    "bool" : $flatten,

    // Attributes.
    "int64_t" : $tripCount,
    "int64_t" : $flattenTripCount,
    "int64_t" : $noshareDsp,
    "int64_t" : $iterLatency,

    "int64_t" : $latency,
    "int64_t" : $minII
  );
}

def FuncAttr : HLSCppAttr<"FuncAttr"> {
  let summary = "The aggregation of function directives";
  let description = [{
    This attribute include all function directives (loop pipelining and
    dataflow) and attributes (top function predicate, overall latency, and
    minimum initial interval).
  }];
  let mnemonic = "func_attr";

  let parameters = (ins
    // Directives.
    "bool" : $pipeline,
    "bool" : $dataflow,

    // Attributes.
    "bool" : $topFunc,

    "int64_t" : $latency,
    "int64_t" : $minII
  );
}

#endif // SCALEHLS_DIALECT_HLSCPP_ATTRIBUTES_TD
