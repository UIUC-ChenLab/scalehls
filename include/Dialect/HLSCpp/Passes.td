//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_PASSES_TD
#define SCALEHLS_DIALECT_HLSCPP_PASSES_TD

include "mlir/Pass/PassBase.td"

def PragmaInsertion : Pass<"hlscpp-pragma-insertion", "ModuleOp"> {
  let summary = "Insert HLS pragmas for performance and area optimization.";
  let description = [{
    This hlscpp-pragma-insertion pass will automatically insert HLS pragmas into
    the input IR for performance and area optimization. By calling methods
    provided by EstimateQoR, this pass is able to rapidly feedback the QoR of
    the current design point to the design space exploration engine for an
    efficient optimization convergence.
  }];

  let constructor = "mlir::scalehls::hlscpp::createPragmaInsertionPass()";
}

#endif // SCALEHLS_DIALECT_HLSCPP_PASSES_TD
