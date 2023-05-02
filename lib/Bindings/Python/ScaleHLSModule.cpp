//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION

#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir/../../lib/Bindings/Python/IRModule.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "mlir/CAPI/IR.h"
#include "scalehls-c/EmitHLSCpp.h"
#include "scalehls-c/HLS.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"
#include "llvm-c/ErrorHandling.h"
#include "llvm/Support/Signals.h"

#include <numpy/arrayobject.h>
#include <pybind11/pybind11.h>

namespace py = pybind11;

using namespace mlir;
using namespace mlir::python;
using namespace scalehls;

//===----------------------------------------------------------------------===//
// PybindUtils
//===----------------------------------------------------------------------===//

pybind11::error_already_set
mlir::python::SetPyError(PyObject *excClass, const llvm::Twine &message) {
  auto messageStr = message.str();
  PyErr_SetString(excClass, messageStr.c_str());
  return pybind11::error_already_set();
}

//===----------------------------------------------------------------------===//
// Emission APIs
//===----------------------------------------------------------------------===//

static bool emitHlsCpp(MlirModule mod, py::object fileObject) {
  PyFileAccumulator accum(fileObject, false);
  py::gil_scoped_release();
  return mlirLogicalResultIsSuccess(
      mlirEmitHlsCpp(mod, accum.getCallback(), accum.getUserData()));
}

//===----------------------------------------------------------------------===//
// ScaleHLS Python module definition
//===----------------------------------------------------------------------===//

PYBIND11_MODULE(_scalehls, m) {
  m.doc() = "ScaleHLS Python Native Extension";
  llvm::sys::PrintStackTraceOnErrorSignal(/*argv=*/"");
  LLVMEnablePrettyStackTrace();

  m.def("register_dialects", [](py::object capsule) {
    // Get the MlirContext capsule from PyMlirContext capsule.
    auto wrappedCapsule = capsule.attr(MLIR_PYTHON_CAPI_PTR_ATTR);
    MlirContext context = mlirPythonCapsuleToContext(wrappedCapsule.ptr());

    MlirDialectHandle hls = mlirGetDialectHandle__hls__();
    mlirDialectHandleRegisterDialect(hls, context);
    mlirDialectHandleLoadDialect(hls, context);
  });

  m.def("emit_hlscpp", &emitHlsCpp);
}
