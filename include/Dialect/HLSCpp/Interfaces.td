//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_INTERFACES_TD
#define SCALEHLS_DIALECT_HLSCPP_INTERFACES_TD

include "mlir/IR/OpBase.td"

def PragmaOpInterface : OpInterface<"PragmaOpInterface"> {
  let description = [{
    This interface indicates the operation represents one pragma directive or a
    set of pragmas.
  }];
}

#endif // SCALEHLS_DIALECT_HLSCPP_INTERFACES_TD
