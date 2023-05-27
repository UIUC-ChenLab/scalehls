"""HLS Dialect Python Native Extension"""
from __future__ import annotations
import _hls_dialect
import typing
from importlib._bootstrap import MemoryKindType
from importlib._bootstrap import PortKindAttr
from importlib._bootstrap import PortType
from importlib._bootstrap import TaskImplType
from importlib._bootstrap import TypeType

__all__ = [
    "MemoryKindType",
    "PortKind",
    "PortKindAttr",
    "PortType",
    "TaskImplType",
    "TypeType",
    "semantics_init_args"
]


class PortKind():
    """
    Members:

      input

      output

      param
    """

    def __eq__(self, other: object) -> bool: ...
    def __getstate__(self) -> int: ...
    def __hash__(self) -> int: ...
    def __index__(self) -> int: ...
    def __init__(self, value: int) -> None: ...
    def __int__(self) -> int: ...
    def __ne__(self, other: object) -> bool: ...
    def __repr__(self) -> str: ...
    def __setstate__(self, state: int) -> None: ...

    @property
    def name(self) -> str:
        """
        :type: str
        """
    @property
    def value(self) -> int:
        """
        :type: int
        """
    __members__: dict  # value = {'input': <PortKind.input: 0>, 'output': <PortKind.output: 1>, 'param': <PortKind.param: 2>}
    input: _hls_dialect.PortKind  # value = <PortKind.input: 0>
    output: _hls_dialect.PortKind  # value = <PortKind.output: 1>
    param: _hls_dialect.PortKind  # value = <PortKind.param: 2>
    pass


def semantics_init_args(semantics: MlirOperation) -> None:
    pass
