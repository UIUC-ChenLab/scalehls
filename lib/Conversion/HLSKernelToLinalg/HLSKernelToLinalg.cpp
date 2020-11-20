//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/HLSKernelToLinalg.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Dialect/HLSKernel/Visitor.h"
#include "mlir/Dialect/Linalg/IR/LinalgOps.h"
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
  bool visitOp(GemmOp op);
};
} // namespace

bool HLSKernelVisitor::visitOp(GemmOp op) {
  OpBuilder builder(op);

  auto alpha = op.getOperand(0);
  auto beta = op.getOperand(1);
  auto A = op.getOperand(2);
  auto B = op.getOperand(3);
  auto C = op.getOperand(4);

  auto CType = C.getType().cast<MemRefType>();
  auto ElementType = CType.getElementType();

  auto Cout = builder.create<mlir::AllocOp>(op.getLoc(), CType);
  op.getResult().replaceAllUsesWith(Cout);

  // Calculate beta * C and store to Cout.
  SmallVector<AffineExpr, 2> idxExprs;
  idxExprs.push_back(builder.getAffineDimExpr(0));
  idxExprs.push_back(builder.getAffineDimExpr(1));
  auto betaCMap = AffineMap::get(2, 0, idxExprs, op.getContext());

  auto betaCOp = builder.create<linalg::GenericOp>(
      op.getLoc(), ArrayRef<Value>(C), ArrayRef<Value>(Cout),
      ArrayRef<AffineMap>({betaCMap, betaCMap}),
      ArrayRef<StringRef>({"parallel", "parallel"}));

  auto betaCBlock = builder.createBlock(
      &betaCOp.getRegion(), {}, ArrayRef<Type>({ElementType, ElementType}));

  builder.setInsertionPointToStart(betaCOp.getBody());
  auto betaCResult = builder.create<mlir::MulFOp>(
      op.getLoc(), ElementType, beta, betaCBlock->getArgument(0));
  builder.create<linalg::YieldOp>(op.getLoc(), ArrayRef<Value>(betaCResult));

  // Calculate alpha * A * B and accumulate to Cout.
  builder.setInsertionPoint(op);

  idxExprs.clear();
  idxExprs.push_back(builder.getAffineDimExpr(0));
  idxExprs.push_back(builder.getAffineDimExpr(2));
  auto alphaABMapA = AffineMap::get(3, 0, idxExprs, op.getContext());

  idxExprs.clear();
  idxExprs.push_back(builder.getAffineDimExpr(2));
  idxExprs.push_back(builder.getAffineDimExpr(1));
  auto alphaABMapB = AffineMap::get(3, 0, idxExprs, op.getContext());

  idxExprs.clear();
  idxExprs.push_back(builder.getAffineDimExpr(0));
  idxExprs.push_back(builder.getAffineDimExpr(1));
  auto alphaABMapC = AffineMap::get(3, 0, idxExprs, op.getContext());

  auto alphaABOp = builder.create<linalg::GenericOp>(
      op.getLoc(), ArrayRef<Value>({A, B}), ArrayRef<Value>(Cout),
      ArrayRef<AffineMap>({alphaABMapA, alphaABMapB, alphaABMapC}),
      ArrayRef<StringRef>({"parallel", "parallel", "reduction"}));

  auto alphaABBlock = builder.createBlock(
      &alphaABOp.getRegion(), {},
      ArrayRef<Type>({ElementType, ElementType, ElementType}));

  builder.setInsertionPointToStart(alphaABOp.getBody());
  auto alphaAResult = builder.create<mlir::MulFOp>(
      op.getLoc(), ElementType, alpha, alphaABBlock->getArgument(0));
  auto alphaABResult = builder.create<mlir::MulFOp>(
      op.getLoc(), ElementType, alphaAResult, alphaABBlock->getArgument(1));
  auto result = builder.create<mlir::AddFOp>(
      op.getLoc(), ElementType, alphaABResult, alphaABBlock->getArgument(2));
  builder.create<linalg::YieldOp>(op.getLoc(), ArrayRef<Value>(result));

  return true;
}

//===----------------------------------------------------------------------===//
// HLSkernel to Linalg Lowering Pass
//===----------------------------------------------------------------------===//

namespace {
class HLSKernelToLinalgPass
    : public mlir::PassWrapper<HLSKernelToLinalgPass, OperationPass<ModuleOp>> {
public:
  void runOnOperation() override;
};
} // namespace

void HLSKernelToLinalgPass::runOnOperation() {
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

void hlskernel::registerHLSKernelToLinalgPass() {
  PassRegistration<HLSKernelToLinalgPass>(
      "hlskernel-to-linalg",
      "Lower hlskernel operations to corresponding affine representation.");
}
