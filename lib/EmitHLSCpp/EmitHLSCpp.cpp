//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "mlir/Dialect/Affine/IR/AffineOps.h"
#include "mlir/Dialect/SCF/SCF.h"
#include "mlir/Dialect/StandardOps/IR/Ops.h"
#include "mlir/IR/Function.h"
#include "mlir/IR/Module.h"
#include "mlir/IR/StandardTypes.h"
#include "mlir/Support/LLVM.h"
#include "mlir/Translation.h"
#include "llvm/ADT/StringSet.h"
#include "llvm/ADT/TypeSwitch.h"
#include "llvm/Support/raw_ostream.h"

#include "EmitHLSCpp.h"

using namespace std;
using namespace mlir;

//===----------------------------------------------------------------------===//
// Some Base Classes
//
// These classes should be factored out, and can be inherited by emitters
// targeting various backends (e.g., Xilinx Vivado HLS, Intel FPGAs, etc.).
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

namespace {
/// This class is a visitor for SSACFG operation nodes.
template <typename ConcreteType, typename ResultType, typename... ExtraArgs>
class HLSCppVisitorBase {
public:
  ResultType dispatchVisitor(Operation *op, ExtraArgs... args) {
    auto *thisCast = static_cast<ConcreteType *>(this);
    return TypeSwitch<Operation *, ResultType>(op)
        .template Case<
            // Binary expressions.
            AddIOp,
            // Special operations.
            ReturnOp>([&](auto opNode) -> ResultType {
          return thisCast->visitOp(opNode, args...);
        })
        .Default([&](auto opNode) -> ResultType {
          return thisCast->visitInvalidOp(op, args...);
        });
  }

  /// This callback is invoked on any invalid operations.
  ResultType visitInvalidOp(Operation *op, ExtraArgs... args) {
    op->emitOpError("is unsupported operation.");
    abort();
  }

  /// This callback is invoked on any operations that are not handled by the
  /// concrete visitor.
  ResultType visitUnhandledOp(Operation *op, ExtraArgs... args) {
    return ResultType();
  }

#define HANDLE(OPTYPE)                                                         \
  ResultType visitOp(OPTYPE op, ExtraArgs... args) {                           \
    return static_cast<ConcreteType *>(this)->visitUnhandledOp(op, args...);   \
  }

  // Binary expressions.
  HANDLE(AddIOp);

  // Special operations.
  HANDLE(ReturnOp);
#undef HANDLE
};
} // namespace

//===----------------------------------------------------------------------===//
// Utils
//===----------------------------------------------------------------------===//

//===----------------------------------------------------------------------===//
// ModuleEmitter Class Definition
//===----------------------------------------------------------------------===//

namespace {
class ModuleEmitter : public HLSCppEmitterBase {
public:
  explicit ModuleEmitter(HLSCppEmitterState &state)
      : HLSCppEmitterBase(state) {}

  void emitBinaryExpr(Operation *op, const char *syntax);

  void emitModule(ModuleOp module);

private:
  DenseMap<Value, SmallString<8>> nameTable;

  SmallString<8> getName(Value val) { return nameTable[val]; }
  SmallString<8> addName(Value val, bool isPtr);

  void emitValueDecl(Value val, bool isPtr);

  void emitOperation(Operation *op);
  void emitFunction(FuncOp func);
};
} // namespace

//===----------------------------------------------------------------------===//
// ExprVisitor Class
//===----------------------------------------------------------------------===//

namespace {
class ExprVisitor : public HLSCppVisitorBase<ExprVisitor, bool> {
public:
  ExprVisitor(ModuleEmitter &emitter) : emitter(emitter) {}

  using HLSCppVisitorBase::visitOp;
  bool visitOp(AddIOp op) { return emitter.emitBinaryExpr(op, "+"), true; }
  bool visitOp(ReturnOp op) { return true; }

private:
  ModuleEmitter &emitter;
};
} // namespace

