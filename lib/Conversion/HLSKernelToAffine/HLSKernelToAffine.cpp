//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/HLSKernelToAffine.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Dialect/HLSKernel/Visitor.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/IntegerSet.h"
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

  bool visitOp(GemmOp op);
  bool visitOp(SymmOp op);
  bool visitOp(SyrkOp op);
  bool visitOp(Syr2kOp op);
  bool visitOp(TrmmOp op);

private:
  OpBuilder &builder;
  Location loc;

  // Helpers for creating loops.
  // Constant upper and lower bound.
  Value createLoop(int64_t lower, int64_t upper, int64_t step = 1) {
    auto loop = builder.create<mlir::AffineForOp>(loc, lower, upper, step);
    builder.setInsertionPointToStart(&loop.getLoopBody().front());
    return loop.getInductionVar();
  }

  // General case.
  Value createLoop(std::initializer_list<Value> lower, AffineMap lowerMap,
                   std::initializer_list<Value> upper, AffineMap upperMap,
                   int64_t step = 1) {
    auto loop = builder.create<mlir::AffineForOp>(loc, lower, lowerMap, upper,
                                                  upperMap, step);
    builder.setInsertionPointToStart(&loop.getLoopBody().front());
    return loop.getInductionVar();
  }

  Value createLoop(Value lower, Value upper, int64_t step = 1) {
    auto indexMap = AffineMap::get(1, 0, getDim(0));
    return createLoop({lower}, indexMap, {upper}, indexMap);
  }

  Value createLoop(Value lower, int64_t upper, int64_t step = 1) {
    auto lowerMap = AffineMap::get(1, 0, getDim(0));
    auto upperMap = AffineMap::get(0, 0, getConst(upper));
    return createLoop({lower}, lowerMap, {}, upperMap);
  }

  Value createLoop(int64_t lower, Value upper, int64_t step = 1) {
    auto lowerMap = AffineMap::get(0, 0, getConst(lower));
    auto upperMap = AffineMap::get(1, 0, getDim(0));
    return createLoop({}, lowerMap, {upper}, upperMap);
  }

  // Helpers for creating constant, loads, stores and binary operations.
  Value createConst(int64_t val, Type valType) {
    if (valType.isa<IntegerType>())
      return builder.create<mlir::ConstantOp>(
          loc, valType, builder.getIntegerAttr(valType, val));
    else if (valType.isa<FloatType>())
      return builder.create<mlir::ConstantOp>(
          loc, valType, builder.getFloatAttr(valType, val));
    else if (valType.isa<IndexType>())
      return builder.create<mlir::ConstantOp>(loc, valType,
                                              builder.getIndexAttr(val));
    else {
      assert("unsupported value type when creating constant operation");
      return nullptr;
    }
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

//===----------------------------------------------------------------------===//
// CNNOps Handler
//===----------------------------------------------------------------------===//

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
  auto n = createLoop(0, OShape[0]);

  // Create output channel loop.
  auto f = createLoop(0, KShape[0]);

  // Load bias into O array.
  auto bias = createLoad(B, {f});
  createStore(bias, O, {n, f});

  // Create input channel loop.
  auto c = createLoop(0, KShape[1]);

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
  auto n = createLoop(0, OShape[0]);

  // Create feature map height loop.
  auto h = createLoop(0, OShape[2]);

  // Create feature map width loop.
  auto w = createLoop(0, OShape[3]);

  // Create filter number loop.
  auto f = createLoop(0, KShape[0]);

  // Load bias into newY array.
  auto bias = createLoad(B, {f});
  createStore(bias, O, {n, f, h, w});

  // Create channel number loop.
  auto c = createLoop(0, KShape[1]);

  // Create kernel height loop.
  auto r = createLoop(0, KShape[2]);

  // Create kernel width loop.
  auto s = createLoop(0, KShape[3]);

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
  auto n = createLoop(0, OShape[0]);

  // Create height loop.
  auto h = createLoop(0, OShape[2]);

  // Create width loop.
  auto w = createLoop(0, OShape[3]);

  // Create channel loop.
  auto c = createLoop(0, OShape[1]);

  // Set largest value as zero.
  auto dataType = O.getType().cast<MemRefType>().getElementType();
  auto zeroConst = builder.create<mlir::ConstantOp>(
      op.getLoc(), builder.getZeroAttr(dataType));
  createStore(zeroConst, O, {h, c, h, w});

  // Create kernel height loop.
  auto r = createLoop(0, kernelShape[0]);

  // Create kernel width loop.
  auto s = createLoop(0, kernelShape[1]);

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
  auto n = createLoop(0, OShape[0]);

  // Create height loop.
  auto h = createLoop(0, OShape[2]);

  // Create width loop.
  auto w = createLoop(0, OShape[3]);

  // Create channel loop.
  auto c = createLoop(0, OShape[1]);

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
  auto n = createLoop(0, OShape[0]);

  // Create height loop.
  auto h = createLoop(0, OShape[2]);

  // Create width loop.
  auto w = createLoop(0, OShape[3]);

  // Create channel loop.
  auto c = createLoop(0, OShape[1]);

  // Load original value from input array.
  auto fmap0 = createLoad(I0, {n, c, h, w});
  auto fmap1 = createLoad(I1, {n, c, h, w});

  // Carry out add and store the result.
  auto result = createBinaryOp<mlir::AddFOp>(fmap0, fmap1);
  createStore(result, O, {n, c, h, w});

  return true;
}

