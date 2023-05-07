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

PYBIND11_MODULE(_hls_dialect, m) {
  m.doc() = "HLS Dialect Python Native Extension";

  //===--------------------------------------------------------------------===//
  // HLS Dialect Attributes Definition
  //===--------------------------------------------------------------------===//

  py::enum_<MlirValueParamKind>(m, "ValueParamKind", py::module_local())
      .value("static", MlirValueParamKind::STATIC)
      .value("dynamic", MlirValueParamKind::DYNAMIC);

  auto valueParamKindAttr = mlir_attribute_subclass(
      m, "ValueParamKindAttr", mlirAttrIsHLSValueParamKindAttr);
  valueParamKindAttr.def_classmethod(
      "get",
      [](py::object cls, MlirValueParamKind kind, MlirContext ctx) {
        return cls(mlirHLSValueParamKindAttrGet(ctx, kind));
      },
      "Get an instance of ValueParamKindAttr in given context.", py::arg("cls"),
      py::arg("kind"), py::arg("context") = py::none());
  valueParamKindAttr.def_property_readonly(
      "value",
      [](MlirAttribute attr) {
        return mlirHLSValueParamKindAttrGetValue(attr);
      },
      "Returns the value of ValueParamKindAttr.");

  py::enum_<MlirPortDirection>(m, "PortDirection", py::module_local())
      .value("input", MlirPortDirection::INPUT)
      .value("output", MlirPortDirection::OUTPUT);

  auto PortDirectionAttr = mlir_attribute_subclass(
      m, "PortDirectionAttr", mlirAttrIsHLSPortDirectionAttr);
  PortDirectionAttr.def_classmethod(
      "get",
      [](py::object cls, MlirPortDirection direction, MlirContext ctx) {
        return cls(mlirHLSPortDirectionAttrGet(ctx, direction));
      },
      "Get an instance of PortDirectionAttr in given context.", py::arg("cls"),
      py::arg("direction"), py::arg("context") = py::none());
  PortDirectionAttr.def_property_readonly(
      "value",
      [](MlirAttribute attr) { return mlirHLSPortDirectionAttrGetValue(attr); },
      "Returns the value of PortDirectionAttr.");

  //===--------------------------------------------------------------------===//
  // HLS Dialect Types Definition
  //===--------------------------------------------------------------------===//

  auto typeParamType =
      mlir_type_subclass(m, "TypeParamType", mlirTypeIsHLSTypeParamType);
  typeParamType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSTypeParamTypeGet(ctx));
      },
      "Get an instance of TypeParamType in given context.", py::arg("cls"),
      py::arg("context") = py::none());

  auto valueParamType =
      mlir_type_subclass(m, "ValueParamType", mlirTypeIsHLSValueParamType);
  valueParamType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSValueParamTypeGet(ctx));
      },
      "Get an instance of ValueParamType in given context.", py::arg("cls"),
      py::arg("context") = py::none());

  auto portType = mlir_type_subclass(m, "PortType", mlirTypeIsHLSPortType);
  portType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSPortTypeGet(ctx));
      },
      "Get an instance of PortType in given context.", py::arg("cls"),
      py::arg("context") = py::none());

  auto ipIdentifierType =
      mlir_type_subclass(m, "IPIdentifierType", mlirTypeIsHLSIPIdentifierType);
  ipIdentifierType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSIPIdentifierTypeGet(ctx));
      },
      "Get an instance of IPIdentifierType in given context.", py::arg("cls"),
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
