//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/Transforms/Passes.h"
#include "scalehls/Utils/Utils.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

namespace mlir {
namespace scalehls {
namespace hls {
#define GEN_PASS_DEF_GENERATEDIRECTIVES
#include "scalehls/Dialect/HLS/Transforms/Passes.h.inc"
} // namespace hls
} // namespace scalehls
} // namespace mlir

static bool isLeafLoop(scf::ForOp loop) {
  auto walkResult = loop.walk([&](scf::ForOp subLoop) {
    if (subLoop != loop)
      return WalkResult::interrupt();
    return WalkResult::advance();
  });
  return !walkResult.wasInterrupted();
}

// A helper to determine whether a dimension of a subview is partitionable.
static bool isCyclicPartitionable(OpFoldResult offset, int64_t size) {
  if (auto staticOffset = getConstantIntValue(offset))
    return staticOffset == 0;

  if (auto loop = scf::getForInductionVarOwner(offset.get<Value>()))
    if (auto step = loop.getSingleStep())
      if (auto staticStep = getConstantIntValue(*step))
        return staticStep == size;
  return false;
}

namespace {
struct Partition {
  hls::PartitionKind kind;
  int64_t factor;
};
} // namespace

namespace {
struct GenerateDirectives
    : public hls::impl::GenerateDirectivesBase<GenerateDirectives> {
  void runOnOperation() override {
    auto func = getOperation();
    auto builder = OpBuilder(func);

    // Set dataflow directive for the function if it contains any task.
    if (!func.getOps<hls::TaskOp>().empty())
      func->setAttr(kDataflowAttrName, builder.getUnitAttr());

    func.walk([&](hls::TaskOp task) {
      // Set dataflow directive for the task if it contains any task.
      if (!task.getOps<hls::TaskOp>().empty())
        task->setAttr(kDataflowAttrName, builder.getUnitAttr());
    });

    llvm::SmallDenseMap<BufferOp, SmallVector<Partition>> partitionsMap;
    func.walk([&](scf::ForOp loop) {
      // Set dataflow directive if the loop contains any task. Otherwise, set
      // pipeline directive if the loop is leaf loop.
      if (!loop.getOps<hls::TaskOp>().empty())
        loop->setAttr(kDataflowAttrName, builder.getUnitAttr());
      else if (isLeafLoop(loop)) {
        loop->setAttr(kPipelineAttrName, builder.getUnitAttr());

        for (auto subview : loop.getOps<memref::SubViewOp>()) {
          auto buffer = subview.getSource().getDefiningOp<BufferOp>();

          // For subview with non-unit stride and dynamic sizes, we cannot
          // decide the partition kind and factor.
          if (!buffer || !subview.hasUnitStride() ||
              llvm::any_of(subview.getMixedSizes(),
                           [](OpFoldResult size) { return size.is<Value>(); }))
            continue;

          // Otherwise, we try to partition the original buffer.
          auto &partitions = partitionsMap[buffer];
          partitions.resize(subview.getType().getRank(),
                            {PartitionKind::NONE, 1});
          for (auto [offset, size, partition] :
               llvm::zip(subview.getMixedOffsets(), subview.getStaticSizes(),
                         partitions))
            if (isCyclicPartitionable(offset, size))
              if (size > partition.factor)
                partition = {PartitionKind::CYCLIC, size};
        }
      }
    });

    for (auto [buffer, partitions] : partitionsMap) {
      if (partitions.empty())
        continue;

      SmallVector<hls::PartitionKind> kinds;
      SmallVector<int64_t> factors;
      for (auto partition : partitions) {
        kinds.push_back(partition.kind);
        factors.push_back(partition.factor);
      }

      auto layoutAttr =
          hls::PartitionLayoutAttr::get(builder.getContext(), kinds, factors);
      buffer->setAttr(kPartitionAttrName, layoutAttr);
    }
  }
};
} // namespace
