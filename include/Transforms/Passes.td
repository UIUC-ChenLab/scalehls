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
    This affine-loop-perfection pass will try to perfect all affine loops.
    Specifically, this pass will move operations under non-innermost loops into
    innermost loop and create affine if regions to ensure the correctness of the
    movement.
  }];

  let constructor = "mlir::scalehls::createAffineLoopPerfectionPass()";
}

def PartialAffineLoopTile : Pass<"partial-affine-loop-tile", "ModuleOp"> {
  let summary = "Try to perfect a nested loop";
  let description = [{
    This partial-affine-loop-tile pass will try to tile the nested loops. The
    difference with the official affine-loop-tile pass is this pass will only
    tile the first "tileLevel" outermost loop levels rather than all loops
    levels.
  }];

  let constructor = "mlir::scalehls::createPartialAffineLoopTilePass()";

    let options = [
    Option<"tileLevel", "tile-level", "unsigned", /*default=*/"1", 
           "Positive number: the level of loops to be tiles">,
    Option<"tileSize", "tile-size", "unsigned", /*default=*/"2", 
           "Positive number: the size of tiling">
  ];
}

#endif // SCALEHLS_TRANSFORMS_PASSES_TD
