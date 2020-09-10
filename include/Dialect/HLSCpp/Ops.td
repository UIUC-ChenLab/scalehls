//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

include "mlir/Interfaces/SideEffectInterfaces.td"

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
