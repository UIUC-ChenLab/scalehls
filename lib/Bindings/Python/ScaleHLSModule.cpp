//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "mlir/CAPI/IR.h"
#include "scalehls-c/Dialect/HLSCpp.h"
#include "scalehls-c/Transforms/Utils.h"
#include "scalehls-c/Translation/EmitHLSCpp.h"
#include "scalehls/Support/Utils.h"

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
  PyAffineLoopBand(AffineLoopBand &band) {
    for (auto loop : band)
      impl.push_back(wrap(loop));
  }

  operator MlirAffineLoopBand() const { return get(); }
  MlirAffineLoopBand get() const { return {impl.begin(), impl.end()}; }
  size_t size() const { return impl.size(); }

  PyAffineLoopBand &dunderIter() { return *this; }

  MlirOperation dunderNext() {
    if (nextIndex >= impl.size())
      throw py::stop_iteration();
    return impl[nextIndex++];
  }

private:
  llvm::SmallVector<MlirOperation, 6> impl;
  size_t nextIndex = 0;
};

class PyAffineLoopBandList {
public:
  PyAffineLoopBandList(MlirOperation op) {
    for (auto &region : unwrap(op)->getRegions())
      for (auto &block : region) {
        AffineLoopBands bands;
        getLoopBands(block, bands);
        for (auto band : bands)
          impl.push_back(PyAffineLoopBand(band));
      }
  }

  size_t size() const { return impl.size(); }

  PyAffineLoopBandList &dunderIter() { return *this; }

  PyAffineLoopBand dunderNext() {
    if (nextIndex >= impl.size())
      throw py::stop_iteration();
    return impl[nextIndex++];
  }

private:
  llvm::SmallVector<PyAffineLoopBand> impl;
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

  m.def("apply_affine_loop_perfection", [](PyAffineLoopBand band) -> bool {
    py::gil_scoped_release();
    return mlirApplyAffineLoopPerfection(band.get());
  });

  m.def("apply_affine_loop_order_opt", [](PyAffineLoopBand band) -> bool {
    py::gil_scoped_release();
    return mlirApplyAffineLoopOrderOpt(band.get());
  });

  m.def("apply_remove_variable_bound", [](PyAffineLoopBand band) -> bool {
    py::gil_scoped_release();
    return mlirApplyRemoveVariableBound(band.get());
  });

  m.def("apply_legalize_to_hlscpp",
        [](MlirOperation op, bool top_func) -> bool {
          py::gil_scoped_release();
          return mlirApplyLegalizeToHlscpp(op, top_func);
        });

  m.def("apply_loop_pipelining",
        [](PyAffineLoopBand band, unsigned pipelineLoc,
           unsigned targetII) -> bool {
          py::gil_scoped_release();
          return mlirApplyLoopPipelining(band.get(), pipelineLoc, targetII);
        });

  m.def("apply_memory_access_opt", [](MlirOperation op) -> bool {
    py::gil_scoped_release();
    return mlirApplyMemoryAccessOpt(op);
  });

  m.def("apply_array_partition", [](MlirOperation op) -> bool {
    py::gil_scoped_release();
    return mlirApplyArrayPartition(op);
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
      .def(py::init<MlirOperation>(), py::arg("op"),
           "Initialize with all loop bands contained by the operation")
      .def_property_readonly("size", &PyAffineLoopBandList::size)
      .def("__iter__", &PyAffineLoopBandList::dunderIter)
      .def("__next__", &PyAffineLoopBandList::dunderNext);
}
