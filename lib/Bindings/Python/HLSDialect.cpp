//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#include "mlir-c/IR.h"
#include "mlir/Bindings/Python/PybindAdaptors.h"
#include "mlir/CAPI/IR.h"
#include "scalehls-c/Dialect/HLS/HLS.h"
#include "scalehls/Dialect/HLS/IR/HLS.h"
#include "llvm/ADT/SmallPtrSet.h"

#include <pybind11/pybind11.h>

namespace py = pybind11;

using namespace mlir;
using namespace mlir::python;
using namespace mlir::python::adaptors;
using namespace scalehls;

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
  portKindAttr.def_staticmethod(
      "get",
      [](py::object cls, MlirMemoryKind kind, MlirContext ctx) {
        return cls(mlirHLSMemoryKindAttrGet(ctx, kind));
      },
      py::arg("cls"), py::arg("kind"), py::arg("context") = py::none(),
      "Get an instance of MemoryKindAttr in given context.");
  portKindAttr.def_property_readonly(
      "value",
      [](MlirAttribute attr) { return mlirHLSMemoryKindAttrGetValue(attr); },
      "Returns the value of MemoryKindAttr.");
}

//===----------------------------------------------------------------------===//
// HLS Dialect Types
//===----------------------------------------------------------------------===//

void populateHLSTypes(py::module &m) {
  auto iTensorType = mlir_type_subclass(
      m, "ITensorType", mlirTypeIsHLSITensorType, mlirHLSITensorTypeGetTypeID);
  iTensorType.def_property_readonly(
      "depth", [](MlirType type) { return mlirHLSITensorTypeGetDepth(type); },
      "Get the depth of an itensor type.");
  iTensorType.def(
      "set_depth",
      [](MlirType type, int64_t depth) {
        return mlirHLSITensorTypeSetDepth(type, depth);
      },
      py::arg("depth"), "Set the depth of an itensor type and return.");
}

//===----------------------------------------------------------------------===//
// Module Definition
//===----------------------------------------------------------------------===//

PYBIND11_MODULE(_hls_dialect, m) {
  m.doc() = "HLS Dialect Python Native Extension";

  m.def(
      "get_live_ins",
      [](MlirOperation op) {
        hls::TaskOp task = dyn_cast<hls::TaskOp>(unwrap(op));
        assert(task && "input operation is not linalg generic operation");
        auto liveIns = task.getLiveIns();
        py::list pyLiveIns;
        for (auto &liveIn : liveIns)
          pyLiveIns.append(wrap(liveIn));
        return pyLiveIns;
      },
      py::arg("task_op"));

  m.def(
      "get_parent_task_or_func",
      [](MlirOperation op) {
        if (auto parentTask = unwrap(op)->getParentOfType<hls::TaskOp>())
          return wrap(parentTask);
        return wrap(unwrap(op)->getParentOfType<func::FuncOp>());
      },
      py::arg("op"));

  m.def(
      "get_defining_instance",
      [](MlirValue value) {
        if (auto defTask = unwrap(value).getDefiningOp<hls::TaskOp>()) {
          auto result = cast<OpResult>(unwrap(value));
          auto init = defTask.getInits()[result.getResultNumber()];
          if (auto instance =
                  init.getDefiningOp<hls::MemoryInstanceOpInterface>())
            return wrap(instance.getOperation());
        }
        return MlirOperation();
      },
      py::arg("value"));

  m.def(
      "get_defining_tasks",
      [](MlirValue value) {
        py::list tasks;
        Value result = unwrap(value);
        while (auto defOp = result.getDefiningOp()) {
          auto resultIdx = result.cast<OpResult>().getResultNumber();
          if (auto task = dyn_cast<hls::TaskOp>(defOp)) {
            result = task.getYieldOp().getOperand(resultIdx);
            tasks.append(wrap(task));
          } else if (auto loop = dyn_cast<scf::ForOp>(defOp))
            result = loop.getYieldedValues()[resultIdx];
          else
            break;
        }
        return tasks;
      },
      py::arg("value"));

  populateHLSAttributes(m);
  populateHLSTypes(m);
}
