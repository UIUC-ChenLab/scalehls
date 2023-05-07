"""HLS Dialect Python Native Extension"""
from __future__ import annotations
import _hls_dialect
import typing
from importlib._bootstrap import IPIdentifierType
from importlib._bootstrap import MemoryKindType
from importlib._bootstrap import PortDirectionAttr
from importlib._bootstrap import PortType
from importlib._bootstrap import TypeParamType
from importlib._bootstrap import ValueParamKindAttr
from importlib._bootstrap import ValueParamType

__all__ = [
    "IPIdentifierType",
    "MemoryKindType",
    "PortDirection",
    "PortDirectionAttr",
    "PortType",
    "TypeParamType",
    "ValueParamKind",
    "ValueParamKindAttr",
    "ValueParamType",
    "semantics_init_args"
]


class PortDirection():
    """
    Members:

      input

      output
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
    __members__: dict  # value = {'input': <PortDirection.input: 0>, 'output': <PortDirection.output: 1>}
    input: _hls_dialect.PortDirection  # value = <PortDirection.input: 0>
    output: _hls_dialect.PortDirection  # value = <PortDirection.output: 1>
    pass


class ValueParamKind():
    """
    Members:

      static

      dynamic
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
    __members__: dict  # value = {'static': <ValueParamKind.static: 0>, 'dynamic': <ValueParamKind.dynamic: 1>}
    dynamic: _hls_dialect.ValueParamKind  # value = <ValueParamKind.dynamic: 1>
    static: _hls_dialect.ValueParamKind  # value = <ValueParamKind.static: 0>
    pass


def semantics_init_args(semantics: MlirOperation) -> None:
    pass
