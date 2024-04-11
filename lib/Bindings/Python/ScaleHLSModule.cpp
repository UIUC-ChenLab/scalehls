//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "PybindUtils.h"
#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "mlir/CAPI/IR.h"
#include "mlir/Dialect/Linalg/IR/Linalg.h"
#include "scalehls-c/Pipelines/Pipelines.h"
#include "scalehls-c/Registration.h"
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
      "get_static_loop_ranges",
      [](MlirOperation linalgOp) {
        linalg::GenericOp genericOp =
            dyn_cast<linalg::GenericOp>(unwrap(linalgOp));
        assert(genericOp && "input operation is not linalg generic operation");
        py::list pyLoopRanges;
        for (auto &range : genericOp.getStaticLoopRanges())
          pyLoopRanges.append(range);
        return pyLoopRanges;
      },
      py::arg("linalg_op"));

  m.def(
      "walk_operation",
      [](MlirOperation self, std::function<void(MlirOperation)> callback) {
        unwrap(self)->walk<WalkOrder::PreOrder>(
            [&callback](Operation *op) { callback(wrap(op)); });
      },
      py::arg("self"), py::arg("callback"));

  m.def(
      "emit_hlscpp",
      [](MlirModule module, py::object fileObject, int64_t axiMaxWidenBitwidth,
         bool omitGlobalConstants) {
        PyFileAccumulator accum(fileObject, false);
        py::gil_scoped_release();
        return mlirLogicalResultIsSuccess(mlirScaleHLSEmitHlsCpp(
            module, accum.getCallback(), accum.getUserData(),
            axiMaxWidenBitwidth, omitGlobalConstants));
      },
      py::arg("module"), py::arg("file_object"),
      py::arg("axi_max_widen_bitwidth") = 512,
      py::arg("omit_global_constants") = true);
}
