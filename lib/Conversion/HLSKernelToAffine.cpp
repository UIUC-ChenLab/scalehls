//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Conversion/Passes.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Dialect/HLSKernel/Visitor.h"
#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/IntegerSet.h"

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
  bool visitOp(CopyOp op);

  bool visitOp(GemmOp op);
  bool visitOp(SymmOp op);
  bool visitOp(SyrkOp op);
  bool visitOp(Syr2kOp op);
  bool visitOp(TrmmOp op);

private:
  OpBuilder &builder;
  Location loc;

  /// Helpers for creating loops.
  /// Constant upper and lower bound.
  Value createLoop(int64_t lower, int64_t upper, int64_t step = 1) {
    auto loop = builder.create<mlir::AffineForOp>(loc, lower, upper, step);
    builder.setInsertionPointToStart(&loop.getLoopBody().front());
    return loop.getInductionVar();
  }

  /// General case loop boundary.
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

  /// Helpers for creating constant, loads, stores and binary operations.
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

  auto IShape = I.getType().cast<MemRefType>().getShape();
  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder. Create batch and output channel loop.
  builder.setInsertionPoint(op);
  auto n = createLoop(0, OShape[0]);
  auto f = createLoop(0, OShape[1]);

  // Load bias into O array.
  auto bias = createLoad(B, {f});
  createStore(bias, O, {n, f});

  // Create input channel loop.
  auto c = createLoop(0, IShape[1]);

  if (IShape.size() == 2) {
    // Fetch feature map, kernel and carry out multiplication.
    auto fmap = createLoad(I, {n, c});
    auto kernel = createLoad(K, {f, c});
    auto mult = createBinaryOp<mlir::MulFOp>(fmap, kernel);

    // Fetch partial result and carry out accumulation.
    auto partial = createLoad(O, {n, f});
    auto accum = createBinaryOp<mlir::AddFOp>(partial, mult);
    createStore(accum, O, {n, f});
  } else {
    // Create kernel height loop.
    auto r = createLoop(0, IShape[2]);

    // Create kernel width loop.
    auto s = createLoop(0, IShape[3]);

    // Fetch feature map, kernel and carry out multiplication.
    auto fmap = createLoad(I, {n, c, r, s});
    auto kernel = createLoad(K, {f, c, r, s});
    auto mult = createBinaryOp<mlir::MulFOp>(fmap, kernel);

    // Fetch partial result and carry out accumulation.
    auto partial = createLoad(O, {n, f});
    auto accum = createBinaryOp<mlir::AddFOp>(partial, mult);
    createStore(accum, O, {n, f});
  }

  return true;
}

