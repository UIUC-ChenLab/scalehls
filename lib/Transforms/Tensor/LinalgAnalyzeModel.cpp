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

    for (auto &op : func.getOps()) {
      if (auto convOp = dyn_cast<linalg::Conv2DNchwFchwOp>(op)) {
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

        auto ops = 2 * batch * height * width * in_filter * out_filter *
                   hkernel * wkernel;
        numOps += ops;

        llvm::dbgs() << "(\"conv" << layerIdx << "\", Workload(" << batch
                     << ", " << height << ", " << width << ", " << in_filter
                     << ", " << out_filter << ", " << hkernel << ", " << wkernel
                     << "), Complexity(" << ops << ")),\n";
        ++layerIdx;

      } else if (auto depthOp =
                     dyn_cast<linalg::DepthwiseConv2DNchwChwOp>(op)) {
        auto weightShape =
            depthOp.filter().getType().cast<RankedTensorType>().getShape();
        auto outputShape =
            depthOp->getResult(0).getType().cast<RankedTensorType>().getShape();

        auto batch = outputShape[0];
        auto height = outputShape[2];
        auto width = outputShape[3];
        auto filter = weightShape[0];
        auto hkernel = weightShape[1];
        auto wkernel = weightShape[2];

        auto ops = 2 * batch * height * width * filter * hkernel * wkernel;
        numOps += ops;

        llvm::dbgs() << "(\"depth_conv" << layerIdx << "\", Workload(" << batch
                     << ", " << height << ", " << width << ", " << filter
                     << ", " << hkernel << ", " << wkernel << "), Complexity("
                     << ops << ")),\n";
        ++layerIdx;

      } else if (auto gemmOp = dyn_cast<linalg::MatmulOp>(op)) {
        auto inputShape =
            gemmOp.getOperand(0).getType().cast<RankedTensorType>().getShape();
        auto weightShape =
            gemmOp.getOperand(1).getType().cast<RankedTensorType>().getShape();

        auto batch = inputShape[0];
        auto in_filter = weightShape[0];
        auto out_filter = weightShape[1];

        auto ops = 2 * batch * in_filter * out_filter;
        numOps += ops;

        llvm::dbgs() << "(\"matmul" << layerIdx << "\", Workload(" << batch
                     << ", " << in_filter << ", " << out_filter
                     << "), Complexity(" << ops << ")),\n";
        ++layerIdx;
      }
    }

    llvm::dbgs() << "TOTAL OPS NUM: " << numOps << "\n";
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLinalgAnalyzeModelPass() {
  return std::make_unique<LinalgAnalyzeModel>();
}
