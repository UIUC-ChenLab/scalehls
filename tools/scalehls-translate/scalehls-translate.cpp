//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/Tools/mlir-translate/MlirTranslateMain.h"
#include "scalehls/Translation/EmitHLSCpp.h"

int main(int argc, char **argv) {
  mlir::scalehls::registerEmitHLSCppTranslation();

  return mlir::failed(
      mlir::mlirTranslateMain(argc, argv, "ScaleHLS Translation Tool"));
}
