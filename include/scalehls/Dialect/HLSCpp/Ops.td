//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD
#define SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD

include "mlir/Interfaces/SideEffectInterfaces.td"

def AssignOp : HLSCppOp<"assign", [SameOperandsAndResultType, NoSideEffect]> {
  let summary = "Assign the input value to the output";
  let description = [{
    This hlscpp.assign operation assigns the input value to the output, and can
    be inserted anywhere without changing the original semantic. This is useful
    for EmitHLSCpp to handle some weird corner cases (e.g., the operand of
    return operation is function argument, etc.).
  }];

  let arguments = (ins AnyType : $input);
  let results = (outs AnyType : $output);
}

def CastOp : HLSCppOp<"cast", [NoSideEffect]> {
  let summary = "Cast between any scalar values";
  let description = [{
    This operation cast from the input value to the output.
  }];

  let arguments = (ins AnyType : $input);
  let results = (outs AnyType : $output);

  let hasCanonicalizer = 1;
}

def AddOp : HLSCppOp<"add", [NoSideEffect]> {
  let summary = "Addition operation";
  let description = [{
    This addition operation does not require the input and output values to have
    the same type.
  }];

  let arguments = (ins AnyType : $lhs, AnyType : $rhs);
  let results = (outs AnyType : $output);
}

def MulOp : HLSCppOp<"mul", [NoSideEffect]> {
  let summary = "Multiplication operation";
  let description = [{
    This multiplication operation does not require the input and output values
    to have the same type.
  }];

  let arguments = (ins AnyType : $lhs, AnyType : $rhs);
  let results = (outs AnyType : $output);
}

def IPOp : HLSCppOp<"ip", [NoSideEffect]> {
  let summary = "General IP";
  let description = [{}];

  let arguments = (ins
    Variadic<AnyType>:$inputs,
    StrAttr:$name
  );
}

#endif // SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD
