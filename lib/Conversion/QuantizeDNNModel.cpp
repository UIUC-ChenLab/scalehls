//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
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
    auto maps = memrefType.getAffineMaps();
    auto memorySpace = memrefType.getMemorySpace();
    return MemRefType::get(shape, int8Type, maps, memorySpace);

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

    if (auto constOp = dyn_cast<mlir::ConstantOp>(op)) {
      auto attr = constOp.value();

      if (auto floatAttr = attr.dyn_cast<FloatAttr>()) {
        int8_t floatValue = floatAttr.getValue().convertToFloat();
        newOp = builder.create<mlir::ConstantOp>(
            constOp.getLoc(), builder.getI8IntegerAttr(floatValue));

      } else if (auto intAttr = attr.dyn_cast<IntegerAttr>()) {
        int8_t intValue = intAttr.getInt();
        newOp = builder.create<mlir::ConstantOp>(
            constOp.getLoc(), builder.getI8IntegerAttr(intValue));

      } else if (auto tensorAttr = attr.dyn_cast<DenseElementsAttr>()) {
        SmallVector<int8_t, 16> newTensorValues;
        for (auto elem : tensorAttr.getFloatValues()) {
          int8_t value = elem.convertToFloat();
          newTensorValues.push_back(value);
        }

        auto newTensorType = RankedTensorType::get(newTensorValues.size(),
                                                   builder.getIntegerType(8));
        auto newTensorAttr =
            DenseIntElementsAttr::get(newTensorType, newTensorValues);
        newOp =
            builder.create<mlir::ConstantOp>(constOp.getLoc(), newTensorAttr);

      } else
        constOp.emitError("unexpected constant value");

    } else if (auto castOp = dyn_cast<mlir::UIToFPOp>(op)) {
      newOp = builder.create<hlscpp::CastOp>(castOp.getLoc(), int8Type,
                                             castOp.in());

    } else if (auto allocOp = dyn_cast<memref::AllocOp>(op)) {
      auto newType = quantizeType(allocOp.memref().getType(), builder);
      newOp = builder.create<memref::AllocOp>(allocOp.getLoc(),
                                              newType.cast<MemRefType>());

    } else if (auto bufferOp = dyn_cast<memref::BufferCastOp>(op)) {
      auto newType = quantizeType(bufferOp.memref().getType(), builder);
      newOp = builder.create<memref::BufferCastOp>(
          bufferOp.getLoc(), newType.cast<MemRefType>(), bufferOp.tensor());
    }

    else if (auto loadOp = dyn_cast<mlir::AffineLoadOp>(op))
      newOp = builder.create<mlir::AffineLoadOp>(
          loadOp.getLoc(), loadOp.getAffineMap(), loadOp.getOperands());

    else if (auto selectOp = dyn_cast<mlir::SelectOp>(op))
      newOp = builder.create<mlir::SelectOp>(
          selectOp.getLoc(), selectOp.condition(), selectOp.true_value(),
          selectOp.false_value());

    else if (auto mulOp = dyn_cast<mlir::MulFOp>(op)) {
      auto lhsValue = builder.create<hlscpp::CastOp>(mulOp.getLoc(), int16Type,
                                                     mulOp.lhs());
      auto rhsValue = builder.create<hlscpp::CastOp>(mulOp.getLoc(), int16Type,
                                                     mulOp.rhs());
      newOp = builder.create<hlscpp::MulOp>(mulOp.getLoc(), int32Type, lhsValue,
                                            rhsValue);
    }

    else if (auto addOp = dyn_cast<mlir::AddFOp>(op)) {
      auto lhsValue = builder.create<hlscpp::CastOp>(addOp.getLoc(), int32Type,
                                                     addOp.lhs());
      auto rhsValue = builder.create<hlscpp::CastOp>(addOp.getLoc(), int32Type,
                                                     addOp.rhs());
      auto accValue = builder.create<hlscpp::AddOp>(addOp.getLoc(), int32Type,
                                                    lhsValue, rhsValue);
      newOp =
          builder.create<hlscpp::CastOp>(addOp.getLoc(), int8Type, accValue);
    }

    else if (auto divOp = dyn_cast<mlir::DivFOp>(op))
      newOp = builder.create<mlir::SignedDivIOp>(divOp.getLoc(), divOp.lhs(),
                                                 divOp.rhs());

    else if (auto cmpOp = dyn_cast<mlir::CmpFOp>(op)) {
      CmpIPredicate predicate;
      switch (cmpOp.predicate()) {
      case CmpFPredicate::OEQ:
        predicate = CmpIPredicate::eq;
        break;
      case CmpFPredicate::ONE:
        predicate = CmpIPredicate::ne;
        break;
      case CmpFPredicate::OGT:
        predicate = CmpIPredicate::sgt;
        break;
      case CmpFPredicate::OGE:
        predicate = CmpIPredicate::sge;
        break;
      case CmpFPredicate::OLT:
        predicate = CmpIPredicate::slt;
        break;
      case CmpFPredicate::OLE:
        predicate = CmpIPredicate::sle;
        break;
      default:
        cmpOp.emitError("unexpected compare predicate");
        break;
      }
      newOp = builder.create<mlir::CmpIOp>(cmpOp.getLoc(), predicate,
                                           cmpOp.lhs(), cmpOp.rhs());

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

bool applyQuantizeDNNModel(FuncOp func) {
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
struct QuantizeDNNModel : public QuantizeDNNModelBase<QuantizeDNNModel> {
  void runOnOperation() override {
    auto func = getOperation();
    applyQuantizeDNNModel(func);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createQuantizeDNNModelPass() {
  return std::make_unique<QuantizeDNNModel>();
}
