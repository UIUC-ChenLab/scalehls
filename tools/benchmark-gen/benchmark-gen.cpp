//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Passes.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "INIReader.h"
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
    benchmarkType("type", llvm::cl::desc("Benchmark type"),
                  llvm::cl::value_desc("cnn/blas/isp"), llvm::cl::init("cnn"));

static llvm::cl::opt<std::string>
    configFilename("config", llvm::cl::desc("Configuration filename"),
                   llvm::cl::value_desc("filename"),
                   llvm::cl::init("../config/cnn-config.ini"));

static llvm::cl::opt<unsigned>
    benchmarkNumber("number", llvm::cl::desc("Benchmark number"),
                    llvm::cl::value_desc("positive number"), llvm::cl::init(1));

static llvm::cl::opt<std::string>
    outputFilename("o", llvm::cl::desc("Output filename"),
                   llvm::cl::value_desc("filename"), llvm::cl::init("-"));

//===----------------------------------------------------------------------===//
// Benchmark Generator Class Definition
//===----------------------------------------------------------------------===//

namespace {
/// Class for automatically generating benchmarks.
class BenchmarkGenerator {
public:
  explicit BenchmarkGenerator(raw_ostream &os, ModuleOp &module)
      : os(os), module(module) {}

  raw_ostream &os;
  ModuleOp &module;

  /// Methods for generating various types of benchmarks.
  LogicalResult genCNN(INIReader config);
  LogicalResult genBLAS(INIReader config) { return failure(); }
  LogicalResult genISP(INIReader config) { return failure(); }
}; // namespace
} // namespace

//===----------------------------------------------------------------------===//
// CNN Benchmark Generation Logic
//===----------------------------------------------------------------------===//

