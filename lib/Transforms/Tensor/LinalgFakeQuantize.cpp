//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Transforms/Passes.h"
#include "llvm/Support/RandomNumberGenerator.h"

using namespace mlir;
using namespace scalehls;

namespace {
template <typename FloatOpType, typename IntOpType>
struct ArithFloatToInt : public OpRewritePattern<FloatOpType> {
  using OpRewritePattern<FloatOpType>::OpRewritePattern;

  LogicalResult matchAndRewrite(FloatOpType floatOp,
                                PatternRewriter &rewriter) const override {
    SmallVector<NamedAttribute> attrs;
    for (auto item : floatOp->getAttrDictionary())
      attrs.push_back(item);
    rewriter.replaceOpWithNewOp<IntOpType>(floatOp, floatOp->getResultTypes(),
                                           floatOp->getOperands(), attrs);
    return success();
  }
};
} // namespace

namespace {
struct CmpFloatToInt : public OpRewritePattern<arith::CmpFOp> {
  using OpRewritePattern<arith::CmpFOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(arith::CmpFOp cmpFloat,
                                PatternRewriter &rewriter) const override {
    arith::CmpIPredicate predicate;
    switch (cmpFloat.getPredicate()) {
    case arith::CmpFPredicate::UEQ:
      predicate = arith::CmpIPredicate::eq;
      break;
    case arith::CmpFPredicate::UGE:
      predicate = arith::CmpIPredicate::uge;
      break;
    case arith::CmpFPredicate::UGT:
      predicate = arith::CmpIPredicate::ugt;
      break;
    case arith::CmpFPredicate::ULE:
      predicate = arith::CmpIPredicate::ule;
      break;
    case arith::CmpFPredicate::ULT:
      predicate = arith::CmpIPredicate::ult;
      break;
    case arith::CmpFPredicate::UNE:
      predicate = arith::CmpIPredicate::ne;
      break;
    default:
      return cmpFloat.emitOpError("unsupport compare predicate");
      break;
    }
    rewriter.replaceOpWithNewOp<arith::CmpIOp>(
        cmpFloat, predicate, cmpFloat.getLhs(), cmpFloat.getRhs());
    return success();
  }
};
} // namespace

namespace {
/// This pass is only for testing use!!! To really support quantized model,
/// first we need to have front-ends, such as Torch-MLIR, to support the model
/// quantization, which has not came true unfortunately.
struct LinalgFakeQuantize : public LinalgFakeQuantizeBase<LinalgFakeQuantize> {
  /// Get the quantized type from float scalar or tensor type.
  Type getQuantizeType(Type type) {
    auto integerType = IntegerType::get(type.getContext(), quanBits.getValue());
    if (type.isa<FloatType>())
      return integerType;
    if (type.isa<IntegerType, IndexType>())
      return type;

    if (auto tensorType = type.dyn_cast<RankedTensorType>()) {
      if (tensorType.getElementType().isa<FloatType>())
        return RankedTensorType::get(tensorType.getShape(), integerType);
      if (tensorType.getElementType().isa<IntegerType, IndexType>())
        return type;
    }
    return Type();
  }

  template <typename ValueType>
  DenseIntElementsAttr generateRandomValues(Type quanType, unsigned size) {
    std::srand(time(0));
    unsigned maxValue = std::pow(2, quanBits.getValue());
    SmallVector<ValueType, 64> values;
    for (unsigned i = 0; i < size; ++i)
      values.push_back(std::rand() % maxValue);
    return DenseIntElementsAttr::get(quanType, values);
  }

  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();
    auto builder = OpBuilder(context);

    auto result = module.walk([&](Block *block) {
      // Convert the type of block arguments.
      for (auto arg : block->getArguments()) {
        if (auto quantType = getQuantizeType(arg.getType()))
          arg.setType(quantType);
        else
          return WalkResult::interrupt();
      }

      // Convert the type of each result of each operation.
      for (auto &op : block->getOperations()) {
        for (auto result : op.getResults()) {
          if (auto quantType = getQuantizeType(result.getType()))
            result.setType(quantType);
          else
            return WalkResult::interrupt();
        }

        // Convert the type of constant values.
        if (auto constant = dyn_cast<arith::ConstantOp>(op)) {
          auto quanType = getQuantizeType(constant.getValue().getType());
          assert(quanType == constant.getType() && "invalid quantization type");
          if (quanType == constant.getValue().getType())
            continue;

          // Convert tensor typed constant values. At this point, we have known
          // that the tensor has floating-point elements.
          if (constant.getValue().getType().isa<RankedTensorType>()) {
            auto denseAttr = constant.getValue().cast<DenseElementsAttr>();
            DenseIntElementsAttr attr;

            switch (quanBits.getValue()) {
            case 8:
              attr = generateRandomValues<int8_t>(quanType, denseAttr.size());
              break;
            case 16:
              attr = generateRandomValues<int16_t>(quanType, denseAttr.size());
              break;
            case 32:
              attr = generateRandomValues<int32_t>(quanType, denseAttr.size());
              break;
            case 64:
              attr = generateRandomValues<int64_t>(quanType, denseAttr.size());
              break;
            default:
              return WalkResult::interrupt();
              break;
            }
            constant.setValueAttr(attr);
          } else {
            std::srand(time(0));
            unsigned maxValue = std::pow(2, quanBits.getValue());
            auto attr = IntegerAttr::get(quanType, std::rand() % maxValue);
            constant.setValueAttr(attr);
          }
        }
      }
      return WalkResult::advance();
    });

    if (result.wasInterrupted()) {
      emitError(module.getLoc(), "failed to quantize the module");
      return signalPassFailure();
    }

    // As we have updated the type of all values in the function, we can safely
    // convert the function type as well.
    module.walk([&](func::FuncOp func) {
      func.setType(builder.getFunctionType(
          func.front().getArgumentTypes(),
          func.back().getTerminator()->getOperandTypes()));
    });

    // Convert arithmetic ops.
    mlir::RewritePatternSet patterns(context);
    patterns.add<CmpFloatToInt>(context);
    patterns.add<ArithFloatToInt<arith::AddFOp, arith::AddIOp>>(context);
    patterns.add<ArithFloatToInt<arith::DivFOp, arith::DivUIOp>>(context);
    patterns.add<ArithFloatToInt<arith::ExtFOp, arith::ExtUIOp>>(context);
    patterns.add<ArithFloatToInt<arith::MaxFOp, arith::MaxUIOp>>(context);
    patterns.add<ArithFloatToInt<arith::MinFOp, arith::MinUIOp>>(context);
    patterns.add<ArithFloatToInt<arith::MulFOp, arith::MulIOp>>(context);
    patterns.add<ArithFloatToInt<arith::RemFOp, arith::RemUIOp>>(context);
    patterns.add<ArithFloatToInt<arith::SubFOp, arith::SubIOp>>(context);
    patterns.add<ArithFloatToInt<arith::TruncFOp, arith::TruncIOp>>(context);
    patterns.add<ArithFloatToInt<math::AbsFOp, math::AbsIOp>>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createLinalgFakeQuantizePass() {
  return std::make_unique<LinalgFakeQuantize>();
}
