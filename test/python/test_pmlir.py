# REQUIRES: bindings_python
# RUN: %PYTHON %s | FileCheck %s

from pmlir import *
import numpy


@pmlir_function_ast()
def foo(a: int,b: int) -> int:
    c = a + b
    c = c + a
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
# CHECK:     %alloc = memref.alloc() : memref<i32>
# CHECK:     memref.store %arg0, %alloc[] : memref<i32>
# CHECK:     %alloc_0 = memref.alloc() : memref<i32>
# CHECK:     memref.store %arg1, %alloc_0[] : memref<i32>
# CHECK:     %0 = memref.load %alloc[] : memref<i32>
# CHECK:     %1 = memref.load %alloc_0[] : memref<i32>
# CHECK:     %2 = arith.addi %0, %1 : i32
# CHECK:     %alloc_1 = memref.alloc() : memref<i32>
# CHECK:     memref.store %2, %alloc_1[] : memref<i32>
# CHECK:     %3 = memref.load %alloc_1[] : memref<i32>
# CHECK:     return %3 : i32
# CHECK:   }
# CHECK: }
pmlir_compile(foo)
