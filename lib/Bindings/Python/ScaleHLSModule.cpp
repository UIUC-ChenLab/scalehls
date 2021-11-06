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

//===----------------------------------------------------------------------===//
// Customized Python classes
//===----------------------------------------------------------------------===//

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

//===----------------------------------------------------------------------===//
// Numpy array retrieval utils
//===----------------------------------------------------------------------===//

static bool getVectorFromUnsignedNpArray(PyObject *object,
                                         SmallVectorImpl<unsigned> &vector) {
  _import_array();
  if (!PyArray_Check(object)) {
    throw py::raiseValueError("expect numpy array");
    return false;
  }

  auto array = reinterpret_cast<PyArrayObject *>(object);
  if (PyArray_TYPE(array) != NPY_INT64 || PyArray_NDIM(array) != 1) {
    throw py::raiseValueError("expect single-dimensional int64 array");
    return false;
  }

  auto dataBegin = reinterpret_cast<int64_t *>(PyArray_DATA(array));
  auto dataEnd = dataBegin + PyArray_DIM(array, 0);

  vector.clear();
  for (auto i = dataBegin; i != dataEnd; ++i) {
    auto value = *i;
    if (value < 0) {
      throw py::raiseValueError("expect non-negative array element");
      return false;
    }
    vector.push_back((unsigned)value);
  }
  return true;
}

//===----------------------------------------------------------------------===//
// Loop transform APIs
//===----------------------------------------------------------------------===//

static bool loopPerfectization(PyAffineLoopBand band) {
  py::gil_scoped_release();
  return applyAffineLoopPerfection(band.get());
}

static bool loopOrderOpt(PyAffineLoopBand band) {
  py::gil_scoped_release();
  return applyAffineLoopOrderOpt(band.get());
}

static bool loopPermutation(PyAffineLoopBand band, py::object permMapObject) {
  py::gil_scoped_release();
  SmallVector<unsigned, 8> permMap;
  if (!getVectorFromUnsignedNpArray(permMapObject.ptr(), permMap))
    return false;
  return applyAffineLoopOrderOpt(band.get(), permMap);
}

/// Loop variable bound elimination.
static bool loopRemoveVarBound(PyAffineLoopBand band) {
  py::gil_scoped_release();
  return applyRemoveVariableBound(band.get());
}

/// If succeeded, return the location of the innermost tile-space loop.
/// Otherwise, return -1.
static int64_t loopTiling(PyAffineLoopBand band, py::object tileListObject) {
  py::gil_scoped_release();
  llvm::SmallVector<unsigned, 8> tileList;
  if (!getVectorFromUnsignedNpArray(tileListObject.ptr(), tileList))
    return -1;
  auto loc = applyLoopTiling(band.get(), tileList);
  return loc.hasValue() ? loc.getValue() : -1;
}

static bool loopPipelining(PyAffineLoopBand band, int64_t pipelineLoc,
                           int64_t targetII) {
  py::gil_scoped_release();
  if (pipelineLoc < 0 || pipelineLoc >= (int64_t)band.size() || targetII < 1) {
    throw py::raiseValueError("invalid location or targeted II");
    return false;
  }
  return applyLoopPipelining(band.get(), pipelineLoc, targetII);
}

//===----------------------------------------------------------------------===//
// Function transform APIs
//===----------------------------------------------------------------------===//

static bool legalizeToHLSCpp(MlirOperation op, bool topFunc) {
  py::gil_scoped_release();
  if (auto func = dyn_cast<FuncOp>(unwrap(op)))
    return applyLegalizeToHLSCpp(func, topFunc);
  throw py::raiseValueError("targeted operation not a function");
  return false;
}

static bool memoryAccessOpt(MlirOperation op) {
  py::gil_scoped_release();
  if (auto func = dyn_cast<FuncOp>(unwrap(op)))
    return applyMemoryAccessOpt(func);
  throw py::raiseValueError("targeted operation not a function");
  return false;
}

static bool autoArrayPartition(MlirOperation op) {
  py::gil_scoped_release();
  if (auto func = dyn_cast<FuncOp>(unwrap(op)))
    return applyAutoArrayPartition(func);
  throw py::raiseValueError("targeted operation not a function");
  return false;
}

//===----------------------------------------------------------------------===//
// Array transform APIs
//===----------------------------------------------------------------------===//

/// TODO: Support to apply different partition kind to different dimension.
static bool arrayPartition(MlirValue array, py::object factorsObject,
                           std::string kind) {
  py::gil_scoped_release();
  llvm::SmallVector<unsigned, 4> factors;
  if (!getVectorFromUnsignedNpArray(factorsObject.ptr(), factors))
    return false;
  llvm::SmallVector<hlscpp::PartitionKind, 4> kinds(
      factors.size(), kind == "cyclic"  ? hlscpp::PartitionKind::CYCLIC
                      : kind == "block" ? hlscpp::PartitionKind::BLOCK
                                        : hlscpp::PartitionKind::NONE);
  return applyArrayPartition(unwrap(array), factors, kinds);
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

    MlirDialectHandle hlscpp = mlirGetDialectHandle__hlscpp__();
    mlirDialectHandleRegisterDialect(hlscpp, context);
    mlirDialectHandleLoadDialect(hlscpp, context);
  });

  // Loop transform APIs.
  m.def("loop_perfectization", &loopPerfectization);
  m.def("loop_order_opt", &loopOrderOpt);
  m.def("loop_permutation", &loopPermutation);
  m.def("loop_remove_var_bound", &loopRemoveVarBound);
  m.def("loop_tiling", &loopTiling);
  m.def("loop_pipelining", &loopPipelining);

  // Function transform APIs.
  m.def("legalize_to_hlscpp", &legalizeToHLSCpp);
  m.def("memory_access_opt", &memoryAccessOpt);
  m.def("auto_array_partition", &autoArrayPartition);

  // Array transform APIs.
  m.def("array_partition", &arrayPartition);

  // Emission APIs.
  m.def("emit_hlscpp", &emitHlsCpp);

  // Customized Python classes.
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
