//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Dialect/HLSCpp/Passes.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct PragmaInsertion : public PragmaInsertionBase<PragmaInsertion> {
  void runOnOperation() override;
};
} // namespace

void PragmaInsertion::runOnOperation() {
  auto module = getOperation();
  for (auto &func : module) {
    if (auto funcOp = dyn_cast<FuncOp>(func)) {
      if (funcOp.getBlocks().size() != 1)
        funcOp.emitError("has more than one basic blocks");

      for (auto &op : funcOp.getBlocks().front()) {
        if (auto forOp = dyn_cast<mlir::AffineForOp>(op)) {
          Block &loopBody = forOp.getLoopBody().front();
          auto builder = OpBuilder(&loopBody, loopBody.begin());

          auto applyOp = builder.create<hlscpp::ApplyPragmasOp>(forOp.getLoc());
          auto applyBuilder = applyOp.getBodyBuilder();

          applyBuilder.create<hlscpp::PragmaPipelineOp>(
              applyOp.getLoc(), /*II=*/APInt(32, 1), /*enable_flush=*/false,
              /*rewind=*/false, /*off=*/false);
          applyBuilder.create<hlscpp::PragmaUnrollOp>(
              applyOp.getLoc(), /*factor=*/APInt(32, 2), /*region=*/false,
              /*skip_exit_check=*/false);
        }
        if (auto allocOp = dyn_cast<mlir::AllocOp>(op)) {
          auto builder = OpBuilder(&op);
          builder.setInsertionPointAfter(&op);
          builder.create<hlscpp::PragmaArrayPartitionOp>(
              allocOp.getLoc(), /*variable=*/allocOp.getResult(),
              /*type=*/"complete", /*factor=*/APInt(32, 2),
              /*dim=*/APInt(32, 0));
        }
      }
    }
  }
}

std::unique_ptr<mlir::Pass>
mlir::scalehls::hlscpp::createPragmaInsertionPass() {
  return std::make_unique<PragmaInsertion>();
}
