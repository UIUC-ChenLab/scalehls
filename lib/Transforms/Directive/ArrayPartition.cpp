//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/Analysis/AffineAnalysis.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/Dialect/MemRef/IR/MemRef.h"
#include "mlir/Dialect/Vector/IR/VectorOps.h"
#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hlscpp;

static void updateSubFuncs(FuncOp func, Builder builder) {
  func.walk([&](func::CallOp op) {
    auto callee = SymbolTable::lookupNearestSymbolFrom(op, op.getCalleeAttr());
    auto subFunc = dyn_cast<FuncOp>(callee);

    // Set sub-function type.
    auto subResultTypes = op.getResultTypes();
    auto subInputTypes = op.getOperandTypes();
    auto newType = builder.getFunctionType(subInputTypes, subResultTypes);

    if (subFunc.getType() != newType) {
      subFunc.setType(newType);

      // Set arguments type.
      unsigned index = 0;
      for (auto inputType : op.getOperandTypes())
        subFunc.getArgument(index++).setType(inputType);

      // Set results type.
      auto returnOp = cast<func::ReturnOp>(subFunc.front().getTerminator());
      index = 0;
      for (auto resultType : op.getResultTypes())
        returnOp.getOperand(index++).setType(resultType);

      // Recursively apply array partition strategy.
      updateSubFuncs(subFunc, builder);
    }
  });
}

/// Apply the specified array partition factors and kinds.
bool scalehls::applyArrayPartition(Value array, ArrayRef<unsigned> factors,
                                   ArrayRef<hlscpp::PartitionKind> kinds,
                                   bool updateFuncSignature) {
  auto builder = Builder(array.getContext());
  auto arrayType = array.getType().dyn_cast<MemRefType>();
  if (!arrayType || !arrayType.hasStaticShape() ||
      (int64_t)factors.size() != arrayType.getRank() ||
      (int64_t)kinds.size() != arrayType.getRank())
    return false;

  // Walk through each dimension of the current memory.
  SmallVector<AffineExpr, 4> partitionIndices;
  SmallVector<AffineExpr, 4> addressIndices;

  for (int64_t dim = 0; dim < arrayType.getRank(); ++dim) {
    auto kind = kinds[dim];
    auto factor = factors[dim];

    if (kind == PartitionKind::CYCLIC) {
      partitionIndices.push_back(builder.getAffineDimExpr(dim) % factor);
      addressIndices.push_back(builder.getAffineDimExpr(dim).floorDiv(factor));

    } else if (kind == PartitionKind::BLOCK) {
      auto blockFactor = (arrayType.getShape()[dim] + factor - 1) / factor;
      partitionIndices.push_back(
          builder.getAffineDimExpr(dim).floorDiv(blockFactor));
      addressIndices.push_back(builder.getAffineDimExpr(dim) % blockFactor);

    } else {
      partitionIndices.push_back(builder.getAffineConstantExpr(0));
      addressIndices.push_back(builder.getAffineDimExpr(dim));
    }
  }

  // Construct new layout map.
  partitionIndices.append(addressIndices.begin(), addressIndices.end());
  auto layoutMap = AffineMap::get(arrayType.getRank(), 0, partitionIndices,
                                  builder.getContext());

  // Construct new array type.
  auto newType =
      MemRefType::get(arrayType.getShape(), arrayType.getElementType(),
                      layoutMap, arrayType.getMemorySpace());

  // Set new type.
  array.setType(newType);

  if (updateFuncSignature)
    if (auto func = dyn_cast<FuncOp>(array.getParentBlock()->getParentOp())) {
      // Align function type with entry block argument types only if the array
      // is defined as an argument of the function.
      if (!array.getDefiningOp()) {
        auto resultTypes = func.front().getTerminator()->getOperandTypes();
        auto inputTypes = func.front().getArgumentTypes();
        func.setType(builder.getFunctionType(inputTypes, resultTypes));
      }

      // Update the types of all sub-functions.
      updateSubFuncs(func, builder);
    }
  return true;
}