//===----------------------------------------------------------------------===//
// StmtVisitor Class
//===----------------------------------------------------------------------===//

namespace {
class StmtVisitor : public HLSCppVisitorBase<StmtVisitor, bool> {
public:
  StmtVisitor(ModuleEmitter &emitter) : emitter(emitter) {}

private:
  ModuleEmitter &emitter;
};
} // namespace

//===----------------------------------------------------------------------===//
// ModuleEmitter Class Implementation
//===----------------------------------------------------------------------===//

SmallString<8> ModuleEmitter::addName(Value val, bool isPtr = false) {
  // Temporary naming rule.
  SmallString<8> newName;
  if (isPtr)
    newName += "*";
  newName += StringRef("val" + to_string(nameTable.size()));

  auto valName = nameTable[val];
  if (!valName.empty() && valName != newName)
    return valName;
  else {
    nameTable[val] = newName;
    return newName;
  }
}

void ModuleEmitter::emitValueDecl(Value val, bool isPtr = false) {
  // Value has been declared before.
  if (!getName(val).empty()) {
    os << getName(val);
    return;
  }

  switch (val.getType().getKind()) {
  // Handle float types.
  case StandardTypes::F16:
    os << "float ";
    break;
  case StandardTypes::F32:
    os << "double ";
    break;

  // Handle integer types.
  case StandardTypes::Index:
    os << "int ";
    break;
  case StandardTypes::Integer: {
    auto intType = val.getType().cast<IntegerType>();
    os << "ap_";
    if (intType.getSignedness() == IntegerType::SignednessSemantics::Unsigned)
      os << "u";
    os << "int<" << intType.getWidth() << "> ";
    break;
  }
  default:
    emitError(val.getDefiningOp(), "has unsupported type.");
    break;
  }

  // Add the new value declaration to nameTable.
  os << addName(val, isPtr);
  return;
}

void ModuleEmitter::emitBinaryExpr(Operation *op, const char *syntax) {
  indent();
  emitValueDecl(op->getResult(0));

  // Emit expression. We are not folding sub-expressions for now.
  os << " = " << getName(op->getOperand(0));
  os << " " << syntax << " ";
  os << getName(op->getOperand(1)) << ";\n";
}

void ModuleEmitter::emitOperation(Operation *op) {
  if (ExprVisitor(*this).dispatchVisitor(op))
    return;

  emitError(op, "can't be correctly emitted.");
}

void ModuleEmitter::emitFunction(FuncOp func) {
  if (func.getBlocks().size() != 1)
    emitError(func, "has more than one basic blocks.");
  os << "void " << func.getName() << "(\n";

  // Emit function signature.
  addIndent();

  // Handle input arguments.
  unsigned argIdx = 0;
  for (auto &arg : func.getArguments()) {
    indent();
    emitValueDecl(arg);
    if (argIdx == func.getNumArguments() - 1 && func.getNumResults() == 0)
      os << "\n";
    else
      os << ",\n";
    argIdx += 1;
  }

  // Handle results.
  if (auto funcReturn = dyn_cast<ReturnOp>(func.front().getTerminator())) {
    unsigned resultIdx = 0;
    for (auto result : funcReturn.getOperands()) {
      indent();
      emitValueDecl(result, /*isPtr=*/true);
      if (resultIdx == func.getNumResults() - 1)
        os << "\n";
      else
        os << ",\n";
      resultIdx += 1;
    }
  } else {
    emitError(func, "doesn't have return operation as terminator.");
  }

  reduceIndent();
  os << ") {\n";

  // Emit function body.
  addIndent();

  // Traverse all operations and emit them.
  for (auto &op : func.front())
    emitOperation(&op);

  reduceIndent();
  os << "}\n";
}

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
      emitFunction(func);
    else if (!isa<ModuleTerminatorOp>(op))
      emitError(&op, "is unsupported operation.");
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
