//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/Function.h"
#include "mlir/IR/Module.h"
#include "mlir/IR/StandardTypes.h"
#include "mlir/Translation.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/Support/raw_ostream.h"

#include "EmitHLSCpp.h"

using namespace mlir;

//===----------------------------------------------------------------------===//
// Visitors
//
// These classes should (?) be factored out from here, and can be inherited by
// different backend/emitter (e.g. HLS Cpp for Vivado, HLS Cpp for Intel FPGAs,
// OpenCL, etc.).
//===----------------------------------------------------------------------===//

namespace {
/// StmtVisitor is a visitor for statement nodes.
template <typename ConcreteType, typename ResultType = void,
          typename... ExtraArgs>
class StmtVisitor {
public:
  ResultType dispatchStmtVisitor(Operation *op, ExtraArgs... args) {
    auto *thisCast = static_cast<ConcreteType *>(this);
    return TypeSwitch<Operation *, ResultType>(op)
        .template Case<scf::IfOp>([&](auto opNode) -> ResultType {
          return thisCast->visitStmt(opNode, args...);
        })
        .Default([&](auto expr) -> ResultType {
          return thisCast->visitInvalidStmt(op, args...);
        });
  }

  /// This callback is invoked on any non-statement operations.
  ResultType visitInvalidStmt(Operation *op, ExtraArgs... args) {
    op->emitOpError("Unknown statement.");
    abort();
  }

  /// This callback is invoked on any statement operations that are not handled
  /// by the concrete visitor.
  ResultType visitUnhandledStmt(Operation *op, ExtraArgs... args) {
    return ResultType();
  }

#define HANDLE(OPTYPE)                                                         \
  ResultType visitStmt(OPTYPE op, ExtraArgs... args) {                         \
    return static_cast<ConcreteType *>(this)->visitUnhandledStmt(op, args...); \
  }

  HANDLE(scf::IfOp);
#undef HANDLE
};
} // namespace

namespace {
/// ExprVisitor is a visitor for expression nodes.
template <typename ConcreteType, typename ResultType = void,
          typename... ExtraArgs>
class ExprVisitor {
public:
  ResultType dispatchExprVisitor(Operation *op, ExtraArgs... args) {
    auto *thisCast = static_cast<ConcreteType *>(this);
    return TypeSwitch<Operation *, ResultType>(op)
        .template Case<AddIOp>([&](auto expr) -> ResultType {
          return thisCast->visitExpr(expr, args...);
        })
        .Default([&](auto expr) -> ResultType {
          return thisCast->visitInvalidExpr(op, args...);
        });
  }

  /// This callback is invoked on any non-expression operations.
  ResultType visitInvalidExpr(Operation *op, ExtraArgs... args) {
    op->emitOpError("Unknown expression.");
    abort();
  }

  /// This callback is invoked on any expression operations that are not handled
  /// by the concrete visitor.
  ResultType visitUnhandledExpr(Operation *op, ExtraArgs... args) {
    return ResultType();
  }

  /// This fallback is invoked on any unary expr that isn't explicitly handled.
  /// The default implementation delegates to the unhandled expression fallback.
  ResultType visitUnaryExpr(Operation *op, ExtraArgs... args) {
    return static_cast<ConcreteType *>(this)->visitUnhandledExpr(op, args...);
  }

  /// This fallback is invoked on any binary expr that isn't explicitly handled.
  /// The default implementation delegates to the unhandled expression fallback.
  ResultType visitBinaryExpr(Operation *op, ExtraArgs... args) {
    return static_cast<ConcreteType *>(this)->visitUnhandledExpr(op, args...);
  }

#define HANDLE(OPTYPE, OPKIND)                                                 \
  ResultType visitExpr(OPTYPE op, ExtraArgs... args) {                         \
    return static_cast<ConcreteType *>(this)->visit##OPKIND##Expr(op,          \
                                                                  args...);    \
  }

  HANDLE(AddIOp, Binary);
#undef HANDLE
};
} // namespace

//===----------------------------------------------------------------------===//
// HLSCppEmitter Base Classes
//
// These classes should (?) be factored out from here somehow.
//===----------------------------------------------------------------------===//

