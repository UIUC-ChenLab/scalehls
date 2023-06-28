//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Linalg/Transforms/Transforms.h"
#include "mlir/Dialect/SCF/Transforms/Transforms.h"
#include "mlir/Dialect/SCF/Utils/Utils.h"
#include "mlir/Transforms/GreedyPatternRewriteDriver.h"
#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Dialect/HLS/Utils/Matchers.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static FailureOr<Attribute> getParamAttr(Value param, ParamKind paramKind) {
  // If the param is not defined by ParamLikeInterface or doesn't align with the
  // given paramKind, return nullptr.
  auto paramOp = param.getDefiningOp<hls::ParamLikeInterface>();
  if (!paramOp || paramOp.getKind() != paramKind)
    return failure();

  // If the param hasn't been assigned a value, return nullptr.
  if (!paramOp.getValue().has_value())
    return failure();
  return *paramOp.getValue();
}

static FailureOr<SpaceOp> getImplSpaceOp(SpaceOp parentSpace,
                                         SymbolRefAttr &implSymbolRef) {
  // For now, the implementation design space must be defined by SpaceSelectOp.
  auto implSpace = parentSpace.getSpacePackOp().getOperands().back();
  auto implSelect = implSpace.getDefiningOp<SpaceSelectOp>();
  assert(implSelect && "invalid task implementation design space");

  // Return failure if we cannot get the task implementation parameter.
  auto implParamAttr = getParamAttr(implSelect.getArg(), ParamKind::TASK_IMPL);
  if (failed(implParamAttr))
    return failure();

  // Find the space corresponding to the selected task implementation.
  for (auto [candidate, space] :
       llvm::zip(implSelect.getConditions(), implSelect.getSpaces()))
    if (candidate == *implParamAttr) {
      implSpace = space;
      break;
    }
  auto implSpaceOp = implSpace.getDefiningOp<SpaceOp>();
  assert(implSpaceOp && "invalid task implementation candidates");

  // Get the symbol name of the IP declaration if applicable.
  implSymbolRef = implParamAttr->cast<TaskImplAttr>().getSymbolRef();
  return implSpaceOp;
}

static FailureOr<linalg::TiledLinalgOp>
tileLinalgOp(linalg::LinalgOp linalgOp, ValueRange tileParams,
             ParamKind paramKind, PatternRewriter &rewriter) {
  // Extract the tile sizes from the given tile params.
  SmallVector<int64_t> tileSizes;
  for (auto tileParam : tileParams) {
    auto tileParamAttr = getParamAttr(tileParam, paramKind);
    if (failed(tileParamAttr))
      return failure();
    tileSizes.push_back(tileParamAttr->cast<IntegerAttr>().getInt());
  }

  // Tile the linalg op with the collected tile sizes.
  linalg::LinalgTilingOptions options;
  options.setTileSizes(tileSizes);
  auto tiledLinalgOp = linalg::tileLinalgOp(rewriter, linalgOp, options);
  if (failed(tiledLinalgOp))
    return failure();

  // Replace the original linalg op with the tiled one.
  rewriter.replaceOp(linalgOp, tiledLinalgOp->tensorResults);
  return tiledLinalgOp;
}

// If the given pointer union is a value, return it. Otherwise, create a
// constant op and return it.
static Value getValueOrCreateConstant(OpFoldResult valueOrAttr,
                                      PatternRewriter &rewriter) {
  if (valueOrAttr.is<Value>())
    return valueOrAttr.get<Value>();
  auto attr = valueOrAttr.get<Attribute>();
  return rewriter.create<arith::ConstantOp>(rewriter.getUnknownLoc(),
                                            TypedAttr(attr));
}

