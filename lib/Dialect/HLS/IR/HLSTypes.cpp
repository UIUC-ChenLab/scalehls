//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Dialect/HLS/IR/HLS.h"

using namespace mlir;
using namespace scalehls;
using namespace hls;

/// Clone this type with the given shape and element type. If the provided
/// shape is `std::nullopt`, the current shape of the type is used.
StreamType hls::StreamType::cloneWith(std::optional<ArrayRef<int64_t>> shape,
                                      Type elementType) const {
  return StreamType::get(elementType, shape ? *shape : getShape(),
                         getIterLayout(), getDepth());
}

/// Return whether the "other" stream type is compatible with this stream type.
/// By being compatible, it means that the two stream types have the element
/// type and iteration order, but not necessarily the same iteration shape and
/// layout. Compatible stream types can be casted to each other.
bool hls::StreamType::isCompatibleWith(StreamType other) {
  if (*this == other)
    return true;
  return false;
}
