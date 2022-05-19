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
        builder.setInsertionPoint(conv2DOp);
        auto helper = ConvOpHelper(conv2DOp);

        // Input MemRef object allocated off-chip
        bufferization::ToTensorOp inToTensor;
        if (conv2DOp.input().getDefiningOp()) {
          if (auto toTensor = dyn_cast<bufferization::ToTensorOp>(
                  conv2DOp.input().getDefiningOp())) {
            inToTensor = toTensor;
          }
        }
        auto inMemref = inToTensor.memref();

        // Output MemRef object allocated off-chip
        bufferization::ToMemrefOp outToMemref;
        for (auto user : conv2DOp.output().getUsers()) {
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

          auto outSubview =
              dyn_cast<memref::SubViewOp>(builder.insert(subview.clone()));
          subview.result().replaceAllUsesWith(outSubview.result());
          outMemref = outSubview.result();
          opToErase.push_back(subview);
        }

        // Instantiate a buffer for weight of shared function
        auto newWeightType = MemRefType::get(
            {helper.kernelSize, helper.kernelSize, helper.inCh, helper.outCh},
            helper.weightType);
        auto weightBuffer = func.front().addArgument(newWeightType, loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Convert weight to memref
        auto weightToMemref = builder.create<bufferization::ToMemrefOp>(
            loc,
            MemRefType::get({helper.outCh, helper.kernelSize, helper.kernelSize,
                             helper.inCh},
                            helper.weightType),
            conv2DOp.weight());
        auto weightMemref = weightToMemref.memref();

        // Reshape weight appropriately
        auto weightMap = AffineMap::get(
            4, 0,
            {builder.getAffineDimExpr(3), builder.getAffineDimExpr(0),
             builder.getAffineDimExpr(1), builder.getAffineDimExpr(2)},
            builder.getContext());
        auto normalMap = AffineMap::get(
            4, 0,
            {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
             builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
            builder.getContext());
        auto parallel = StringRef("parallel");
        auto weightGeneric = builder.create<linalg::GenericOp>(
            loc, ValueRange({weightMemref}), ValueRange({weightBuffer}),
            ArrayRef({weightMap, normalMap}),
            ArrayRef({parallel, parallel, parallel, parallel}));
        auto weightGenericEntry =
            builder.createBlock(&weightGeneric.getBodyRegion());
        auto weightGenericArg0 =
            weightGenericEntry->addArgument(helper.weightType, loc);
        weightGenericEntry->addArgument(helper.weightType, loc);
        builder.setInsertionPointToEnd(weightGenericEntry);
        builder.create<linalg::YieldOp>(loc, weightGenericArg0);

        // Create a linalg convolution
        auto stride = NamedAttribute(
            builder.getStringAttr("strides"),
            builder.getI64TensorAttr({helper.stride, helper.stride}));
        auto dilation = NamedAttribute(
            builder.getStringAttr("dilations"),
            builder.getI64TensorAttr({helper.dilation, helper.dilation}));
        builder.setInsertionPointAfter(weightGeneric);
        builder.create<linalg::Conv2DNhwcHwcfOp>(
            builder.getUnknownLoc(), ValueRange({inMemref, weightBuffer}),
            ValueRange({outMemref}), ArrayRef({stride, dilation}));

        // Create linalg generic for adding bias
        auto biasType = conv2DOp.bias().getType().dyn_cast<RankedTensorType>();
        auto biasToMemref = builder.create<bufferization::ToMemrefOp>(
            loc,
            MemRefType::get(biasType.getShape(), biasType.getElementType()),
            conv2DOp.bias());
        auto biasMemref = biasToMemref.memref();
        auto biasMap = AffineMap::get(4, 0, {builder.getAffineDimExpr(3)},
                                      builder.getContext());
        auto outputGeneric = builder.create<linalg::GenericOp>(
            loc, ValueRange({outMemref, biasMemref}), ValueRange({outMemref}),
            ArrayRef({normalMap, biasMap, normalMap}),
            ArrayRef({parallel, parallel, parallel, parallel}));
        auto outputGenericEntry =
            builder.createBlock(&outputGeneric.getBodyRegion());
        auto outputGenericArg0 =
            outputGenericEntry->addArgument(helper.outputType, loc);
        auto outputGenericArg1 =
            outputGenericEntry->addArgument(biasType.getElementType(), loc);
        outputGenericEntry->addArgument(helper.outputType, loc);
        builder.setInsertionPointToEnd(outputGenericEntry);
        Operation *outputGenericAdd;
        if (helper.outputType == builder.getF32Type()) {
          outputGenericAdd = builder.create<arith::AddFOp>(
              loc, helper.outputType, outputGenericArg0, outputGenericArg1);
        } else {
          outputGenericAdd = builder.create<arith::AddIOp>(
              loc, helper.outputType, outputGenericArg0, outputGenericArg1);
        }
        builder.create<linalg::YieldOp>(loc, outputGenericAdd->getResult(0));

        opToErase.push_back(outCopy);
        opToErase.push_back(outToMemref);
        opToErase.push_back(conv2DOp);
        opToErase.push_back(inToTensor);
      }

      else if (auto reluNOp = dyn_cast<tosa::ReluNOp>(op)) {
        builder.setInsertionPoint(reluNOp);

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
        Value zeroConstant;
        if (inputElementType == builder.getF32Type()) {
          zeroConstant = builder.create<arith::ConstantOp>(
              loc, builder.getF32FloatAttr(0));
        } else {
          zeroConstant = builder.create<arith::ConstantIntOp>(
              loc, 0, inputElementType.getIntOrFloatBitWidth());
        }
        auto rank =
            reluNOp.input().getType().dyn_cast<RankedTensorType>().getRank();
        AffineMap normalMap;
        ArrayRef<StringRef> iteratorType;
        if (rank == 2) {
          normalMap = AffineMap::get(
              2, 0, {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1)},
              builder.getContext());
          auto parallel = StringRef("parallel");
          iteratorType = ArrayRef({parallel, parallel});
        } else if (rank == 4) {
          normalMap = AffineMap::get(
              4, 0,
              {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
               builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
              builder.getContext());
          auto parallel = StringRef("parallel");
          iteratorType = ArrayRef({parallel, parallel, parallel, parallel});
        }
        auto reluGeneric = builder.create<linalg::GenericOp>(
            loc, ValueRange({inMemref}), ValueRange({outMemref}),
            ArrayRef({normalMap, normalMap}), iteratorType);
        auto reluGenericEntry =
            builder.createBlock(&reluGeneric.getBodyRegion());
        auto reluGenericArg0 =
            reluGenericEntry->addArgument(inputElementType, loc);
        reluGenericEntry->addArgument(outputElementType, loc);
        builder.setInsertionPointToEnd(reluGenericEntry);
        Operation *reluGenericCmp;
        if (inputElementType == builder.getF32Type()) {
          reluGenericCmp = builder.create<arith::CmpFOp>(
              loc, arith::CmpFPredicate::OLT, reluGenericArg0, zeroConstant);
        } else {
          reluGenericCmp = builder.create<arith::CmpIOp>(
              loc, arith::CmpIPredicate::slt, reluGenericArg0, zeroConstant);
        }
        auto reluGenericSelect = builder.create<arith::SelectOp>(
            loc, reluGenericCmp->getResult(0), zeroConstant, reluGenericArg0);
        builder.create<linalg::YieldOp>(loc, reluGenericSelect.getResult());

        opToErase.push_back(outCopy);
        opToErase.push_back(outToMemref);
        opToErase.push_back(reluNOp);
        opToErase.push_back(inToTensor);
      }

      else if (auto clampOp = dyn_cast<tosa::ClampOp>(op)) {
        builder.setInsertionPoint(clampOp);

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
        Value zeroConstant;
        if (inputElementType == builder.getF32Type()) {
          zeroConstant =
              builder.create<arith::ConstantOp>(loc, clampOp.min_fpAttr());
        } else {
          zeroConstant = builder.create<arith::ConstantIntOp>(
              loc, clampOp.min_intAttr().getValue().getSExtValue(),
              inputElementType.getIntOrFloatBitWidth());
        }
        auto rank =
            clampOp.input().getType().dyn_cast<RankedTensorType>().getRank();
        AffineMap normalMap;
        ArrayRef<StringRef> iteratorType;
        if (rank == 2) {
          normalMap = AffineMap::get(
              2, 0, {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1)},
              builder.getContext());
          auto parallel = StringRef("parallel");
          iteratorType = ArrayRef({parallel, parallel});
        } else if (rank == 4) {
          normalMap = AffineMap::get(
              4, 0,
              {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
               builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
              builder.getContext());
          auto parallel = StringRef("parallel");
          iteratorType = ArrayRef({parallel, parallel, parallel, parallel});
        }
        auto clampGeneric = builder.create<linalg::GenericOp>(
            loc, ValueRange({inMemref}), ValueRange({outMemref}),
            ArrayRef({normalMap, normalMap}), iteratorType);
        auto clampGenericEntry =
            builder.createBlock(&clampGeneric.getBodyRegion());
        auto clampGenericArg0 =
            clampGenericEntry->addArgument(inputElementType, loc);
        clampGenericEntry->addArgument(outputElementType, loc);
        builder.setInsertionPointToEnd(clampGenericEntry);
        Operation *clampGenericCmp;
        if (inputElementType == builder.getF32Type()) {
          clampGenericCmp = builder.create<arith::CmpFOp>(
              loc, arith::CmpFPredicate::OLT, clampGenericArg0, zeroConstant);
        } else {
          clampGenericCmp = builder.create<arith::CmpIOp>(
              loc, arith::CmpIPredicate::slt, clampGenericArg0, zeroConstant);
        }
        auto clampGenericSelect = builder.create<arith::SelectOp>(
            loc, clampGenericCmp->getResult(0), zeroConstant, clampGenericArg0);
        builder.create<linalg::YieldOp>(loc, clampGenericSelect.getResult());

        opToErase.push_back(outCopy);
        opToErase.push_back(outToMemref);
        opToErase.push_back(clampOp);
        opToErase.push_back(inToTensor);
      }

      else if (auto avgPool2DOp = dyn_cast<tosa::AvgPool2dOp>(op)) {
        builder.setInsertionPoint(avgPool2DOp);

        // Input MemRef object allocated off-chip
        bufferization::ToTensorOp inToTensor;
        if (avgPool2DOp.input().getDefiningOp()) {
          if (auto toTensor = dyn_cast<bufferization::ToTensorOp>(
                  avgPool2DOp.input().getDefiningOp())) {
            inToTensor = toTensor;
          }
        }
        auto inMemref = inToTensor.memref();

        // Output MemRef object allocated off-chip
        bufferization::ToMemrefOp outToMemref;
        for (auto user : avgPool2DOp.output().getUsers()) {
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

          auto outSubview =
              dyn_cast<memref::SubViewOp>(builder.insert(subview.clone()));
          subview.result().replaceAllUsesWith(outSubview.result());
          outMemref = outSubview.result();
          opToErase.push_back(subview);
        }

        // Create linalg pool sum
        auto strideValue =
            avgPool2DOp.stride()[0].dyn_cast<IntegerAttr>().getInt();
        auto stride = NamedAttribute(
            builder.getStringAttr("strides"),
            builder.getI64VectorAttr({strideValue, strideValue}));
        auto dilation = NamedAttribute(builder.getStringAttr("dilations"),
                                       builder.getI64VectorAttr({1, 1}));
        auto inputType =
            avgPool2DOp.input().getType().dyn_cast<RankedTensorType>();
        auto kernelValue =
            avgPool2DOp.kernel()[0].dyn_cast<IntegerAttr>().getInt();
        auto inputElementType = inputType.getElementType();
        auto accumulator = builder.create<memref::AllocOp>(
            loc, MemRefType::get(ArrayRef({kernelValue, kernelValue}),
                                 inputElementType));
        builder.create<linalg::PoolingNhwcSumOp>(
            loc, ValueRange({inMemref, accumulator}), ValueRange({outMemref}),
            ArrayRef({stride, dilation}));

        // Create linalg generic for division
        Value divConstant;
        if (inputElementType == builder.getF32Type()) {
          divConstant = builder.create<arith::ConstantOp>(
              loc, builder.getF32FloatAttr(kernelValue * kernelValue));
        } else {
          divConstant = builder.create<arith::ConstantIntOp>(
              loc, kernelValue * kernelValue,
              inputElementType.getIntOrFloatBitWidth());
        }
        auto normalMap = AffineMap::get(
            4, 0,
            {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
             builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
            builder.getContext());
        auto parallel = StringRef("parallel");
        auto outputGeneric = builder.create<linalg::GenericOp>(
            loc, ValueRange({outMemref}), ValueRange({outMemref}),
            ArrayRef({normalMap, normalMap}),
            ArrayRef({parallel, parallel, parallel, parallel}));
        auto outputGenericEntry =
            builder.createBlock(&outputGeneric.getBodyRegion());
        auto outputGenericArg0 =
            outputGenericEntry->addArgument(inputElementType, loc);
        outputGenericEntry->addArgument(inputElementType, loc);
        builder.setInsertionPointToEnd(outputGenericEntry);
        Operation *outputGenericDiv;
        if (inputElementType == builder.getF32Type()) {
          outputGenericDiv = builder.create<arith::DivFOp>(
              loc, inputElementType, outputGenericArg0, divConstant);
        } else {
          outputGenericDiv = builder.create<arith::DivSIOp>(
              loc, inputElementType, outputGenericArg0, divConstant);
        }
        builder.create<linalg::YieldOp>(loc, outputGenericDiv->getResult(0));

        opToErase.push_back(outCopy);
        opToErase.push_back(outToMemref);
        opToErase.push_back(avgPool2DOp);
        opToErase.push_back(inToTensor);
      }

      else if (auto maxPool2DOp = dyn_cast<tosa::MaxPool2dOp>(op)) {
        builder.setInsertionPoint(maxPool2DOp);

        // Input MemRef object allocated off-chip
        bufferization::ToTensorOp inToTensor;
        if (maxPool2DOp.input().getDefiningOp()) {
          if (auto toTensor = dyn_cast<bufferization::ToTensorOp>(
                  maxPool2DOp.input().getDefiningOp())) {
            inToTensor = toTensor;
          }
        }
        auto inMemref = inToTensor.memref();

        // Output MemRef object allocated off-chip
        bufferization::ToMemrefOp outToMemref;
        for (auto user : maxPool2DOp.output().getUsers()) {
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

          auto outSubview =
              dyn_cast<memref::SubViewOp>(builder.insert(subview.clone()));
          subview.result().replaceAllUsesWith(outSubview.result());
          outMemref = outSubview.result();
          opToErase.push_back(subview);
        }

        // Create linalg pool max
        auto strideValue =
            maxPool2DOp.stride()[0].dyn_cast<IntegerAttr>().getInt();
        auto stride = NamedAttribute(
            builder.getStringAttr("strides"),
            builder.getI64VectorAttr({strideValue, strideValue}));
        auto dilation = NamedAttribute(builder.getStringAttr("dilations"),
                                       builder.getI64VectorAttr({1, 1}));
        auto inputType =
            maxPool2DOp.input().getType().dyn_cast<RankedTensorType>();
        auto kernelValue =
            maxPool2DOp.kernel()[0].dyn_cast<IntegerAttr>().getInt();
        auto inputElementType = inputType.getElementType();
        auto accumulator = builder.create<memref::AllocOp>(
            loc, MemRefType::get(ArrayRef({kernelValue, kernelValue}),
                                 inputElementType));
        builder.create<linalg::PoolingNhwcMaxOp>(
            loc, ValueRange({inMemref, accumulator}), ValueRange({outMemref}),
            ArrayRef({stride, dilation}));

        opToErase.push_back(outCopy);
        opToErase.push_back(outToMemref);
        opToErase.push_back(maxPool2DOp);
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
