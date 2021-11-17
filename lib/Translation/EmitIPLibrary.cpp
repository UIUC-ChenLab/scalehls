#include "scalehls/Translation/EmitHLSCpp.h"
#include "mlir/Dialect/Affine/IR/AffineValueMap.h"
#include "mlir/IR/AffineExprVisitor.h"
#include "mlir/IR/IntegerSet.h"
#include "mlir/Translation.h"
#include "scalehls/Dialect/HLSCpp/Visitor.h"
#include "scalehls/Dialect/HLSKernel/Visitor.h"
#include "scalehls/InitAllDialects.h"
#include "scalehls/Support/Utils.h"
#include "llvm/Support/raw_ostream.h"

#include "scalehls/Translation/EmissionMethods.h"
#include "scalehls/Translation/EmitIPLibrary.h"
#include "llvm/Support/JSON.h"
#include <iostream>
#include <fstream>

using namespace mlir;
using namespace scalehls;

LogicalResult scalehls::emitIPLibrary(ModuleOp module, llvm::raw_ostream &os) {
  // TODO: Somehow we need to find a way to get a filename argument into this scope. How can I add a filename option to the "emit-ip" cmd-line arg?
  
  std::string filename = "iplibrary.json";  // This will need to be set by the command line
  std::string optimized_source, json_file_contents;
  llvm::raw_string_ostream stream_to_str(optimized_source);

  ScaleHLSEmitterState state(stream_to_str);
  ModuleEmitter(state).emitModule(module, false);

  // std::cout << "Now emitting optimized source" << std::endl << optimized_source << std::endl;

  /* Build the JSON object representing the IP */
  // llvm::json::Object ip_in_json;
  // ip_in_json.insert({"source", optimized_source});

  /* JSON emission to string */
  llvm::raw_string_ostream stream_to_json_str(json_file_contents);
  llvm::json::OStream json_os(stream_to_json_str);
  json_os.object([&]{
    json_os.attribute("source", llvm::json::Value(optimized_source));
  });

  /* Final emission to JSON file */
  std::fstream fio;
  fio.open(filename, std::ios::trunc | std::ios::out | std::ios::in);
  fio << json_file_contents;

  return failure(state.encounteredError);
}

void scalehls::registerEmitIPLibraryTranslation() {
  static TranslateFromMLIRRegistration toIPLibrary(
      "emit-ip", emitIPLibrary, [&](DialectRegistry &registry) {
        scalehls::registerAllDialects(registry);
      });
}
