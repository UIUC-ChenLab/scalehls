//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLSCPP_PASSES_TD
#define SCALEHLS_DIALECT_HLSCPP_PASSES_TD

include "mlir/Pass/PassBase.td"

def StaticAnalysis : Pass<"hlscpp-static-analysis", "ModuleOp"> {
  let summary = "Analyze CDFG and generate parameters for QoR estimation";
  let description = [{
    This hlscpp-static-analysis pass will analyze the input CDFG and insert
    HLSCpp parameter operations for each function, loop, and other regions. The
    extracted parameters will then be passed to QoREstimation for estimating
    quality of results.
  }];

  let constructor = "mlir::scalehls::hlscpp::createStaticAnalysisPass()";
}

def QoREstimation : Pass<"hlscpp-qor-estimation", "ModuleOp"> {
  let summary = "Estimate the performance and resource utilization";
  let description = [{
    This hlscpp-qor-estimation pass will take HLSCpp parameter operations inside
    of each function, loop, and other regions into consideration and estimate
    performance and resource utilization of the HLS results.
  }];

  let constructor = "mlir::scalehls::hlscpp::createQoREstimationPass()";
}

def ParallelOpt : Pass<"hlscpp-parallel-opt", "ModuleOp"> {
  let summary = "Optimize parallel strategy of each optimizable region";
  let description = [{
    This hlscpp-parallel-opt pass will automatically tune HLS parallel strategy
    of each optimizable region for performance and area opt. By calling methods
    provided by hlscpp-qor-estimation, this pass is able to rapidly obtain the
    QoR estimation of the current design point, and feed it back to the design
    space exploration engine for an efficient convergence.
  }];

  let constructor = "mlir::scalehls::hlscpp::createParallelOptPass()";
}

def PragmaInsertion : Pass<"hlscpp-pragma-insertion", "ModuleOp"> {
  let summary = "Insert HLS pragmas according to optimization results";
  let description = [{
    This hlscpp-pragma-insertion pass will insert HLSCpp pragma operations
    according to the results of hlscpp-parallel-opt.
  }];

  let constructor = "mlir::scalehls::hlscpp::createPragmaInsertionPass()";
}

#endif // SCALEHLS_DIALECT_HLSCPP_PASSES_TD
