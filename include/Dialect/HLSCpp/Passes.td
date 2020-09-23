//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_PASSES_TD
#define SCALEHLS_DIALECT_HLSCPP_PASSES_TD

include "mlir/Pass/PassBase.td"

def QoREstimation : Pass<"hlscpp-qor-estimation", "ModuleOp"> {
  let summary = "Estimate the performance and resource utilization";
  let description = [{
    This hlscpp-qor-estimation pass will analyze the input CDFG and pragma
    operations (if applied) for estimating performance and resource utilization
    of the HLS results.
  }];

  let constructor = "mlir::scalehls::hlscpp::createQoREstimationPass()";

  let options = [
    Option<"toolConfig", "tool-config", "std::string",
           /*default=*/"\"../config/tool-config.ini\"", 
           "Config file path: global configurations for the ScaleHLS tools">,
    Option<"opLatency", "op-latency", "std::string",
           /*default=*/"\"../config/op-latency.ini\"", 
           "Config file path: profiling data for operation latency">
  ];
}

def PragmaDSE : Pass<"hlscpp-pragma-dse", "ModuleOp"> {
  let summary = "Optimize pragma configuration of each optimizable region";
  let description = [{
    This hlscpp-pragma-dse pass will automatically tune HLS pragma insertion and
    configuration for performance and area optimization. By calling methods
    provided by hlscpp-qor-estimation, this pass is able to rapidly obtain the
    QoR estimation of the current design point, and feed it back to the design
    space exploration engine for an efficient convergence.
  }];

  let constructor = "mlir::scalehls::hlscpp::createPragmaDSEPass()";
}

#endif // SCALEHLS_DIALECT_HLSCPP_PASSES_TD
