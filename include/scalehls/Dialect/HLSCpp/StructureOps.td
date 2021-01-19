//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD
#define SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD

def AssignOp : HLSCppOp<"assign", [SameOperandsAndResultType]> {
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

def EndOp : HLSCppOp<"end", [Terminator]> {
  let summary = "Mark the end of a HLSCpp region";
  let description = [{
    This hlscpp.end operation marks the end of a region in the HLSCpp dialect.
  }];
}

#endif // SCALEHLS_DIALECT_HLSCPP_STRUCTUREOPS_TD
