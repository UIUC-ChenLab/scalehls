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

  bool visitInvaliddOp(Operation *op) { return false; }
  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSKernelVisitorBase::visitOp;
  bool visitOp(ConvOp op);
  bool visitOp(MaxPoolOp op);
  bool visitOp(ReluOp op);
  bool visitOp(DenseOp op);
};
} // namespace

/// Padding is not suppored.
bool HLSKernelVisitor::visitOp(ConvOp op) {
  OpBuilder builder(op);

  auto X = op.getOperand(0);
  auto W = op.getOperand(1);
  auto B = op.getOperand(2);
  auto Y = op.getResult();

  auto WShape = W.getType().cast<MemRefType>().getShape();
  auto YShape = Y.getType().cast<MemRefType>().getShape();

  auto newY = builder.create<mlir::AllocOp>(op.getLoc(),
                                            Y.getType().cast<MemRefType>());
  Y.replaceAllUsesWith(newY);

  // Create batch loop.
  auto gLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[0]);
  builder.setInsertionPointToStart(&gLoop.getLoopBody().front());
  auto g = gLoop.getInductionVar();

  // Create feature map height loop.
  auto hLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[2]);
  builder.setInsertionPointToStart(&hLoop.getLoopBody().front());
  auto h = hLoop.getInductionVar();

  // Create feature map width loop.
  auto wLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[3]);
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

// Only support when kernel size is equal to stride size.
bool HLSKernelVisitor::visitOp(MaxPoolOp op) {
  OpBuilder builder(op);

  SmallVector<int64_t, 2> kernelShape;
  for (auto shape : op.getAttrOfType<ArrayAttr>("kernel_shape"))
    kernelShape.push_back(shape.cast<IntegerAttr>().getInt());

  auto X = op.getOperand();
  auto Y = op.getResult();

  auto YShape = Y.getType().cast<MemRefType>().getShape();
  auto dataType = Y.getType().cast<MemRefType>().getElementType();

  auto newY = builder.create<mlir::AllocOp>(op.getLoc(),
                                            Y.getType().cast<MemRefType>());
  Y.replaceAllUsesWith(newY);

  // Create batch loop.
  auto gLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[0]);
  builder.setInsertionPointToStart(&gLoop.getLoopBody().front());
  auto g = gLoop.getInductionVar();

  // Create channel loop.
  auto cLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[1]);
  builder.setInsertionPointToStart(&cLoop.getLoopBody().front());
  auto c = cLoop.getInductionVar();

  // Create height loop.
  auto hLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[2]);
  builder.setInsertionPointToStart(&hLoop.getLoopBody().front());
  auto h = hLoop.getInductionVar();

  // Create width loop.
  auto wLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[3]);
  builder.setInsertionPointToStart(&wLoop.getLoopBody().front());
  auto w = wLoop.getInductionVar();

  // Set largest value as zero.
  auto zeroConstant = builder.create<mlir::ConstantOp>(
      op.getLoc(), builder.getZeroAttr(dataType));
  builder.create<mlir::AffineStoreOp>(op.getLoc(), zeroConstant, newY,
                                      ArrayRef<Value>({g, c, h, w}));

  // Create kernel height loop.
  auto rLoop =
      builder.create<mlir::AffineForOp>(op.getLoc(), 0, kernelShape[0]);
  builder.setInsertionPointToStart(&rLoop.getLoopBody().front());
  auto r = rLoop.getInductionVar();

  // Create kernel width loop.
  auto sLoop =
      builder.create<mlir::AffineForOp>(op.getLoc(), 0, kernelShape[1]);
  builder.setInsertionPointToStart(&sLoop.getLoopBody().front());
  auto s = sLoop.getInductionVar();

  // Fetch feature map.
  SmallVector<AffineExpr, 4> idxExprs;
  idxExprs.push_back(builder.getAffineDimExpr(0));
  idxExprs.push_back(builder.getAffineDimExpr(1));
  idxExprs.push_back(builder.getAffineDimExpr(2) *
                         builder.getAffineConstantExpr(kernelShape[0]) +
                     builder.getAffineDimExpr(4));
  idxExprs.push_back(builder.getAffineDimExpr(3) *
                         builder.getAffineConstantExpr(kernelShape[1]) +
                     builder.getAffineDimExpr(5));
  auto fmap = builder.create<mlir::AffineLoadOp>(
      op.getLoc(), X, AffineMap::get(6, 0, idxExprs, op.getContext()),
      ArrayRef<Value>({g, c, h, w, r, s}));

  // Fetch current greatest value.
  auto tmpGreatest = builder.create<mlir::AffineLoadOp>(
      op.getLoc(), newY, ArrayRef<Value>({g, c, h, w}));
  auto greaterThanTmp = builder.create<mlir::CmpFOp>(
      op.getLoc(), CmpFPredicate::OGT, fmap, tmpGreatest);

  auto newGreatest = builder.create<mlir::SelectOp>(op.getLoc(), greaterThanTmp,
                                                    fmap, tmpGreatest);

  // Store back the greater value.
  builder.create<mlir::AffineStoreOp>(op.getLoc(), newGreatest, newY,
                                      ArrayRef<Value>({g, c, h, w}));

  return true;
}