/// Strides has not been suppored.
bool HLSKernelVisitor::visitOp(ConvOp op) {
  SmallVector<int64_t, 4> padding;
  for (auto pad : op.getAttrOfType<ArrayAttr>("padding"))
    padding.push_back(pad.cast<IntegerAttr>().getInt());

  auto I = op.getOperand(0);
  auto K = op.getOperand(1);
  auto B = op.getOperand(2);
  auto O = op.getOperand(3);

  auto IShape = I.getType().cast<MemRefType>().getShape();
  auto KShape = K.getType().cast<MemRefType>().getShape();
  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder. Create batch, feature map height, feature
  // map width, and filter number loop.
  builder.setInsertionPoint(op);
  auto n = createLoop(0, OShape[0]);
  auto h = createLoop(0, OShape[2]);
  auto w = createLoop(0, OShape[3]);
  auto f = createLoop(0, KShape[0]);

  // Load bias into newY array.
  auto bias = createLoad(B, {f});
  createStore(bias, O, {n, f, h, w});

  // Create channel number, kernel height, and kernel width loop.
  auto c = createLoop(0, KShape[1]);
  auto r = createLoop(0, KShape[2]);
  auto s = createLoop(0, KShape[3]);

  // Create if condition for padding input feature map.
  SmallVector<AffineExpr, 4> conditionExprs;
  conditionExprs.push_back(getDim(0) + getDim(2) - getConst(padding[0]));
  conditionExprs.push_back(getConst(IShape[2] - 1) - getDim(0) - getDim(2) +
                           getConst(padding[0]));
  conditionExprs.push_back(getDim(1) + getDim(3) - getConst(padding[2]));
  conditionExprs.push_back(getConst(IShape[3] - 1) - getDim(1) - getDim(3) +
                           getConst(padding[2]));
  auto conditionSet =
      IntegerSet::get(4, 0, conditionExprs, {false, false, false, false});

  auto dataType = I.getType().cast<MemRefType>().getElementType();
  auto paddingIf = builder.create<mlir::AffineIfOp>(
      loc, dataType, conditionSet, ArrayRef<Value>({h, w, r, s}), true);

  // Fetch feature map.
  builder.setInsertionPointToStart(paddingIf.getThenBlock());
  SmallVector<AffineExpr, 4> indexExprs;
  indexExprs.push_back(getDim(0));
  indexExprs.push_back(getDim(1));
  indexExprs.push_back(getDim(2) + getDim(4) - getConst(padding[0]));
  indexExprs.push_back(getDim(3) + getDim(5) - getConst(padding[2]));
  auto trueFmap = builder.create<mlir::AffineLoadOp>(
      op.getLoc(), I, AffineMap::get(6, 0, indexExprs, op.getContext()),
      ArrayRef<Value>({n, c, h, w, r, s}));
  builder.create<mlir::AffineYieldOp>(op.getLoc(), trueFmap.getResult());

  // Padding.
  builder.setInsertionPointToStart(paddingIf.getElseBlock());
  auto zeroFmap = builder.create<mlir::ConstantOp>(
      op.getLoc(), builder.getZeroAttr(dataType));
  builder.create<mlir::AffineYieldOp>(op.getLoc(), zeroFmap.getResult());

  // Fetch weight and carry out multiplication.
  builder.setInsertionPointAfter(paddingIf);
  auto fmap = paddingIf.getResult(0);
  auto kernel = createLoad(K, {f, c, r, s});
  auto multi = createBinaryOp<mlir::MulFOp>(fmap, kernel);

  // Fetch partial result and carry out accumulation.
  auto partial = createLoad(O, {n, f, h, w});
  auto accum = createBinaryOp<mlir::AddFOp>(partial, multi);
  createStore(accum, O, {n, f, h, w});

  return true;
}

/// Padding and strides has not been suppored. Only support when kernel size is
/// equal to stride size.
bool HLSKernelVisitor::visitOp(MaxPoolOp op) {
  SmallVector<int64_t, 2> kernelShape;
  for (auto shape : op.getAttrOfType<ArrayAttr>("kernel_shape"))
    kernelShape.push_back(shape.cast<IntegerAttr>().getInt());

  auto I = op.getOperand(0);
  auto O = op.getOperand(1);

  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder. Create batch, height, width, and channel
  // loop.
  builder.setInsertionPoint(op);
  auto n = createLoop(0, OShape[0]);
  auto h = createLoop(0, OShape[2]);
  auto w = createLoop(0, OShape[3]);
  auto c = createLoop(0, OShape[1]);

  // Set largest value as zero.
  // TODO: should be negative infinite.
  auto dataType = O.getType().cast<MemRefType>().getElementType();
  auto zeroConst = builder.create<mlir::ConstantOp>(
      op.getLoc(), builder.getZeroAttr(dataType));
  createStore(zeroConst, O, {n, c, h, w});

  // Create kernel height, and kernel width loop.
  auto r = createLoop(0, kernelShape[0]);
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
  createStore(newGreatest, O, {n, c, h, w});

  return true;
}

bool HLSKernelVisitor::visitOp(ReluOp op) {
  auto I = op.getOperand(0);
  auto O = op.getOperand(1);

  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder. Create batch, height, width, and channel
  // loop.
  builder.setInsertionPoint(op);
  auto n = createLoop(0, OShape[0]);
  auto h = createLoop(0, OShape[2]);
  auto w = createLoop(0, OShape[3]);
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

  // Set insertion point of builder. Create batch, height, width, and channel
  // loop.
  builder.setInsertionPoint(op);
  auto n = createLoop(0, OShape[0]);
  auto h = createLoop(0, OShape[2]);
  auto w = createLoop(0, OShape[3]);
  auto c = createLoop(0, OShape[1]);

  // Load original value from input array.
  auto fmap0 = createLoad(I0, {n, c, h, w});
  auto fmap1 = createLoad(I1, {n, c, h, w});

  // Carry out add and store the result.
  auto result = createBinaryOp<mlir::AddFOp>(fmap0, fmap1);
  createStore(result, O, {n, c, h, w});

  return true;
}

