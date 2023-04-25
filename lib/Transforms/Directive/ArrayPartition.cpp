//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Transforms/Passes.h"
#include "scalehls/Transforms/Utils.h"
#include "llvm/Support/Debug.h"

#define DEBUG_TYPE "array-partition"

using namespace mlir;
using namespace scalehls;
using namespace hls;

static void updateSubFuncs(func::FuncOp func, Builder builder) {
  func.walk([&](func::CallOp op) {
    auto callee = SymbolTable::lookupNearestSymbolFrom(op, op.getCalleeAttr());
    auto subFunc = dyn_cast<func::FuncOp>(callee);

    // Set sub-function type.
    auto subResultTypes = op.getResultTypes();
    auto subInputTypes = op.getOperandTypes();
    auto newType = builder.getFunctionType(subInputTypes, subResultTypes);

    if (subFunc.getFunctionType() != newType) {
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
                                   ArrayRef<hls::PartitionKind> kinds,
                                   bool updateFuncSignature,
                                   unsigned threshold) {
  auto arrayType = array.getType().dyn_cast<MemRefType>();
  if (!arrayType || isExtBuffer(array) || !arrayType.hasStaticShape() ||
      (int64_t)factors.size() != arrayType.getRank() ||
      (int64_t)kinds.size() != arrayType.getRank())
    return false;

  LLVM_DEBUG(llvm::dbgs() << "\nApply array partition to " << array << " at "
                          << array.getLoc(););
  LLVM_DEBUG(llvm::dbgs() << "\nfactors: ";);
  LLVM_DEBUG(for (auto factor : factors) llvm::dbgs() << factor << ", ";);
  LLVM_DEBUG(llvm::dbgs() << "\nkinds: ";);
  LLVM_DEBUG(for (auto kind : kinds) llvm::dbgs() << kind << ", ";);
  LLVM_DEBUG(llvm::dbgs() << "\n";);

  // Calculate the actual depth of the partitioned array.
  unsigned actualDepth = 1;
  for (auto [factor, dimSize] : llvm::zip(factors, arrayType.getShape())) {
    if (dimSize % factor != 0)
      return false;
    if (factor != 0)
      actualDepth *= dimSize / factor;
  }

  // Construct and set new array type.
  auto layoutAttr = PartitionLayoutAttr::getWithActualFactors(
      array.getContext(), kinds, SmallVector<int64_t>(factors),
      arrayType.getShape());
  auto kindAttr = arrayType.getMemorySpace().cast<MemoryKindAttr>();
  if (actualDepth < threshold)
    kindAttr = MemoryKindAttr::get(array.getContext(), MemoryKind::LUTRAM_2P);
  array.setType(MemRefType::get(
      arrayType.getShape(), arrayType.getElementType(), layoutAttr, kindAttr));

  if (updateFuncSignature)
    if (auto func = array.getParentRegion()->getParentOfType<func::FuncOp>()) {
      auto builder = Builder(array.getContext());

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
  if (auto loadOp = dyn_cast<AffineReadOpInterface>(op)) {
    operands = loadOp.getMapOperands();
    map = loadOp.getAffineMap();

  } else if (auto storeOp = dyn_cast<AffineWriteOpInterface>(op)) {
    operands = storeOp.getMapOperands();
    map = storeOp.getAffineMap();

  } else if (auto readOp = dyn_cast<vector::TransferReadOp>(op)) {
    operands = readOp.getIndices();
    map = getIdentityAffineMap(operands, readOp.getShapedType().getRank(),
                               readOp.getContext());
  } else {
    auto writeOp = cast<vector::TransferWriteOp>(op);
    operands = writeOp.getIndices();
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
    permuteMap = readOp.getPermutationMap();
    vectorShape = readOp.getVectorType().getShape();
  } else if (auto writeOp = dyn_cast<vector::TransferWriteOp>(op)) {
    permuteMap = writeOp.getPermutationMap();
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

SmallVector<int64_t> createPermutationMap(ArrayRef<Value> vec1,
                                          ArrayRef<Value> vec2) {
  if (llvm::SmallDenseSet<Value>(vec1.begin(), vec1.end()) !=
      llvm::SmallDenseSet<Value>(vec2.begin(), vec2.end()))
    return {};

  SmallVector<int64_t> permutation_map(vec1.size());
  llvm::SmallDenseMap<Value, int> index_map;

  for (size_t i = 0; i < vec1.size(); ++i) {
    index_map[vec1[i]] = i;
  }
  for (size_t i = 0; i < vec2.size(); ++i) {
    permutation_map[i] = index_map[vec2[i]];
  }
  return permutation_map;
}

/// Find the suitable array partition factors and kinds for all arrays in the
/// targeted function.
bool scalehls::applyAutoArrayPartition(func::FuncOp func, unsigned threshold) {
  // Check whether the input function is pipelined.
  bool funcPipeline = false;
  if (auto attr = getFuncDirective(func))
    funcPipeline = attr.getPipeline();

  // Collect target basic blocks to be considered.
  SmallVector<Block *, 4> targetBlocks;
  if (funcPipeline)
    targetBlocks.push_back(&func.front());
  else {
    // Collect all target loop bands.
    AffineLoopBands targetBands;
    getLoopBands(func.front(), targetBands);
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
  using Partition = std::pair<PartitionKind, int64_t>;
  DenseMap<Value, SmallVector<Partition, 4>> partitionsMap;

  // Traverse all blocks that requires to be considered.
  for (auto block : targetBlocks) {
    MemAccessesMap accessesMap;
    getMemAccessesMap(*block, accessesMap, /*includeVectorTransfer=*/true);

    for (auto [memref, loadStores] : accessesMap) {
      auto memrefType = memref.getType().cast<MemRefType>();
      auto &partitions = partitionsMap[memref];

      // If the current partitionsMap is empty, initialize it with no partition.
      if (partitions.empty())
        partitions = SmallVector<Partition, 4>(
            memrefType.getRank(), Partition(PartitionKind::NONE, 1));

      LLVM_DEBUG(llvm::dbgs()
                     << "\n----------\nArray partition for " << memref;);

      // Find the best partition solution for each dimensions of the
      // memref.
      for (int64_t dim = 0; dim < memrefType.getRank(); ++dim) {
        // Collect all array access indices of the current dimension.
        SmallVector<AffineValueMap, 4> indices;

        LLVM_DEBUG(llvm::dbgs() << "\n\nDimension " << dim << "";);

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
                }) == indices.end()) {
              indices.push_back(dimValueMap);
              LLVM_DEBUG(llvm::dbgs()
                             << "\nIndex: " << dimValueMap.getResult(0););
            }
          }
        }
        auto accessNum = indices.size();

        // Find the max array access distance in the current block.
        unsigned maxDistance = 0;
        unsigned maxCommonDivisor = 0;
        bool requireMux = false;

        for (unsigned i = 0; i < accessNum; ++i) {
          for (unsigned j = i + 1; j < accessNum; ++j) {
            auto lhsIndex = indices[i];
            auto rhsIndex = indices[j];
            auto lhsExpr = lhsIndex.getResult(0);
            auto rhsExpr = rhsIndex.getResult(0);

            if (lhsIndex.getOperands() != rhsIndex.getOperands()) {
              // Here, we try to find a permutation map to make the two index
              // identical.
              auto possiblePermutation = createPermutationMap(
                  lhsIndex.getOperands(), rhsIndex.getOperands());

              if (possiblePermutation.empty()) {
                // If no permutation map is found, we need to use a mux to
                // select value from the partitioned array. Meanwhile, we cannot
                // calculate the distance in this case, so continue.
                requireMux = true;
                continue;
              } else {
                // If a permutation map is found, we need to apply it to the
                // rhsExpr.
                SmallVector<AffineExpr, 4> dimReplacements;
                SmallVector<AffineExpr, 4> symReplacements;
                for (auto i : possiblePermutation) {
                  if (i < rhsIndex.getNumDims())
                    dimReplacements.push_back(
                        getAffineDimExpr(i, func.getContext()));
                  else
                    symReplacements.push_back(getAffineSymbolExpr(
                        i - rhsIndex.getNumDims(), func.getContext()));
                }
                rhsExpr = rhsExpr.replaceDimsAndSymbols(dimReplacements,
                                                        symReplacements);
              }
            }

            LLVM_DEBUG(llvm::dbgs() << "\nDistance: "
                                    << "(" << lhsExpr << ")"
                                    << " - "
                                    << "(" << rhsExpr << ")";);
            auto newExpr =
                simplifyAffineExpr(rhsExpr - lhsExpr, lhsIndex.getNumDims(),
                                   lhsIndex.getNumSymbols());

            if (auto constDistance = newExpr.dyn_cast<AffineConstantExpr>()) {
              LLVM_DEBUG(llvm::dbgs() << " = " << constDistance.getValue(););

              unsigned distance = std::abs(constDistance.getValue());
              maxDistance = std::max(maxDistance, distance);
              maxCommonDivisor = std::gcd(distance, maxCommonDivisor);
            } else
              requireMux = true;
          }
        }
        ++maxDistance;

        // This means all accesses have the same index, and this dimension
        // should not be partitioned.
        if (maxDistance == 1)
          continue;

        // Determine array partition factor and kind.
        // TODO: take storage type into consideration.
        int64_t factor = 1;
        PartitionKind kind = PartitionKind::NONE;
        if (accessNum >= maxDistance) {
          // This means some elements are accessed more than once or exactly
          // once, and successive elements are accessed. In most cases, apply
          // "cyclic" partition should be the best solution.
          factor = maxDistance;
          kind = PartitionKind::CYCLIC;
        } else if (maxCommonDivisor > 1) {
          // This means the memory access is perfectly strided.
          factor = maxDistance;
          while (factor % maxCommonDivisor != 0)
            factor++;
          kind = PartitionKind::CYCLIC;
        } else {
          // This means elements are accessed in a descrete manner however not
          // strided. Typically, "block" partition will be the most benefitial
          // partition strategy.
          factor = accessNum;
          kind = PartitionKind::BLOCK;
        }

        LLVM_DEBUG(llvm::dbgs() << "\nStretegy: "
                                << " factor=" << factor << " kind=" << kind;);

        // TODO: For now, we always pick the partition with the largest factor.
        if (factor > partitions[dim].second) {
          LLVM_DEBUG(llvm::dbgs() << " (update)";);

          // The rationale here is if the accessing partition index cannot be
          // determined and partition factor is more than 3, a multiplexer will
          // be generated and the memory access operation will be wrapped into a
          // function call, which will cause dependency problems and make the
          // latency and II even worse.
          if (requireMux) {
            for (auto i = 3; i > 0; --i)
              if (factor % i == 0) {
                partitions[dim] = Partition(kind, i);
                break;
              }
          } else
            partitions[dim] = Partition(kind, factor);
        }
      }

      LLVM_DEBUG(llvm::dbgs() << "\n\nAccesses: ";);
      for (auto op : loadStores)
        LLVM_DEBUG(llvm::dbgs() << "\n" << *op;);
    }
  }

  // Apply partition to all sub-functions and traverse all function to update
  // the "partitionsMap".
  func.walk([&](func::CallOp op) {
    auto callee = SymbolTable::lookupNearestSymbolFrom(op, op.getCalleeAttr());
    auto subFunc = dyn_cast<func::FuncOp>(callee);
    assert(subFunc && "callable is not a function operation");

    // Apply array partition to the sub-function.
    applyAutoArrayPartition(subFunc, threshold);

    for (auto [type, operand] :
         llvm::zip(subFunc.getArgumentTypes(), op.getOperands())) {
      if (auto memrefType = type.dyn_cast<MemRefType>()) {
        auto &partitions = partitionsMap[operand];

        // If the current partitionsMap is empty, initialize it with no
        // partition.
        if (partitions.empty())
          partitions = SmallVector<Partition, 4>(
              memrefType.getRank(), Partition(PartitionKind::NONE, 1));

        // Traverse all dimension of the memref.
        if (auto attr = memrefType.getLayout().dyn_cast<PartitionLayoutAttr>())
          for (int64_t dim = 0; dim < memrefType.getRank(); ++dim) {
            auto kind = attr.getKinds()[dim];
            auto factor = attr.getFactors()[dim];

            // If the factor from the sub-function is larger than the current
            // factor, replace it.
            if (factor > partitions[dim].second)
              partitions[dim] = Partition(kind, factor);
          }
      } else
        operand.setType(type);
    }
  });

  // Constuct and set new type to each partitioned MemRefType.
  auto builder = Builder(func);
  for (auto [memref, partitions] : partitionsMap) {
    SmallVector<hls::PartitionKind, 4> kinds;
    SmallVector<unsigned, 4> factors;
    for (auto [kind, factor] : partitions) {
      kinds.push_back(kind);
      factors.push_back(factor);
    }

    if (llvm::any_of(kinds, [](PartitionKind kind) {
          return kind != PartitionKind::NONE;
        }))
      applyArrayPartition(memref, factors, kinds, false, threshold);

    if (auto axiPort = memref.getDefiningOp<AxiPortOp>()) {
      auto axiType = AxiType::get(memref.getContext(), memref.getType());
      LLVM_DEBUG(llvm::dbgs() << "\nUpdate AxiPort type: " << *axiPort
                              << ", Type: " << axiType << "\n";);
      axiPort.getAxi().setType(axiType);
      LLVM_DEBUG(llvm::dbgs() << "Updated op: " << *axiPort << "\n";);
    }
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
  ArrayPartition() = default;
  explicit ArrayPartition(unsigned argThreshold) { threshold = argThreshold; }

  void runOnOperation() override {
    auto module = getOperation();

    // Get the top function.
    // FIXME: A better solution to handle the runtime main function.
    func::FuncOp topFunc;
    for (auto func : module.getOps<func::FuncOp>()) {
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
    applyAutoArrayPartition(topFunc, threshold);
  }
};
} // namespace

std::unique_ptr<Pass> scalehls::createArrayPartitionPass(unsigned threshold) {
  return std::make_unique<ArrayPartition>(threshold);
}
