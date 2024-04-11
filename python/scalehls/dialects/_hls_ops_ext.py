# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

try:
    from ..ir import *
    from typing import List
except ImportError as e:
    raise RuntimeError("Error loading imports from extension module") from e


class TaskOp:
    """Specialization for the task op class."""

    def __init__(self, results_, inits, *, name=None, location=None, loc=None, ip=None):
        super().__init__(results_, inits, name=name, location=location, loc=loc, ip=ip)

    @property
    def name(self):
        return StringAttr(self.operation.attributes["name"]).value
