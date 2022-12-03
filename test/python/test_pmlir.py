# REQUIRES: bindings_python
# RUN: %PYTHON %s | FileCheck %s

from pmlir import *


@pmlir_function()
def test_gemm():
    return


# CHECK: module
compile(test_gemm)
