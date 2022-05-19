//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Support/FileUtilities.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/TosaOpHelper.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"

#define DEBUG_TYPE "scalehls"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static bool replaceFunction(ModuleOp module, ConvOpHelper sharedHelper,
                            FuncOp funcOp) {
  auto builder = OpBuilder(module);

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Convert matching convolutions into CallOp to shared function.
  for (auto func : module.getOps<FuncOp>()) {
    if (func->getAttr("shared"))
      continue;

    // Instantiate a buffer for input of shared function
    builder.setInsertionPointToStart(&func.front());
    auto inputBufferAlloc = builder.create<memref::AllocOp>(
        func.getLoc(),
        MemRefType::get({sharedHelper.batchSize, sharedHelper.inWH,
                         sharedHelper.inWH, sharedHelper.inCh},
                        sharedHelper.inputType));
    auto inputBuffer = inputBufferAlloc.memref();

    // Instantiate a buffer for weight of shared function
    auto weightBufferAlloc = builder.create<memref::AllocOp>(
        func.getLoc(),
        MemRefType::get({sharedHelper.kernelSize, sharedHelper.kernelSize,
                         sharedHelper.inCh, sharedHelper.outCh},
                        sharedHelper.weightType));
    auto weightBuffer = weightBufferAlloc.memref();

    // Instantiate a buffer for output of shared function
    auto outputBufferAlloc = builder.create<memref::AllocOp>(
        func.getLoc(),
        MemRefType::get({sharedHelper.batchSize, sharedHelper.outWH,
                         sharedHelper.outWH, sharedHelper.outCh},
                        sharedHelper.outputType));
    auto outputBuffer = outputBufferAlloc.memref();

    func.walk([&](tosa::Conv2DOp conv2DOp) {
      auto loc = conv2DOp.getLoc();
      ConvOpHelper currHelper = ConvOpHelper(conv2DOp);

      if (!currHelper.equalAttr(sharedHelper))
        return;

      int64_t outChDiv =
          (currHelper.outCh + sharedHelper.outCh - 1) / sharedHelper.outCh;
      int64_t inChDiv =
          (currHelper.inCh + sharedHelper.inCh - 1) / sharedHelper.inCh;
      int64_t WHDiv =
          (currHelper.outWH + sharedHelper.outWH - 1) / sharedHelper.outWH;

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

        builder.setInsertionPoint(conv2DOp);
        auto outSubview =
            dyn_cast<memref::SubViewOp>(builder.insert(subview.clone()));
        subview.result().replaceAllUsesWith(outSubview.result());
        outMemref = outSubview.result();
        opToErase.push_back(subview);
      }

      // Create linalg generic for setting up output as bias
      builder.setInsertionPoint(conv2DOp);
      auto biasType = conv2DOp.bias().getType().dyn_cast<RankedTensorType>();
      auto biasToMemref = builder.create<bufferization::ToMemrefOp>(
          loc, MemRefType::get(biasType.getShape(), biasType.getElementType()),
          conv2DOp.bias());
      auto biasMemref = biasToMemref.memref();
      auto biasMap = AffineMap::get(4, 0, {builder.getAffineDimExpr(3)},
                                    builder.getContext());
      auto normalMap = AffineMap::get(
          4, 0,
          {builder.getAffineDimExpr(0), builder.getAffineDimExpr(1),
           builder.getAffineDimExpr(2), builder.getAffineDimExpr(3)},
          builder.getContext());
      auto parallel = StringRef("parallel");
      auto biasGeneric = builder.create<linalg::GenericOp>(
          loc, ValueRange({biasMemref}), ValueRange({outMemref}),
          ArrayRef({biasMap, normalMap}),
          ArrayRef({parallel, parallel, parallel, parallel}));
      auto biasGenericEntry = builder.createBlock(&biasGeneric.getBodyRegion());
      auto biasGenericArg0 =
          biasGenericEntry->addArgument(biasType.getElementType(), loc);
      biasGenericEntry->addArgument(sharedHelper.outputType, loc);
      builder.setInsertionPointToEnd(biasGenericEntry);
      builder.create<linalg::YieldOp>(loc, biasGenericArg0);

      // Create output channel loop
      builder.setInsertionPointAfter(biasGeneric);
      auto outChLoop = builder.create<AffineForOp>(loc, 0, outChDiv, 1);
      builder.setInsertionPointToStart(outChLoop.getBody());
      auto outChApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.outCh),
          outChLoop.getInductionVar());
      auto outCh = outChApply.getODSResults(0)[0];

      // Create input channel loop
      auto inChLoop = builder.create<AffineForOp>(loc, 0, inChDiv, 1);
      builder.setInsertionPointToStart(inChLoop.getBody());
      auto inChApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0, builder.getAffineDimExpr(0) * sharedHelper.inCh),
          inChLoop.getInductionVar());
      auto inCh = inChApply.getODSResults(0)[0];

      // Create width loop
      auto widthLoop = builder.create<AffineForOp>(loc, 0, WHDiv, 1);
      builder.setInsertionPointToStart(widthLoop.getBody());
      auto inWidthApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.outWH *
                             sharedHelper.stride),
          widthLoop.getInductionVar());
      auto inWidth = inWidthApply.getODSResults(0)[0];
      auto outWidthApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.outWH),
          widthLoop.getInductionVar());
      auto outWidth = outWidthApply.getODSResults(0)[0];

      // Create height loop
      auto heightLoop = builder.create<AffineForOp>(loc, 0, WHDiv, 1);
      builder.setInsertionPointToStart(heightLoop.getBody());
      auto inHeightApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.outWH *
                             sharedHelper.stride),
          heightLoop.getInductionVar());
      auto inHeight = inHeightApply.getODSResults(0)[0];
      auto outHeightApply = builder.create<AffineApplyOp>(
          loc,
          AffineMap::get(1, 0,
                         builder.getAffineDimExpr(0) * sharedHelper.outWH),
          heightLoop.getInductionVar());
      auto outHeight = outHeightApply.getODSResults(0)[0];

      // Slice inputs
      auto bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), inWidth, inHeight, inCh});
      auto bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(sharedHelper.batchSize),
           builder.getI64IntegerAttr(sharedHelper.inWH),
           builder.getI64IntegerAttr(sharedHelper.inWH),
           builder.getI64IntegerAttr(sharedHelper.inCh)});
      auto bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedInputSubview = builder.create<memref::SubViewOp>(
          loc, inMemref, bufOffset, bufSize, bufStride);
      builder.create<memref::CopyOp>(loc, slicedInputSubview.result(),
                                     inputBuffer);

      // Slice weights
      auto weightToMemref = builder.create<bufferization::ToMemrefOp>(
          loc,
          MemRefType::get({currHelper.outCh, currHelper.kernelSize,
                           currHelper.kernelSize, currHelper.inCh},
                          currHelper.weightType),
          conv2DOp.weight());
      auto weightMemref = weightToMemref.memref();
      bufOffset = ArrayRef<OpFoldResult>({outCh, builder.getI64IntegerAttr(0),
                                          builder.getI64IntegerAttr(0), inCh});
      bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(sharedHelper.outCh),
           builder.getI64IntegerAttr(sharedHelper.kernelSize),
           builder.getI64IntegerAttr(sharedHelper.kernelSize),
           builder.getI64IntegerAttr(sharedHelper.inCh)});
      bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedWeightSubview = builder.create<memref::SubViewOp>(
          loc, weightMemref, bufOffset, bufSize, bufStride);
      auto slicedWeight = slicedWeightSubview.result();

      // Reshape weight appropriately
      auto weightMap = AffineMap::get(
          4, 0,
          {builder.getAffineDimExpr(3), builder.getAffineDimExpr(0),
           builder.getAffineDimExpr(1), builder.getAffineDimExpr(2)},
          builder.getContext());
      auto weightGeneric = builder.create<linalg::GenericOp>(
          loc, ValueRange({slicedWeight}), ValueRange({weightBuffer}),
          ArrayRef({weightMap, normalMap}),
          ArrayRef({parallel, parallel, parallel, parallel}));
      auto weightGenericEntry =
          builder.createBlock(&weightGeneric.getBodyRegion());
      auto weightGenericArg0 =
          weightGenericEntry->addArgument(sharedHelper.weightType, loc);
      weightGenericEntry->addArgument(sharedHelper.weightType, loc);
      builder.setInsertionPointToEnd(weightGenericEntry);
      builder.create<linalg::YieldOp>(loc, weightGenericArg0);

      // Call function
      builder.setInsertionPointAfter(weightGeneric);
      auto operands = {inputBuffer, weightBuffer, outputBuffer};
      builder.create<func::CallOp>(loc, funcOp, operands);

      // Create a subview of the final output memref
      bufOffset = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(0), outWidth, outHeight, outCh});
      bufSize = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(sharedHelper.batchSize),
           builder.getI64IntegerAttr(sharedHelper.outWH),
           builder.getI64IntegerAttr(sharedHelper.outWH),
           builder.getI64IntegerAttr(sharedHelper.outCh)});
      bufStride = ArrayRef<OpFoldResult>(
          {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
           builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
      auto slicedOutput = builder.create<memref::SubViewOp>(
          loc, outMemref, bufOffset, bufSize, bufStride);

      // Add to sliced output
      auto outputGeneric = builder.create<linalg::GenericOp>(
          loc, ValueRange({outputBuffer}), ValueRange({slicedOutput}),
          ArrayRef({normalMap, normalMap}),
          ArrayRef({parallel, parallel, parallel, parallel}));
      auto outputGenericEntry =
          builder.createBlock(&outputGeneric.getBodyRegion());
      auto outputGenericArg0 =
          outputGenericEntry->addArgument(sharedHelper.outputType, loc);
      auto outputGenericArg1 =
          outputGenericEntry->addArgument(sharedHelper.outputType, loc);
      builder.setInsertionPointToEnd(outputGenericEntry);
      Operation *outputGenericAdd;
      if (sharedHelper.outputType == builder.getF32Type()) {
        outputGenericAdd = builder.create<arith::AddFOp>(
            loc, sharedHelper.outputType, outputGenericArg0, outputGenericArg1);
      } else {
        outputGenericAdd = builder.create<arith::AddIOp>(
            loc, sharedHelper.outputType, outputGenericArg0, outputGenericArg1);
      }
      builder.create<linalg::YieldOp>(loc, outputGenericAdd->getResult(0));

      opToErase.push_back(outCopy);
      opToErase.push_back(outToMemref);
      opToErase.push_back(conv2DOp);
      opToErase.push_back(inToTensor);
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

static bool
applyReplaceTensorOperation(ModuleOp module,
                            SmallVector<std::string> selectedFunctions,
                            bool dse, llvm::json::Object *solutionObj) {
  auto builder = OpBuilder(module);

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Traverse the entire module and replace ops with shared functions.
  for (auto func : module.getOps<FuncOp>()) {
    if (!func->getAttr("shared"))
      continue;

    bool selected = false;
    for (auto selectedFunction : selectedFunctions) {
      if (func.getSymName().str() == selectedFunction) {
        selected = true;
        break;
      }
    }

    if (selected) {
      // Replace conv ops if selected
      if (func->getAttr("type").dyn_cast<StringAttr>().str() == "convolution") {
        auto batchSize =
            func->getAttr("batchSize").dyn_cast<IntegerAttr>().getInt();
        auto inCh = func->getAttr("inCh").dyn_cast<IntegerAttr>().getInt();
        auto inWH = func->getAttr("inWH").dyn_cast<IntegerAttr>().getInt();
        auto outCh = func->getAttr("outCh").dyn_cast<IntegerAttr>().getInt();
        auto outWH = func->getAttr("outWH").dyn_cast<IntegerAttr>().getInt();
        auto kernelSize =
            func->getAttr("kernelSize").dyn_cast<IntegerAttr>().getInt();
        auto pad = func->getAttr("pad").dyn_cast<IntegerAttr>().getInt();
        auto stride = func->getAttr("stride").dyn_cast<IntegerAttr>().getInt();
        auto dilation =
            func->getAttr("dilation").dyn_cast<IntegerAttr>().getInt();
        auto convOpHelper = ConvOpHelper(batchSize, inCh, inWH, outCh, outWH,
                                         kernelSize, pad, stride, dilation);
        convOpHelper.inputType =
            func.getArgumentTypes()[0].dyn_cast<MemRefType>().getElementType();
        convOpHelper.weightType =
            func.getArgumentTypes()[1].dyn_cast<MemRefType>().getElementType();
        convOpHelper.outputType =
            func.getArgumentTypes()[2].dyn_cast<MemRefType>().getElementType();

        replaceFunction(module, convOpHelper, func);

        if (!dse) {
          auto funcObj = solutionObj->getObject(func.getSymName());
          auto strategy = *funcObj->getArray("strategy");
          auto inChUnrollFactor = strategy[0].getAsInteger().getValueOr(1);
          auto outChUnrollFactor = strategy[1].getAsInteger().getValueOr(1);
          AffineLoopBands bands;
          getLoopBands(func.front(), bands);

          bands[0][3]->setAttr("unroll",
                               builder.getI64IntegerAttr(outChUnrollFactor));
          bands[0][6]->setAttr("unroll",
                               builder.getI64IntegerAttr(inChUnrollFactor));
        }
      }
    } else {
      // Remove function if not selected
      opToErase.push_back(func);
    }
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

namespace {
struct ReplaceTensorOperation
    : public ReplaceTensorOperationBase<ReplaceTensorOperation> {
  void runOnOperation() override {
    auto module = getOperation();

    std::string errorMessage;
    auto solutionFile = mlir::openInputFile(ILPSolution, &errorMessage);
    if (!solutionFile) {
      llvm::errs() << errorMessage << "\n";
      return signalPassFailure();
    }

    // Parse JSON File into memory.
    auto solution = llvm::json::parse(solutionFile->getBuffer());
    if (!solution) {
      llvm::errs() << "failed to parse the ILP strategy json file\n";
      return signalPassFailure();
    }
    auto solutionObj = solution.get().getAsObject();
    if (!solutionObj) {
      llvm::errs() << "support an object in the ILP strategy json file, found "
                      "something else\n";
      return signalPassFailure();
    }

    SmallVector<std::string> selectedFunctions;
    auto solutionArray = solutionObj->getArray("selected");
    for (auto selected : *solutionArray) {
      selectedFunctions.push_back(selected.getAsString().getValueOr("").str());
    }

    SmallVector<int64_t> unrolls;
    auto dse = solutionObj->getBoolean("dse").getValueOr(true);

    applyReplaceTensorOperation(module, selectedFunctions, dse, solutionObj);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createReplaceTensorOperationPass() {
  return std::make_unique<ReplaceTensorOperation>();
}
