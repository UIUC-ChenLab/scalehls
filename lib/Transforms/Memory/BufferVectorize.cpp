//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

/// Get the vectorized type of the given memref. Specifically, the vectorized
/// memref type always has 1-D vector elements.
static MemRefType getVectorizedType(MemRefType type) {
  auto layout = type.getLayout().dyn_cast<TileLayoutAttr>();
  if (!layout || !layout.isVectorized() ||
      type.getElementType().dyn_cast<VectorType>())
    return MemRefType();

  // Calculate the shape of the new memref with vector elements.
  auto newShape = SmallVector<int64_t>(type.getShape());
  auto newTileShape = SmallVector<int64_t>(layout.getTileShape());
  auto vectorNumElements = 1;
  for (auto [size, tileSize, vectorSize] :
       llvm::zip(newShape, newTileShape, layout.getVectorShape())) {
    size /= vectorSize;
    tileSize /= vectorSize;
    vectorNumElements *= vectorSize;
  }

  // Construct the new memref type.
  return MemRefType::get(
      newShape, VectorType::get({vectorNumElements}, type.getElementType()),
      TileLayoutAttr::get(type.getContext(), newTileShape),
      type.getMemorySpace());
}

static LogicalResult vectorizeMemref(Value memref) {
  auto layout = getTileLayout(memref);
  if (!isExtBuffer(memref) || !layout)
    return failure();

  // Apply new memref type with buffer layout.
  auto type = memref.getType().cast<MemRefType>();
  auto newType = MemRefType::get(type.getShape(), type.getElementType(), layout,
                                 type.getMemorySpace());
  memref.setType(newType);

  // Create vectorization and devectorization ops if the necessary.
  auto builder = OpBuilder(memref.getContext());
  if (auto vectorizedType = getVectorizedType(newType)) {
    builder.setInsertionPointAfterValue(memref);
    auto vectorizedMemref = builder.create<BufferVectorizeOp>(
        memref.getLoc(), vectorizedType, memref);
    auto devectorizedMemref = builder.create<BufferDevectorizeOp>(
        memref.getLoc(), newType, vectorizedMemref);
    memref.replaceUsesWithIf(devectorizedMemref, [&](OpOperand &use) {
      return use.getOwner() != vectorizedMemref;
    });
  }
  return success();
}

namespace {
/// Encode TileLayoutAttr into the type of the memref. Then, propagate the type
/// changes to the schedules and nodes recursively.
struct MaterializeTileLayout : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    for (auto arg : func.getArguments())
      if (succeeded(vectorizeMemref(arg))) {
        hasChanged = true;
        func.removeArgAttr(arg.getArgNumber(), "hls.tile_layout");
      }
    func.walk([&](hls::BufferLikeInterface buffer) {
      if (succeeded(vectorizeMemref(buffer.getMemref()))) {
        hasChanged = true;
        buffer->removeAttr("tile_layout");
      }
    });

