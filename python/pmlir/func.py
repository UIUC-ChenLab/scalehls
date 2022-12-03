# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

from typing import Callable
from functools import wraps

from mlir.ir import InsertionPoint
from mlir.dialects import func as func_dialect
from .context import get_context, get_location, get_module
from .type import convert_to_mlir_type
from .value import value


def pmlir_function():
    """
    A decorator used for defining a pmlir function.
    """
    def decorator(func: Callable):
        @wraps(func)
        def wrapper(*inputs: value):
            if len(inputs) != 0:
                raise Exception('function call is not supported')

            annos = func.__annotations__

            input_types = map(lambda name: convert_to_mlir_type(
                annos[name]), filter(lambda name: name != 'return', annos))
            output_type = convert_to_mlir_type(annos['return'])

            with InsertionPoint.at_block_begin(get_module().body):
                func_op = func_dialect.FuncOp(
                    func.__name__, (list(input_types), [output_type]))

            entry_block = func_op.add_entry_block()
            mlir_inputs = map(lambda mlir_input: value(
                mlir_input), entry_block.arguments)

            with InsertionPoint.at_block_begin(entry_block):
                output = func(*tuple(mlir_inputs))
                func_dialect.ReturnOp([output.mlir_value])
        return wrapper
    return decorator


def pmlir_compile(pmlir_func: Callable):
    with get_context(), get_location():
        pmlir_func()
    print(get_module())
