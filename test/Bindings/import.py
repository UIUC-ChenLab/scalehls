# REQUIRES: bindings_python
# RUN: %PYTHON %s
# XFAIL: *

import mlir.ir
from mlir.dialects import builtin
import scalehls
from scalehls.dialects import hls
