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

  // ===== Emit HLS code =====
  // ScaleHLSEmitterState state(stream_to_str);
  // ModuleEmitter(state).emitModule(module);

  // ===== Emit optimized MLIR given to us by scalehls-opt =====
  
  llvm::json::Object ip_json;
  ip_json["raw"] = llvm::json::Value("");  // Default raw (unoptimized) json entry
  ip_json["source"] = llvm::json::Value("");  // Default source (optimized) json entry
  
  // Iterate through the MLIR functions in the MLIR module presented to us
  // We assume there are two functions given, one having a "bypass = true" attribute
  for (auto func : module.getOps<FuncOp>()) {
    FuncOpAdaptor func_adaptor(func);
    DictionaryAttr attr_dict = func_adaptor.getAttributes();
    
    // If this function contains "bypass = true", then emit it to the IP JSON under the "raw" field
    Attribute bypass_attr = attr_dict.get("bypass");
    if (bypass_attr != Attribute()) {
      std::string bypass_func_serialized;
      llvm::raw_string_ostream bypass_func_ss(bypass_func_serialized);
      bypass_func_ss << func;  // Luke- I had using this string streaming idiom but it seems to be the only option
      ip_json["raw"] = bypass_func_serialized;
    } else {
      std::string source_func_serialized;
      llvm::raw_string_ostream source_func_ss(source_func_serialized);
      source_func_ss << func;
      ip_json["source"] = source_func_serialized;
    }
  }

  /* JSON Object emission to string */
  std::string file_outputs;
  llvm::raw_string_ostream file_output_ss(file_outputs);
  llvm::json::OStream json_os(file_output_ss);
  json_os.object([&]{
    for (auto attr_pair : ip_json) {
      json_os.attribute(attr_pair.first, attr_pair.second);
    }
  });

  /* Final emission to JSON file */
  std::fstream fio;
  fio.open(filename, std::ios::trunc | std::ios::out | std::ios::in);
  fio << file_outputs;

  return LogicalResult::success();
}

void scalehls::registerEmitIPLibraryTranslation() {
  static TranslateFromMLIRRegistration toIPLibrary(
    "emit-ip", emitIPLibrary, [&](DialectRegistry &registry) {
        scalehls::registerAllDialects(registry);
      }
  );
}
