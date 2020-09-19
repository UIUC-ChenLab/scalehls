//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Dialect/HLSCpp/HLSCpp.h"
#include "Dialect/HLSCpp/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

namespace {
struct PragmaInsertion : public PragmaInsertionBase<PragmaInsertion> {
  void runOnOperation() override;
};
} // namespace

void PragmaInsertion::runOnOperation() {
  for (auto &funcOp : getOperation()) {
    if (auto func = dyn_cast<FuncOp>(funcOp)) {
      if (func.getBlocks().size() != 1)
        func.emitError("has zero or more than one basic blocks");

      for (auto &op : func.front()) {
        if (auto forOp = dyn_cast<mlir::AffineForOp>(op)) {
          Block &loopBody = forOp.getLoopBody().front();
          auto builder = OpBuilder(&loopBody, loopBody.begin());

          auto applyOp = builder.create<hlscpp::ApplyPragmasOp>(forOp.getLoc());
          auto applyBuilder = applyOp.getBodyBuilder();

          applyBuilder.create<hlscpp::PragmaPipelineOp>(
              applyOp.getLoc(), /*II=*/APInt(32, 1), /*enable_flush=*/true,
              /*rewind=*/true, /*off=*/true);
          applyBuilder.create<hlscpp::PragmaUnrollOp>(
              applyOp.getLoc(), /*factor=*/APInt(32, 2), /*region=*/false,
              /*skip_exit_check=*/true);
        }
        if (auto allocOp = dyn_cast<mlir::AllocOp>(op)) {
          auto builder = OpBuilder(allocOp);
          builder.setInsertionPointAfter(allocOp);
          builder.create<hlscpp::PragmaArrayPartitionOp>(
              allocOp.getLoc(), /*variable=*/allocOp.getResult(),
              /*type=*/"cyclic", /*factor=*/APInt(32, 2),
              /*dim=*/APInt(32, 0));
        }
      }
    }
  }
}

std::unique_ptr<mlir::Pass> hlscpp::createPragmaInsertionPass() {
  return std::make_unique<PragmaInsertion>();
}
