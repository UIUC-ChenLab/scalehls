//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_TRANSFORMS_DATAFLOWER_H
#define SCALEHLS_TRANSFORMS_DATAFLOWER_H

#include "scalehls/Transforms/Utils.h"

namespace mlir {
namespace scalehls {

class ScaleHLSDataflower : public PatternRewriter {
public:
  ScaleHLSDataflower(MLIRContext *context) : PatternRewriter(context) {}
};

} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_TRANSFORMS_DATAFLOWER_H