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

static LogicalResult collapseMemref(Value memref) {
  auto type = memref.getType().dyn_cast<MemRefType>();
  if (!type)
    return failure();

  // TODO: Support non-identity buffers.
  if (!type.getLayout().getAffineMap().isIdentity() ||
      !llvm::any_of(type.getShape(),
                    [](int64_t dimSize) { return dimSize == 1; }))
    return failure();

  // TODO: Support non-affine read/write interfaces.
  if (llvm::any_of(memref.getUsers(), [](Operation *op) {
        return !isa<AffineReadOpInterface, AffineWriteOpInterface>(op);
      }))
    return failure();

  // Construct new shape.
  SmallVector<int64_t> newShape;
  SmallVector<unsigned> remainDims;
  for (auto dimSize : llvm::enumerate(type.getShape()))
    if (dimSize.value() != 1) {
      newShape.push_back(dimSize.value());
      remainDims.push_back(dimSize.index());
    }

  // Set the buffer to a new type.
  auto newType = MemRefType::get(newShape, type.getElementType(), AffineMap(),
                                 type.getMemorySpace());
  memref.setType(newType);

  // Update buffer users.
  for (auto user : memref.getUsers()) {
    AffineMap map;
    if (auto read = dyn_cast<mlir::AffineReadOpInterface>(user))
      map = read.getAffineMap();
    else if (auto write = dyn_cast<mlir::AffineWriteOpInterface>(user))
      map = write.getAffineMap();

    SmallVector<AffineExpr> newResults;
    for (auto dim : remainDims)
      newResults.push_back(map.getResult(dim));
    auto newMap = AffineMap::get(map.getNumDims(), map.getNumSymbols(),
                                 newResults, map.getContext());
    user->setAttr("map", AffineMapAttr::get(newMap));
  }

  // Update buffer info.
  if (auto bufferInfo = getBufferInfo(memref)) {
    SmallVector<int64_t> newTileShape;
    SmallVector<int64_t> newVectorShape;

    for (auto dim : remainDims) {
      newTileShape.push_back(bufferInfo.getTileShape()[dim]);
      if (!bufferInfo.getVectorShape().empty())
        newVectorShape.push_back(bufferInfo.getVectorShape()[dim]);
    }

    setBufferInfo(memref, newTileShape, newVectorShape);
  }
  return success();
}

namespace {
struct CollapseFuncMemref : public OpRewritePattern<func::FuncOp> {
  using OpRewritePattern<func::FuncOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(func::FuncOp func,
                                PatternRewriter &rewriter) const override {
    bool hasChanged = false;
    for (auto arg : func.getArguments())
      if (succeeded(collapseMemref(arg)))
        hasChanged = true;

    func.walk([&](hls::BufferLikeInterface buffer) {
      if (succeeded(collapseMemref(buffer.getMemref()))) {
        hasChanged = true;
        if (auto constBuffer = dyn_cast<ConstBufferOp>(buffer.getOperation())) {
          auto memrefType = buffer.getMemrefType();
          auto tensorType = RankedTensorType::get(memrefType.getShape(),
                                                  memrefType.getElementType());

          SmallVector<Attribute> attrs;
          for (auto attr : constBuffer.getValue().getValues<Attribute>())
            attrs.push_back(attr);
          constBuffer.setValueAttr(DenseElementsAttr::get(tensorType, attrs));
        }
      }
    });

    func.setType(rewriter.getFunctionType(
        func.front().getArgumentTypes(),
        func.front().getTerminator()->getOperandTypes()));
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct CollapseMemrefUnitDims
    : public scalehls::CollapseMemrefUnitDimsBase<CollapseMemrefUnitDims> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<CollapseFuncMemref>(context);
    (void)applyOpPatternsAndFold(func, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCollapseMemrefUnitDimsPass() {
  return std::make_unique<CollapseMemrefUnitDims>();
}
