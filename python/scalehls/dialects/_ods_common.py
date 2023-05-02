# ===----------------------------------------------------------------------=== #
#
# Copyright 2020-2021 The ScaleHLS Authors.
#
# ===----------------------------------------------------------------------=== #

# Generated tablegen dialects expect to be able to find some symbols from
# the mlir.dialects package.
from mlir.dialects._ods_common import (
    _cext,
    segmented_accessor,
    equally_sized_accessor,
    extend_opview_class,
    get_default_loc_context,
    get_op_result_or_value,
    get_op_results_or_values
)
