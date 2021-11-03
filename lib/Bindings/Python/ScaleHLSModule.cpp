//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "mlir/CAPI/IR.h"
#include "scalehls-c/EmitHLSCpp.h"
#include "scalehls-c/HLSCpp.h"
#include "scalehls/Transforms/Utils.h"

#include "llvm-c/ErrorHandling.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/Support/Signals.h"

#include "PybindUtils.h"
#include <pybind11/pybind11.h>
namespace py = pybind11;

using namespace mlir;
using namespace scalehls;

class PyAffineLoopBand {
public:
  PyAffineLoopBand(AffineLoopBand &band) : band(band) {}

  AffineLoopBand &get() const { return band; }
  size_t size() const { return band.size(); }

  PyAffineLoopBand &dunderIter() { return *this; }
  MlirOperation dunderNext() {
    if (nextIndex >= band.size())
      throw py::stop_iteration();
    return wrap(band[nextIndex++]);
  }

private:
  AffineLoopBand &band;
  size_t nextIndex = 0;
};

class PyAffineLoopBandList {
public:
  PyAffineLoopBandList(MlirOperation op) {
    for (auto &region : unwrap(op)->getRegions())
      for (auto &block : region)
        getLoopBands(block, impl);
  }

  size_t size() const { return impl.size(); }

  PyAffineLoopBandList &dunderIter() { return *this; }
  PyAffineLoopBand dunderNext() {
    if (nextIndex >= impl.size())
      throw py::stop_iteration();
    return PyAffineLoopBand(impl[nextIndex++]);
  }

private:
  AffineLoopBands impl;
  size_t nextIndex = 0;
};

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

  m.def("apply_affine_loop_perfection", [](PyAffineLoopBand band) {
    py::gil_scoped_release();
    return applyAffineLoopPerfection(band.get());
  });

  m.def("apply_affine_loop_order_opt", [](PyAffineLoopBand band) {
    py::gil_scoped_release();
    return applyAffineLoopOrderOpt(band.get());
  });

  m.def("apply_remove_variable_bound", [](PyAffineLoopBand band) {
    py::gil_scoped_release();
    return applyRemoveVariableBound(band.get());
  });

  m.def("apply_loop_pipelining",
        [](PyAffineLoopBand band, unsigned pipeline_loc, unsigned target_ii) {
          py::gil_scoped_release();
          return applyLoopPipelining(band.get(), pipeline_loc, target_ii);
        });

  m.def("apply_legalize_to_hlscpp", [](MlirOperation op, bool top_func) {
    py::gil_scoped_release();
    if (auto func = dyn_cast<FuncOp>(unwrap(op)))
      return applyLegalizeToHLSCpp(func, top_func);
    return false;
  });

  m.def("apply_memory_access_opt", [](MlirOperation op) {
    py::gil_scoped_release();
    if (auto func = dyn_cast<FuncOp>(unwrap(op)))
      return applyMemoryAccessOpt(func);
    return false;
  });

  m.def("apply_array_partition", [](MlirOperation op) {
    py::gil_scoped_release();
    if (auto func = dyn_cast<FuncOp>(unwrap(op)))
      return applyArrayPartition(func);
    return false;
  });

  m.def("emit_hlscpp", [](MlirModule mod, py::object fileObject) {
    PyFileAccumulator accum(fileObject, false);
    py::gil_scoped_release();
    mlirEmitHlsCpp(mod, accum.getCallback(), accum.getUserData());
  });

  py::class_<PyAffineLoopBand>(m, "LoopBand", py::module_local())
      .def_property_readonly("size", &PyAffineLoopBand::size)
      .def("__iter__", &PyAffineLoopBand::dunderIter)
      .def("__next__", &PyAffineLoopBand::dunderNext);

  py::class_<PyAffineLoopBandList>(m, "LoopBandList", py::module_local())
      .def(py::init<MlirOperation>(), py::arg("op"))
      .def_property_readonly("size", &PyAffineLoopBandList::size)
      .def("__iter__", &PyAffineLoopBandList::dunderIter)
      .def("__next__", &PyAffineLoopBandList::dunderNext);
}
