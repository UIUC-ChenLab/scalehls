// #ifndef SCALEHLS_TRANSLATION_EMITHLSCPP_H
// #define SCALEHLS_TRANSLATION_EMITHLSCPP_H

#include "mlir/IR/BuiltinOps.h"

namespace mlir {
namespace scalehls {

LogicalResult emitIPLibrary(ModuleOp module, llvm::raw_ostream &os);
void registerEmitIPLibraryTranslation();

} // namespace scalehls
} // namespace mlir

// #endif // SCALEHLS_TRANSLATION_EMITHLSCPP_H
