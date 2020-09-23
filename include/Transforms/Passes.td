//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

def QoREstimation : Pass<"qor-estimation", "ModuleOp"> {
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
    Option<"opLatency", "op-latency", "std::string",
           /*default=*/"\"../config/op-latency.ini\"", 
           "File path: profiling data for operation latency">
  ];
}

def PragmaDSE : Pass<"pragma-dse", "ModuleOp"> {
  let summary = "Optimize pragma configuration of each optimizable region";
  let description = [{
    This pragma-dse pass will automatically tune HLS pragma insertion and
    configuration for performance and area optimization. By calling methods
    provided by hlscpp-qor-estimation, this pass is able to rapidly obtain the
    QoR estimation of the current design point, and feed it back to the design
    space exploration engine for an efficient convergence.
  }];

  let constructor = "mlir::scalehls::createPragmaDSEPass()";
}

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
