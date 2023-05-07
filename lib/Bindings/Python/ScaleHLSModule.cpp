//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "IRModule.h"
#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "scalehls-c/Registration.h"
#include "scalehls-c/Translation/EmitHLSCpp.h"
#include "llvm-c/ErrorHandling.h"
#include "llvm/Support/Signals.h"

#include <pybind11/pybind11.h>

namespace py = pybind11;

using namespace mlir;
using namespace mlir::python;
using namespace mlir::python::adaptors;

//===----------------------------------------------------------------------===//
// ScaleHLS Python Module Definition
//===----------------------------------------------------------------------===//

PYBIND11_MODULE(_scalehls, m) {
  m.doc() = "ScaleHLS Python Native Extension";
  llvm::sys::PrintStackTraceOnErrorSignal(/*argv=*/"");
  LLVMEnablePrettyStackTrace();

  m.def("register_everything", [](py::object capsule) {
    // Get the MlirContext capsule from PyMlirContext capsule.
    auto wrappedCapsule = capsule.attr(MLIR_PYTHON_CAPI_PTR_ATTR);
    MlirContext context = mlirPythonCapsuleToContext(wrappedCapsule.ptr());

    MlirDialectRegistry registry = mlirDialectRegistryCreate();
    mlirScaleHLSRegisterAllDialects(registry);
    mlirScaleHLSRegisterAllInterfaceExternalModels(registry);
    mlirContextAppendDialectRegistry(context, registry);
    mlirContextLoadAllAvailableDialects(context);
    mlirScaleHLSRegisterAllPasses();
  });

  m.def("emit_hlscpp", [](MlirModule mod, py::object fileObject) {
    PyFileAccumulator accum(fileObject, false);
    py::gil_scoped_release();
    return mlirLogicalResultIsSuccess(
        mlirScaleHLSEmitHlsCpp(mod, accum.getCallback(), accum.getUserData()));
  });
}
