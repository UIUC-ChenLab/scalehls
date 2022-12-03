# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

from mlir.ir import Type, IntegerType


def convert_to_mlir_type(value) -> Type:
    if isinstance(value, int) or value is int:
        return IntegerType.get_signless(32)
    else:
        raise Exception("only integer is supported")
