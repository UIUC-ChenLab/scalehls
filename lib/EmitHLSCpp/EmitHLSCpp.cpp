//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "EmitHLSCpp.h"
#include "mlir/IR/Function.h"
#include "mlir/IR/Module.h"
#include "mlir/IR/StandardTypes.h"
#include "mlir/Translation.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/Support/raw_ostream.h"

using namespace mlir;

//===----------------------------------------------------------------------===//
// Utilities
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
// FuncEmitter
//===----------------------------------------------------------------------===//

namespace {
class FuncEmitter : public HLSCppEmitterBase {
public:
  explicit FuncEmitter(HLSCppEmitterState &state) : HLSCppEmitterBase(state) {}

  void emitFunc(FuncOp func);
};
} // namespace

void FuncEmitter::emitFunc(FuncOp func) { os << "new function\n"; };

//===----------------------------------------------------------------------===//
// HLSCppEmitter
//===----------------------------------------------------------------------===//

namespace {
class HLSCppEmitter : public HLSCppEmitterBase {
public:
  explicit HLSCppEmitter(HLSCppEmitterState &state)
      : HLSCppEmitterBase(state) {}

  void emitMLIRModule(ModuleOp module);
};
} // namespace

void HLSCppEmitter::emitMLIRModule(ModuleOp module) {
  for (auto &op : *module.getBody()) {
    if (auto func = dyn_cast<FuncOp>(op))
      FuncEmitter(state).emitFunc(func);
    else if (!isa<ModuleTerminatorOp>(op))
      op.emitError("unknown operation");
  }
}

//===----------------------------------------------------------------------===//
// hlsld-translate Entry
//===----------------------------------------------------------------------===//

static LogicalResult emitHLSCpp(ModuleOp module, llvm::raw_ostream &os) {
  HLSCppEmitterState state(os);
  HLSCppEmitter(state).emitMLIRModule(module);
  return failure(state.encounteredError);
}

void hlsld::registerHLSCppEmitterTranslation() {
  static TranslateFromMLIRRegistration toHLSCpp("emit-hlscpp", emitHLSCpp);
}
