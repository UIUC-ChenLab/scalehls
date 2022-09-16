//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"

using namespace mlir;
using namespace scalehls;

static Type getQuantizeType(Type type) {
  auto i8Type = IntegerType::get(type.getContext(), 8);
  if (type.isa<Float32Type>())
    return i8Type;

  if (auto tensorType = type.dyn_cast<RankedTensorType>())
    if (tensorType.getElementType().isa<Float32Type>())
      return RankedTensorType::get(tensorType.getShape(), i8Type);

  return nullptr;
}

namespace {
/// This pass is only for testing use!!! To really support quantized model,
/// first we need to have front-ends, such as Torch-MLIR, to support the model
/// quantization, which has not came true unfortunately.
struct TosaFakeQuantize : public TosaFakeQuantizeBase<TosaFakeQuantize> {
  void runOnOperation() override {
    auto module = getOperation();

    // Convert the type of block arguments.
    module.walk([&](Block *block) {
      for (auto arg : block->getArguments())
        if (auto quantType = getQuantizeType(arg.getType()))
          arg.setType(quantType);
    });

    // Convert the type of operation results. Also, handle function, constant,
    // conv2d, and matmul operations.
    int8_t fakeIdx = 1;
    module.walk([&](Operation *op) {
      for (auto result : op->getResults())
        if (auto quantType = getQuantizeType(result.getType())) {
          result.setType(quantType);

          if (auto constant = dyn_cast<tosa::ConstOp>(op)) {
            // Because we are not trying to really quantize the model, here we
            // just assign a fake value to the constant operation.
            SmallVector<int8_t, 64> list(constant.getValue().size(), fakeIdx++);
            // for (auto value : constant.valueAttr().getValues<float>())
            //   list.push_back(value);

            auto quantValue = DenseIntElementsAttr::get(quantType, list);
            constant->setAttr(constant.getValueAttrName(), quantValue);
          }

          if (auto conv2d = dyn_cast<tosa::Conv2DOp>(op)) {
            auto quantInfoAttr =
                tosa::ConvOpQuantizationAttr::get(conv2d.getContext(), 0, 0);
            conv2d->setAttr(conv2d.getQuantizationInfoAttrName(),
                            quantInfoAttr);

          } else if (auto matMul = dyn_cast<tosa::MatMulOp>(op)) {
            auto quantInfoAttr =
                tosa::MatMulOpQuantizationAttr::get(matMul.getContext(), 0, 0);
            matMul->setAttr(matMul.getQuantizationInfoAttrName(),
                            quantInfoAttr);

          } else if (auto pool2d = dyn_cast<tosa::AvgPool2dOp>(op)) {
            auto quantInfoAttr =
                tosa::UnaryOpQuantizationAttr::get(pool2d.getContext(), 0, 0);
            pool2d->setAttr(pool2d.getQuantizationInfoAttrName(),
                            quantInfoAttr);
          }
        }

      // As we have updated the type of all values in the function, we can
      // safely convert the function type as well.
      if (auto func = dyn_cast<func::FuncOp>(op))
        func.setType(FunctionType::get(
            func.getContext(), func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));
    });
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createTosaFakeQuantizePass() {
  return std::make_unique<TosaFakeQuantize>();
}
