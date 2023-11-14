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
  py::enum_<MlirParamKind>(m, "ParamKind", py::module_local())
      .value("tile", MlirParamKind::TILE_SIZE)
      .value("parallel", MlirParamKind::PARALLEL_SIZE)
      .value("template", MlirParamKind::IP_TEMPLATE)
      .value("impl", MlirParamKind::TASK_IMPL)
      .value("memory", MlirParamKind::MEMORY_KIND);

  auto paramKindAttr =
      mlir_attribute_subclass(m, "ParamKindAttr", mlirAttrIsHLSParamKindAttr);
  paramKindAttr.def_classmethod(
      "get",
      [](py::object cls, MlirParamKind kind, MlirContext ctx) {
        return cls(mlirHLSParamKindAttrGet(ctx, kind));
      },
      "Get an instance of ParamKindAttr in given context.", py::arg("cls"),
      py::arg("kind"), py::arg("context") = py::none());
  paramKindAttr.def_property_readonly(
      "value",
      [](MlirAttribute attr) { return mlirHLSParamKindAttrGetValue(attr); },
      "Returns the value of ParamKindAttr.");

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

void populateHLSTypes(py::module &m) {
  auto StructType =
      mlir_type_subclass(m, "StructType", mlirTypeIsHLSStructType);
  StructType.def_classmethod(
      "get",
      [](py::object cls, std::string name, MlirContext ctx) {
        return cls(mlirHLSStructTypeGet(
            mlirStringRefCreateFromCString(name.c_str()), ctx));
      },
      "Get an instance of StructType in given context.", py::arg("cls"),
      py::arg("name"), py::arg("context") = py::none());

  auto typeType = mlir_type_subclass(m, "TypeType", mlirTypeIsHLSTypeType);
  typeType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSTypeTypeGet(ctx));
      },
      "Get an instance of TypeType in given context.", py::arg("cls"),
      py::arg("context") = py::none());

  auto intParamType =
      mlir_type_subclass(m, "IntParamType", mlirTypeIsHLSIntParamType);
  intParamType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSIntParamTypeGet(ctx));
      },
      "Get an instance of IntParamType in given context.", py::arg("cls"),
      py::arg("context") = py::none());

  auto floatParamType =
      mlir_type_subclass(m, "FloatParamType", mlirTypeIsHLSFloatParamType);
  floatParamType.def_classmethod(
      "get",
      [](py::object cls, MlirContext ctx) {
        return cls(mlirHLSFloatParamTypeGet(ctx));
      },
      "Get an instance of FloatParamType in given context.", py::arg("cls"),
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
        py::arg("semantics"), py::arg("ports"));

  populateHLSAttributes(m);
  populateHLSTypes(m);
}
