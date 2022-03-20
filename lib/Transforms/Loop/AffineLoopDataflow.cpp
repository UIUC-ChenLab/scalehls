//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/LoopUtils.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct AffineLoopDataflow : public AffineLoopDataflowBase<AffineLoopDataflow> {
  AffineLoopDataflow() = default;
  AffineLoopDataflow(unsigned dataflowGran, bool dataflowBalance) {
    gran = dataflowGran;
    balance = dataflowBalance;
  }

  void runOnOperation() override {
    auto module = getOperation();

    // Dataflow each function in the module.
    for (auto func : llvm::make_early_inc_range(module.getOps<FuncOp>())) {
      // Collect all target loop bands.
      AffineLoopBands targetBands;
      getLoopBands(func.front(), targetBands, /*allowHavingChilds=*/true);

      // Apply loop dataflow to each innermost loop that has more than one
      // child loops.
      for (auto &band : targetBands)
        if (getChildLoopNum(band.back()) > 1)
          applyDataflow(*band.back().getBody(), gran, balance);
    }
  }
};
} // namespace

std::unique_ptr<Pass>
scalehls::createAffineLoopDataflowPass(unsigned dataflowGran,
                                       bool dataflowBalance) {
  return std::make_unique<AffineLoopDataflow>(dataflowGran, dataflowBalance);
}
