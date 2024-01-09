//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "IRModule.h"
#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "mlir/CAPI/IR.h"
#include "scalehls-c/Registration.h"
#include "scalehls-c/Transforms/Pipelines.h"
#include "scalehls-c/Translation/EmitHLSCpp.h"
#include "llvm-c/ErrorHandling.h"
#include "llvm/Support/Signals.h"

#include <pybind11/functional.h>
#include <pybind11/pybind11.h>

namespace py = pybind11;

using namespace mlir;
using namespace mlir::python;
using namespace mlir::python::adaptors;

PYBIND11_MODULE(_scalehls, m) {
  m.doc() = "ScaleHLS Python Native Extension";
  llvm::sys::PrintStackTraceOnErrorSignal(/*argv=*/"");
  LLVMEnablePrettyStackTrace();

  m.def(
      "register_everything",
      [](py::object capsule) {
        // Get the MlirContext capsule from PyMlirContext capsule.
        auto wrappedCapsule = capsule.attr(MLIR_PYTHON_CAPI_PTR_ATTR);
        MlirContext context = mlirPythonCapsuleToContext(wrappedCapsule.ptr());

        MlirDialectRegistry registry = mlirDialectRegistryCreate();
        mlirScaleHLSRegisterAllDialects(registry);
        mlirScaleHLSRegisterAllExtensions(registry);
        mlirScaleHLSRegisterAllInterfaceExternalModels(registry);
        mlirContextAppendDialectRegistry(context, registry);
        mlirContextLoadAllAvailableDialects(context);
        mlirScaleHLSRegisterAllPasses();
      },
      py::arg("context"));

  auto pyOperationCallback = py::class_<std::function<void(MlirOperation)>>(
      m, "Callable[[MlirOperation], None]");

  m.def(
      "walk_operation",
      [](MlirOperation self, std::function<void(MlirOperation)> callback) {
        unwrap(self)->walk<WalkOrder::PreOrder>(
            [&callback](Operation *op) { callback(wrap(op)); });
      },
      py::arg("self"), py::arg("callback"));

  m.def(
      "emit_hlscpp",
      [](MlirModule module, py::object fileObject) {
        PyFileAccumulator accum(fileObject, false);
        py::gil_scoped_release();
        return mlirLogicalResultIsSuccess(mlirScaleHLSEmitHlsCpp(
            module, accum.getCallback(), accum.getUserData()));
      },
      py::arg("module"), py::arg("file_object"));

  m.def("add_linalg_transform_passes", mlirAddLinalgTransformPasses,
        py::arg("pass_manager"));
  m.def("add_convert_linalg_to_dataflow_passes",
        mlirAddConvertLinalgToDataflowPasses, py::arg("pass_manager"));
  m.def("add_comprehensive_bufferize_passes",
        mlirAddComprehensiveBufferizePasses, py::arg("pass_manager"));
  m.def("add_lower_dataflow_passes", mlirAddLowerDataflowPasses,
        py::arg("pass_manager"));
  m.def("add_convert_dataflow_to_func_passes",
        mlirAddConvertDataflowToFuncPasses, py::arg("pass_manager"));
}
