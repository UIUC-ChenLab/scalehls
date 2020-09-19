//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_INTERFACES_TD
#define SCALEHLS_DIALECT_HLSCPP_INTERFACES_TD

include "mlir/IR/OpBase.td"

def PragmaOpInterface : OpInterface<"PragmaOpInterface"> {
  let description = [{
    This interface indicates the operation represents one pragma directive or a
    group of pragmas.
  }];
}

def ParameterOpInterface : OpInterface<"ParameterOpInterface"> {
  let description = [{
    This interface indicates the operation represents a group of parameters of
    its parent region.
  }];
}

#endif // SCALEHLS_DIALECT_HLSCPP_INTERFACES_TD