    if (hasChanged) {
      // Update the type of schedules and nodes recursively.
      for (auto schedule : func.getOps<ScheduleOp>())
        schedule.updateSignatureRecursively();

      // Update the type of the function.
      func.setType(rewriter.getFunctionType(
          func.front().getArgumentTypes(),
          func.front().getTerminator()->getOperandTypes()));
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct VectorizeNode : public OpRewritePattern<NodeOp> {
  using OpRewritePattern<NodeOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(NodeOp node,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    for (auto [operand, arg] :
         llvm::zip(node->getOpOperands(), node.getBody().getArguments()))
      if (auto type = arg.getType().dyn_cast<MemRefType>())
        if (auto vectorizedType = getVectorizedType(type)) {
          arg.setType(vectorizedType);

          rewriter.setInsertionPoint(node);
          auto vectorOperand = rewriter.create<BufferVectorizeOp>(
              operand.get().getLoc(), vectorizedType, operand.get());
          operand.set(vectorOperand);

          rewriter.setInsertionPointToStart(&node.getBody().front());
          auto devectorArg =
              rewriter.create<BufferDevectorizeOp>(arg.getLoc(), type, arg);
          arg.replaceUsesWithIf(devectorArg, [&](OpOperand &use) {
            return use.getOwner() != devectorArg;
          });
          hasChanged = true;
        }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct VectorizeSchedule : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    for (auto [operand, arg] : llvm::zip(schedule->getOpOperands(),
                                         schedule.getBody().getArguments()))
      if (auto type = arg.getType().dyn_cast<MemRefType>())
        if (auto vectorizedType = getVectorizedType(type)) {
          arg.setType(vectorizedType);

          rewriter.setInsertionPoint(schedule);
          auto vectorOperand = rewriter.create<BufferVectorizeOp>(
              operand.get().getLoc(), vectorizedType, operand.get());
          operand.set(vectorOperand);

          rewriter.setInsertionPointToStart(&schedule.getBody().front());
          auto devectorArg =
              rewriter.create<BufferDevectorizeOp>(arg.getLoc(), type, arg);
          arg.replaceUsesWithIf(devectorArg, [&](OpOperand &use) {
            return use.getOwner() != devectorArg;
          });
          hasChanged = true;
        }
    return success(hasChanged);
  }
};
} // namespace

// Calculate the vectorized indices given the original indices and vector shape.
// Assume the vector shape if [v0, v1], the original indice [d0, d1] should be
// converted to [d0 / v0, d1 / v1].
static LogicalResult
getVectorizedIndices(Location loc, ArrayRef<Value> indices,
                     ArrayRef<int64_t> vectorShape, PatternRewriter &rewriter,
                     SmallVectorImpl<Value> &vectorizedIndices) {
  vectorizedIndices.clear();
  for (auto [index, vectorSize] : llvm::zip(indices, vectorShape)) {
    if (isValidSymbol(index)) {
      auto expr = rewriter.getAffineSymbolExpr(0).floorDiv(vectorSize);
      vectorizedIndices.push_back(rewriter.create<AffineApplyOp>(
          loc, AffineMap::get(0, 1, expr), index));
    } else if (isValidDim(index)) {
      auto expr = rewriter.getAffineDimExpr(0).floorDiv(vectorSize);
      vectorizedIndices.push_back(rewriter.create<AffineApplyOp>(
          loc, AffineMap::get(1, 0, expr), index));
    } else
      return failure();
  }
  return success();
}

/// Calculate the scalar indices given the original indices and vector shape.
/// Assume the vector shape if [v0, v1] and overall index is x, the original
/// indice [d0, d1] should be converted to [d0 + x / v1 % v0, d1 + x % v1].
static LogicalResult getScalarIndices(Location loc, ArrayRef<Value> indices,
                                      ArrayRef<int64_t> vectorShape,
                                      int64_t overallIndex,
                                      PatternRewriter &rewriter,
                                      SmallVectorImpl<Value> &scalarIndices) {
  scalarIndices.clear();
  for (auto [index, vectorSize] : llvm::zip(indices, vectorShape)) {
    if (isValidSymbol(index)) {
      auto expr = rewriter.getAffineSymbolExpr(0) + (overallIndex % vectorSize);
      scalarIndices.push_back(rewriter.create<AffineApplyOp>(
          loc, AffineMap::get(0, 1, expr), index));
    } else if (isValidDim(index)) {
      auto expr = rewriter.getAffineDimExpr(0) + (overallIndex % vectorSize);
      scalarIndices.push_back(rewriter.create<AffineApplyOp>(
          loc, AffineMap::get(1, 0, expr), index));
    } else
      return failure();
    overallIndex /= vectorSize;
  }
  return success();
}

namespace {
struct VectorizeTransferRead : public OpRewritePattern<vector::TransferReadOp> {
  using OpRewritePattern<vector::TransferReadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(vector::TransferReadOp read,
                                PatternRewriter &rewriter) const override {
    if (auto type = read.getShapedType().dyn_cast<MemRefType>()) {
      if (isExtBuffer(read.getSource())) {
        // For external buffers, we convert the transfer_read op to an affine
        // load op that loads a vector from a vectorized buffer.
        if (auto vectorizedType = getVectorizedType(type)) {
          rewriter.setInsertionPoint(read);

          // Calculate the new indices of affine load.
          SmallVector<Value, 4> vectorIndices;
          if (failed(getVectorizedIndices(
                  read.getLoc(), SmallVector<Value>(read.getIndices()),
                  read.getVectorType().getShape(), rewriter, vectorIndices)))
            return failure();

          // Because the generated vector type always has 1-D shape, we need to
          // explicitly cast the load result back to the resulting shape of
          // transfer read.
          auto vectorBuffer = rewriter.create<BufferVectorizeOp>(
              read.getLoc(), vectorizedType, read.getSource());
          auto vectorLoad = rewriter.create<AffineLoadOp>(
              read.getLoc(), vectorBuffer, vectorIndices);
          rewriter.replaceOpWithNewOp<vector::ShapeCastOp>(
              read, read.getVectorType(), vectorLoad);
          return success();
        }
      } else {
        // For internal buffers, we convert the transfer_read op to multiple
        // scalar loads and construct a vector from them.
        rewriter.setInsertionPoint(read);
        auto vectorType = read.getVectorType();
        auto newVectorType = VectorType::get(vectorType.getNumElements(),
                                             vectorType.getElementType());
        auto newVector =
            rewriter.create<VectorInitOp>(read.getLoc(), newVectorType)
                .getResult();

        // Construct a scalar affine load and vector insertion for each element
        // of the vector.
        for (int64_t i = 0; i < vectorType.getNumElements(); ++i) {
          SmallVector<Value, 4> scalarIndices;
          if (failed(getScalarIndices(
                  read.getLoc(), SmallVector<Value>(read.getIndices()),
                  vectorType.getShape(), i, rewriter, scalarIndices)))
            return failure();

          auto scalarLoad = rewriter.create<AffineLoadOp>(
              read.getLoc(), read.getSource(), scalarIndices);
          newVector = rewriter.create<vector::InsertOp>(
              read.getLoc(), scalarLoad, newVector,
              rewriter.getI64ArrayAttr({i}));
        }

        // Replace the transfer_read op with the newly generated vector.
        rewriter.replaceOpWithNewOp<vector::ShapeCastOp>(read, vectorType,
                                                         newVector);
        return success();
      }
    }
    return failure();
  }
};
} // namespace

namespace {
struct VectorizeTransferWrite
    : public OpRewritePattern<vector::TransferWriteOp> {
  using OpRewritePattern<vector::TransferWriteOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(vector::TransferWriteOp write,
                                PatternRewriter &rewriter) const override {
    if (auto type = write.getShapedType().dyn_cast<MemRefType>()) {
      if (isExtBuffer(write.getSource())) {
        // For external buffers, we convert the transfer_write op to an affine
        // store op that stores a vector into a vectorized buffer.
        if (auto vectorizedType = getVectorizedType(type)) {
          auto layout = type.getLayout().cast<TileLayoutAttr>();
          rewriter.setInsertionPoint(write);

          // Calculate the new indices of affine store.
          SmallVector<Value, 4> vectorIndices;
          if (failed(getVectorizedIndices(
                  write.getLoc(), SmallVector<Value>(write.getIndices()),
                  layout.getVectorShape(), rewriter, vectorIndices)))
            return failure();

          // Because the generated vector type always has 1-D shape, we need to
          // explicitly cast the input value of transfer write to the 1-D vector
          // shape.
          auto vectorBuffer = rewriter.create<BufferVectorizeOp>(
              write.getLoc(), vectorizedType, write.getSource());
          auto vectorToStore = rewriter.create<vector::ShapeCastOp>(
              write.getLoc(), vectorizedType.getElementType(),
              write.getVector());
          rewriter.replaceOpWithNewOp<AffineStoreOp>(
              write, vectorToStore, vectorBuffer, vectorIndices);
          return success();
        }
      } else {
        // For internal buffers, we convert the transfer_write op to multiple
        // vector extract ops and scalar stores.
        rewriter.setInsertionPoint(write);
        auto vectorType = write.getVectorType();
        auto newVectorType = VectorType::get(vectorType.getNumElements(),
                                             vectorType.getElementType());
        auto newVector = rewriter.create<vector::ShapeCastOp>(
            write.getLoc(), newVectorType, write.getVector());

        for (int64_t i = 0; i < vectorType.getNumElements(); ++i) {
          SmallVector<Value, 4> scalarIndices;
          if (failed(getScalarIndices(
                  write.getLoc(), SmallVector<Value>(write.getIndices()),
                  vectorType.getShape(), i, rewriter, scalarIndices)))
            return failure();

          auto scalar = rewriter.create<vector::ExtractOp>(
              write.getLoc(), newVector, rewriter.getI64ArrayAttr({i}));
          rewriter.create<AffineStoreOp>(write.getLoc(), scalar,
                                         write.getSource(), scalarIndices);
        }
        rewriter.eraseOp(write);
        return success();
      }
    }
    return failure();
  }
};
} // namespace

namespace {
struct VectorizeLoad : public OpRewritePattern<AffineLoadOp> {
  using OpRewritePattern<AffineLoadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineLoadOp load,
                                PatternRewriter &rewriter) const override {
    auto type = load.getMemRefType();
    if (auto vectorizedType = getVectorizedType(type)) {
      auto layout = type.getLayout().cast<TileLayoutAttr>();
      rewriter.setInsertionPoint(load);

      // Calculate the new indices of affine load.
      SmallVector<AffineExpr, 4> vectorExprs;
      for (auto [expr, vectorSize] :
           llvm::zip(load.getAffineMap().getResults(), layout.getVectorShape()))
        vectorExprs.push_back(expr.floorDiv(vectorSize));
      auto vectorMap = AffineMap::get(load.getAffineMap().getNumDims(),
                                      load.getAffineMap().getNumSymbols(),
                                      vectorExprs, rewriter.getContext());

      // We need to extract the scalar from the loaded vector's first element.
      auto vectorBuffer = rewriter.create<BufferVectorizeOp>(
          load.getLoc(), vectorizedType, load.getMemRef());
      auto vectorLoad = rewriter.create<AffineLoadOp>(
          load.getLoc(), vectorBuffer, vectorMap, load.getMapOperands());
      rewriter.replaceOpWithNewOp<vector::ExtractOp>(
          load, vectorLoad, rewriter.getI64ArrayAttr({0}));
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct VectorizeStore : public OpRewritePattern<AffineStoreOp> {
  using OpRewritePattern<AffineStoreOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(AffineStoreOp store,
                                PatternRewriter &rewriter) const override {
    auto type = store.getMemRefType();
    if (auto vectorizedType = getVectorizedType(type))
      store.emitOpError("masked vector store has not been supported");
    return failure();
  }
};
} // namespace

namespace {
struct BufferVectorize : public BufferVectorizeBase<BufferVectorize> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<MaterializeTileLayout>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));

    patterns.clear();
    patterns.add<VectorizeNode>(context);
    patterns.add<VectorizeSchedule>(context);
    patterns.add<VectorizeTransferRead>(context);
    patterns.add<VectorizeTransferWrite>(context);
    patterns.add<VectorizeLoad>(context);
    patterns.add<VectorizeStore>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createBufferVectorizePass() {
  return std::make_unique<BufferVectorize>();
}