//===----------------------------------------------------------------------===//
// BLASOps Handler
//===----------------------------------------------------------------------===//

// Only default attributes configuration are supported.
bool HLSKernelVisitor::visitOp(GemmOp op) {
  auto alpha = op.getOperand(0);
  auto beta = op.getOperand(1);

  auto A = op.getOperand(2);
  auto B = op.getOperand(3);
  auto C = op.getOperand(4);

  auto AShape = A.getType().cast<MemRefType>().getShape();
  auto CShape = C.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create M dimension loop.
  auto m = createLoop(0, CShape[0]);

  // Create N dimension loop.
  auto n = createLoop(0, CShape[1]);

  // Update C with beta * C.
  auto initC = createLoad(C, {m, n});
  auto betaC = createBinaryOp<mlir::MulFOp>(beta, initC);
  createStore(betaC, C, {m, n});

  // Create K dimension loop.
  auto k = createLoop(0, AShape[1]);

  // Accumulate C with alpha * A * B.
  auto valA = createLoad(A, {m, k});
  auto valB = createLoad(B, {k, n});
  auto valC = createLoad(C, {m, n});

  auto alphaA = createBinaryOp<mlir::MulFOp>(alpha, valA);
  auto alphaAB = createBinaryOp<mlir::MulFOp>(alphaA, valB);
  auto accumC = createBinaryOp<mlir::AddFOp>(alphaAB, valC);
  createStore(accumC, C, {m, n});

  return true;
}

bool HLSKernelVisitor::visitOp(SymmOp op) {
  auto alpha = op.getOperand(0);
  auto beta = op.getOperand(1);

  auto A = op.getOperand(2);
  auto B = op.getOperand(3);
  auto C = op.getOperand(4);

  auto CShape = C.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create M dimension loop.
  auto m = createLoop(0, CShape[0]);

  // Create N dimension loop.
  auto n = createLoop(0, CShape[1]);

  // Update C with beta * C.
  auto initC = createLoad(C, {m, n});
  auto betaC = createBinaryOp<mlir::MulFOp>(beta, initC);
  createStore(betaC, C, {m, n});

  // Create K dimension loop.
  auto k = createLoop(0, CShape[0]);

  // Create if condition for fetching value from array A. The then block of the
  // AffineIf operation is corresponding to lower triangle and vice versa.
  auto dataType = A.getType().cast<MemRefType>().getElementType();
  auto conditionSet = IntegerSet::get(2, 0, getDim(0) - getDim(1), false);
  auto lowerUpperIf = builder.create<mlir::AffineIfOp>(
      loc, dataType, conditionSet, ArrayRef<Value>({m, k}), true);

  builder.setInsertionPointToStart(lowerUpperIf.getThenBlock());
  auto trueValA = createLoad(A, {m, k});
  builder.create<mlir::AffineYieldOp>(loc, trueValA);

  builder.setInsertionPointToStart(lowerUpperIf.getElseBlock());
  auto falseValA = createLoad(A, {k, m});
  builder.create<mlir::AffineYieldOp>(loc, falseValA);

  // Accumulate C with alpha * A * B.
  builder.setInsertionPointAfter(lowerUpperIf);
  auto valA = lowerUpperIf.getResult(0);
  auto valB = createLoad(B, {k, n});
  auto valC = createLoad(C, {m, n});

  auto alphaA = createBinaryOp<mlir::MulFOp>(alpha, valA);
  auto alphaAB = createBinaryOp<mlir::MulFOp>(alphaA, valB);
  auto accumC = createBinaryOp<mlir::AddFOp>(alphaAB, valC);
  createStore(accumC, C, {m, n});

  return true;
}

