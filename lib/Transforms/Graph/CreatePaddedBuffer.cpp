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
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static bool applyCreatePaddedBuffer(ModuleOp module) {
  auto builder = OpBuilder(module);

  // Record ops to be erased.
  SmallVector<Operation *, 32> opToErase;

  for (auto func : module.getOps<FuncOp>()) {
    func.walk([&](Operation *op) {
      auto loc = op->getLoc();

      if (auto conv2DOp = dyn_cast<tosa::Conv2DOp>(op)) {
        // Check if there already is a memref for the input
        bool argExists = false;
        bufferization::ToMemrefOp inToMemref;
        for (auto user : conv2DOp.input().getUsers()) {
          if (auto toMemref = dyn_cast<bufferization::ToMemrefOp>(user)) {
            argExists = true;
            inToMemref = toMemref;
          }
        }

        // If there is already a memref for the input, use it instead
        bufferization::ToTensorOp inToTensor;
        if (argExists) {
          for (auto user : inToMemref.memref().getUsers()) {
            if (auto copy = dyn_cast<memref::CopyOp>(user)) {
              // Change the new input to tensor
              inToTensor =
                  builder.create<bufferization::ToTensorOp>(loc, copy.target());
            }
          }
        } else {
          // Create a new function argument
          auto inType = conv2DOp.input().getType().dyn_cast<RankedTensorType>();
          auto pad = conv2DOp.pad()[0].dyn_cast<IntegerAttr>().getInt();
          ArrayRef<int64_t> newInShape = {
              inType.getShape()[0], inType.getShape()[1] + 2 * pad,
              inType.getShape()[2] + 2 * pad, inType.getShape()[3]};
          auto inMemrefArg = func.front().addArgument(
              MemRefType::get(newInShape, inType.getElementType()), loc);
          func.setType(builder.getFunctionType(
              func.front().getArgumentTypes(),
              func.back().getTerminator()->getOperandTypes()));

          // Change the original input to memref
          builder.setInsertionPoint(conv2DOp);
          inToMemref = builder.create<bufferization::ToMemrefOp>(
              loc, MemRefType::get(inType.getShape(), inType.getElementType()),
              conv2DOp.input());

          // Create a subview for the argument (copy to buffer)
          auto offset = ArrayRef<OpFoldResult>(
              {builder.getI64IntegerAttr(0), builder.getI64IntegerAttr(pad),
               builder.getI64IntegerAttr(pad), builder.getI64IntegerAttr(0)});
          auto size = ArrayRef<OpFoldResult>(
              {builder.getI64IntegerAttr(inType.getShape()[0]),
               builder.getI64IntegerAttr(inType.getShape()[1]),
               builder.getI64IntegerAttr(inType.getShape()[2]),
               builder.getI64IntegerAttr(inType.getShape()[3])});
          auto stride = ArrayRef<OpFoldResult>(
              {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
               builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
          auto inSubview = builder.create<memref::SubViewOp>(
              loc, inMemrefArg, offset, size, stride);

          // Copy original input to the new input
          builder.create<memref::CopyOp>(loc, inToMemref, inSubview);

          // Change the new input to tensor
          inToTensor =
              builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);
        }

        // Create a new convolution without padding
        auto newConv2DOp = builder.create<tosa::Conv2DOp>(
            loc, conv2DOp.output().getType(), inToTensor.result(),
            conv2DOp.weight(), conv2DOp.bias(),
            builder.getI64ArrayAttr({0, 0, 0, 0}), conv2DOp.stride(),
            conv2DOp.dilation());

        conv2DOp.output().replaceAllUsesWith(newConv2DOp.output());
        opToErase.push_back(conv2DOp);
      }

      else if (auto reluNOp = dyn_cast<tosa::ReluNOp>(op)) {
        // Create a new function argument
        auto inType = reluNOp.input().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(reluNOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            reluNOp.input());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new relu
        auto newReluNOp = builder.create<tosa::ReluNOp>(
            loc, reluNOp.output().getType(), inToTensor.result(),
            reluNOp.max_int(), reluNOp.max_fp());

        reluNOp.output().replaceAllUsesWith(newReluNOp.output());
        opToErase.push_back(reluNOp);
      }

      else if (auto clampOp = dyn_cast<tosa::ClampOp>(op)) {
        // Create a new function argument
        auto inType = clampOp.input().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(clampOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            clampOp.input());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new clamp
        auto newClampOp = builder.create<tosa::ClampOp>(
            loc, clampOp.output().getType(), inToTensor.result(),
            clampOp.min_int(), clampOp.max_int(), clampOp.min_fp(),
            clampOp.max_fp());

        clampOp.output().replaceAllUsesWith(newClampOp.output());
        opToErase.push_back(clampOp);
      }

      else if (auto maxPool2dOp = dyn_cast<tosa::MaxPool2dOp>(op)) {
        // Create a new function argument
        auto inType =
            maxPool2dOp.input().getType().dyn_cast<RankedTensorType>();
        auto inShape = inType.getShape();
        auto pad = maxPool2dOp.pad()[0].dyn_cast<IntegerAttr>().getInt();
        ArrayRef<int64_t> newInShape = {inShape[0], inShape[1] + 2 * pad,
                                        inShape[2] + 2 * pad, inShape[3]};
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(newInShape, inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(maxPool2dOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            maxPool2dOp.input());

        // Create a subview for the argument (copy to buffer)
        auto offset = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(0), builder.getI64IntegerAttr(pad),
             builder.getI64IntegerAttr(pad), builder.getI64IntegerAttr(0)});
        auto size =
            ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(inShape[0]),
                                    builder.getI64IntegerAttr(inShape[1]),
                                    builder.getI64IntegerAttr(inShape[2]),
                                    builder.getI64IntegerAttr(inShape[3])});
        auto stride = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
             builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
        auto inSubview = builder.create<memref::SubViewOp>(
            loc, inMemrefArg, offset, size, stride);

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inSubview);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new maxpool without padding
        auto newMaxPool2dOp = builder.create<tosa::MaxPool2dOp>(
            loc, maxPool2dOp.output().getType(), inToTensor.result(),
            maxPool2dOp.kernel(), maxPool2dOp.stride(),
            builder.getI64ArrayAttr({0, 0, 0, 0}));

        maxPool2dOp.output().replaceAllUsesWith(newMaxPool2dOp.output());
        opToErase.push_back(maxPool2dOp);
      }

      else if (auto avgPool2dOp = dyn_cast<tosa::AvgPool2dOp>(op)) {
        // Create a new function argument
        auto inType =
            avgPool2dOp.input().getType().dyn_cast<RankedTensorType>();
        auto inShape = inType.getShape();
        auto pad = avgPool2dOp.pad()[0].dyn_cast<IntegerAttr>().getInt();
        ArrayRef<int64_t> newInShape = {inShape[0], inShape[1] + 2 * pad,
                                        inShape[2] + 2 * pad, inShape[3]};
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(newInShape, inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(avgPool2dOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            avgPool2dOp.input());

        // Create a subview for the argument (copy to buffer)
        auto offset = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(0), builder.getI64IntegerAttr(pad),
             builder.getI64IntegerAttr(pad), builder.getI64IntegerAttr(0)});
        auto size =
            ArrayRef<OpFoldResult>({builder.getI64IntegerAttr(inShape[0]),
                                    builder.getI64IntegerAttr(inShape[1]),
                                    builder.getI64IntegerAttr(inShape[2]),
                                    builder.getI64IntegerAttr(inShape[3])});
        auto stride = ArrayRef<OpFoldResult>(
            {builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1),
             builder.getI64IntegerAttr(1), builder.getI64IntegerAttr(1)});
        auto inSubview = builder.create<memref::SubViewOp>(
            loc, inMemrefArg, offset, size, stride);

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inSubview);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new avgpool without padding
        auto newAvgPool2dOp = builder.create<tosa::AvgPool2dOp>(
            loc, avgPool2dOp.output().getType(), inToTensor.result(),
            avgPool2dOp.kernel(), avgPool2dOp.stride(),
            builder.getI64ArrayAttr({0, 0, 0, 0}));

        avgPool2dOp.output().replaceAllUsesWith(newAvgPool2dOp.output());
        opToErase.push_back(avgPool2dOp);
      }

      else if (auto addOp = dyn_cast<tosa::AddOp>(op)) {
        // Create a new function argument for input 1
        auto in1Type = addOp.input1().getType().dyn_cast<RankedTensorType>();
        auto in1MemrefArg = func.front().addArgument(
            MemRefType::get(in1Type.getShape(), in1Type.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(addOp);
        auto in1ToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(in1Type.getShape(), in1Type.getElementType()),
            addOp.input1());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, in1ToMemref, in1MemrefArg);

        // Change the new input to tensor
        auto in1ToTensor =
            builder.create<bufferization::ToTensorOp>(loc, in1MemrefArg);

        // Create a new function argument for input 2 if there is not already
        // one
        bool argExists = false;
        Value in2Memref;
        for (auto user : addOp.input2().getUsers()) {
          if (auto toMemref = dyn_cast<bufferization::ToMemrefOp>(user)) {
            in2Memref = toMemref.memref();
            argExists = true;
          }
        }

        bufferization::ToTensorOp in2ToTensor;
        if (argExists) {
          for (auto user : in2Memref.getUsers()) {
            if (auto copy = dyn_cast<memref::CopyOp>(user)) {
              // Change the new input to tensor
              in2ToTensor =
                  builder.create<bufferization::ToTensorOp>(loc, copy.target());
            }
          }
        } else {
          auto in2Type = addOp.input2().getType().dyn_cast<RankedTensorType>();
          auto in2MemrefArg = func.front().addArgument(
              MemRefType::get(in2Type.getShape(), in2Type.getElementType()),
              loc);
          func.setType(builder.getFunctionType(
              func.front().getArgumentTypes(),
              func.back().getTerminator()->getOperandTypes()));

          // Change the original input to memref
          builder.setInsertionPoint(addOp);
          auto in2ToMemref = builder.create<bufferization::ToMemrefOp>(
              loc,
              MemRefType::get(in2Type.getShape(), in2Type.getElementType()),
              addOp.input2());

          // Copy original input to the new input
          builder.create<memref::CopyOp>(loc, in2ToMemref, in2MemrefArg);

          // Change the new input to tensor
          in2ToTensor =
              builder.create<bufferization::ToTensorOp>(loc, in2MemrefArg);
        }

        // Create a new add
        auto newAddOp = builder.create<tosa::AddOp>(
            loc, addOp.output().getType(), in1ToTensor.result(),
            in2ToTensor.result());

        addOp.output().replaceAllUsesWith(newAddOp.output());
        opToErase.push_back(addOp);
      }

      else if (auto reshapeOp = dyn_cast<tosa::ReshapeOp>(op)) {
        // Create a new function argument
        auto inType = reshapeOp.input1().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(reshapeOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            reshapeOp.input1());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new reshape
        auto newReshapeOp = builder.create<tosa::ReshapeOp>(
            loc, reshapeOp.output().getType(), inToTensor.result(),
            reshapeOp.new_shape());

        reshapeOp.output().replaceAllUsesWith(newReshapeOp.output());
        opToErase.push_back(reshapeOp);
      }

      else if (auto fullyConnectedOp = dyn_cast<tosa::FullyConnectedOp>(op)) {
        // Create a new function argument
        auto inType =
            fullyConnectedOp.input().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(fullyConnectedOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            fullyConnectedOp.input());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new fc
        auto newFullyConnectedOp = builder.create<tosa::FullyConnectedOp>(
            loc, fullyConnectedOp.output().getType(), inToTensor.result(),
            fullyConnectedOp.weight(), fullyConnectedOp.bias());

        fullyConnectedOp.output().replaceAllUsesWith(
            newFullyConnectedOp.output());
        opToErase.push_back(fullyConnectedOp);
      }

      else if (auto matMulOp = dyn_cast<tosa::MatMulOp>(op)) {
        // Create a new function argument
        auto inType = matMulOp.a().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(matMulOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            matMulOp.a());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Change the new input to tensor
        auto inToTensor =
            builder.create<bufferization::ToTensorOp>(loc, inMemrefArg);

        // Create a new matmul
        auto newMatMulOp = builder.create<tosa::MatMulOp>(
            loc, matMulOp.c().getType(), inToTensor.result(), matMulOp.b());

        matMulOp.c().replaceAllUsesWith(newMatMulOp.c());
        opToErase.push_back(matMulOp);
      }

      else if (auto returnOp = dyn_cast<func::ReturnOp>(op)) {
        // Create a new function argument
        auto inType =
            returnOp.operands().front().getType().dyn_cast<RankedTensorType>();
        auto inMemrefArg = func.front().addArgument(
            MemRefType::get(inType.getShape(), inType.getElementType()), loc);
        func.setType(builder.getFunctionType(
            func.front().getArgumentTypes(),
            func.back().getTerminator()->getOperandTypes()));

        // Change the original input to memref
        builder.setInsertionPoint(returnOp);
        auto inToMemref = builder.create<bufferization::ToMemrefOp>(
            loc, MemRefType::get(inType.getShape(), inType.getElementType()),
            returnOp.operands().front());

        // Copy original input to the new input
        builder.create<memref::CopyOp>(loc, inToMemref, inMemrefArg);

        // Create a new return without a return value
        builder.create<func::ReturnOp>(loc);
        func.setType(builder.getFunctionType(func.front().getArgumentTypes(),
                                             TypeRange()));

        opToErase.push_back(returnOp);
      }

      else if (auto funcOp = dyn_cast<func::FuncOp>(op)) {
        return;
      }

      else {
        op->emitError("Unsupported operation");
      }
    });
  }

  // Erase all ops on the list.
  for (auto op : opToErase)
    op->erase();

  return true;
}

namespace {
struct CreatePaddedBuffer : public CreatePaddedBufferBase<CreatePaddedBuffer> {
  void runOnOperation() override {
    auto module = getOperation();
    applyCreatePaddedBuffer(module);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createCreatePaddedBufferPass() {
  return std::make_unique<CreatePaddedBuffer>();
}
