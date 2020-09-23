//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_PARAMOPS_TD
#define SCALEHLS_DIALECT_HLSCPP_PARAMOPS_TD

//===----------------------------------------------------------------------===//
// FuncParamOp
//===----------------------------------------------------------------------===//

def FuncParamOp : HLSCppOp<"func_param", [
  ParamOpInterface,
  HasParent<"FuncOp">
]> {
  let summary = "Hold function parameters";
  let description = [{
    This hlscpp.func_param operation holds parameters for function region.
  }];

  let arguments = (ins
    // Pragma configuration parameters
    // BoolAttr : $enable_pipeline,
    // PositiveUI32Attr : $initial_interval,

    // Resource utilization parameters
    UI32Attr : $lut,
    UI32Attr : $dsp,
    UI32Attr : $bram
  );
}

//===----------------------------------------------------------------------===//
// LoopParamOp
//===----------------------------------------------------------------------===//

def LoopParamOp : HLSCppOp<"loop_param", [
  ParamOpInterface,
  HasParent<"AffineForOp">
]> {
  let summary = "Hold loop parameters";
  let description = [{
    This hlscpp.loop_param operation holds parameters for loop region.
  }];

  let arguments = (ins
    // Pragma configuration parameters
    BoolAttr : $enable_pipeline,
    PositiveUI32Attr : $initial_interval,
    PositiveUI32Attr : $unroll_factor,

    // Performance parameters
    UI32Attr : $loop_bound,
    UI32Attr : $nonproc_latency,
    UI32Attr : $iteration_latency,
    UI32Attr : $latency,

    // Resource utilization parameters
    UI32Attr : $lut,
    UI32Attr : $dsp,
    UI32Attr : $bram
  );

  let extraClassDeclaration = [{
    unsigned getUnrollFactor() {
      return getAttrOfType<IntegerAttr>("unroll_factor").getUInt();
    }

    unsigned getLoopBound() {
      return getAttrOfType<IntegerAttr>("loop_bound").getUInt();
    }

    unsigned getNonprocLatency() {
      return getAttrOfType<IntegerAttr>("nonproc_latency").getUInt();
    }

    unsigned getIterationLatency() {
      return getAttrOfType<IntegerAttr>("iteration_latency").getUInt();
    }

    unsigned getLatency() {
      return getAttrOfType<IntegerAttr>("latency").getUInt();
    }
  }];
}

//===----------------------------------------------------------------------===//
// IfParamOp
//===----------------------------------------------------------------------===//

def IfParamOp : HLSCppOp<"if_param", [
  ParamOpInterface,
  HasParent<"AffineIfOp">
]> {
  let summary = "Hold if region parameters";
  let description = [{
    This hlscpp.if_param operation holds parameters for if regions, including
    then region and else region (if applicable).
  }];

  let arguments = (ins
    // Performance parameters
    UI32Attr : $latency,

    // Resource utilization parameters
    UI32Attr : $lut,
    UI32Attr : $dsp,
    UI32Attr : $bram
  );
}

//===----------------------------------------------------------------------===//
// ArrayParamOp
//===----------------------------------------------------------------------===//

def ArrayParamOp : HLSCppOp<"array_param", [
  ParamOpInterface
]> {
  let summary = "Hold array parameters";
  let description = [{
    This hlscpp.array_param operation holds parameters for arrays.
  }];

  let arguments = (ins
    // Pragma configuration parameters
    StorageTypeAttr : $storage_type,
    PartitionTypeAttr : $partition_type,
    PositiveUI32ArrayAttr : $partition_factor,

    // Performance parameters
    UI32Attr : $reads,
    UI32Attr : $writes,
    PositiveUI32Attr : $read_ports,
    PositiveUI32Attr : $write_ports,
    UI32Attr : $dependency_latency,
    UI32Attr : $dependency_distance,

    // Resource utilization parameters
    UI32Attr : $lut,
    UI32Attr : $bram
  );
}

#endif // SCALEHLS_DIALECT_HLSCPP_PARAMOPS_TD