namespace {
/// This class maintains the mutable state that cross-cuts and is shared by the
/// various emitters.
class HLSCppEmitterState {
public:
  explicit HLSCppEmitterState(raw_ostream &os) : os(os) {}

  /// The stream to emit to.
  raw_ostream &os;

  bool encounteredError = false;
  unsigned currentIndent = 0;

private:
  HLSCppEmitterState(const HLSCppEmitterState &) = delete;
  void operator=(const HLSCppEmitterState &) = delete;
};
} // namespace

namespace {
/// This is the base class for all of the HLSCpp Emitter components.
class HLSCppEmitterBase {
public:
  explicit HLSCppEmitterBase(HLSCppEmitterState &state)
      : state(state), os(state.os) {}

  InFlightDiagnostic emitError(Operation *op, const Twine &message) {
    state.encounteredError = true;
    return op->emitError(message);
  }

  InFlightDiagnostic emitOpError(Operation *op, const Twine &message) {
    state.encounteredError = true;
    return op->emitOpError(message);
  }

  raw_ostream &indent() { return os.indent(state.currentIndent); }

  void addIndent() { state.currentIndent += 2; }
  void reduceIndent() { state.currentIndent -= 2; }

  // All of the mutable state we are maintaining.
  HLSCppEmitterState &state;

  /// The stream to emit to.
  raw_ostream &os;

private:
  HLSCppEmitterBase(const HLSCppEmitterBase &) = delete;
  void operator=(const HLSCppEmitterBase &) = delete;
};
} // namespace

//===----------------------------------------------------------------------===//
// ExprEmitter Class
//===----------------------------------------------------------------------===//

namespace {
class ExprEmitter : public ExprVisitor<ExprEmitter> {
public:
private:
};
} // namespace

//===----------------------------------------------------------------------===//
// StmtEmitter Class
//===----------------------------------------------------------------------===//

namespace {
class StmtEmitter : public ExprVisitor<StmtEmitter> {
public:
private:
};
} // namespace

//===----------------------------------------------------------------------===//
// ModuleEmitter Class
//===----------------------------------------------------------------------===//

namespace {
class ModuleEmitter : public HLSCppEmitterBase {
public:
  explicit ModuleEmitter(HLSCppEmitterState &state)
      : HLSCppEmitterBase(state) {}

  void emitOperation(Operation *op);
  void emitFunc(FuncOp func);
  void emitModule(ModuleOp module);
};
} // namespace

void ModuleEmitter::emitOperation(Operation *op) {
  os << "new op:" << op->getName() << ";\n";
};

void ModuleEmitter::emitFunc(FuncOp func) {
  os << "void " << func.getName() << " (";

  // TODO: handle arguments.
  os << ") {\n";
  addIndent();

  // TODO: daclarations.

  // TODO: handle all operations.
  if (func.getBlocks().size() != 1) {
    func.emitError("More than one blocks in the current function.");
  }
  for (auto &op : func.front()) {
    indent();
    emitOperation(&op);
  }
  os << "}\n";
};

void ModuleEmitter::emitModule(ModuleOp module) {
  os << R"XXX(
//===------------------------------------------------------------*- C++ -*-===//
//
// Automatically generated file for High-level Synthesis (HLS).
//
//===----------------------------------------------------------------------===//

#include <ap_axi_sdata.h>
#include <ap_fixed.h>
#include <ap_int.h>
#include <hls_math.h>
#include <hls_stream.h>
#include <math.h>
#include <stdint.h>

)XXX";

  for (auto &op : *module.getBody()) {
    if (auto func = dyn_cast<FuncOp>(op))
      emitFunc(func);
    else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("Unknown operation.");
  }
}

//===----------------------------------------------------------------------===//
// Entry of hlsld-translate
//===----------------------------------------------------------------------===//

static LogicalResult emitHLSCpp(ModuleOp module, llvm::raw_ostream &os) {
  HLSCppEmitterState state(os);
  ModuleEmitter(state).emitModule(module);
  return failure(state.encounteredError);
}

void hlsld::registerHLSCppEmitterTranslation() {
  static TranslateFromMLIRRegistration toHLSCpp("emit-hlscpp", emitHLSCpp);
}
