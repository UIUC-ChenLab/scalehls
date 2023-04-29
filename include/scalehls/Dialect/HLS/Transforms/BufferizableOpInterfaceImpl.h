//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_DIALECT_HLS_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H
#define SCALEHLS_DIALECT_HLS_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H

namespace mlir {
class DialectRegistry;

namespace scalehls {
namespace hls {
void registerBufferizableOpInterfaceExternalModels(DialectRegistry &registry);
} // namespace hls
} // namespace scalehls
} // namespace mlir

#endif // SCALEHLS_DIALECT_HLS_TRANSFORMS_BUFFERIZABLEOPINTERFACEIMPL_H
