//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir-c/IR.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "scalehls-c/Dialect/HLS/HLS.h"

#include <pybind11/pybind11.h>

namespace py = pybind11;

using namespace mlir;
using namespace mlir::python;
using namespace mlir::python::adaptors;

//===----------------------------------------------------------------------===//
// HLS Dialect Attributes
//===----------------------------------------------------------------------===//

void populateHLSAttributes(py::module &m) {
  py::enum_<MlirPortKind>(m, "PortKind", py::module_local())
      .value("input", MlirPortKind::INPUT)
      .value("output", MlirPortKind::OUTPUT)
      .value("param", MlirPortKind::PARAM);

  auto portKindAttr =
      mlir_attribute_subclass(m, "PortKindAttr", mlirAttrIsHLSPortKindAttr);
  portKindAttr.def_classmethod(
      "get",
      [](py::object cls, MlirPortKind kind, MlirContext ctx) {
        return cls(mlirHLSPortKindAttrGet(ctx, kind));
      },
      "Get an instance of PortKindAttr in given context.", py::arg("cls"),
      py::arg("kind"), py::arg("context") = py::none());
  portKindAttr.def_property_readonly(
      "value",
      [](MlirAttribute attr) { return mlirHLSPortKindAttrGetValue(attr); },
      "Returns the value of PortKindAttr.");
}

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

PYBIND11_MODULE(_hls_dialect, m) {
  m.doc() = "HLS Dialect Python Native Extension";

  populateHLSAttributes(m);
}
