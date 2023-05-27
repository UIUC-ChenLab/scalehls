"""ScaleHLS Python Native Extension"""
from __future__ import annotations
import _scalehls
import typing

__all__ = [
    "add_comprehensive_bufferize_passes",
    "add_convert_dataflow_to_func_passes",
    "add_convert_linalg_to_dataflow_passes",
    "add_generate_design_space_passes",
    "add_linalg_transform_passes",
    "add_lower_dataflow_passes",
    "emit_hlscpp",
    "register_everything"
]


def add_comprehensive_bufferize_passes(pass_manager: MlirPassManager) -> None:
    pass


def add_convert_dataflow_to_func_passes(pass_manager: MlirPassManager) -> None:
    pass


def add_convert_linalg_to_dataflow_passes(pass_manager: MlirPassManager) -> None:
    pass


def add_generate_design_space_passes(pass_manager: MlirPassManager) -> None:
    pass


def add_linalg_transform_passes(pass_manager: MlirPassManager) -> None:
    pass


def add_lower_dataflow_passes(pass_manager: MlirPassManager) -> None:
    pass


def emit_hlscpp(module: MlirModule, file_object: object) -> bool:
    pass


def register_everything(context: object) -> None:
    pass