static FailureOr<InstanceOp>
replaceLinalgOpWithInstanceOp(SpaceOp implSpaceOp, linalg::LinalgOp linalgOp,
                              SymbolRefAttr symbol, PatternRewriter &rewriter) {
  auto ipDeclare = SymbolTable::lookupNearestSymbolFrom<DeclareOp>(
      linalgOp->getParentOfType<ModuleOp>(), symbol);
  assert(ipDeclare && "invalid IP declaration");

  auto matchingResult = IPMatcher(linalgOp, ipDeclare).match();
  if (failed(matchingResult))
    return failure();

  // Mapping from a value (port/template) in an IP declaration to a payload IR.
  llvm::SmallDenseMap<Value, Value> ipToInstValueMap;

  // Collect the instance ports and the result types of the IP instance.
  rewriter.setInsertionPoint(linalgOp);
  SmallVector<Type> instOutputTypes;
  SmallVector<Value> instPorts;
  unsigned outputIdx = 0;
  for (auto [ipPort, instPortOrAttr] : llvm::zip(
           ipDeclare.getSemanticsOp().getPorts(), matchingResult->instPorts)) {
    auto instPort = getValueOrCreateConstant(instPortOrAttr, rewriter);
    instPorts.push_back(instPort);
    ipToInstValueMap[ipPort] = instPort;

    // If the port is an output, collect the type of it.
    auto portOp = ipPort.getDefiningOp<PortOp>();
    if (portOp.getKind() == PortKind::OUTPUT) {
      auto linalgIdx = matchingResult->mapIpResIndexToPayload(outputIdx++);
      auto outputType =
          linalgOp->getResult(linalgIdx).getType().cast<TensorType>();
      assert(instPort.getType() == outputType && "invalid result type");

      if (portOp.isStream())
        instOutputTypes.push_back(StreamType::get(outputType.getElementType()));
      else
        instOutputTypes.push_back(outputType);
    }
  }

  // Collect the instance templates.
  SmallVector<Attribute> instTemplates;
  for (auto [ipTemplate, instTemplateAttr] :
       llvm::zip(ipDeclare.getSemanticsOp().getTemplates(),
                 matchingResult->instTemplates)) {
    if (instTemplateAttr) {
      instTemplates.push_back(instTemplateAttr);
      continue;
    }

    // In some cases, the template value cannot be inferred from the IP
    // matching. So these values MUST have a default value.
    auto templateParam = implSpaceOp.getSpacePackOp().findOperand(
        ipTemplate.getDefiningOp<ParamOp>().getNameAttr());
    assert(templateParam && "invalid template parameter");

    auto templateParamAttr =
        getParamAttr(templateParam, ParamKind::IP_TEMPLATE);
    if (failed(templateParamAttr))
      return failure();

    instTemplates.push_back(*templateParamAttr);
    if (!ipTemplate.getType().isa<hls::TypeType>()) {
      auto instTemplate =
          getValueOrCreateConstant(*templateParamAttr, rewriter);
      ipToInstValueMap[ipTemplate] = instTemplate;
    }
  }

  // Now, we can create the instance op.
  auto instance =
      rewriter.create<InstanceOp>(linalgOp.getLoc(), instOutputTypes, instPorts,
                                  rewriter.getArrayAttr(instTemplates), symbol);

  // If the IP expects stream interface, we will convert tensor to stream for
  // inputs and vice versa for outputs.
  outputIdx = 0;
  for (auto [ipPort, instPort] :
       llvm::zip(ipDeclare.getSemanticsOp().getPorts(), instPorts)) {
    auto portOp = ipPort.getDefiningOp<PortOp>();

    // We use the ipToInstValueMap to get the corresponding dim/symbol values
    // in the payload IR.
    SmallVector<Value> instDims;
    for (auto ipDim : portOp.getDims())
      instDims.push_back(ipToInstValueMap.lookup(ipDim));
    SmallVector<Value> instSymbols;
    for (auto ipSymbol : portOp.getSymbols())
      instSymbols.push_back(ipToInstValueMap.lookup(ipSymbol));

    // Replace the original input port with a stream port is applicable.
    if (portOp.isStream()) {
      rewriter.setInsertionPoint(instance);
      auto streamType = StreamType::get(
          instPort.getType().cast<TensorType>().getElementType());
      auto stream = rewriter.create<TensorToStreamOp>(
          linalgOp.getLoc(), streamType, instPort, instDims, instSymbols,
          portOp.getStreamLayoutAttr(), portOp.getMemoryLayoutAttr());
      instPort.replaceUsesWithIf(stream.getResult(), [&](OpOperand &use) {
        return use.getOwner() == instance;
      });
    }

    // Convert stream output to tensors and replace all uses of the original
    // linalg op results.
    if (portOp.getKind() == PortKind::OUTPUT) {
      auto tensor = instance.getResult(outputIdx);

      if (portOp.isStream()) {
        rewriter.setInsertionPointAfter(instance);
        tensor = rewriter.create<StreamToTensorOp>(
            linalgOp.getLoc(), instPort.getType(), tensor, instDims,
            instSymbols, portOp.getStreamLayoutAttr(),
            portOp.getMemoryLayoutAttr());
      }

      auto linalgIdx = matchingResult->mapIpResIndexToPayload(outputIdx++);
      linalgOp->getResult(linalgIdx).replaceAllUsesWith(tensor);
    }
  }

  rewriter.eraseOp(linalgOp);
  return instance;
}

