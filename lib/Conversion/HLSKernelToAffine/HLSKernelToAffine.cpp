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
  explicit HLSKernelVisitor(OpBuilder &builder, Location loc)
      : builder(builder), loc(loc) {}

  bool visitInvaliddOp(Operation *op) { return false; }
  bool visitUnhandledOp(Operation *op) { return true; }

  using HLSKernelVisitorBase::visitOp;
  bool visitOp(DenseOp op);
  bool visitOp(ConvOp op);
  bool visitOp(MaxPoolOp op);
  bool visitOp(ReluOp op);
  bool visitOp(MergeOp op);

private:
  OpBuilder &builder;
  Location loc;

  // Helpers for creating loops, loads, stores and binary operations.
  Value createLoop(unsigned upper, unsigned step = 1, unsigned lower = 0) {
    auto loop = builder.create<mlir::AffineForOp>(loc, lower, upper, step);
    builder.setInsertionPointToStart(&loop.getLoopBody().front());
    return loop.getInductionVar();
  }

  Value createLoad(Value array, std::initializer_list<Value> index) {
    return builder.create<mlir::AffineLoadOp>(loc, array,
                                              ArrayRef<Value>(index));
  }

  void createStore(Value valToStore, Value array,
                   std::initializer_list<Value> index) {
    builder.create<mlir::AffineStoreOp>(loc, valToStore, array,
                                        ArrayRef<Value>(index));
  }

  template <typename OpType>
  Value createBinaryOp(Value lhs, Value rhs, Type resultType = nullptr) {
    if (!resultType) {
      return builder.create<OpType>(loc, lhs.getType(), lhs, rhs);
    } else {
      return builder.create<OpType>(loc, resultType, lhs, rhs);
    }
  }

  // Helpers for getting dimension or constant affine expression.
  AffineExpr getDim(unsigned pos) { return builder.getAffineDimExpr(pos); }
  AffineExpr getConst(int64_t val) {
    return builder.getAffineConstantExpr(val);
  }
};
} // namespace

bool HLSKernelVisitor::visitOp(DenseOp op) {
  auto I = op.getOperand(0);
  auto K = op.getOperand(1);
  auto B = op.getOperand(2);
  auto O = op.getOperand(3);

  auto KShape = K.getType().cast<MemRefType>().getShape();
  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create batch loop.
  auto n = createLoop(OShape[0]);

  // Create output channel loop.
  auto f = createLoop(KShape[0]);

  // Load bias into O array.
  auto bias = createLoad(B, {f});
  createStore(bias, O, {n, f});

  // Create input channel loop.
  auto c = createLoop(KShape[1]);

  // Fetch feature map, kernel and carry out multiplication.
  auto fmap = createLoad(I, {n, c});
  auto kernel = createLoad(K, {f, c});
  auto mult = createBinaryOp<mlir::MulFOp>(fmap, kernel);

  // Fetch partial result and carry out accumulation.
  auto partial = createLoad(O, {n, f});
  auto accum = createBinaryOp<mlir::AddFOp>(partial, mult);
  createStore(accum, O, {n, f});

  return true;
}

/// Padding and strides has not been suppored.
bool HLSKernelVisitor::visitOp(ConvOp op) {
  auto I = op.getOperand(0);
  auto K = op.getOperand(1);
  auto B = op.getOperand(2);
  auto O = op.getOperand(3);

  auto KShape = K.getType().cast<MemRefType>().getShape();
  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create batch loop.
  auto n = createLoop(OShape[0]);

  // Create feature map height loop.
  auto h = createLoop(OShape[2]);

  // Create feature map width loop.
  auto w = createLoop(OShape[3]);

  // Create filter number loop.
  auto f = createLoop(KShape[0]);

  // Load bias into newY array.
  auto bias = createLoad(B, {f});
  createStore(bias, O, {n, f, h, w});

  // Create channel number loop.
  auto c = createLoop(KShape[1]);

  // Create kernel height loop.
  auto r = createLoop(KShape[2]);

  // Create kernel width loop.
  auto s = createLoop(KShape[3]);

  // Fetch feature map.
  SmallVector<AffineExpr, 4> indexExprs;
  indexExprs.push_back(getDim(0));
  indexExprs.push_back(getDim(1));
  indexExprs.push_back(getDim(2) + getDim(4));
  indexExprs.push_back(getDim(3) + getDim(5));
  auto fmap = builder.create<mlir::AffineLoadOp>(
      op.getLoc(), I, AffineMap::get(6, 0, indexExprs, op.getContext()),
      ArrayRef<Value>({n, c, h, w, r, s}));

  // Fetch weight and carry out multiplication.
  auto kernel = createLoad(K, {f, c, r, s});
  auto multi = createBinaryOp<mlir::MulFOp>(fmap, kernel);

  // Fetch partial result and carry out accumulation.
  auto partial = createLoad(O, {n, f, h, w});
  auto accum = createBinaryOp<mlir::AddFOp>(partial, multi);
  createStore(accum, O, {n, f, h, w});

  return true;
}

