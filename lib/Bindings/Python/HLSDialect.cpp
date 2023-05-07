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
// HLS Dialect Python Submodule Definition
//===----------------------------------------------------------------------===//

PYBIND11_MODULE(_hls_dialect, m) {
  m.doc() = "HLS Dialect Python Native Extension";

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