static AffineMap getIdentityAffineMap(const SmallVectorImpl<Value> &operands,
                                      unsigned rank, MLIRContext *context) {
  SmallVector<AffineExpr, 4> exprs;
  exprs.reserve(rank);
  unsigned dimCount = 0;
  unsigned symbolCount = 0;

  for (auto operand : operands) {
    if (isValidDim(operand))
      exprs.push_back(getAffineDimExpr(dimCount++, context));
    else if (isValidSymbol(operand))
      exprs.push_back(getAffineSymbolExpr(symbolCount++, context));
    else
      return AffineMap();
  }
  return AffineMap::get(dimCount, symbolCount, exprs, context);
}

static AffineValueMap getAffineValueMap(Operation *op) {
  // Get affine map from AffineLoad/Store.
  AffineMap map;
  SmallVector<Value, 4> operands;
  if (auto loadOp = dyn_cast<mlir::AffineReadOpInterface>(op)) {
    operands = loadOp.getMapOperands();
    map = loadOp.getAffineMap();

  } else if (auto storeOp = dyn_cast<mlir::AffineWriteOpInterface>(op)) {
    operands = storeOp.getMapOperands();
    map = storeOp.getAffineMap();

  } else if (auto readOp = dyn_cast<vector::TransferReadOp>(op)) {
    operands = readOp.indices();
    map = getIdentityAffineMap(operands, readOp.getShapedType().getRank(),
                               readOp.getContext());
  } else {
    auto writeOp = cast<vector::TransferWriteOp>(op);
    operands = writeOp.indices();
    map = getIdentityAffineMap(operands, writeOp.getShapedType().getRank(),
                               writeOp.getContext());
  }

  fullyComposeAffineMapAndOperands(&map, &operands);
  map = simplifyAffineMap(map);
  canonicalizeMapAndOperands(&map, &operands);
  return AffineValueMap(map, operands);
}

static SmallVector<AffineMap, 4>
getDimAccessMaps(Operation *op, AffineValueMap valueMap, int64_t dim) {
  // Only keep the mapping result of the target dimension.
  auto baseMap = AffineMap::get(valueMap.getNumDims(), valueMap.getNumSymbols(),
                                valueMap.getResult(dim));

  // Get the permuation map from the transfer read/write op.
  AffineMap permuteMap;
  ArrayRef<int64_t> vectorShape;
  if (auto readOp = dyn_cast<vector::TransferReadOp>(op)) {
    permuteMap = readOp.permutation_map();
    vectorShape = readOp.getVectorType().getShape();
  } else if (auto writeOp = dyn_cast<vector::TransferWriteOp>(op)) {
    permuteMap = writeOp.permutation_map();
    vectorShape = writeOp.getVectorType().getShape();
  }

  SmallVector<AffineMap, 4> maps({baseMap});
  if (!permuteMap)
    return maps;

  // Traverse each dimension of the transfered vector.
  for (unsigned i = 0, e = permuteMap.getNumResults(); i < e; ++i) {
    auto dimExpr = permuteMap.getResult(i).dyn_cast<AffineDimExpr>();

    // If the permutation result of the current dimension is equal to the target
    // dimension, we push back the access map of each element of the vector into
    // the "maps" to be returned.
    if (dimExpr && dimExpr.getPosition() == dim) {
      for (int64_t offset = 0, size = vectorShape[i]; offset < size; ++offset) {
        auto map = AffineMap::get(baseMap.getNumDims(), baseMap.getNumSymbols(),
                                  baseMap.getResult(0) + offset);
        maps.push_back(map);
      }
      break;
    }
  }
  return maps;
}

