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
      [](py::object cls, MlirPortKind direction, MlirContext ctx) {
        return cls(mlirHLSPortKindAttrGet(ctx, direction));
      },
      "Get an instance of PortKindAttr in given context.", py::arg("cls"),
      py::arg("direction"), py::arg("context") = py::none());
  portKindAttr.def_property_readonly(
      "value",
      [](MlirAttribute attr) { return mlirHLSPortKindAttrGetValue(attr); },
      "Returns the value of PortKindAttr.");
}

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

void populateHLSTypes(py::module &m) {
  auto typeType = mlir_type_subclass(m, "TypeType", mlirTypeIsHLSTypeType);
  typeType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSTypeTypeGet(ctx));
      },
      "Get an instance of TypeType in given context.", py::arg("cls"),
      py::arg("context") = py::none());

  auto portType = mlir_type_subclass(m, "PortType", mlirTypeIsHLSPortType);
  portType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSPortTypeGet(ctx));
      },
      "Get an instance of PortType in given context.", py::arg("cls"),
      py::arg("context") = py::none());

  auto taskImplType =
      mlir_type_subclass(m, "TaskImplType", mlirTypeIsHLSTaskImplType);
  taskImplType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSTaskImplTypeGet(ctx));
      },
      "Get an instance of TaskImplType in given context.", py::arg("cls"),
      py::arg("context") = py::none());

  auto memoryKindType =
      mlir_type_subclass(m, "MemoryKindType", mlirTypeIsHLSMemoryKindType);
  memoryKindType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSMemoryKindTypeGet(ctx));
      },
      "Get an instance of MemoryKindType in given context.", py::arg("cls"),
      py::arg("context") = py::none());
}

PYBIND11_MODULE(_hls_dialect, m) {
  m.doc() = "HLS Dialect Python Native Extension";

  m.def("semantics_init_args", mlirSemanticsInitializeBlockArguments,
        py::arg("semantics"));

  populateHLSAttributes(m);
  populateHLSTypes(m);
}
