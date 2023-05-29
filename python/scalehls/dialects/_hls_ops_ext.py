# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

try:
    from ..ir import *
    from typing import List
    from .._mlir_libs._hls_dialect import ParamKindAttr
    from .._mlir_libs._hls_dialect import semantics_init_args
except ImportError as e:
    raise RuntimeError("Error loading imports from extension module") from e


class ParamOp:
    """Specialization for the param op class."""

    def __init__(self, result, args, kind, sym_name, *, step=None, bounds=None, candidates=None, value=None, loc=None, ip=None):
        super().__init__(result, args, kind, sym_name, step=step,
                         bounds=bounds, candidates=candidates, value=value, loc=loc, ip=ip)

    @property
    def kind(self):
        return ParamKindAttr(self.operation.attributes["kind"]).value

    @property
    def candidates(self):
        return ArrayAttr(self.operation.attributes["candidates"])


class SemanticsOp:
    """Specialization for the semantics op class."""

    def __init__(self, ports, templates, args_map, *, loc=None, ip=None):
        super().__init__(ports, templates, args_map, loc=loc, ip=ip)

    def init_args(self, ports: List[Value]):
        return semantics_init_args(self, ports)
