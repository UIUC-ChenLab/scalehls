//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir-c/Registration.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "scalehls-c/Transforms/Utils.h"
#include "scalehls-c/Translation/EmitHLSCpp.h"

#include "llvm-c/ErrorHandling.h"
#include "llvm/Support/Signals.h"

#include "PybindUtils.h"
#include <pybind11/pybind11.h>
namespace py = pybind11;

PYBIND11_MODULE(_scalehls, m) {
  m.doc() = "ScaleHLS Python Native Extension";
  llvm::sys::PrintStackTraceOnErrorSignal(/*argv=*/"");
  LLVMEnablePrettyStackTrace();

  m.def("apply_array_partition", [](MlirFunc func) -> bool {
    py::gil_scoped_release();
    return MlirApplyArrayPartition(func);
  });

  m.def("emit_hlscpp", [](MlirModule mod, py::object fileObject) {
    scalehls::python::PyFileAccumulator accum(fileObject, false);
    py::gil_scoped_release();
    mlirEmitHlsCpp(mod, accum.getCallback(), accum.getUserData());
  });
}
