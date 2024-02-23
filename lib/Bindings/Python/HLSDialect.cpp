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
  py::enum_<MlirMemoryKind>(m, "MemoryKind", py::module_local())
      .value("UNKNOWN", MlirMemoryKind::UNKNOWN)
      .value("LUTRAM_1P", MlirMemoryKind::LUTRAM_1P)
      .value("LUTRAM_2P", MlirMemoryKind::LUTRAM_2P)
      .value("LUTRAM_S2P", MlirMemoryKind::LUTRAM_S2P)
      .value("BRAM_1P", MlirMemoryKind::BRAM_1P)
      .value("BRAM_2P", MlirMemoryKind::BRAM_2P)
      .value("BRAM_S2P", MlirMemoryKind::BRAM_S2P)
      .value("BRAM_T2P", MlirMemoryKind::BRAM_T2P)
      .value("URAM_1P", MlirMemoryKind::URAM_1P)
      .value("URAM_2P", MlirMemoryKind::URAM_2P)
      .value("URAM_S2P", MlirMemoryKind::URAM_S2P)
      .value("URAM_T2P", MlirMemoryKind::URAM_T2P)
      .value("DRAM", MlirMemoryKind::DRAM);

  auto portKindAttr =
      mlir_attribute_subclass(m, "MemoryKindAttr", mlirAttrIsHLSMemoryKindAttr);
  portKindAttr.def_classmethod(
      "get",
      [](py::object cls, MlirMemoryKind kind, MlirContext ctx) {
        return cls(mlirHLSMemoryKindAttrGet(ctx, kind));
      },
      "Get an instance of MemoryKindAttr in given context.", py::arg("cls"),
      py::arg("kind"), py::arg("context") = py::none());
  portKindAttr.def_property_readonly(
      "value",
      [](MlirAttribute attr) { return mlirHLSMemoryKindAttrGetValue(attr); },
      "Returns the value of MemoryKindAttr.");
}

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

PYBIND11_MODULE(_hls_dialect, m) {
  m.doc() = "HLS Dialect Python Native Extension";

  populateHLSAttributes(m);
}
