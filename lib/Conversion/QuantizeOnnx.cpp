//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/Arithmetic/IR/Arithmetic.h"
#include "mlir/Dialect/Bufferization/IR/Bufferization.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/Builders.h"
#include "scalehls/Conversion/Passes.h"
#include "scalehls/Dialect/HLSCpp/HLSCpp.h"

using namespace mlir;
using namespace scalehls;

static Type quantizeType(Type type, OpBuilder &builder) {
  auto int8Type = builder.getIntegerType(8);

  // Weights, input, and output feature maps are quantized to 8-bits, while
  // biases are quantized to 32-bits.
  if (auto memrefType = type.dyn_cast<MemRefType>()) {
    auto shape = memrefType.getShape();
    auto layout = memrefType.getLayout();
    auto memorySpace = memrefType.getMemorySpace();
    return MemRefType::get(shape, int8Type, layout, memorySpace);

  } else if (auto tensorType = type.dyn_cast<TensorType>()) {
    auto shape = tensorType.getShape();
    return RankedTensorType::get(shape, int8Type);

  } else if (type.isa<Float32Type>()) {
    return int8Type;
  }

  return nullptr;
}

static void quantizeBlock(Block &block, OpBuilder &builder,
                          SmallVectorImpl<Operation *> &OpsToErase) {
  auto int8Type = builder.getIntegerType(8);
  auto int16Type = builder.getIntegerType(16);
  auto int32Type = builder.getI32Type();

  for (auto &op : block) {
    Operation *newOp = nullptr;
    builder.setInsertionPoint(&op);

    if (auto constOp = dyn_cast<arith::ConstantOp>(op)) {
      auto attr = constOp.getValue();

      if (auto floatAttr = attr.dyn_cast<FloatAttr>()) {
        int8_t floatValue = floatAttr.getValue().convertToFloat();
        newOp = builder.create<arith::ConstantOp>(
            constOp.getLoc(), builder.getI8IntegerAttr(floatValue));

      } else if (auto intAttr = attr.dyn_cast<IntegerAttr>()) {
        int8_t intValue = intAttr.getInt();
        newOp = builder.create<arith::ConstantOp>(
            constOp.getLoc(), builder.getI8IntegerAttr(intValue));

      } else if (auto tensorAttr = attr.dyn_cast<DenseElementsAttr>()) {
        SmallVector<int8_t, 16> newTensorValues;
        for (auto elem : tensorAttr.getValues<FloatAttr>()) {
          int8_t value = elem.getValueAsDouble();
          newTensorValues.push_back(value);
        }

        auto newTensorType = RankedTensorType::get(newTensorValues.size(),
                                                   builder.getIntegerType(8));
        auto newTensorAttr =
            DenseIntElementsAttr::get(newTensorType, newTensorValues);
        newOp =
            builder.create<arith::ConstantOp>(constOp.getLoc(), newTensorAttr);

      } else
        constOp.emitError("unexpected constant value");

    } else if (auto castOp = dyn_cast<arith::UIToFPOp>(op)) {
      newOp = builder.create<hlscpp::CastOp>(castOp.getLoc(), int8Type,
                                             castOp.getIn());

    } else if (auto allocOp = dyn_cast<memref::AllocOp>(op)) {
      auto newType = quantizeType(allocOp.memref().getType(), builder);
      newOp = builder.create<memref::AllocOp>(allocOp.getLoc(),
                                              newType.cast<MemRefType>());

    } else if (auto bufferOp = dyn_cast<bufferization::ToMemrefOp>(op)) {
      auto newType = quantizeType(bufferOp.memref().getType(), builder);
      newOp = builder.create<bufferization::ToMemrefOp>(
          bufferOp.getLoc(), newType.cast<MemRefType>(), bufferOp.tensor());
    }

    else if (auto loadOp = dyn_cast<mlir::AffineLoadOp>(op))
      newOp = builder.create<mlir::AffineLoadOp>(
          loadOp.getLoc(), loadOp.getAffineMap(), loadOp.getOperands());

    else if (auto selectOp = dyn_cast<mlir::SelectOp>(op))
      newOp = builder.create<mlir::SelectOp>(
          selectOp.getLoc(), selectOp.getCondition(), selectOp.getTrueValue(),
          selectOp.getFalseValue());

    else if (auto mulOp = dyn_cast<arith::MulFOp>(op)) {
      auto lhsValue = builder.create<hlscpp::CastOp>(mulOp.getLoc(), int16Type,
                                                     mulOp.getLhs());
      auto rhsValue = builder.create<hlscpp::CastOp>(mulOp.getLoc(), int16Type,
                                                     mulOp.getRhs());
      newOp = builder.create<hlscpp::MulOp>(mulOp.getLoc(), int32Type, lhsValue,
                                            rhsValue);
    }

    else if (auto addOp = dyn_cast<arith::AddFOp>(op)) {
      auto lhsValue = builder.create<hlscpp::CastOp>(addOp.getLoc(), int32Type,
                                                     addOp.getLhs());
      auto rhsValue = builder.create<hlscpp::CastOp>(addOp.getLoc(), int32Type,
                                                     addOp.getRhs());
      auto accValue = builder.create<hlscpp::AddOp>(addOp.getLoc(), int32Type,
                                                    lhsValue, rhsValue);
      newOp =
          builder.create<hlscpp::CastOp>(addOp.getLoc(), int8Type, accValue);
    }

    else if (auto divOp = dyn_cast<arith::DivFOp>(op))
      newOp = builder.create<arith::DivSIOp>(divOp.getLoc(), divOp.getLhs(),
                                             divOp.getRhs());

    else if (auto cmpOp = dyn_cast<arith::CmpFOp>(op)) {
      arith::CmpIPredicate predicate;
      switch (cmpOp.getPredicate()) {
      case arith::CmpFPredicate::OEQ:
        predicate = arith::CmpIPredicate::eq;
        break;
      case arith::CmpFPredicate::ONE:
        predicate = arith::CmpIPredicate::ne;
        break;
      case arith::CmpFPredicate::OGT:
        predicate = arith::CmpIPredicate::sgt;
        break;
      case arith::CmpFPredicate::OGE:
        predicate = arith::CmpIPredicate::sge;
        break;
      case arith::CmpFPredicate::OLT:
        predicate = arith::CmpIPredicate::slt;
        break;
      case arith::CmpFPredicate::OLE:
        predicate = arith::CmpIPredicate::sle;
        break;
      default:
        cmpOp.emitError("unexpected compare predicate");
        break;
      }
      newOp = builder.create<arith::CmpIOp>(cmpOp.getLoc(), predicate,
                                            cmpOp.getLhs(), cmpOp.getRhs());

    } else if (!isa<mlir::CallOp, mlir::ReturnOp, memref::DeallocOp,
                    mlir::AffineApplyOp, mlir::AffineForOp, mlir::AffineIfOp,
                    mlir::AffineYieldOp, mlir::AffineStoreOp>(op))
      op.emitError("unexpected op kind");

    // Replace all uses with the new generated op.
    if (newOp) {
      unsigned resultIndex = 0;
      for (auto result : op.getResults())
        result.replaceAllUsesWith(newOp->getResult(resultIndex++));

      OpsToErase.push_back(&op);
    }

    // Recursively convert all child blocks.
    if (op.getNumRegions() != 0) {
      for (auto &region : op.getRegions())
        for (auto &block : region.getBlocks())
          quantizeBlock(block, builder, OpsToErase);
    }
  }
}

bool applyQuantizeOnnx(FuncOp func) {
  auto builder = OpBuilder(func);

  // Convert the types of arguments.
  SmallVector<Type, 16> newInputTypes;
  for (auto arg : func.getArguments()) {
    if (auto type = quantizeType(arg.getType(), builder)) {
      arg.setType(type);
      newInputTypes.push_back(type);
    } else
      func.emitError("unexpected function argument type");
  }

  // Convert the function body.
  SmallVector<Operation *, 32> OpsToErase;
  for (auto &block : func.getBody())
    quantizeBlock(block, builder, OpsToErase);

  for (auto op : OpsToErase)
    op->erase();

  // Convert the function type.
  auto newResultTypes = func.front().getTerminator()->getOperandTypes();
  auto newFuncType = builder.getFunctionType(newInputTypes, newResultTypes);
  func.setType(newFuncType);

  return true;
}

namespace {
struct QuantizeOnnx : public QuantizeOnnxBase<QuantizeOnnx> {
  void runOnOperation() override {
    auto func = getOperation();
    applyQuantizeOnnx(func);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createQuantizeOnnxPass() {
  return std::make_unique<QuantizeOnnx>();
}
