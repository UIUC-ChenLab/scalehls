//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Support/FileUtilities.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/TosaOpHelper.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/ToolOutputFile.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

int64_t getInWH(int64_t outWH, int64_t stride, int64_t kernelSize) {
  return (outWH - 1) * stride + kernelSize;
}

static SmallVector<ConvOpHelper, 32>
exploreTilingStrategy(ModuleOp module, SmallVector<OpHelper *, 32> opHelpers,
                      unsigned numTilings) {
  SmallVector<ConvOpHelper, 32> tilingOptions;

  SmallVector<ConvOpHelper, 32> convOpHelpers;
  for (auto helper : opHelpers) {
    convOpHelpers.push_back(*dyn_cast<ConvOpHelper>(helper));
  }

  ConvOpHelper finalTiling = ConvOpHelper(convOpHelpers[0]);
  for (auto helper : convOpHelpers) {
    finalTiling.takeSmallerDim(helper);
  }

  // Get maximum dimensions of all
  auto maxInCh = 0;
  auto maxOutCh = 0;
  auto maxOutWH = 0;
  for (auto helper : convOpHelpers) {
    if (helper.inCh > maxInCh) {
      maxInCh = helper.inCh;
    }
    if (helper.outCh > maxOutCh) {
      maxOutCh = helper.outCh;
    }
    if (helper.outWH > maxOutWH) {
      maxOutWH = helper.outWH;
    }
  }

  // Find the best outWH
  // Find how many computations are performed extra
  SmallVector<int64_t> lostComputes;
  lostComputes.push_back(0);
  for (auto outWH = 1; outWH <= maxOutWH; outWH++) {
    int64_t lostCompute = 0;
    for (auto helper : convOpHelpers) {
      auto outWHDiv = (helper.outWH + outWH - 1) / outWH;
      lostCompute +=
          (outWHDiv * outWH * outWHDiv * outWH - helper.outWH * helper.outWH) *
          helper.kernelSize * helper.kernelSize * helper.outCh * helper.inCh;
    }
    lostComputes.push_back(lostCompute);
  }

  // Find the outWH values with minimum lost computations
  SmallVector<int64_t> outWHOptions;
  for (unsigned i = 0; i < numTilings; i++) {
    auto minLostCompute = lostComputes[1];
    auto minOutWH = 1;
    for (auto outWH = 2; outWH <= maxOutWH; outWH++) {
      if (minLostCompute >= lostComputes[outWH]) {
        minLostCompute = lostComputes[outWH];
        minOutWH = outWH;
      }
    }
    outWHOptions.push_back(minOutWH);
    lostComputes[minOutWH] = INT_MAX;
  }

  // Find the best outCh
  // Find how many computations are performed extra
  lostComputes = SmallVector<int64_t>();
  lostComputes.push_back(0);
  for (auto outCh = 1; outCh <= maxOutCh; outCh++) {
    int64_t lostCompute = 0;
    for (auto helper : convOpHelpers) {
      auto outChDiv = (helper.outCh + outCh - 1) / outCh;
      lostCompute += (outChDiv * outCh - helper.outCh) * helper.kernelSize *
                     helper.kernelSize * helper.inCh * helper.outWH *
                     helper.outWH;
    }
    lostComputes.push_back(lostCompute);
  }

  // Find the outCh values with minimum lost computations
  SmallVector<int64_t> outChOptions;
  for (unsigned i = 0; i < numTilings; i++) {
    auto minLostCompute = lostComputes[1];
    auto minOutCh = 1;
    for (auto outCh = 2; outCh <= maxOutCh; outCh++) {
      if (minLostCompute >= lostComputes[outCh]) {
        minLostCompute = lostComputes[outCh];
        minOutCh = outCh;
      }
    }
    outChOptions.push_back(minOutCh);
    lostComputes[minOutCh] = INT_MAX;
  }

  // Find the best inCh
  // Find how many computations are performed extra
  lostComputes = SmallVector<int64_t>();
  lostComputes.push_back(0);
  for (auto inCh = 1; inCh <= maxInCh; inCh++) {
    int64_t lostCompute = 0;
    for (auto helper : convOpHelpers) {
      auto inChDiv = (helper.inCh + inCh - 1) / inCh;
      lostCompute += (inChDiv * inCh - helper.inCh) * helper.kernelSize *
                     helper.kernelSize * helper.outCh * helper.outWH *
                     helper.outWH;
    }
    lostComputes.push_back(lostCompute);
  }

  // Find the inCh values with minimum lost computations
  SmallVector<int64_t> inChOptions;
  for (unsigned i = 0; i < numTilings; i++) {
    auto minLostCompute = lostComputes[1];
    auto minInCh = 1;
    for (auto inCh = 2; inCh <= maxInCh; inCh++) {
      if (minLostCompute >= lostComputes[inCh]) {
        minLostCompute = lostComputes[inCh];
        minInCh = inCh;
      }
    }
    inChOptions.push_back(minInCh);
    lostComputes[minInCh] = INT_MAX;
  }

  // Record all possible configuartions
  for (unsigned i = 0; i < numTilings; i++) {
    for (unsigned j = 0; j < numTilings; j++) {
      for (unsigned k = 0; k < numTilings; k++) {
        finalTiling.outCh = outChOptions[i];
        finalTiling.inCh = outChOptions[j];
        finalTiling.outWH = outWHOptions[k];
        finalTiling.getCorrectInWH();
        tilingOptions.push_back(finalTiling);
      }
    }
  }

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
  auto newFuncOp = builder.create<func::FuncOp>(builder.getUnknownLoc(),
                                                functionName, newType);
  newFuncOp->setAttr("shared", builder.getUnitAttr());
  newFuncOp->setAttr("type", builder.getStringAttr("convolution"));

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

static std::tuple<int64_t, int64_t, int64_t>
recordSizeAndCount(ModuleOp module, ConvOpHelper sharedHelper) {
  // Compute the size of buffers required
  int64_t inputSize = sharedHelper.batchSize * sharedHelper.inCh *
                      sharedHelper.inWH * sharedHelper.inWH;
  int64_t weightSize = sharedHelper.inCh * sharedHelper.outCh *
                       sharedHelper.kernelSize * sharedHelper.kernelSize;
  int64_t outputSize = sharedHelper.batchSize * sharedHelper.outCh *
                       sharedHelper.outWH * sharedHelper.outWH;
  int64_t size = inputSize + weightSize + outputSize;

  // Compute the number of times the shared function is called
  int64_t count = 0;
  for (auto func : module.getOps<FuncOp>()) {
    if (func->getAttr("shared"))
      continue;

    func.walk([&](tosa::Conv2DOp conv2DOp) {
      ConvOpHelper currHelper = ConvOpHelper(conv2DOp);

      if (!currHelper.equalAttr(sharedHelper))
        return;

      int64_t outChDiv =
          (currHelper.outCh + sharedHelper.outCh - 1) / sharedHelper.outCh;
      int64_t inChDiv =
          (currHelper.inCh + sharedHelper.inCh - 1) / sharedHelper.inCh;
      int64_t WHDiv =
          (currHelper.outWH + sharedHelper.outWH - 1) / sharedHelper.outWH;
      count += outChDiv * inChDiv * WHDiv * WHDiv;
    });
  }

  int64_t cycle = sharedHelper.batchSize * sharedHelper.inCh *
                  sharedHelper.outWH * sharedHelper.outWH * sharedHelper.outCh *
                  sharedHelper.kernelSize * sharedHelper.kernelSize;

  return std::tuple<int64_t, int64_t, int64_t>(size, count, cycle);
}

static void dumpTilingOptions(
    SmallVector<std::tuple<std::string, int64_t, int64_t, int64_t>> tilingList,
    SmallVector<ConvOpHelper> tilingHelpers, StringRef csvFilePath) {
  std::string errorMessage;
  auto csvFile = mlir::openOutputFile(csvFilePath, &errorMessage);
  if (!csvFile)
    return;
  auto &os = csvFile->os();

  // Print header row.
  os << "name,size,count,cycle,batchSize,inCh,inWH,outCh,outWH,"
        "kernelSize\n";

  // Print tiling options
  for (unsigned i = 0; i < tilingHelpers.size(); i++) {
    auto tiling = tilingList[i];
    auto helper = tilingHelpers[i];
    auto [name, count, size, cycle] = tiling;
    os << name << "," << count << "," << size << "," << cycle << ","
       << helper.batchSize << "," << helper.inCh << "," << helper.inWH << ","
       << helper.outCh << "," << helper.outWH << "," << helper.kernelSize
       << "\n";
  }

  csvFile->keep();
}

static bool applySharedTilingOptions(ModuleOp module, unsigned numTargets,
                                     unsigned numTilings,
                                     StringRef outputPath) {
  auto builder = OpBuilder(module);

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

  // Find the types of convolutions that happen frequently and create
  // functions with different tilings
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
        SmallVector<ConvOpHelper> tilingHelpers =
            exploreTilingStrategy(module, countMap[*opHelper], numTilings);
        countMap.erase(*opHelper);
        SmallVector<std::tuple<std::string, int64_t, int64_t, int64_t>>
            tilingList;
        for (unsigned j = 0; j < tilingHelpers.size(); j++) {
          auto functionName =
              "shared_function_" + std::to_string(i) + "_" + std::to_string(j);
          auto newFuncOp =
              createSharedConvolution(module, tilingHelpers[j], functionName);
          auto [size, count, cycle] =
              recordSizeAndCount(module, tilingHelpers[j]);
          newFuncOp->setAttr("size", builder.getI64IntegerAttr(size));
          newFuncOp->setAttr("count", builder.getI64IntegerAttr(count));
          newFuncOp->setAttr("cycle", builder.getI64IntegerAttr(cycle));
          tilingList.push_back(
              std::make_tuple(functionName, size, count, cycle));
        }
        auto csvFilePath = outputPath.str() + "shared_function_" +
                           std::to_string(i) + "_tiling.csv";
        dumpTilingOptions(tilingList, tilingHelpers, csvFilePath);
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
    applySharedTilingOptions(module, numTargets, numTilings, outputPath);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createSharedTilingOptionsPass() {
  return std::make_unique<SharedTilingOptions>();
}