bool HLSKernelVisitor::visitOp(SyrkOp op) {
  auto alpha = op.getOperand(0);
  auto beta = op.getOperand(1);

  auto A = op.getOperand(2);
  auto C = op.getOperand(3);

  auto AShape = A.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create M dimension loop, M == N.
  auto m = createLoop(0, AShape[0]);

  // Create N dimension loop.
  auto n = createLoop(0, m);

  // Update C with beta * C.
  auto initC = createLoad(C, {m, n});
  auto betaC = createBinaryOp<mlir::MulFOp>(beta, initC);
  createStore(betaC, C, {m, n});

  // Create K dimension loop.
  auto k = createLoop(0, AShape[1]);

  // Accumulate C with alpha * A * B.
  auto valA = createLoad(A, {m, k});
  auto valAT = createLoad(A, {n, k});
  auto valC = createLoad(C, {m, n});

  auto alphaA = createBinaryOp<mlir::MulFOp>(alpha, valA);
  auto alphaAAT = createBinaryOp<mlir::MulFOp>(alphaA, valAT);
  auto accumC = createBinaryOp<mlir::AddFOp>(alphaAAT, valC);
  createStore(accumC, C, {m, n});
  return true;
}

bool HLSKernelVisitor::visitOp(Syr2kOp op) {
  auto alpha = op.getOperand(0);
  auto beta = op.getOperand(1);

  auto A = op.getOperand(2);
  auto B = op.getOperand(3);
  auto C = op.getOperand(4);

  auto AShape = A.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create M dimension loop, M == N.
  auto m = createLoop(0, AShape[0]);

  // Create N dimension loop.
  auto n = createLoop(0, m);

  // Update C with beta * C.
  auto initC = createLoad(C, {m, n});
  auto betaC = createBinaryOp<mlir::MulFOp>(beta, initC);
  createStore(betaC, C, {m, n});

  // Create K dimension loop.
  auto k = createLoop(0, AShape[1]);

  // Accumulate C with alpha * A * BT and alpha * AT * B.
  auto valA = createLoad(A, {m, k});
  auto valBT = createLoad(B, {n, k});
  auto valB = createLoad(B, {m, k});
  auto valAT = createLoad(A, {n, k});
  auto valC = createLoad(C, {m, n});

  auto alphaA = createBinaryOp<mlir::MulFOp>(alpha, valA);
  auto alphaABT = createBinaryOp<mlir::MulFOp>(alphaA, valBT);
  auto alphaB = createBinaryOp<mlir::MulFOp>(alpha, valB);
  auto alphaBAT = createBinaryOp<mlir::MulFOp>(alphaB, valAT);

  auto accumC = createBinaryOp<mlir::AddFOp>(alphaABT, valC);
  auto accum2C = createBinaryOp<mlir::AddFOp>(alphaBAT, accumC);
  createStore(accum2C, C, {m, n});
  return true;
}

bool HLSKernelVisitor::visitOp(TrmmOp op) {
  auto alpha = op.getOperand(0);

  auto A = op.getOperand(1);
  auto B = op.getOperand(2);

  auto BShape = B.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder.
  builder.setInsertionPoint(op);

  // Create M dimension loop.
  auto m = createLoop(0, BShape[0]);

  // Create N dimension loop.
  auto n = createLoop(0, BShape[1]);

  // Create K dimension loop, K == M.
  auto lowerMap = AffineMap::get(1, 0, getDim(0) + getConst(1));
  auto upperMap = AffineMap::get(0, 0, getConst(BShape[0]));
  auto k = createLoop({m}, lowerMap, {}, upperMap);

  // Accumulate C with alpha * A * B.
  auto valA = createLoad(A, {m, k});
  auto valB = createLoad(B, {k, n});
  auto valBout = createLoad(B, {m, n});

  auto alphaA = createBinaryOp<mlir::MulFOp>(alpha, valA);
  auto alphaAB = createBinaryOp<mlir::MulFOp>(alphaA, valB);
  auto accumB = createBinaryOp<mlir::AddFOp>(alphaAB, valBout);
  createStore(accumB, B, {m, n});
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
