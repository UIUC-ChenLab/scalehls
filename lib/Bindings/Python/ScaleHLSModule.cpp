//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION

#include "PybindAdaptors.h"

#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir/../../lib/Bindings/Python/IRModule.h"
#include "mlir/CAPI/IR.h"
#include "mlir/Dialect/Affine/Analysis/LoopAnalysis.h"
#include "scalehls-c/EmitHLSCpp.h"
#include "scalehls-c/HLS.h"
#include "scalehls/Dialect/HLS/Utils/Utils.h"

#include "llvm-c/ErrorHandling.h"
#include "llvm/ADT/SmallVector.h"
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
// Customized Python classes
//===----------------------------------------------------------------------===//

class PyAffineLoopBand {
public:
  PyAffineLoopBand(AffineLoopBand &band) : band(band) {}

  AffineLoopBand &get() const { return band; }
  size_t depth() const { return band.size(); }
  int64_t getTripCount(size_t loc) {
    auto optTripCount = getConstantTripCount(band[loc]);
    return optTripCount.value() ? optTripCount.value() : -1;
  }

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
    auto func = dyn_cast<func::FuncOp>(unwrap(op));
    if (!func)
      throw SetPyError(PyExc_ValueError, "targeted operation not a function");
    if (!llvm::hasSingleElement(func.getBody()))
      throw SetPyError(PyExc_ValueError, "function must have single block");
    getLoopBands(func.front(), impl);
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

class PyArrayList {
public:
  PyArrayList(MlirOperation op) {
    auto func = dyn_cast<func::FuncOp>(unwrap(op));
    if (!func)
      throw SetPyError(PyExc_ValueError, "targeted operation not a function");
    if (!llvm::hasSingleElement(func.getBody()))
      throw SetPyError(PyExc_ValueError, "function must have single block");
    getArrays(func.front(), impl);
  }

  size_t size() const { return impl.size(); }

  PyArrayList &dunderIter() { return *this; }
  MlirValue dunderNext() {
    if (nextIndex >= impl.size())
      throw py::stop_iteration();
    return wrap(impl[nextIndex++]);
  }

private:
  SmallVector<Value, 8> impl;
  size_t nextIndex = 0;
};

//===----------------------------------------------------------------------===//
// Numpy array retrieval utils
//===----------------------------------------------------------------------===//

// static void getVectorFromUnsignedNpArray(PyObject *object,
//                                          SmallVectorImpl<unsigned> &vector) {
//   _import_array();
//   if (!PyArray_Check(object))
//     throw SetPyError(PyExc_ValueError, "expect numpy array");
//   auto array = reinterpret_cast<PyArrayObject *>(object);
//   if (PyArray_TYPE(array) != NPY_INT64 || PyArray_NDIM(array) != 1)
//     throw SetPyError(PyExc_ValueError, "expect single-dimensional int64
//     array");

//   auto dataBegin = reinterpret_cast<int64_t *>(PyArray_DATA(array));
//   auto dataEnd = dataBegin + PyArray_DIM(array, 0);

//   vector.clear();
//   for (auto i = dataBegin; i != dataEnd; ++i) {
//     auto value = *i;
//     if (value < 0)
//       throw SetPyError(PyExc_ValueError, "expect non-negative array
//       element");
//     vector.push_back((unsigned)value);
//   }
// }

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

  // Emission APIs.
  m.def("emit_hlscpp", &emitHlsCpp);

  // Customized Python classes.
  py::class_<PyAffineLoopBand>(m, "LoopBand", py::module_local())
      .def_property_readonly("depth", &PyAffineLoopBand::depth)
      .def("get_trip_count", &PyAffineLoopBand::getTripCount)
      .def("__iter__", &PyAffineLoopBand::dunderIter)
      .def("__next__", &PyAffineLoopBand::dunderNext);

  py::class_<PyAffineLoopBandList>(m, "LoopBandList", py::module_local())
      .def(py::init<MlirOperation>(), py::arg("op"))
      .def_property_readonly("size", &PyAffineLoopBandList::size)
      .def("__iter__", &PyAffineLoopBandList::dunderIter)
      .def("__next__", &PyAffineLoopBandList::dunderNext);

  py::class_<PyArrayList>(m, "ArrayList", py::module_local())
      .def(py::init<MlirOperation>(), py::arg("op"))
      .def_property_readonly("size", &PyArrayList::size)
      .def("__iter__", &PyArrayList::dunderIter)
      .def("__next__", &PyArrayList::dunderNext);
}
