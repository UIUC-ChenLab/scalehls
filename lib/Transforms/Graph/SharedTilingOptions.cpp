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

static SmallVector<ConvOpHelper, 32>
exploreTilingStrategy(ModuleOp module,
                      SmallVector<OpHelper *, 32> convOpHelpers) {
  SmallVector<ConvOpHelper, 32> tilingOptions;
  ConvOpHelper finalTiling =
      ConvOpHelper(*dyn_cast<ConvOpHelper>(convOpHelpers[0]));
  for (auto helper : convOpHelpers) {
    finalTiling.takeSmallerDim(*dyn_cast<ConvOpHelper>(helper));
  }
  tilingOptions.push_back(finalTiling);

  return tilingOptions;
}

static FuncOp createSharedConvolution(ModuleOp module, ConvOpHelper helper,
                                      StringRef functionName) {
  auto builder = OpBuilder(module);

  // Create a shared function that contains helper's convolution
  SmallVector<Type, 16> inputTypes;
  auto inputShape = ArrayRef<int64_t>(
      {helper.batchSize, helper.inWH, helper.inWH, helper.inCh});
  auto inputType = MemRefType::get((inputShape), helper.inputType);
  inputTypes.push_back(inputType);

  auto weightShape = ArrayRef<int64_t>(
      {helper.kernelSize, helper.kernelSize, helper.inCh, helper.outCh});
  auto weightType = MemRefType::get((weightShape), helper.weightType);
  inputTypes.push_back(weightType);

  auto resultShape = ArrayRef<int64_t>(
      {helper.batchSize, helper.outWH, helper.outWH, helper.outCh});
  auto resultType = MemRefType::get((resultShape), helper.outputType);
  inputTypes.push_back(resultType);

  // Define function
  auto newType = builder.getFunctionType(inputTypes, TypeRange());
  builder.setInsertionPointToStart(module.getBody());
  auto newFuncOp =
      builder.create<FuncOp>(builder.getUnknownLoc(), functionName, newType);
  newFuncOp->setAttr("shared", builder.getUnitAttr());
  newFuncOp->setAttr("type", builder.getStringAttr("convolution"));
  newFuncOp->setAttr("count", builder.getI64IntegerAttr(0));
  newFuncOp->setAttr("batchSize", builder.getI64IntegerAttr(helper.batchSize));
  newFuncOp->setAttr("inCh", builder.getI64IntegerAttr(helper.inCh));
  newFuncOp->setAttr("inWH", builder.getI64IntegerAttr(helper.inWH));
  newFuncOp->setAttr("outCh", builder.getI64IntegerAttr(helper.outCh));
  newFuncOp->setAttr("outWH", builder.getI64IntegerAttr(helper.outWH));
  newFuncOp->setAttr("kernelSize",
                     builder.getI64IntegerAttr(helper.kernelSize));
  newFuncOp->setAttr("pad", builder.getI64IntegerAttr(helper.pad));
  newFuncOp->setAttr("stride", builder.getI64IntegerAttr(helper.stride));
  newFuncOp->setAttr("dilation", builder.getI64IntegerAttr(helper.dilation));

  auto entryBlock = newFuncOp.addEntryBlock();
  builder.setInsertionPointToStart(entryBlock);

  // Get parameters
  auto input = entryBlock->getArgument(0);
  auto weight = entryBlock->getArgument(1);
  auto output = entryBlock->getArgument(2);

  // Create a linalg convolution
  auto stride =
      NamedAttribute(builder.getStringAttr("strides"),
                     builder.getI64TensorAttr({helper.stride, helper.stride}));
  auto dilation = NamedAttribute(
      builder.getStringAttr("dilations"),
      builder.getI64TensorAttr({helper.dilation, helper.dilation}));
  builder.create<linalg::Conv2DNhwcHwcfOp>(
      builder.getUnknownLoc(), ValueRange({input, weight}),
      ValueRange({output}), ArrayRef({stride, dilation}));

  builder.create<func::ReturnOp>(builder.getUnknownLoc());
  return newFuncOp;
}

static bool applySharedTilingOptions(ModuleOp module, unsigned numTargets) {
  // Count the number of each shape of convolution.
  DenseMap<OpHelper, SmallVector<OpHelper *, 32>> countMap;
  // Traverse the entire module and count all the convolutions.
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](Operation *op) {
      if (auto conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvOpHelper *helper = new ConvOpHelper(conv2DOp);
        if (!countMap.count(*helper)) {
          countMap[*helper] = SmallVector<OpHelper *, 32>();
          countMap[*helper].push_back(helper);
        } else {
          countMap[*helper].push_back(helper);
        }
      }
    });
  }

  // Find the types of convolutions that happen frequently and create functions
  // with different tilings
  OpHelper *opHelper;
  for (unsigned i = 0; i < numTargets || numTargets == 0; i++) {
    unsigned maxCount = 0;
    for (auto item : countMap) {
      if (item.second.size() > maxCount) {
        opHelper = item.second[0];
        maxCount = item.second.size();
      }
    }
    if (maxCount == 0)
      break;
    else {
      if (auto convOpHelper = dyn_cast<ConvOpHelper>(opHelper)) {
        SmallVector<ConvOpHelper> tilingOptions =
            exploreTilingStrategy(module, countMap[*opHelper]);
        countMap.erase(*opHelper);
        for (unsigned j = 0; j < tilingOptions.size(); j++) {
          auto functionName =
              "shared_function_" + std::to_string(i) + "_" + std::to_string(j);
          createSharedConvolution(module, tilingOptions[j], functionName);
        }
      }
    }
  }

  return true;
}

namespace {
struct SharedTilingOptions
    : public SharedTilingOptionsBase<SharedTilingOptions> {
  void runOnOperation() override {
    auto module = getOperation();
    applySharedTilingOptions(module, numTargets);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSharedTilingOptionsPass() {
  return std::make_unique<SharedTilingOptions>();
}
