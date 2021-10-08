//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "scalehls-c/Dialect/HLSCpp.h"
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

  m.def("register_dialects", [](py::object capsule) {
    // Get the MlirContext capsule from PyMlirContext capsule.
    auto wrappedCapsule = capsule.attr(MLIR_PYTHON_CAPI_PTR_ATTR);
    MlirContext context = mlirPythonCapsuleToContext(wrappedCapsule.ptr());

    MlirDialectHandle hlscpp = mlirGetDialectHandle__hlscpp__();
    mlirDialectHandleRegisterDialect(hlscpp, context);
    mlirDialectHandleLoadDialect(hlscpp, context);
  });

  m.def("apply_legalize_to_hlscpp",
        [](MlirOperation op, bool top_func) -> bool {
          py::gil_scoped_release();
          return mlirApplyLegalizeToHlscpp(op, top_func);
        });

  m.def("apply_array_partition", [](MlirOperation op) -> bool {
    py::gil_scoped_release();
    return mlirApplyArrayPartition(op);
  });

  m.def("emit_hlscpp", [](MlirModule mod, py::object fileObject) {
    scalehls::python::PyFileAccumulator accum(fileObject, false);
    py::gil_scoped_release();
    mlirEmitHlsCpp(mod, accum.getCallback(), accum.getUserData());
  });
}