// Padding and strides has not been suppored. Only support when kernel size is
// equal to stride size.
bool HLSKernelVisitor::visitOp(MaxPoolOp op) {
  SmallVector<int64_t, 2> kernelShape;
  for (auto shape : op.getAttrOfType<ArrayAttr>("kernel_shape"))
    kernelShape.push_back(shape.cast<IntegerAttr>().getInt());

  auto I = op.getOperand(0);
  auto O = op.getOperand(1);

  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create batch loop.
  auto n = createLoop(OShape[0]);

  // Create height loop.
  auto h = createLoop(OShape[2]);

  // Create width loop.
  auto w = createLoop(OShape[3]);

  // Create channel loop.
  auto c = createLoop(OShape[1]);

  // Set largest value as zero.
  auto dataType = O.getType().cast<MemRefType>().getElementType();
  auto zeroConst = builder.create<mlir::ConstantOp>(
      op.getLoc(), builder.getZeroAttr(dataType));
  createStore(zeroConst, O, {h, c, h, w});

  // Create kernel height loop.
  auto r = createLoop(kernelShape[0]);

  // Create kernel width loop.
  auto s = createLoop(kernelShape[1]);

  // Fetch feature map.
  SmallVector<AffineExpr, 4> indexExprs;
  indexExprs.push_back(getDim(0));
  indexExprs.push_back(getDim(1));
  indexExprs.push_back(getDim(2) * getConst(kernelShape[0]) + getDim(4));
  indexExprs.push_back(getDim(3) * getConst(kernelShape[1]) + getDim(5));
  auto fmap = builder.create<mlir::AffineLoadOp>(
      op.getLoc(), I, AffineMap::get(6, 0, indexExprs, op.getContext()),
      ArrayRef<Value>({n, c, h, w, r, s}));

  // Carry out comparison.
  auto tmpGreatest = createLoad(O, {n, c, h, w});
  auto greaterThanTmp = builder.create<mlir::CmpFOp>(
      op.getLoc(), CmpFPredicate::OGT, fmap, tmpGreatest);

  // Carry out selection and store the greater value.
  auto newGreatest = builder.create<mlir::SelectOp>(op.getLoc(), greaterThanTmp,
                                                    fmap, tmpGreatest);
  createStore(newGreatest, O, {h, c, h, w});

  return true;
}

bool HLSKernelVisitor::visitOp(ReluOp op) {
  auto I = op.getOperand(0);
  auto O = op.getOperand(1);

  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create batch loop.
  auto n = createLoop(OShape[0]);

  // Create height loop.
  auto h = createLoop(OShape[2]);

  // Create width loop.
  auto w = createLoop(OShape[3]);

  // Create channel loop.
  auto c = createLoop(OShape[1]);

  // Load original value from input array.
  auto fmap = createLoad(I, {n, c, h, w});

  // Carry out comparison.
  auto zeroConstant = builder.create<mlir::ConstantOp>(
      op.getLoc(), builder.getZeroAttr(fmap.getType()));
  auto greaterThanZero = builder.create<mlir::CmpFOp>(
      op.getLoc(), CmpFPredicate::OGT, fmap, zeroConstant);

  // Carry out selection and store the activation.
  auto activ = builder.create<mlir::SelectOp>(op.getLoc(), greaterThanZero,
                                              fmap, zeroConstant);
  createStore(activ, O, {n, c, h, w});

  return true;
}

bool HLSKernelVisitor::visitOp(MergeOp op) {
  auto I0 = op.getOperand(0);
  auto I1 = op.getOperand(1);
  auto O = op.getOperand(2);

  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create batch loop.
  auto n = createLoop(OShape[0]);

  // Create height loop.
  auto h = createLoop(OShape[2]);

  // Create width loop.
  auto w = createLoop(OShape[3]);

  // Create channel loop.
  auto c = createLoop(OShape[1]);

  // Load original value from input array.
  auto fmap0 = createLoad(I0, {n, c, h, w});
  auto fmap1 = createLoad(I1, {n, c, h, w});

  // Carry out add and store the result.
  auto result = createBinaryOp<mlir::AddFOp>(fmap0, fmap1);
  createStore(result, O, {n, c, h, w});

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
  auto module = getOperation();
  OpBuilder builder(module);
  HLSKernelVisitor visitor(builder, module.getLoc());

  for (auto &op : module) {
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
