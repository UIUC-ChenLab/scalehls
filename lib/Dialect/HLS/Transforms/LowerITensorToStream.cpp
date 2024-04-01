//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_LOWERITENSORTOSTREAM
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

static StreamType getStreamType(hls::ITensorType iTensorType) {
  return hls::StreamType::get(iTensorType.getDataType(),
                              iTensorType.getDepth());
}

namespace {
struct LowerITensorInstanceOp
    : public OpRewritePattern<hls::ITensorInstanceOp> {
  using OpRewritePattern<hls::ITensorInstanceOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorInstanceOp inst,
                                PatternRewriter &rewriter) const override {
    auto streamType = getStreamType(inst.getType());
    auto stream = rewriter.create<hls::StreamOp>(inst.getLoc(), streamType,
                                                 inst.getLocationAttr());
    rewriter.replaceOpWithNewOp<hls::StreamToITensorOp>(inst, inst.getType(),
                                                        stream);
    return success();
  }
};
} // namespace

namespace {
struct LowerITensorReadOp : public OpRewritePattern<hls::ITensorReadOp> {
  using OpRewritePattern<hls::ITensorReadOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorReadOp read,
                                PatternRewriter &rewriter) const override {
    auto streamType = getStreamType(read.getSourceType());
    auto stream = rewriter.create<hls::ITensorToStreamOp>(
        read.getLoc(), streamType, read.getSource());
    rewriter.replaceOpWithNewOp<hls::StreamReadOp>(read, read.getType(),
                                                   stream);
    return success();
  }
};
} // namespace

namespace {
struct LowerITensorWriteOp : public OpRewritePattern<hls::ITensorWriteOp> {
  using OpRewritePattern<hls::ITensorWriteOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorWriteOp write,
                                PatternRewriter &rewriter) const override {
    auto stream = rewriter.create<hls::ITensorToStreamOp>(
        write.getLoc(), getStreamType(write.getDestType()), write.getDest());
    rewriter.create<hls::StreamWriteOp>(write.getLoc(), write.getValue(),
                                        stream);
    auto replacement = rewriter.create<hls::StreamToITensorOp>(
        write.getLoc(), write.getResultType(), stream);
    rewriter.replaceOp(write, replacement);
    return success();
  }
};
} // namespace

namespace {
struct LowerITensorViewLikeOpInterface
    : public OpInterfaceRewritePattern<hls::ITensorViewLikeOpInterface> {
  using OpInterfaceRewritePattern<
      hls::ITensorViewLikeOpInterface>::OpInterfaceRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorViewLikeOpInterface view,
                                PatternRewriter &rewriter) const override {
    auto stream = rewriter.create<hls::ITensorToStreamOp>(
        view.getLoc(), getStreamType(view.getResultType()), view.getSource());
    auto replacement = rewriter.create<hls::StreamToITensorOp>(
        view.getLoc(), view.getResultType(), stream);
    rewriter.replaceOp(view, replacement);
    return success();
  }
};
} // namespace

static LogicalResult lowerDestinationStyleContainerOp(
    Operation *op, ValueRange initOperands, ValueRange iterArgs,
    ValueRange yieldedValues, ValueRange results, PatternRewriter &rewriter) {
  bool hasChanged = false;
  auto loc = op->getLoc();

  for (auto [initArg, iterArg, yieldedValue, result] :
       llvm::zip(initOperands, iterArgs, yieldedValues, results)) {
    auto iTensorType = dyn_cast<ITensorType>(result.getType());
    if (iTensorType && iterArg != yieldedValue && !iterArg.use_empty()) {
      hasChanged = true;
      auto streamType = getStreamType(iTensorType);

      rewriter.setInsertionPoint(op);
      auto stream =
          rewriter.create<hls::ITensorToStreamOp>(loc, streamType, initArg);

      rewriter.setInsertionPointAfterValue(iterArg);
      auto iterArgRepl =
          rewriter.create<hls::StreamToITensorOp>(loc, iTensorType, stream);
      rewriter.replaceAllUsesWith(iterArg, iterArgRepl);

      rewriter.setInsertionPointAfter(op);
      auto resultRepl =
          rewriter.create<hls::StreamToITensorOp>(loc, iTensorType, stream);
      rewriter.replaceAllUsesWith(result, resultRepl);
    }
  }
  return success(hasChanged);
}

namespace {
struct LowerForOp : public OpRewritePattern<scf::ForOp> {
  using OpRewritePattern<scf::ForOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(scf::ForOp loop,
                                PatternRewriter &rewriter) const override {
    return lowerDestinationStyleContainerOp(
        loop, loop.getInitArgs(), loop.getRegionIterArgs(),
        loop.getYieldedValues(), loop.getResults(), rewriter);
  }
};
} // namespace