bool HLSKernelVisitor::visitOp(CopyOp op) {
  auto I = op.getOperand(0);
  auto O = op.getOperand(1);

  auto OShape = O.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder. Create batch, height, width, and channel
  // loop.
  builder.setInsertionPoint(op);
  auto n = createLoop(0, OShape[0]);
  auto h = createLoop(0, OShape[2]);
  auto w = createLoop(0, OShape[3]);
  auto c = createLoop(0, OShape[1]);

  // Load original value from input array.
  auto fmap = createLoad(I, {n, c, h, w});

  // Store the result.
  createStore(fmap, O, {n, c, h, w});

  return true;
}

//===----------------------------------------------------------------------===//
// BLASOps Handler
//===----------------------------------------------------------------------===//

/// Only default attributes configuration are supported.
bool HLSKernelVisitor::visitOp(GemmOp op) {
  auto alpha = op.getOperand(0);
  auto beta = op.getOperand(1);

  auto A = op.getOperand(2);
  auto B = op.getOperand(3);
  auto C = op.getOperand(4);

  auto AShape = A.getType().cast<MemRefType>().getShape();
  auto CShape = C.getType().cast<MemRefType>().getShape();

  // Set insertion point of builder. Create M and N dimension loop.
  builder.setInsertionPoint(op);
  auto m = createLoop(0, CShape[0]);
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

  // Set insertion point of builder. Create M and N dimension loop.
  builder.setInsertionPoint(op);
  auto m = createLoop(0, CShape[0]);
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
      op.getLoc(), dataType, conditionSet, ArrayRef<Value>({m, k}), true);

  builder.setInsertionPointToStart(lowerUpperIf.getThenBlock());
  auto trueValA = createLoad(A, {m, k});
  builder.create<mlir::AffineYieldOp>(op.getLoc(), trueValA);

  builder.setInsertionPointToStart(lowerUpperIf.getElseBlock());
  auto falseValA = createLoad(A, {k, m});
  builder.create<mlir::AffineYieldOp>(op.getLoc(), falseValA);

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

  // Set insertion point of builder. Create M (M == N) and N dimension loop.
  builder.setInsertionPoint(op);
  auto m = createLoop(0, AShape[0]);
  auto lowerMap = AffineMap::get(0, 0, getConst(0));
  auto upperMap = AffineMap::get(1, 0, getDim(0) + 1);
  auto n = createLoop({}, lowerMap, {m}, upperMap);

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

  // Set insertion point of builder. Create M (M == N) and N dimension loop.
  builder.setInsertionPoint(op);
  auto m = createLoop(0, AShape[0]);
  auto lowerMap = AffineMap::get(0, 0, getConst(0));
  auto upperMap = AffineMap::get(1, 0, getDim(0) + 1);
  auto n = createLoop({}, lowerMap, {m}, upperMap);

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

  // Set insertion point of builder. Create M, N, and K (K == M) dimension loop.
  builder.setInsertionPoint(op);
  auto m = createLoop(0, BShape[0]);
  auto n = createLoop(0, BShape[1]);
  auto k = createLoop(0, m);

  // Accumulate B with A * B.
  auto valA = createLoad(A, {m, k});
  auto valB = createLoad(B, {k, n});
  auto valBout = createLoad(B, {m, n});

  auto AB = createBinaryOp<mlir::MulFOp>(valA, valB);
  auto accumB = createBinaryOp<mlir::AddFOp>(AB, valBout);
  createStore(accumB, B, {m, n});

  // Update B with alpha * B.
  builder.setInsertionPoint(n.getParentBlock()->getTerminator());
  auto initB = createLoad(B, {m, n});
  auto alphaB = createBinaryOp<mlir::MulFOp>(alpha, initB);
  createStore(alphaB, B, {m, n});
  return true;
}

//===----------------------------------------------------------------------===//
// HLSkernel to Affine Lowering Pass
//===----------------------------------------------------------------------===//

namespace {
struct HLSKernelToAffine : public HLSKernelToAffineBase<HLSKernelToAffine> {
public:
  void runOnOperation() override;
};
} // namespace

void HLSKernelToAffine::runOnOperation() {
  auto func = getOperation();
  OpBuilder builder(func);
  HLSKernelVisitor visitor(builder, func.getLoc());

  func.walk([&](HLSKernelOpInterface kernelOp) {
    if (visitor.dispatchVisitor(kernelOp)) {
      kernelOp.erase();
    } else
      kernelOp.emitError("can't be correctly lowered.");
  });
}

std::unique_ptr<mlir::Pass> scalehls::createHLSKernelToAffinePass() {
  return std::make_unique<HLSKernelToAffine>();
}
