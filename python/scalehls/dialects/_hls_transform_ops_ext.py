# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

try:
    from ..ir import *
    from ..dialects import transform
except ImportError as e:
    raise RuntimeError("Error loading imports from extension module") from e
