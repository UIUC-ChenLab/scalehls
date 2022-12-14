# REQUIRES: bindings_python
# RUN: %PYTHON %s | FileCheck %s

from pmlir import *
import numpy


@pmlir_function_ast()
def foo(a: int,b: int) -> int:
    c = a + b
    return c
    # array = numpy.empty(3,dtype=int)
    # --> %array = memref.alloc : memref<16xi32>
    # array[a] = b
    # --> %a_index = arith.index_cast %a : i32
    # --> memref.store %b, %array[%a] : memref<16xi32>
    # c = array[a]
    # --> %c = memref.load %array[%a] : memref<16xi32>
    # return c
    # c = a + b
    # return a


# CHECK: module {
# CHECK:   func.func @foo(%arg0: i32, %arg1: i32) -> i32 {
# CHECK:     %0 = arith.addi %arg0, %arg1 : i32
# CHECK:     return %0 : i32
# CHECK:   }
# CHECK: }
pmlir_compile(foo)
