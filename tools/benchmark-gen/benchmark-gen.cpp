//===------------------------------------------------------------*- C++ -*-===//
//
//===----------------------------------------------------------------------===//

#include "Analysis/Passes.h"
#include "Dialect/HLSKernel/HLSKernel.h"
#include "INIReader.h"
#include "mlir/IR/Dialect.h"
#include "mlir/IR/MLIRContext.h"
#include "mlir/Support/FileUtilities.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/ToolOutputFile.h"
#include <numeric>

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

  const auto bypassNumber = config.GetInteger("config", "bypassNumber", 1);
  const auto minBypassLength =
      config.GetInteger("config", "minBypassLength", 2);
  const auto maxBypassLength =
      config.GetInteger("config", "maxBypassLength", 4);

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

  auto getTensorType = [&](std::initializer_list<int64_t> shape) {
    return RankedTensorType::get(shape, builder.getF32Type());
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
      getTensorType({batchSize, inputChannel, inputHeight, inputWidth}));
  SmallVector<mlir::Type, 2> outputTypes;
  outputTypes.push_back(getTensorType({batchSize, outputChannel}));

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
  while (poolingCount < poolingNumber || topChannel < maxChannel) {
    // Create convolutional layer.
    kernels.push_back(builder.create<mlir::AllocOp>(
        loc, getMemType({btmChannel, topChannel, kernelShape, kernelShape})));
    biases.push_back(
        builder.create<mlir::AllocOp>(loc, getMemType({btmChannel})));

    auto convLayer = builder.create<ConvOp>(
        loc, getTensorType({batchSize, btmChannel, topHeight, topWidth}),
        fmaps.back(), kernels.back(), biases.back(), nullptr,
        builder.getI64ArrayAttr({1, 1}),
        builder.getI64ArrayAttr({padding, padding, padding, padding}));
    fmaps.push_back(convLayer.getResult(0));

    // Create ReLU layer.
    if (includeRelu) {
      auto reluLayer = builder.create<ReluOp>(
          loc, getTensorType({batchSize, btmChannel, topHeight, topWidth}),
          fmaps.back(), nullptr);
      fmaps.push_back(reluLayer.getResult(0));
    }

    // Create max pooling layer if applied.
    if (poolingFlag) {
      auto poolLayer = builder.create<MaxPoolOp>(
          loc, getTensorType({batchSize, btmChannel, btmHeight, btmWidth}),
          fmaps.back(), nullptr, builder.getI64ArrayAttr({2, 2}),
          builder.getI64ArrayAttr({2, 2}),
          builder.getI64ArrayAttr({0, 0, 0, 0}));
      fmaps.push_back(poolLayer.getResult(0));
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
  kernels.push_back(builder.create<mlir::AllocOp>(
      loc, getMemType({outputChannel, topChannel, topHeight, topWidth})));
  biases.push_back(
      builder.create<mlir::AllocOp>(loc, getMemType({outputChannel})));

  auto denseLayer = builder.create<DenseOp>(
      loc, getTensorType({batchSize, outputChannel}), fmaps.back(),
      kernels.back(), biases.back(), nullptr);
  fmaps.push_back(denseLayer.getResult(0));

  builder.create<mlir::ReturnOp>(loc, denseLayer.getResult(0));

  // Add bypass paths to the current model.
  // Ensure the specified bypass number is available. Since the last dense layer
  // will never be bypassed, (fmaps.size() - 2) is the number of available
  // layers that can be bypassed.
  int maxBypassNumber = (fmaps.size() - 2) / maxBypassLength;
  if (bypassNumber > maxBypassNumber)
    func.emitError("bypass number or maximum bypass length is too large");

  // Generate a random vector to determine the length of each bypass path.
  SmallVector<unsigned, 4> lengthVec;
  for (unsigned i = 0, e = bypassNumber; i < e; ++i)
    lengthVec.push_back(std::rand() % (maxBypassLength + 1 - minBypassLength) +
                        minBypassLength);

  // Generate a random vector to determine the start point and end point pair of
  // each bypass path.
  unsigned minStartPoint = 0;
  unsigned maxStartPoint =
      fmaps.size() - 2 - std::accumulate(lengthVec.begin(), lengthVec.end(), 0);

  SmallVector<std::pair<unsigned, unsigned>, 4> bypassVec;
  for (unsigned i = 0, e = bypassNumber; i < e; ++i) {
    unsigned startPoint =
        std::rand() % (maxStartPoint + 1 - minStartPoint) + minStartPoint;
    bypassVec.push_back({startPoint, startPoint + lengthVec[i]});

    minStartPoint = startPoint + lengthVec[i];
    maxStartPoint += lengthVec[i];
  }

  // Create bypass path between each pair of start point and end point.
  for (auto bypass : bypassVec) {
    auto startFmap = fmaps[bypass.first];
    auto endFmap = fmaps[bypass.second];

    auto startFmapShape = startFmap.getType().cast<ShapedType>().getShape();
    auto endFmapShape = endFmap.getType().cast<ShapedType>().getShape();

    // Set builder insertion point to the end of block.
    builder.setInsertionPointAfterValue(endFmap);

    // Insert max pooling layer to align height and width.
    if (startFmapShape[2] != endFmapShape[2] ||
        startFmapShape[3] != endFmapShape[3]) {
      auto kernelHeight = startFmapShape[2] / endFmapShape[2];
      auto kernelWidth = startFmapShape[2] / endFmapShape[3];

      auto poolType = getTensorType(
          {batchSize, startFmapShape[1], endFmapShape[2], endFmapShape[3]});
      auto poolLayer = builder.create<MaxPoolOp>(
          loc, poolType, startFmap, nullptr,
          builder.getI64ArrayAttr({kernelHeight, kernelWidth}),
          builder.getI64ArrayAttr({kernelHeight, kernelWidth}),
          builder.getI64ArrayAttr({0, 0, 0, 0}));

      // Update start fmap information.
      startFmap = poolLayer.getResult(0);
      startFmapShape = startFmap.getType().cast<ShapedType>().getShape();
    }

    // Insert 1x1 convolutional layer to align channel size.
    if (startFmapShape[1] != endFmapShape[1]) {
      kernels.push_back(builder.create<mlir::AllocOp>(
          loc, getMemType({endFmapShape[1], startFmapShape[1], 1, 1})));
      biases.push_back(
          builder.create<mlir::AllocOp>(loc, getMemType({endFmapShape[1]})));

      auto convType = getTensorType(
          {batchSize, endFmapShape[1], endFmapShape[2], endFmapShape[3]});
      auto convLayer = builder.create<ConvOp>(
          loc, convType, startFmap, kernels.back(), biases.back(), nullptr,
          builder.getI64ArrayAttr({1, 1}),
          builder.getI64ArrayAttr({0, 0, 0, 0}));

      // Update start fmap information.
      startFmap = convLayer.getResult(0);
      startFmapShape = startFmap.getType().cast<ShapedType>().getShape();
    }

    // Insert MergeOp to merge the bypass path and original path.
    auto mergeType = getTensorType(
        {batchSize, endFmapShape[1], endFmapShape[2], endFmapShape[3]});
    auto mergeLayer =
        builder.create<MergeOp>(loc, mergeType, startFmap, endFmap, nullptr);
    endFmap.replaceAllUsesExcept(mergeLayer.getResult(0),
                                 SmallPtrSet<Operation *, 1>{mergeLayer});
  }

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