bool HLSKernelVisitor::visitOp(ReluOp op) {
  OpBuilder builder(op);

  auto X = op.getOperand();
  auto Y = op.getResult();

  auto YShape = Y.getType().cast<MemRefType>().getShape();

  auto newY = builder.create<mlir::AllocOp>(op.getLoc(),
                                            Y.getType().cast<MemRefType>());
  Y.replaceAllUsesWith(newY);

  // Create batch loop.
  auto gLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[0]);
  builder.setInsertionPointToStart(&gLoop.getLoopBody().front());
  auto g = gLoop.getInductionVar();

  // Create channel loop.
  auto cLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[1]);
  builder.setInsertionPointToStart(&cLoop.getLoopBody().front());
  auto c = cLoop.getInductionVar();

  // Create height loop.
  auto hLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[2]);
  builder.setInsertionPointToStart(&hLoop.getLoopBody().front());
  auto h = hLoop.getInductionVar();

  // Create width loop.
  auto wLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[3]);
  builder.setInsertionPointToStart(&wLoop.getLoopBody().front());
  auto w = wLoop.getInductionVar();

  // Load original value from input array.
  auto fmap = builder.create<mlir::AffineLoadOp>(op.getLoc(), X,
                                                 ArrayRef<Value>({g, c, h, w}));

  // Carry out activation.
  auto zeroConstant = builder.create<mlir::ConstantOp>(
      op.getLoc(), builder.getZeroAttr(fmap.getType()));
  auto greaterThanZero = builder.create<mlir::CmpFOp>(
      op.getLoc(), CmpFPredicate::OGT, fmap, zeroConstant);

  auto activ = builder.create<mlir::SelectOp>(op.getLoc(), greaterThanZero,
                                              fmap, zeroConstant);

  // Store back the activations.
  builder.create<mlir::AffineStoreOp>(op.getLoc(), activ, newY,
                                      ArrayRef<Value>({g, c, h, w}));

  return true;
}

bool HLSKernelVisitor::visitOp(DenseOp op) {
  OpBuilder builder(op);

  auto X = op.getOperand(0);
  auto W = op.getOperand(1);
  auto B = op.getOperand(2);
  auto Y = op.getResult();

  auto WShape = W.getType().cast<MemRefType>().getShape();
  auto YShape = Y.getType().cast<MemRefType>().getShape();

  auto newY = builder.create<mlir::AllocOp>(op.getLoc(),
                                            Y.getType().cast<MemRefType>());
  Y.replaceAllUsesWith(newY);

  // Create batch loop.
  auto gLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, YShape[0]);
  builder.setInsertionPointToStart(&gLoop.getLoopBody().front());
  auto g = gLoop.getInductionVar();

  // Create output channel loop.
  auto kLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, WShape[0]);
  builder.setInsertionPointToStart(&kLoop.getLoopBody().front());
  auto k = kLoop.getInductionVar();

  // Load bias into newY array.
  auto bias = builder.create<mlir::AffineLoadOp>(op.getLoc(), B, k);
  builder.create<mlir::AffineStoreOp>(op.getLoc(), bias, newY,
                                      ArrayRef<Value>({g, k}));

  // Create input channel loop.
  auto cLoop = builder.create<mlir::AffineForOp>(op.getLoc(), 0, WShape[1]);
  builder.setInsertionPointToStart(&cLoop.getLoopBody().front());
  auto c = cLoop.getInductionVar();

  // Fetch feature map, weight and carry out multiplication.
  auto fmap = builder.create<mlir::AffineLoadOp>(op.getLoc(), X,
                                                 ArrayRef<Value>({g, c}));
  auto weight = builder.create<mlir::AffineLoadOp>(op.getLoc(), W,
                                                   ArrayRef<Value>({k, c}));
  auto multi =
      builder.create<mlir::MulFOp>(op.getLoc(), fmap.getType(), fmap, weight);

  // Fetch partial result and carry out accumulation.
  auto partial = builder.create<mlir::AffineLoadOp>(op.getLoc(), newY,
                                                    ArrayRef<Value>({g, k}));
  auto accum =
      builder.create<mlir::AddFOp>(op.getLoc(), fmap.getType(), partial, multi);
  builder.create<mlir::AffineStoreOp>(op.getLoc(), accum, newY,
                                      ArrayRef<Value>({g, k}));

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
        if (visitor.dispatchVisitor(kernelOp)) {
          kernelOp.erase();
        } else
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
