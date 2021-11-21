//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "scalehls/Translation/EmitHLSCpp.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/IR/AffineExprVisitor.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Support/FileUtilities.h"
#include "mlir/Translation.h"
#include "scalehls/Dialect/HLSCpp/Visitor.h"
#include "scalehls/Dialect/HLSKernel/Visitor.h"
#include "scalehls/InitAllDialects.h"
#include "scalehls/Support/Utils.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/MemoryBuffer.h"
#include "llvm/Support/raw_ostream.h"

// Bring in the emission methods defined in EmissionMethods.cpp
#include "scalehls/Translation/EmissionMethods.h"

#include <iostream>
#include <fstream>

using namespace mlir;
using namespace scalehls;

LogicalResult scalehls::emitHLSCpp(ModuleOp module, llvm::raw_ostream &os) {
  ScaleHLSEmitterState state(os);
  ModuleEmitter(state).emitModule(module);
  return failure(state.encounteredError);
}

void scalehls::registerEmitHLSCppTranslation() {
  static TranslateFromMLIRRegistration toHLSCpp(
      "emit-hlscpp", emitHLSCpp, [&](DialectRegistry &registry) {
        scalehls::registerAllDialects(registry);
      });
}
