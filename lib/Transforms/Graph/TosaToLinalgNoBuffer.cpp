//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Pass/PassManager.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/TosaOpHelper.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static bool applyTosaToLinalgNoBuffer(ModuleOp module) {
  auto builder = OpBuilder(module);

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  for (auto func : module.getOps<FuncOp>()) {
    if (func->getAttr("shared"))
      continue;

    func.walk([&](Operation *op) {
      auto loc = op->getLoc();

      if (auto conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
      }

      else if (auto reluNOp = dyn_cast<tosa::ReluNOp>(op)) {
        // Input MemRef object allocated off-chip
        bufferization::ToTensorOp inToTensor;
        if (reluNOp.input().getDefiningOp()) {
          if (auto toTensor = dyn_cast<bufferization::ToTensorOp>(
                  reluNOp.input().getDefiningOp())) {
            inToTensor = toTensor;
          }
        }
        auto inMemref = inToTensor.memref();

        // Output MemRef object allocated off-chip
        bufferization::ToMemrefOp outToMemref;
        for (auto user : reluNOp.output().getUsers()) {
          if (auto toMemref = dyn_cast<bufferization::ToMemrefOp>(user)) {
            outToMemref = toMemref;
          }
        }
        memref::CopyOp outCopy;
        for (auto user : outToMemref.memref().getUsers()) {
          if (auto copy = dyn_cast<memref::CopyOp>(user)) {
            outCopy = copy;
          }
        }
        Value outMemref = outCopy.target();
        Value outMemrefArg = outMemref;
        memref::SubViewOp outSubview;
        if (outMemref.getDefiningOp()) {
          auto subview = dyn_cast<memref::SubViewOp>(outMemref.getDefiningOp());
          outMemrefArg = subview.source();

          builder.setInsertionPoint(reluNOp);
          auto outSubview =
              dyn_cast<memref::SubViewOp>(builder.insert(subview.clone()));
          subview.result().replaceAllUsesWith(outSubview.result());
          outMemref = outSubview.result();
          opToErase.push_back(subview);
        }

        // Create linalg generic for relu
        auto inputElementType = reluNOp.input()
                                    .getType()
                                    .dyn_cast<RankedTensorType>()
                                    .getElementType();
        auto outputElementType = reluNOp.output()
                                     .getType()
                                     .dyn_cast<RankedTensorType>()
                                     .getElementType();
        auto zeroConstant =
            builder.create<arith::ConstantOp>(loc, builder.getF32FloatAttr(0));
        auto normalMap = AffineMap::get(
            4, 0,
            {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
             builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
            builder.getContext());
        auto parallel = StringRef("parallel");
        auto reluGeneric = builder.create<linalg::GenericOp>(
            loc, ValueRange({inMemref}), ValueRange({outMemref}),
            ArrayRef({normalMap, normalMap}),
            ArrayRef({parallel, parallel, parallel, parallel}));
        auto reluGenericEntry =
            builder.createBlock(&reluGeneric.getBodyRegion());
        auto reluGenericArg0 =
            reluGenericEntry->addArgument(inputElementType, loc);
        reluGenericEntry->addArgument(outputElementType, loc);
        builder.setInsertionPointToEnd(reluGenericEntry);
        auto reluGenericCmpF = builder.create<arith::CmpFOp>(
            loc, arith::CmpFPredicate::OLT, reluGenericArg0, zeroConstant);
        auto reluGenericSelect = builder.create<arith::SelectOp>(
            loc, reluGenericCmpF.getResult(), zeroConstant, reluGenericArg0);
        builder.create<linalg::YieldOp>(loc, reluGenericSelect.getResult());

        opToErase.push_back(outCopy);
        opToErase.push_back(outToMemref);
        opToErase.push_back(reluNOp);
        opToErase.push_back(inToTensor);
      }

      else if (auto clampOp = dyn_cast<tosa::ClampOp>(op)) {
        // Input MemRef object allocated off-chip
        bufferization::ToTensorOp inToTensor;
        if (clampOp.input().getDefiningOp()) {
          if (auto toTensor = dyn_cast<bufferization::ToTensorOp>(
                  clampOp.input().getDefiningOp())) {
            inToTensor = toTensor;
          }
        }
        auto inMemref = inToTensor.memref();

        // Output MemRef object allocated off-chip
        bufferization::ToMemrefOp outToMemref;
        for (auto user : clampOp.output().getUsers()) {
          if (auto toMemref = dyn_cast<bufferization::ToMemrefOp>(user)) {
            outToMemref = toMemref;
          }
        }
        memref::CopyOp outCopy;
        for (auto user : outToMemref.memref().getUsers()) {
          if (auto copy = dyn_cast<memref::CopyOp>(user)) {
            outCopy = copy;
          }
        }
        Value outMemref = outCopy.target();
        Value outMemrefArg = outMemref;
        memref::SubViewOp outSubview;
        if (outMemref.getDefiningOp()) {
          auto subview = dyn_cast<memref::SubViewOp>(outMemref.getDefiningOp());
          outMemrefArg = subview.source();

          builder.setInsertionPoint(clampOp);
          auto outSubview =
              dyn_cast<memref::SubViewOp>(builder.insert(subview.clone()));
          subview.result().replaceAllUsesWith(outSubview.result());
          outMemref = outSubview.result();
          opToErase.push_back(subview);
        }

        // Create linalg generic for clamp
        auto inputElementType = clampOp.input()
                                    .getType()
                                    .dyn_cast<RankedTensorType>()
                                    .getElementType();
        auto outputElementType = clampOp.output()
                                     .getType()
                                     .dyn_cast<RankedTensorType>()
                                     .getElementType();
        auto zeroConstant =
            builder.create<arith::ConstantOp>(loc, clampOp.min_fpAttr());
        auto normalMap = AffineMap::get(
            4, 0,
            {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
             builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
            builder.getContext());
        auto parallel = StringRef("parallel");
        auto clampGeneric = builder.create<linalg::GenericOp>(
            loc, ValueRange({inMemref}), ValueRange({outMemref}),
            ArrayRef({normalMap, normalMap}),
            ArrayRef({parallel, parallel, parallel, parallel}));
        auto clampGenericEntry =
            builder.createBlock(&clampGeneric.getBodyRegion());
        auto clampGenericArg0 =
            clampGenericEntry->addArgument(inputElementType, loc);
        clampGenericEntry->addArgument(outputElementType, loc);
        builder.setInsertionPointToEnd(clampGenericEntry);
        auto clampGenericCmpF = builder.create<arith::CmpFOp>(
            loc, arith::CmpFPredicate::OLT, clampGenericArg0, zeroConstant);
        auto clampGenericSelect = builder.create<arith::SelectOp>(
            loc, clampGenericCmpF.getResult(), zeroConstant, clampGenericArg0);
        builder.create<linalg::YieldOp>(loc, clampGenericSelect.getResult());

        opToErase.push_back(outCopy);
        opToErase.push_back(outToMemref);
        opToErase.push_back(clampOp);
        opToErase.push_back(inToTensor);
      }
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

namespace {
struct TosaToLinalgNoBuffer
    : public TosaToLinalgNoBufferBase<TosaToLinalgNoBuffer> {
  void runOnOperation() override {
    auto module = getOperation();
    applyTosaToLinalgNoBuffer(module);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createTosaToLinalgNoBufferPass() {
  return std::make_unique<TosaToLinalgNoBuffer>();
}
