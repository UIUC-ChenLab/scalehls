//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_ANALYSIS_PASSES_TD
#define SCALEHLS_ANALYSIS_PASSES_TD

include "mlir/Pass/PassBase.td"

def QoREstimation : Pass<"qor-estimation", "ModuleOp"> {
  let summary = "Estimate the performance and resource utilization";
  let description = [{
    This qor-estimation pass will analyze the input IR and estimate the latency
    and resource utilization of HLS C++ synthesis. This pass will take all
    dependency and resource constraints and pragma settings into consideration,
    and conduct the estimation through an ALAP scheduling.
  }];

  let constructor = "mlir::scalehls::createQoREstimationPass()";

  let options = [
    Option<"targetSpec", "target-spec", "std::string",
           /*default=*/"\"../config/target-spec.ini\"",
           "File path: target backend specifications and configurations">
  ];
}

def ProfileDesignSpace : Pass<"profile-design-space", "ModuleOp"> {
  let summary = "Optimize HLS design at multiple abstraction level";
  let description = [{
    This profile-design-space pass will profile the partial design space and
    output clock cycle and resource utilization estimation results.
  }];

  let constructor = "mlir::scalehls::createProfileDesignSpacePass()";

  let options = [
    Option<"targetSpec", "target-spec", "std::string",
           /*default=*/"\"../config/target-spec.ini\"",
           "File path: target backend specifications and configurations">,
    Option<"profilingFile", "profiling-file", "std::string",
           /*default=*/"\"-\"", "File path: the output file path of profiling">,
    Option<"maxParallel", "max-parallel", "unsigned", /*default=*/"1",
           "Positive number: the maximum tiling parallelism of the profiling">
  ];
}


#endif // SCALEHLS_ANALYSIS_PASSES_TD
