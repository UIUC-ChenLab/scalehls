//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "llvm/Support/Debug.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct LinalgAnalyzeModel : public LinalgAnalyzeModelBase<LinalgAnalyzeModel> {
  void runOnOperation() override {
    auto func = getOperation();

    // auto getIntArray = [&](ArrayAttr arrayAttr) {
    //   SmallVector<int64_t, 4> array;
    //   for (auto value : arrayAttr)
    //     array.push_back(value.cast<IntegerAttr>().getInt());
    //   return array;
    // };

    unsigned layerIdx = 0;
    unsigned long numOps = 0;

    for (auto convOp : func.getOps<linalg::Conv2DNchwFchwOp>()) {
      auto weightShape =
          convOp.filter().getType().cast<RankedTensorType>().getShape();
      auto outputShape =
          convOp->getResult(0).getType().cast<RankedTensorType>().getShape();

      auto batch = outputShape[0];
      auto height = outputShape[2];
      auto width = outputShape[3];
      auto in_filter = weightShape[0];
      auto out_filter = weightShape[1];
      auto hkernel = weightShape[2];
      auto wkernel = weightShape[3];

      numOps += (2 * batch * height * width * in_filter * out_filter * hkernel *
                 wkernel);
      llvm::dbgs() << "(\"conv" << layerIdx << "\", Workload(" << batch << ", "
                   << height << ", " << width << ", " << in_filter << ", "
                   << out_filter << ", " << hkernel << ", " << wkernel
                   << ")),\n";
      ++layerIdx;
    }

    for (auto gemmOp : func.getOps<linalg::MatmulOp>()) {
      auto inputShape =
          gemmOp.getOperand(0).getType().cast<RankedTensorType>().getShape();
      auto weightShape =
          gemmOp.getOperand(1).getType().cast<RankedTensorType>().getShape();

      auto batch = inputShape[0];
      auto in_filter = weightShape[0];
      auto out_filter = weightShape[1];

      numOps += (2 * batch * in_filter * out_filter);
      llvm::dbgs() << "(\"matmul" << layerIdx << "\", Workload(" << batch
                   << ", " << in_filter << ", " << out_filter << ")),\n";
      ++layerIdx;
    }

    llvm::dbgs() << "TOTAL OPS NUM: " << numOps << "\n";
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLinalgAnalyzeModelPass() {
  return std::make_unique<LinalgAnalyzeModel>();
}
