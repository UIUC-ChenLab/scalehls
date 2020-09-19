//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_PARAMETEROPS_TD
#define SCALEHLS_DIALECT_HLSCPP_PARAMETEROPS_TD

include "Interfaces.td"

def FuncParameterOp : HLSCppOp<"func_parameter", [
  ParameterOpInterface,
  HasParent<"FuncOp">
]> {
  let summary = "Hold function parameters";
  let description = [{
    This hlscpp.func_parameter operation holds parameters for function region.
  }];
}

def LoopParameterOp : HLSCppOp<"loop_parameter", [
  ParameterOpInterface,
  HasParent<"AffineForOp">
]> {
  let summary = "Hold loop parameters";
  let description = [{
    This hlscpp.loop_parameter operation holds parameters for loop region.
  }];
}

def ArrayParameterOp : HLSCppOp<"array_parameter", [
  ParameterOpInterface
]> {
  let summary = "Hold array parameters";
  let description = [{
    This hlscpp.array_parameter operation holds parameters for arrays.
  }];
}

#endif // SCALEHLS_DIALECT_HLSCPP_PARAMETEROPS_TD
