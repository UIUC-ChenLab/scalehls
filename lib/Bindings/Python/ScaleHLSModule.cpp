//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION

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
#include <numpy/arrayobject.h>
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

static bool getVectorFromUnsignedNpArray(PyObject *object,
                                         SmallVectorImpl<unsigned> &vector) {
  _import_array();
  if (!PyArray_Check(object)) {
    py::raisePyError(object, "isn't a numpy array");
    return false;
  }

  auto array = reinterpret_cast<PyArrayObject *>(object);
  if (PyArray_TYPE(array) != NPY_INT64 || PyArray_NDIM(array) != 1) {
    py::raisePyError(object, "isn't int64 type or isn't single-dimensional");
    return false;
  }

  auto dataBegin = reinterpret_cast<int64_t *>(PyArray_DATA(array));
  auto dataEnd = dataBegin + PyArray_DIM(array, 0);

  vector.clear();
  for (auto i = dataBegin; i != dataEnd; ++i) {
    auto value = *i;
    if (value < 0) {
      py::raisePyError(object, "contains negative number");
      return false;
    }
    vector.push_back((unsigned)value);
  }
  return true;
}

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

  m.def("apply_loop_perfection", [](PyAffineLoopBand band) {
    py::gil_scoped_release();
    return applyAffineLoopPerfection(band.get());
  });

  m.def("apply_loop_order_opt", [](PyAffineLoopBand band) {
    py::gil_scoped_release();
    return applyAffineLoopOrderOpt(band.get());
  });

  m.def("apply_loop_permutation",
        [](PyAffineLoopBand band, py::object permMapObject) {
          py::gil_scoped_release();
          SmallVector<unsigned, 8> permMap;
          if (!getVectorFromUnsignedNpArray(permMapObject.ptr(), permMap))
            return false;
          return applyAffineLoopOrderOpt(band.get(), permMap);
        });

  m.def("apply_remove_variable_bound", [](PyAffineLoopBand band) {
    py::gil_scoped_release();
    return applyRemoveVariableBound(band.get());
  });

  m.def("apply_loop_tiling",
        [](PyAffineLoopBand band, py::object tileListObject) -> int64_t {
          py::gil_scoped_release();
          TileList tileList;
          if (!getVectorFromUnsignedNpArray(tileListObject.ptr(), tileList))
            return -1;

          auto loc = applyLoopTiling(band.get(), tileList);
          if (!loc.hasValue())
            return -1;
          return loc.getValue();
        });

  m.def("apply_loop_pipelining",
        [](PyAffineLoopBand band, int64_t pipelineLoc, int64_t targetII) {
          py::gil_scoped_release();
          if (pipelineLoc < 0 || targetII < 0)
            return false;
          return applyLoopPipelining(band.get(), pipelineLoc, targetII);
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
