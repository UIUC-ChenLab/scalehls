//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Passes.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "Transforms/Passes.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/IR/Types.h"
#include "mlir/InitAllDialects.h"
#include "mlir/InitAllPasses.h"
#include "mlir/Pass/Pass.h"
#include "mlir/Pass/PassManager.h"
#include "mlir/Support/FileUtilities.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/InitLLVM.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/Support/ToolOutputFile.h"

using namespace llvm;
using namespace mlir;
using namespace scalehls;
using namespace hlskernel;

static llvm::cl::opt<std::string>
    outputFilename("o", llvm::cl::desc("Output filename"),
                   llvm::cl::value_desc("filename"), llvm::cl::init("-"));

static LogicalResult benchmarkGen(raw_ostream &os) {
  MLIRContext context;
  context.loadDialect<HLSKernelDialect>();
  auto module = ModuleOp::create(UnknownLoc::get(&context));
  OpBuilder builder(module.getBodyRegion());
  SmallVector<mlir::Type, 4> types;
  builder.create<FuncOp>(module.getLoc(), "new_func",
                         builder.getFunctionType(types, types));

  module.print(os);
  os << "\n\n";
  return success();
}

int main(int argc, char **argv) {
  llvm::InitLLVM y(argc, argv);

  // Register any pass manager command line options.
  mlir::registerPassManagerCLOptions();
  mlir::PassPipelineCLParser passPipeline("", "Compiler passes to run");

  // Parse pass names in main to ensure static initialization completed.
  llvm::cl::ParseCommandLineOptions(argc, argv,
                                    "MLIR modular optimizer driver\n");

  // Set up the output file.
  std::string errorMessage;
  auto output = mlir::openOutputFile(outputFilename, &errorMessage);
  if (!output) {
    llvm::errs() << errorMessage << "\n";
    exit(1);
  }

  if (failed(benchmarkGen(output->os()))) {
    return 1;
  }

  // Keep the output file if the invocation of MlirOptMain was successful.
  output->keep();
  return 0;
}