/// Find the suitable array partition factors and kinds for all arrays in the
/// targeted function.
bool scalehls::applyAutoArrayPartition(FuncOp func) {
  // Check whether the input function is pipelined.
  bool funcPipeline = false;
  if (auto attr = func->getAttrOfType<BoolAttr>("pipeline"))
    if (attr.getValue())
      funcPipeline = true;

  // Collect target basic blocks to be considered.
  SmallVector<Block *, 4> targetBlocks;
  if (funcPipeline)
    targetBlocks.push_back(&func.front());
  else {
    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands);

    // Apply loop order optimization to each loop band.
    for (auto &band : targetBands)
      targetBlocks.push_back(band.back().getBody());
  }

  // Storing the partition information of each memref. The rationale is there
  // may exist multiple blocks/functions accessing the same memref and in
  // different blocks/functions the best partition fashions and factors are
  // different. To eventually determine a "best" array partition strategy,
  // tentatively we always pick the one with the largest partition factor as the
  // final partition strategy. This "partitionsMap" is used to hold the current
  // partition strategy of each memref.
  using PartitionInfo = std::pair<PartitionKind, int64_t>;
  DenseMap<Value, SmallVector<PartitionInfo, 4>> partitionsMap;

  // Traverse all blocks that requires to be considered.
  for (auto block : targetBlocks) {
    MemAccessesMap accessesMap;
    getMemAccessesMap(*block, accessesMap, /*includeVectorTransfer=*/true);

    for (auto pair : accessesMap) {
      auto memref = pair.first;
      auto memrefType = memref.getType().cast<MemRefType>();
      auto loadStores = pair.second;
      auto &partitions = partitionsMap[memref];

      // If the current partitionsMap is empty, initialize it with no partition
      // and factor of 1.
      if (partitions.empty()) {
        for (int64_t dim = 0; dim < memrefType.getRank(); ++dim)
          partitions.push_back(PartitionInfo(PartitionKind::NONE, 1));
      }

      // Find the best partition solution for each dimensions of the memref.
      for (int64_t dim = 0; dim < memrefType.getRank(); ++dim) {
        // Collect all array access indices of the current dimension.
        SmallVector<AffineValueMap, 4> indices;

        for (auto accessOp : loadStores) {
          auto valueMap = getAffineValueMap(accessOp);
          if (valueMap.getAffineMap().isEmpty())
            continue;

          auto dimMaps = getDimAccessMaps(accessOp, valueMap, dim);
          for (auto dimMap : dimMaps) {
            // Construct the new valueMap.
            AffineValueMap dimValueMap(dimMap, valueMap.getOperands());
            (void)dimValueMap.canonicalize();

            // Only add unique index.
            if (find_if(indices, [&](auto index) {
                  return index.getAffineMap() == dimValueMap.getAffineMap() &&
                         index.getOperands() == dimValueMap.getOperands();
                }) == indices.end())
              indices.push_back(dimValueMap);
          }
        }
        auto accessNum = indices.size();

        // Find the max array access distance in the current block.
        unsigned maxDistance = 0;
        bool requireMux = false;

        for (unsigned i = 0; i < accessNum; ++i) {
          for (unsigned j = i + 1; j < accessNum; ++j) {
            if (indices[i].getOperands() != indices[j].getOperands()) {
              requireMux = true;
              continue;
            }

            auto expr = indices[j].getResult(0) - indices[i].getResult(0);
            auto newExpr = simplifyAffineExpr(expr, indices[i].getNumDims(),
                                              indices[i].getNumSymbols());

            if (auto constDistance = newExpr.dyn_cast<AffineConstantExpr>()) {
              unsigned distance = std::abs(constDistance.getValue());
              maxDistance = std::max(maxDistance, distance);
            } else
              requireMux = true;
          }
        }

        // Determine array partition strategy.
        // TODO: take storage type into consideration.
        // TODO: the partition strategy requires more case study.
        ++maxDistance;
        if (maxDistance == 1) {
          // This means all accesses have the same index, and this dimension
          // should not be partitioned.
          continue;

        } else if (accessNum >= maxDistance) {
          // This means some elements are accessed more than once or exactly
          // once, and successive elements are accessed. In most cases, apply
          // "cyclic" partition should be the best solution.
          unsigned factor = maxDistance;
          if (factor > partitions[dim].second) {
            // The rationale here is if the accessing partition index cannot be
            // determined and partition factor is more than 3, a multiplexer
            // will be generated and the memory access operation will be wrapped
            // into a function call, which will cause dependency problems and
            // make the latency and II even worse.
            if (requireMux)
              for (auto i = 3; i > 0; --i) {
                if (factor % i == 0) {
                  partitions[dim] = PartitionInfo(PartitionKind::CYCLIC, i);
                  break;
                }
              }
            else
              partitions[dim] = PartitionInfo(PartitionKind::CYCLIC, factor);
          }
        } else {
          // This means discrete elements are accessed. Typically, "block"
          // partition will be most benefit for this occasion.
          unsigned factor = accessNum;
          if (factor > partitions[dim].second) {
            if (requireMux)
              for (auto i = 3; i > 0; --i) {
                if (factor % i == 0) {
                  partitions[dim] = PartitionInfo(PartitionKind::BLOCK, i);
                  break;
                }
              }
            else
              partitions[dim] = PartitionInfo(PartitionKind::BLOCK, factor);
          }
        }
      }
    }
  }

  // Apply partition to all sub-functions and traverse all function to update
  // the "partitionsMap".
  func.walk([&](func::CallOp op) {
    auto callee = SymbolTable::lookupNearestSymbolFrom(op, op.getCalleeAttr());
    auto subFunc = dyn_cast<FuncOp>(callee);
    assert(subFunc && "callable is not a function operation");

    // Apply array partition to the sub-function.
    applyAutoArrayPartition(subFunc);

    auto subFuncType = subFunc.getType();
    unsigned index = 0;
    for (auto inputType : subFuncType.getInputs()) {
      if (auto memrefType = inputType.dyn_cast<MemRefType>()) {
        auto &partitions = partitionsMap[op.getOperand(index)];
        auto layoutMap = memrefType.getLayout().getAffineMap();

        // If the current partitionsMap is empty, initialize it with no
        // partition and factor of 1.
        if (partitions.empty()) {
          for (int64_t dim = 0; dim < memrefType.getRank(); ++dim)
            partitions.push_back(PartitionInfo(PartitionKind::NONE, 1));
        }

        // Get the partition factor collected from sub-function.
        SmallVector<int64_t, 8> factors;
        getPartitionFactors(memrefType, &factors);

        // Traverse all dimension of the memref.
        for (int64_t dim = 0; dim < memrefType.getRank(); ++dim) {
          auto factor = factors[dim];

          // If the factor from the sub-function is larger than the current
          // factor, replace it.
          if (factor > partitions[dim].second) {
            if (layoutMap.getResult(dim).getKind() == AffineExprKind::FloorDiv)
              partitions[dim] = PartitionInfo(PartitionKind::BLOCK, factor);
            else
              partitions[dim] = PartitionInfo(PartitionKind::CYCLIC, factor);
          }
        }
      }

      ++index;
    }
  });

  // Constuct and set new type to each partitioned MemRefType.
  auto builder = Builder(func);
  for (auto pair : partitionsMap) {
    auto memref = pair.first;
    auto partitions = pair.second;

    SmallVector<hlscpp::PartitionKind, 4> kinds;
    SmallVector<unsigned, 4> factors;
    for (auto info : partitions) {
      kinds.push_back(info.first);
      factors.push_back(info.second);
    }

    applyArrayPartition(memref, factors, kinds,
                        /*updateFuncSignature=*/false);
  }

  // Align function type with entry block argument types.
  auto resultTypes = func.front().getTerminator()->getOperandTypes();
  auto inputTypes = func.front().getArgumentTypes();
  func.setType(builder.getFunctionType(inputTypes, resultTypes));

  // Update the types of all sub-functions.
  updateSubFuncs(func, builder);

  return true;
}

namespace {
struct ArrayPartition : public ArrayPartitionBase<ArrayPartition> {
  void runOnOperation() override {
    auto module = getOperation();

    // Get the top function.
    // FIXME: A better solution to handle the runtime main function.
    FuncOp topFunc;
    for (auto func : module.getOps<FuncOp>()) {
      if (hasRuntimeAttr(func)) {
        topFunc = func;
        break;
      } else if (hasTopFuncAttr(func))
        topFunc = func;
    }

    if (!topFunc) {
      emitError(module.getLoc(), "fail to find the top function");
      return signalPassFailure();
    }
    applyAutoArrayPartition(topFunc);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createArrayPartitionPass() {
  return std::make_unique<ArrayPartition>();
}
