//===-------------------------------------------------------*- tablegen -*-===//
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_PASSES_TD
#define SCALEHLS_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

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

def AffineLoopPerfection : Pass<"affine-loop-perfection", "ModuleOp"> {
  let summary = "Try to perfect a nested loop";
  let description = [{
    This affine-loop-perfection pass will try to perfect affine loops.
    Specifically, this pass will move operations under non-innermost loops into
    innermost loop and create an affine if region to ensure the correctness of
    the transformation.
  }];

  let constructor = "mlir::scalehls::createAffineLoopPerfectionPass()";
}

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
