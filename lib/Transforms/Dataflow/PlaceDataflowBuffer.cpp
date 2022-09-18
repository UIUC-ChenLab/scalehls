//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Dominance.h"
#include "mlir/Transforms/DialectConversion.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace {
template <typename OpType>
struct BufferConversionPattern : public OpRewritePattern<OpType> {
  using OpRewritePattern<OpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(OpType op,
                                PatternRewriter &rewriter) const override {
    rewriter.replaceOpWithNewOp<BufferOp>(op, op.getType());
    return success();
  }
};
} // namespace

MemRefType getNewType(MemRefType type) {
  // TODO: For now, we just use a heuristic to determine the buffer
  // placement location.
  auto kind = MemoryKind::DRAM;
  if (type.getNumElements() < 1024)
    kind = MemoryKind::BRAM_S2P;

  // We use MemorySpaceInt of MemRefType to represent the space of
  // buffers. Here, we set the new memref type.
  auto newType =
      MemRefType::get(type.getShape(), type.getElementType(),
                      type.getLayout().getAffineMap(), (unsigned)kind);
  return newType;
}

MemRefType getNewDramType(MemRefType type) {
  auto newType = MemRefType::get(type.getShape(), type.getElementType(),
                                 type.getLayout().getAffineMap(),
                                 (unsigned)MemoryKind::DRAM);
  return newType;
}

namespace {
struct PlaceDataflowBufferPattern : public OpRewritePattern<ScheduleOp> {
  using OpRewritePattern<ScheduleOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(ScheduleOp schedule,
                                PatternRewriter &rewriter) const override {
    llvm::SmallDenseSet<Value, 4> outputs(
        schedule.getReturnOp().operand_begin(),
        schedule.getReturnOp().operand_end());

    for (auto task : llvm::make_early_inc_range(schedule.getOps<TaskOp>())) {
      // Update the task argument type.
      for (auto t :
           llvm::zip(task.getBody().getArguments(), task.getOperandTypes()))
        std::get<0>(t).setType(std::get<1>(t));

      SmallVector<Value, 4> buffers;
      SmallVector<Location, 4> locs;
      for (auto buffer : llvm::make_early_inc_range(
               task.getOps<hls::BufferLikeInterface>())) {
        auto memref = buffer.getMemref();
        auto type = buffer.getMemrefType();
        if (llvm::any_of(buffer->getUses(), [&](OpOperand &use) {
              return use.getOwner() == task.getYieldOp() &&
                     outputs.count(task.getResult(use.getOperandNumber()));
            }))
          memref.setType(getNewDramType(type));
        else
          memref.setType(getNewType(type));

        // Move the buffer outside of task.
        buffer->moveBefore(task);
        buffers.push_back(memref);
        locs.push_back(buffer.getLoc());
      }

      if (!buffers.empty()) {
        auto args = task.getBody().addArguments(ValueRange(buffers), locs);
        for (auto t : llvm::zip(buffers, args))
          std::get<0>(t).replaceAllUsesWith(std::get<1>(t));

        SmallVector<Value, 16> newInputs(task.getInputs());
        newInputs.append(buffers.begin(), buffers.end());
        rewriter.setInsertionPoint(task);
        auto newTask = rewriter.create<TaskOp>(
            task.getLoc(), task.getYieldOp().getOperandTypes(), newInputs);
        rewriter.inlineRegionBefore(task.getBody(), newTask.getBody(),
                                    newTask.getBody().end());

        rewriter.replaceOp(task, newTask.getResults());
      }
    }

    for (auto t : llvm::zip(schedule.getResults(),
                            schedule.getReturnOp().getOperandTypes()))
      std::get<0>(t).setType(std::get<1>(t));
    return success();
  }
};
} // namespace

namespace {
struct PlaceDataflowBuffer
    : public PlaceDataflowBufferBase<PlaceDataflowBuffer> {
  void runOnOperation() override {
    auto func = getOperation();
    auto context = func.getContext();

    for (auto arg : func.getArguments())
      if (auto type = arg.getType().dyn_cast<MemRefType>())
        arg.setType(getNewDramType(type));

    mlir::RewritePatternSet patterns(context);
    patterns.add<BufferConversionPattern<memref::AllocOp>>(context);
    patterns.add<BufferConversionPattern<memref::AllocaOp>>(context);
    (void)applyPatternsAndFoldGreedily(func, std::move(patterns));

    patterns.clear();
    patterns.add<PlaceDataflowBufferPattern>(context);
    auto frozenPatterns = FrozenRewritePatternSet(std::move(patterns));
    func.walk([&](ScheduleOp schedule) {
      (void)applyOpPatternsAndFold(schedule, frozenPatterns);
    });

    func.setType(
        FunctionType::get(context, func.front().getArgumentTypes(),
                          func.front().getTerminator()->getOperandTypes()));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createPlaceDataflowBufferPass() {
  return std::make_unique<PlaceDataflowBuffer>();
}
