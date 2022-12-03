# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

from typing import Callable
from functools import wraps

from mlir.dialects import func
from .context import get_module


def pmlir_function():
    """
    A decorator used for defining a pmlir function.
    """
    def decorator(func: Callable[..., None]):
        @wraps(func)
        def wrapper():
            func()
        return wrapper
    return decorator


def compile(func: Callable[..., None]):
    func()
    print(get_module())
