//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_PASSES_TD
#define SCALEHLS_ANALYSIS_PASSES_TD

include "mlir/Pass/PassBase.td"

def QoREstimation : Pass<"qor-estimation", "FuncOp"> {
  let summary = "Estimate the performance and resource utilization";
  let description = [{
    This qor-estimation pass will analyze the input CDFG and pragma operations
    (if applied) for estimating performance and resource utilization of the HLS
    results.
  }];

  let constructor = "mlir::scalehls::createQoREstimationPass()";

  let options = [
    Option<"targetSpec", "target-spec", "std::string",
           /*default=*/"\"../config/target-spec.ini\"", 
           "File path: target backend specifications and configurations">,
  ];
}

#endif // SCALEHLS_ANALYSIS_PASSES_TD
