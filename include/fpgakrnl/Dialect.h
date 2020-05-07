#include "mlir/IR/Dialect.h"
#include "mlir/IR/Function.h"
#include "mlir/Interfaces/SideEffects.h"

namespace mlir {
namespace fpgakrnl {

class FpgaKrnlDialect : public mlir::Dialect {
    explicit FpgaKrnlDialect(mlir::MLIRContext *ctx);
    static llvm::StringRef getDialectNamespace() {
        return "fpgakrnl";
    }
};

#define GET_OP_CLASSES
#include "fpgakrnl/Ops.h.inc"
}
}