namespace {
struct LowerTaskOp : public OpRewritePattern<hls::TaskOp> {
  using OpRewritePattern<hls::TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::TaskOp task,
                                PatternRewriter &rewriter) const override {
    return lowerDestinationStyleContainerOp(
        task, task.getInits(), task.getBody().getArguments(),
        task.getYieldOp().getOperands(), task.getResults(), rewriter);
  }
};
} // namespace

namespace {
struct RemoveITensorToStreamOp
    : public OpRewritePattern<hls::ITensorToStreamOp> {
  using OpRewritePattern<hls::ITensorToStreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::ITensorToStreamOp toStream,
                                PatternRewriter &rewriter) const override {
    if (toStream.use_empty()) {
      rewriter.eraseOp(toStream);
      return success();
    } else if (auto toITensor = toStream.getITensor()
                                    .getDefiningOp<hls::StreamToITensorOp>()) {
      if (toStream.getStreamType() == toITensor.getStreamType()) {
        rewriter.replaceOp(toStream, toITensor.getStream());
        return success();
      }
    }
    return failure();
  }
};
} // namespace

namespace {
struct RemoveStreamToITensorOp
    : public OpRewritePattern<hls::StreamToITensorOp> {
  using OpRewritePattern<hls::StreamToITensorOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamToITensorOp toITensor,
                                PatternRewriter &rewriter) const override {
    if (toITensor.use_empty()) {
      rewriter.eraseOp(toITensor);
      return success();
    }
    return failure();
  }
};
} // namespace

namespace {
struct DuplicateStreamOp : public OpRewritePattern<hls::StreamOp> {
  using OpRewritePattern<hls::StreamOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(hls::StreamOp stream,
                                PatternRewriter &rewriter) const override {
    auto writeUses = stream.getWriteUses();
    if (writeUses.size() != 1)
      return failure();
    auto writer = stream.getWriter();

    bool hasChanged = false;
    for (auto use : llvm::drop_begin(stream.getReadUses())) {
      hasChanged = true;
      rewriter.setInsertionPoint(stream);
      auto newStream = rewriter.create<hls::StreamOp>(
          stream.getLoc(), stream.getType(), stream.getLocationAttr());
      rewriter.setInsertionPoint(writer);
      rewriter.create<hls::StreamWriteOp>(writer.getLoc(), writer.getValue(),
                                          newStream);
      rewriter.modifyOpInPlace(use->getOwner(), [&]() { use->set(newStream); });
    }
    return success(hasChanged);
  }
};
} // namespace

namespace {
struct LowerITensorToStream
    : public hls::impl::LowerITensorToStreamBase<LowerITensorToStream> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = &getContext();

    // Apply lowering patterns.
    mlir::RewritePatternSet patterns(context);
    patterns.add<LowerITensorInstanceOp>(context);
    patterns.add<LowerITensorReadOp>(context);
    patterns.add<LowerITensorWriteOp>(context);
    patterns.add<LowerITensorViewLikeOpInterface>(context);
    patterns.add<LowerForOp>(context);
    patterns.add<LowerTaskOp>(context);
    scf::ForOp::getCanonicalizationPatterns(patterns, context);
    hls::TaskOp::getCanonicalizationPatterns(patterns, context);
    patterns.add<RemoveITensorToStreamOp>(context);
    patterns.add<RemoveStreamToITensorOp>(context);
    patterns.add<DuplicateStreamOp>(context);
    (void)applyPatternsAndFoldGreedily(getOperation(), std::move(patterns));

    // Check if all itensor cast ops have been folded.
    auto checkResult = func.walk([&](Operation *op) {
      if (isa<hls::ITensorBufferOp, hls::ITensorReadFullTensorOp,
              hls::ITensorWriteFullTensorOp>(op)) {
        op->emitOpError("itensor_buffer, itensor_read_full_itensor, and "
                        "itensor_write_full_itensor ops, i.e. itensor DMA ops, "
                        "must have been materialized before lowering");
        return WalkResult::interrupt();
      } else if (isa<hls::ITensorToStreamOp, hls::StreamToITensorOp>(op)) {
        op->emitOpError("itensor_to_stream and stream_to_itensor ops should "
                        "have been folded");
        return WalkResult::interrupt();
      }
      return WalkResult::advance();
    });
    if (checkResult.wasInterrupted())
      return signalPassFailure();
  }
};
} // namespace
