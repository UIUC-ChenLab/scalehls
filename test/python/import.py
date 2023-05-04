# REQUIRES: bindings_python
# RUN: %PYTHON %s

import mlir.ir
from mlir.dialects import builtin
import scalehls
from scalehls.dialects import hls
from scalehls import uip
