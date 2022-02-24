//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

struct ConvInfo {
  tosa::Conv2DOp op;

  ArrayRef<int64_t> getInputShape() {
    auto input = op.getOperand(0);
    return input.getType().cast<RankedTensorType>().getShape();
  }

  ArrayRef<int64_t> getOutputShape() {
    auto output = op.getResult();
    return output.getType().cast<RankedTensorType>().getShape();
  }

  ArrayRef<int64_t> getWeightShape() {
    auto weight = op.getOperand(1);
    return weight.getType().cast<RankedTensorType>().getShape();
  }

  bool operator==(ConvInfo& rhs) {
    return (this->getInputShape() == rhs.getInputShape()) &&
           (this->getOutputShape() == rhs.getOutputShape()) &&
           (this->getWeightShape() == rhs.getWeightShape());
  }

  bool operator<(const ConvInfo& rhs) const {
    ConvInfo lhs = *this;
    ConvInfo rhsCopy = rhs;
    if (lhs == rhsCopy) {
      return false;
    }
    else {
      return (this->op < rhs.op);
    }
  }
};

static bool applyShareTensorOperation(ModuleOp module) {
  auto builder = OpBuilder(module);

  // Count the number of each shape of convolution.
  std::map<ConvInfo, unsigned> countMap;

  // Traverse the entire module and count all the convolutions.
  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](Operation *op) {
      if (auto Conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvInfo info;
        info.op = Conv2DOp;
        if (!countMap.count(info)) {
          countMap[info] = 1;
        }
        else {
          countMap[info] += 1;
        }
      }
    });
  }

  // Find the shape of convolution that happens most frequently.
  unsigned maxCount = 0;
  ConvInfo maxInfo;
  for (auto item : countMap) {
    if (item.second > maxCount) {
      maxCount = item.second;
      maxInfo = item.first;
    }
  }

  // Create a function that contains the most frequent convolution.
  SmallVector<Type, 16> inputTypes;
  for (auto operand : maxInfo.op.getOperands()) {
    inputTypes.push_back(operand.getType());
  }
  auto resultType = maxInfo.op.getResult().getType();
  auto newType = builder.getFunctionType(inputTypes, resultType);
  builder.setInsertionPointToStart(module.getBody());
  auto newFuncOp = builder.create<FuncOp>(builder.getUnknownLoc(), "shared_convolution", newType);
  auto entryBlock = newFuncOp.addEntryBlock();
  builder.setInsertionPointToStart(entryBlock);

  auto input = entryBlock->getArgument(0);
  auto weight = entryBlock->getArgument(1);
  auto bias = entryBlock->getArgument(2);
  auto outputType = newFuncOp.getType().getResults()[0];
  auto pad = maxInfo.op.pad();
  auto stride = maxInfo.op.stride();
  auto dilation = maxInfo.op.dilation();
  auto newConvOp = builder.create<tosa::Conv2DOp>(builder.getUnknownLoc(), outputType, input, weight, bias, pad, stride, dilation);

  auto newReturnOp = builder.create<ReturnOp>(builder.getUnknownLoc(), newConvOp.output());

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Convert those convolutions into a shared function.
  /*for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](Operation *op) {
      if (auto Conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        ConvInfo info;
        info.op = Conv2DOp;
        if (maxInfo == info) {
          //Conv2DOp.dump();
        }
      }
    });
  }*/

  return true;
}

namespace {
struct ShareTensorOperation : public ShareTensorOperationBase<ShareTensorOperation> {
  void runOnOperation() override {
    auto module = getOperation();
    applyShareTensorOperation(module);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createShareTensorOperationPass() {
  return std::make_unique<ShareTensorOperation>();
}
