# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

from mlir.ir import Value
from mlir.dialects import arith


class value(object):
    def __init__(self, impl: Value):
        self.impl = impl

    @property
    def mlir_value(self):
        return self.impl

    def __add__(self, other):
        return value(arith.AddIOp(self.mlir_value, other.mlir_value).result)

    def __radd__(self, other):
        return value(arith.AddIOp(other.mlir_value, self.mlir_value).result)
