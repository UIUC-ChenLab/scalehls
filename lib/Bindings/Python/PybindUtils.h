//===----------------------------------------------------------------------===//
//
// Copyright 2020-2021 The ScaleHLS Authors.
//
//===----------------------------------------------------------------------===//

#ifndef SCALEHLS_BINDINGS_PYTHON_PYBINDUTILS_H
#define SCALEHLS_BINDINGS_PYTHON_PYBINDUTILS_H

#include <string>

#include <pybind11/pybind11.h>
#include <pybind11/pytypes.h>
#include <pybind11/stl.h>

#include "mlir-c/Bindings/Python/Interop.h"
#include "mlir-c/IR.h"
#include "mlir-c/Pass.h"
#include "llvm/ADT/Optional.h"

namespace py = pybind11;

namespace scalehls {
namespace python {

/// Taken from PybindUtils.h in MLIR.
/// Accumulates into a python file-like object, either writing text (default)
/// or binary.
class PyFileAccumulator {
public:
  PyFileAccumulator(pybind11::object fileObject, bool binary)
      : pyWriteFunction(fileObject.attr("write")), binary(binary) {}

  void *getUserData() { return this; }

  MlirStringCallback getCallback() {
    return [](MlirStringRef part, void *userData) {
      pybind11::gil_scoped_acquire();
      PyFileAccumulator *accum = static_cast<PyFileAccumulator *>(userData);
      if (accum->binary) {
        // Note: Still has to copy and not avoidable with this API.
        pybind11::bytes pyBytes(part.data, part.length);
        accum->pyWriteFunction(pyBytes);
      } else {
        pybind11::str pyStr(part.data,
                            part.length); // Decodes as UTF-8 by default.
        accum->pyWriteFunction(pyStr);
      }
    };
  }

private:
  pybind11::object pyWriteFunction;
  bool binary;
};
} // namespace python
} // namespace scalehls

namespace pybind11 {

/// Raises a python exception with the given message.
/// Correct usage:
//   throw RaiseValueError(PyExc_ValueError, "Foobar'd");
inline pybind11::error_already_set raisePyError(PyObject *exc_class,
                                                const char *message) {
  PyErr_SetString(exc_class, message);
  return pybind11::error_already_set();
}

/// Raises a value error with the given message.
/// Correct usage:
///   throw RaiseValueError("Foobar'd");
inline pybind11::error_already_set raiseValueError(const char *message) {
  return raisePyError(PyExc_ValueError, message);
}

/// Raises a value error with the given message.
/// Correct usage:
///   throw RaiseValueError(message);
inline pybind11::error_already_set raiseValueError(const std::string &message) {
  return raisePyError(PyExc_ValueError, message.c_str());
}

} // namespace pybind11

#endif // SCALEHLS_BINDINGS_PYTHON_PYBINDUTILS_H
