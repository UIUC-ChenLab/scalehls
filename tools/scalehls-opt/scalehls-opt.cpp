//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Tools/mlir-opt/MlirOptMain.h"
#include "scalehls/InitAllDialects.h"
#include "scalehls/InitAllPasses.h"

int main(int argc, char **argv) {
  mlir::DialectRegistry registry;
  mlir::scalehls::registerAllDialects(registry);
  mlir::scalehls::registerAllInterfaceExternalModels(registry);
  mlir::scalehls::registerAllPasses();

  return mlir::failed(mlir::MlirOptMain(
      argc, argv, "ScaleHLS Optimization Tool", registry, true));
}