/// Currently bypass have not been supported.
LogicalResult BenchmarkGenerator::genCNN(INIReader config) {
  // Parse configuration file.
  if (config.ParseError())
    llvm::outs() << "error: cnn configuration file parse fail\n";

  const auto inputChannel = config.GetInteger("config", "inputChannel", 3);
  const auto inputHeight = config.GetInteger("config", "inputHeight", 32);
  const auto inputWidth = config.GetInteger("config", "inputWidth", 32);
  const auto outputChannel = config.GetInteger("config", "outputChannel", 10);

  const auto batchSize = config.GetInteger("config", "batchSize", 1);
  const auto minChannel = config.GetInteger("config", "minChannel", 8);
  const auto maxChannel = config.GetInteger("config", "maxChannel", 64);
  const auto poolingNumber = config.GetInteger("config", "poolingNumber", 3);
  // const auto bypassNumber = config.GetInteger("config", "bypassNumber", 0);

  const auto includeRelu = config.GetInteger("config", "includeRelu", 0);
  const auto doubleChannel = config.GetInteger("config", "doubleChannel", 2);
  const auto includePooling = config.GetInteger("config", "includePooling", 2);

  // Create a new builder in the target module.
  OpBuilder builder(module.getBodyRegion());
  auto loc = module.getLoc();
  std::srand(std::time(nullptr));

  // Helpers.
  auto getMemType = [&](std::initializer_list<int64_t> shape) {
    return MemRefType::get(shape, builder.getF32Type());
  };

  auto getKernelShape = [&]() { return std::rand() % 3 * 2 + 3; };

  auto getChannel = [&](int current) {
    if (std::rand() % doubleChannel == 0 && current < maxChannel)
      return current * 2;
    else
      return current;
  };

  auto getPoolingFlag = [&](int current) {
    if ((std::rand() % includePooling == 0 || current == 0) &&
        current < poolingNumber)
      return true;
    else
      return false;
  };

  // Generate function signature and create a new function.
  SmallVector<mlir::Type, 2> inputTypes;
  inputTypes.push_back(
      getMemType({batchSize, inputChannel, inputHeight, inputWidth}));
  inputTypes.push_back(getMemType({batchSize, outputChannel}));
  SmallVector<mlir::Type, 2> outputTypes;

  auto func = builder.create<FuncOp>(
      loc, "tmp", builder.getFunctionType(inputTypes, outputTypes));
  func.addEntryBlock();
  builder.setInsertionPointToStart(&func.front());

  // Initialize status registers.
  int poolingCount = 0;
  bool poolingFlag = getPoolingFlag(poolingCount);
  int kernelShape = getKernelShape();
  int padding = (kernelShape - 1) / 2;

  int topChannel = inputChannel;
  int topHeight = inputHeight;
  int topWidth = inputWidth;

  int btmChannel = minChannel;
  int btmHeight = poolingFlag ? topHeight / 2 : topHeight;
  int btmWidth = poolingFlag ? topWidth / 2 : topWidth;

  // Memory references.
  SmallVector<mlir::Value, 32> fmaps;
  SmallVector<mlir::Value, 32> kernels;
  SmallVector<mlir::Value, 32> biases;
  fmaps.push_back(func.getArgument(0));

  // Generate CNN model.
  while (poolingCount < poolingNumber || btmChannel < maxChannel) {
    // Create convolutional layer.
    fmaps.push_back(builder.create<mlir::AllocOp>(
        loc, getMemType({batchSize, btmChannel, topHeight, topWidth})));
    kernels.push_back(builder.create<mlir::AllocOp>(
        loc, getMemType({btmChannel, topChannel, kernelShape, kernelShape})));
    biases.push_back(
        builder.create<mlir::AllocOp>(loc, getMemType({btmChannel})));

    builder.create<ConvOp>(
        loc, *std::prev(fmaps.end(), 2), kernels.back(), biases.back(),
        fmaps.back(), builder.getI64ArrayAttr({1, 1}),
        builder.getI64ArrayAttr({padding, padding, padding, padding}));

    // Create ReLU layer.
    if (includeRelu) {
      fmaps.push_back(builder.create<mlir::AllocOp>(
          loc, getMemType({batchSize, btmChannel, topHeight, topWidth})));
      builder.create<ReluOp>(loc, *std::prev(fmaps.end(), 2), fmaps.back());
    }

    // Create max pooling layer if applied.
    if (poolingFlag) {
      fmaps.push_back(builder.create<mlir::AllocOp>(
          loc, getMemType({batchSize, btmChannel, btmHeight, btmWidth})));
      builder.create<MaxPoolOp>(loc, *std::prev(fmaps.end(), 2), fmaps.back(),
                                builder.getI64ArrayAttr({2, 2}),
                                builder.getI64ArrayAttr({2, 2}),
                                builder.getI64ArrayAttr({0, 0, 0, 0}));
    }

    // Update status registers.
    poolingCount = poolingFlag ? poolingCount + 1 : poolingCount;
    poolingFlag = getPoolingFlag(poolingCount);
    kernelShape = getKernelShape();
    padding = (kernelShape - 1) / 2;

    topChannel = btmChannel;
    topHeight = btmHeight;
    topWidth = btmWidth;

    btmChannel = getChannel(topChannel);
    btmHeight = poolingFlag ? topHeight / 2 : topHeight;
    btmWidth = poolingFlag ? topWidth / 2 : topWidth;
  }

  // Create the last dense layer.
  fmaps.push_back(func.getArgument(1));
  kernels.push_back(builder.create<mlir::AllocOp>(
      loc, getMemType({outputChannel, topChannel, topHeight, topWidth})));
  biases.push_back(
      builder.create<mlir::AllocOp>(loc, getMemType({outputChannel})));

  builder.create<DenseOp>(loc, *std::prev(fmaps.end(), 2), kernels.back(),
                          biases.back(), fmaps.back());

  builder.create<mlir::ReturnOp>(loc);

  // Create a new function taking all kernels and biases as arguments. This will
  // eliminate all the AllocOp for kernels and biases in the generated code.
  builder.setInsertionPointAfter(func);
  SmallVector<mlir::Type, 32> newInputTypes;

  // Add original types.
  for (auto type : inputTypes)
    newInputTypes.push_back(type);

  // Add kernel types.
  for (auto kernel : kernels)
    newInputTypes.push_back(kernel.getType());

  // Add bias types.
  for (auto bias : biases)
    newInputTypes.push_back(bias.getType());

  // Create function with new signature.
  auto newFunc = builder.create<FuncOp>(
      loc, "auto_gen_cnn", builder.getFunctionType(newInputTypes, outputTypes));
  newFunc.addEntryBlock();
  builder.setInsertionPointToStart(&newFunc.front());

  // Move all operations in the original function into the new created function.
  auto &entryBlock = newFunc.front().getOperations();
  entryBlock.splice(entryBlock.end(), func.front().getOperations());

  // Replace use of original arguments with new function arguments.
  unsigned argIndex = 0;
  for (auto arg : func.getArguments())
    arg.replaceAllUsesWith(newFunc.getArgument(argIndex++));
  func.erase();

  // Replace use of original kernel memref with corresponding argument.
  for (auto kernel : kernels) {
    kernel.replaceAllUsesWith(newFunc.getArgument(argIndex++));
    kernel.getDefiningOp()->erase();
  }

  // Replace use of original bias memref with corresponding argument.
  for (auto bias : biases) {
    bias.replaceAllUsesWith(newFunc.getArgument(argIndex++));
    bias.getDefiningOp()->erase();
  }

  os << module << "\n";
  return success();
}

//===----------------------------------------------------------------------===//
// Benchmark Generation Entry
//===----------------------------------------------------------------------===//

static LogicalResult processBenchmarkGen(raw_ostream &os) {
  // Create a new MLIR context and module.
  MLIRContext context;
  context.loadDialect<StandardOpsDialect, HLSKernelDialect>();
  auto module = ModuleOp::create(UnknownLoc::get(&context));
  BenchmarkGenerator generator(os, module);

  // Generate corresponding benchmark.
  if (benchmarkType == "cnn") {
    INIReader config(configFilename);
    return generator.genCNN(config);

  } else if (benchmarkType == "blas") {
    INIReader config(configFilename);
    return generator.genBLAS(config);

  } else if (benchmarkType == "isp") {
    INIReader config(configFilename);
    return generator.genBLAS(config);

  } else {
    return failure();
  }
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

  // Process benchmark generation.
  if (failed(processBenchmarkGen(output->os()))) {
    return 1;
  }

  // Keep the output file if the invocation of MlirOptMain was successful.
  output->keep();
  return 0;
}
