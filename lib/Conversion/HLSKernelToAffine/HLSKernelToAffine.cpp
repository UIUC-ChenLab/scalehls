//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/HLSKernelToAffine.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Dialect/HLSKernel/Visitor.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Pass/Pass.h"
#include "llvm/ADT/TypeSwitch.h"

using namespace mlir;
using namespace scalehls;
using namespace hlskernel;

//===----------------------------------------------------------------------===//
// HLSKernelVisitor Class
//===----------------------------------------------------------------------===//

namespace {
class HLSKernelVisitor : public HLSKernelVisitorBase<HLSKernelVisitor, bool> {
public:
  explicit HLSKernelVisitor() {}

  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSKernelVisitorBase::visitOp;
  bool visitOp(ConvOp op);
};
} // namespace

bool HLSKernelVisitor::visitOp(ConvOp op) {
  OpBuilder builder(op);

  auto X = op.getOperand(0);
  auto W = op.getOperand(1);
  auto B = op.getOperand(2);
  auto Y = op.getResult();

  auto XShape = X.getType().cast<MemRefType>().getShape();
  auto WShape = W.getType().cast<MemRefType>().getShape();

  auto newY = builder.create<mlir::AllocOp>(op.getLoc(),
                                            Y.getType().cast<MemRefType>());
  Y.replaceAllUsesWith(newY);

  // Create batch loop.
  auto gLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, XShape[0]);
  builder.setInsertionPointToStart(&gLoop.getLoopBody().front());
  auto g = gLoop.getInductionVar();

  // Create feature map height loop.
  auto hLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, XShape[2]);
  builder.setInsertionPointToStart(&hLoop.getLoopBody().front());
  auto h = hLoop.getInductionVar();

  // Create feature map width loop.
  auto wLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, XShape[3]);
  builder.setInsertionPointToStart(&wLoop.getLoopBody().front());
  auto w = wLoop.getInductionVar();

  // Create kernel number loop.
  auto kLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, WShape[0]);
  builder.setInsertionPointToStart(&kLoop.getLoopBody().front());
  auto k = kLoop.getInductionVar();

  // Load bias into newY array.
  auto bias = builder.create<mlir::AffineLoadOp>(op.getLoc(), B, k);
  builder.create<mlir::AffineStoreOp>(op.getLoc(), bias, newY,
                                      ArrayRef<Value>({g, k, h, w}));

  // Create channel number loop.
  auto cLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, WShape[1]);
  builder.setInsertionPointToStart(&cLoop.getLoopBody().front());
  auto c = cLoop.getInductionVar();

  // Create kernel height loop.
  auto rLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, WShape[2]);
  builder.setInsertionPointToStart(&rLoop.getLoopBody().front());
  auto r = rLoop.getInductionVar();

  // Create kernel width loop.
  auto sLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, WShape[3]);
  builder.setInsertionPointToStart(&sLoop.getLoopBody().front());
  auto s = sLoop.getInductionVar();

  // Fetch feature map.
  SmallVector<AffineExpr, 4> idxExprs;
  idxExprs.push_back(builder.getAffineDimExpr(0));
  idxExprs.push_back(builder.getAffineDimExpr(1));
  idxExprs.push_back(builder.getAffineDimExpr(2) + builder.getAffineDimExpr(4));
  idxExprs.push_back(builder.getAffineDimExpr(3) + builder.getAffineDimExpr(5));
  auto fmap = builder.create<mlir::AffineLoadOp>(
      op.getLoc(), X, AffineMap::get(6, 0, idxExprs, op.getContext()),
      ArrayRef<Value>({g, c, h, w, r, s}));

  // Fetch weight and carry out multiplication.
  auto weight = builder.create<mlir::AffineLoadOp>(
      op.getLoc(), W, ArrayRef<Value>({k, c, r, s}));
  auto multi =
      builder.create<mlir::MulFOp>(op.getLoc(), fmap.getType(), fmap, weight);

  // Fetch partial result and carry out accumulation.
  auto partial = builder.create<mlir::AffineLoadOp>(
      op.getLoc(), newY, ArrayRef<Value>({g, k, h, w}));
  auto accum =
      builder.create<mlir::AddFOp>(op.getLoc(), fmap.getType(), partial, multi);
  builder.create<mlir::AffineStoreOp>(op.getLoc(), accum, newY,
                                      ArrayRef<Value>({g, k, h, w}));

  return true;
}

//===----------------------------------------------------------------------===//
// HLSkernel to Affine Lowering Pass
//===----------------------------------------------------------------------===//

namespace {
class HLSKernelToAffinePass
    : public mlir::PassWrapper<HLSKernelToAffinePass, OperationPass<ModuleOp>> {
public:
  void runOnOperation() override;
};
} // namespace

void HLSKernelToAffinePass::runOnOperation() {
  HLSKernelVisitor visitor;

  for (auto &op : getOperation()) {
    if (auto func = dyn_cast<FuncOp>(op)) {
      func.walk([&](HLSKernelOpInterface kernelOp) {
        if (visitor.dispatchVisitor(kernelOp))
          kernelOp.erase();
        else
          kernelOp.emitError("can't be correctly lowered.");
      });
    } else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("is unsupported operation.");
  }
}

void hlskernel::registerHLSKernelToAffinePass() {
  PassRegistration<HLSKernelToAffinePass>(
      "hlskernel-to-affine",
      "Lower hlskernel operations to corresponding affine representation.");
}
