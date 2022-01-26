//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/Dialect/Tosa/IR/TosaOps.h"
#include "scalehls/Conversion/Passes.h"

using namespace mlir;
using namespace scalehls;

namespace {
struct ConvertOnnxToTosa : public ConvertOnnxToTosaBase<ConvertOnnxToTosa> {
  void runOnOperation() override;
};
} // namespace

/// This implementation does not rely on ONNX-MLIR build.
void ConvertOnnxToTosa::runOnOperation() {
  auto module = getOperation();
  auto builder = OpBuilder(module);

  // Helper function for later use.
  auto opIsa = [&](Operation *op, StringRef name) {
    return op->getName().getStringRef() == name;
  };

  auto permuteShape = [&](Type type) {
    auto tensorType = type.cast<RankedTensorType>();
    auto tensorShape = tensorType.getShape();

    if (tensorShape.size() == 4) {
      auto newTensorShape = SmallVector<int64_t, 4>(
          {tensorShape[0], tensorShape[2], tensorShape[3], tensorShape[1]});

      return RankedTensorType::get(newTensorShape, tensorType.getElementType());
    } else {
      return tensorType;
    }
  };

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  // Find all functions in the module and eliminate onnx entrypoint op.
  SmallVector<FuncOp, 2> funcs;
  for (auto &op : module) {
    if (auto func = dyn_cast<FuncOp>(op))
      funcs.push_back(func);
    else if (opIsa(&op, "onnx.EntryPoint"))
      opToErase.push_back(&op);
  }

  for (auto func : funcs) {
    func->removeAttr("input_names");
    func->removeAttr("output_names");

    // Record the type and value of all constant ops if required. The rationale
    // is typically we store weights and biases on external memories, thus they
    // should live outside of the function. In this respect, onnx constant ops
    // will be converted to arguments of the function if "externalizeConstant"
    // option is on.
    SmallVector<Type, 16> constTypes;
    SmallVector<Value, 16> constValues;

    // Traverse function and convert all onnx ops to tosa.
    for (auto &op : func.getBody().front()) {
      builder.setInsertionPoint(&op);

      if (opIsa(&op, "onnx.Constant")) {
        opToErase.push_back(&op);

        // Get output type.
        auto output = op.getResult(0);
        auto outputType = permuteShape(output.getType());
        output.setType(outputType);

        if (externalizeConstant) {
          // Push back the type and value of the onnx constant op.
          constTypes.push_back(outputType);
          constValues.push_back(output);

        } else {
          // Get attributes.
          // TODO: permute value as well.
          auto value = op.getAttrOfType<ElementsAttr>("value");

          // Create the tosa const op and replace all use.
          auto newOp =
              builder.create<tosa::ConstOp>(op.getLoc(), outputType, value);
          op.replaceAllUsesWith(newOp);
        }
      } else if (opIsa(&op, "onnx.Conv")) {
        opToErase.push_back(&op);

        // Get output type.
        auto output = op.getResult(0);
        auto outputType = permuteShape(output.getType());
        output.setType(outputType);

        // Get input and attributes.
        auto input = op.getOperand(0);
        auto weight = op.getOperand(1);
        auto bias = op.getOperand(2);
        auto pad = builder.getArrayAttr(ArrayRef<Attribute>({0, 0, 0, 0}));
        if (op.hasAttr("pads")) {
          pad = op.getAttrOfType<ArrayAttr>("pads");
        }
        auto stride = op.getAttrOfType<ArrayAttr>("strides");
        auto dilation = op.getAttrOfType<ArrayAttr>("dilations");

        // Create the tosa conv2d op and replace all use.
        auto newOp =
            builder.create<tosa::Conv2DOp>(op.getLoc(), outputType, input,
                                           weight, bias, pad, stride, dilation);
        op.replaceAllUsesWith(newOp);

      } else if (opIsa(&op, "onnx.Gemm")) {
        opToErase.push_back(&op);

        // Get output type.
        auto outputType = op.getResult(0).getType();

        // Get input and attributes.
        auto input = op.getOperand(0);
        auto weight = op.getOperand(1);
        auto bias = op.getOperand(2);

        // Create the tosa fc op and replace all use.
        auto newOp = builder.create<tosa::FullyConnectedOp>(
            op.getLoc(), outputType, input, weight, bias);
        op.replaceAllUsesWith(newOp);

      } else if (opIsa(&op, "onnx.Relu")) {
        opToErase.push_back(&op);

        // Get output type.
        auto output = op.getResult(0);
        auto outputType = permuteShape(output.getType());
        output.setType(outputType);

        // Get input and attributes.
        auto input = op.getOperand(0);
        auto max_int = builder.getI64IntegerAttr(INT64_MAX);
        auto max_fp = builder.getF32FloatAttr(INFINITY);

        // Create the tosa relu op and replace all use.
        auto newOp = builder.create<tosa::ReluNOp>(op.getLoc(), outputType,
                                                   input, max_int, max_fp);
        op.replaceAllUsesWith(newOp);

      } else if (opIsa(&op, "onnx.MaxPoolSingleOut")) {
        opToErase.push_back(&op);

        // Get output type.
        auto output = op.getResult(0);
        auto outputType = permuteShape(output.getType());
        output.setType(outputType);

        // Get input and attributes.
        auto input = op.getOperand(0);
        auto kernel = op.getAttrOfType<ArrayAttr>("kernel_shape");
        auto pad = op.getAttrOfType<ArrayAttr>("pads");
        auto stride = op.getAttrOfType<ArrayAttr>("strides");

        // Create the tosa conv2d op and replace all use.
        auto newOp = builder.create<tosa::MaxPool2dOp>(
            op.getLoc(), outputType, input, kernel, stride, pad);
        op.replaceAllUsesWith(newOp);

      } else if (opIsa(&op, "onnx.Add")) {
        opToErase.push_back(&op);

        // Get output type.
        auto output = op.getResult(0);
        auto outputType = permuteShape(output.getType());
        output.setType(outputType);

        // Get input and attributes.
        auto input0 = op.getOperand(0);
        auto input1 = op.getOperand(1);

        // Create the tosa add op and replace all use.
        auto newOp = builder.create<tosa::AddOp>(op.getLoc(), outputType,
                                                 input0, input1);
        op.replaceAllUsesWith(newOp);

      } else if (opIsa(&op, "onnx.Flatten")) {
        opToErase.push_back(&op);

        // Get output type.
        auto outputType = op.getResult(0).getType();

        // Get input and reshape attribute.
        auto input = op.getOperand(0);
        auto shapeAttr = builder.getI64ArrayAttr(
            outputType.cast<RankedTensorType>().getShape());

        // Create tosa reshape op and replace all use.
        auto newOp = builder.create<tosa::ReshapeOp>(op.getLoc(), outputType,
                                                     input, shapeAttr);
        op.replaceAllUsesWith(newOp);

      } else if (opIsa(&op, "onnx.Pad")) {
        opToErase.push_back(&op);

        // Get output type.
        auto output = op.getResult(0);
        auto outputType = permuteShape(output.getType());
        output.setType(outputType);

        // Get input and padding attribute.
        auto input = op.getOperand(0);
        auto padding = op.getAttrOfType<ElementsAttr>("pads");
        auto paddingType = padding.getType().cast<RankedTensorType>();

        // Create tosa pad op and replace all use.
        auto paddingOp =
            builder.create<tosa::ConstOp>(op.getLoc(), paddingType, padding);
        auto newOp = builder.create<tosa::PadOp>(op.getLoc(), outputType, input,
                                                 paddingOp);
        op.replaceAllUsesWith(newOp);

      } else if (opIsa(&op, "onnx.Reshape")) {
        opToErase.push_back(&op);

        // Get output type.
        auto outputType = op.getResult(0).getType();

        // Get input and reshape attribute.
        auto input = op.getOperand(0);
        auto shape = op.getOperand(1);
        auto shapeAttr = builder.getI64ArrayAttr(
            outputType.cast<RankedTensorType>().getShape());

        // Create tosa reshape op and replace all use.
        auto newOp = builder.create<tosa::ReshapeOp>(op.getLoc(), outputType,
                                                     input, shapeAttr);
        op.replaceAllUsesWith(newOp);

      } else if (op.getName().getDialectNamespace() == "onnx")
        op.emitError("is unsupported onnx op");
    }

    // Convert onnx constant ops to function arguments.
    if (externalizeConstant) {
      // Collect result and input types.
      auto resultTypes = func.front().getTerminator()->getOperandTypes();
      SmallVector<Type, 16> inputTypes;

      for (auto arg : func.getArguments()) {
        auto argType = permuteShape(arg.getType());
        arg.setType(argType);
        inputTypes.push_back(argType);
      }

      inputTypes.append(constTypes.begin(), constTypes.end());

      // Construct new function type.
      auto newType = builder.getFunctionType(inputTypes, resultTypes);

      // Record the argument number of the old function.
      auto oldArgNum = func.getNumArguments();

      // Set function type to newType.
      func.setType(newType);

      // Add new arguments to the entry block.
      func.front().addArguments(constTypes);

      // Replace all uses of the onnx constant op with corresponding entry block
      // argument.
      for (unsigned i = 0, e = constValues.size(); i < e; ++i)
        constValues[i].replaceAllUsesWith(
            func.front().getArgument(i + oldArgNum));
    }
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();
}

std::unique_ptr<Pass> scalehls::createConvertOnnxToTosaPass() {
  return std::make_unique<ConvertOnnxToTosa>();
}