namespace {
struct ImplementTaskDesignSpacePattern : public OpRewritePattern<TaskOp> {
  using OpRewritePattern<TaskOp>::OpRewritePattern;

  LogicalResult matchAndRewrite(TaskOp op,
                                PatternRewriter &rewriter) const override {
    // If the task is not attached to a space, return failure.
    if (!op.getSpace().has_value())
      return failure();

    // If the design space or payload linalg op is not found, return failure.
    auto space = SymbolTable::lookupNearestSymbolFrom<SpaceOp>(
        op->getParentOfType<ModuleOp>(), op.getSpaceAttr());
    auto linalgOp = op.getPayloadLinalgOp();
    if (!space || !linalgOp)
      return op.removeSpaceAttr(), failure();

    // First, tile the linalg op with the tile parameters. All operands of the
    // terminator SpacePackOp except the last one should be tile parameters.
    auto tiledLinalgOp = tileLinalgOp(
        linalgOp, llvm::drop_end(space.getSpacePackOp().getOperands()),
        ParamKind::TILE_SIZE, rewriter);
    if (failed(tiledLinalgOp))
      return op.removeSpaceAttr(), failure();
    linalgOp = tiledLinalgOp->op;

    // Then, we find the implementation design space of the task to handle the
    // IP substitution or parallelization of the task.
    SymbolRefAttr symbol;
    auto implSpaceOp = getImplSpaceOp(space, symbol);
    if (failed(implSpaceOp))
      return op.removeSpaceAttr(), failure();

    if (symbol) {
      // If the task will be implemented with an IP, we substitute the original
      // linalg operation with an IP instance.
      if (failed(replaceLinalgOpWithInstanceOp(*implSpaceOp, linalgOp, symbol,
                                               rewriter)))
        return op.removeSpaceAttr(), failure();
    } else {
      // Otherwise, use the default implementation that parallelize the linalg
      // operation with the parallel parameters.
      auto parallelLinalgOp =
          tileLinalgOp(linalgOp, implSpaceOp->getSpacePackOp().getArgs(),
                       ParamKind::PARALLEL_SIZE, rewriter);
      if (failed(parallelLinalgOp))
        return op.removeSpaceAttr(), failure();
      linalgOp = parallelLinalgOp->op;
    }

    // Finally, we remove the space attribute from the task op.
    op.removeSpaceAttr();
    return success();
  }
};
} // namespace

namespace {
struct ImplementTaskDesignSpace
    : public ImplementTaskDesignSpaceBase<ImplementTaskDesignSpace> {
  void runOnOperation() override {
    auto module = getOperation();
    auto context = module.getContext();

    mlir::RewritePatternSet patterns(context);
    patterns.add<ImplementTaskDesignSpacePattern>(context);
    (void)applyPatternsAndFoldGreedily(module, std::move(patterns));
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::hls::createImplementTaskDesignSpacePass() {
  return std::make_unique<ImplementTaskDesignSpace>();
}
