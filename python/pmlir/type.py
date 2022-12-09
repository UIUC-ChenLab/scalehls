# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

from mlir.ir import Type, IntegerType, F32Type


def convert_to_mlir_type(value) -> Type:
    if isinstance(value, int) or value is int:
        return IntegerType.get_signless(32)
    elif isinstance(value, float) or value is float:
        return F32Type.get()
    elif isinstance(value, bool) or value is bool:
        return IntegerType.get_signless(1)
    else:
        raise Exception("only integer is supported")
