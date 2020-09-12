//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_OPS_TD
#define SCALEHLS_DIALECT_HLSCPP_OPS_TD

include "Interfaces.td"
include "mlir/Interfaces/SideEffectInterfaces.td"

def HLSCppApplyPragmasOp : HLSCppOp<"apply_pragmas",
    [NoSideEffect, PragmaOpInterface]> {
  let summary = "apply_pragmas operation";
  let description = [{
    This hlscpp.apply_pragmas operation owns one region containing one or more
    concrete pragmas, and applies all of them to its parent operation (e.g.,
    functions, loops, or other regions). This operation should always be
    inserted to the front of its parent operation.

    This operations takes nothing and returns nothing.
  }];

  let regions = (region SizedRegion<1> : $pragmaRegion);
}



def HLSCppFooOp : HLSCppOp<"foo", [NoSideEffect, SameOperandsAndResultType]> {
  let summary = "Illustrates how to define an operation.";
  let description = [{
    The `hlscpp.foo` operation illustrates how to define a new operation in a
    dialect.

    This operation takes an integer argument and returns an integer.

    Example:

    ```mlir
    %0 = constant 2 : i32
    // Apply the foo operation to %0
    %1 = hlscpp.foo %0 : i32
    ```
  }];

  let arguments = (ins I32:$input);
  let results = (outs I32:$res);

  let assemblyFormat = [{
    $input attr-dict `:` type($input)
  }];
}

#endif // SCALEHLS_DIALECT_HLSCPP_OPS_TD
