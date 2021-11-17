//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/Diagnostics.h"
#include "mlir/Translation.h"
#include "scalehls/Translation/EmitHLSCpp.h"
#include "scalehls/Translation/EmitIPLibrary.h"

int main(int argc, char **argv) {
  mlir::scalehls::registerEmitHLSCppTranslation();
  mlir::scalehls::registerEmitIPLibraryTranslation();

  return mlir::failed(
      mlir::mlirTranslateMain(argc, argv, "ScaleHLS Translation Tool"));
}
