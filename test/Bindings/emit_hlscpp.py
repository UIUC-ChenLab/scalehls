# REQUIRES: bindings_python
# RUN: %PYTHON %s | FileCheck %s

import scalehls
from mlir.ir import *

ctx = Context()
mod = Module.parse(r"""
  func @gemm_32(%arg0: f32, %arg1: f32, %arg2: memref<32x32xf32>, %arg3: memref<32x32xf32>, %arg4: memref<32x32xf32>) {
    affine.for %arg5 = 0 to 32 {
      affine.for %arg6 = 0 to 32 {
        %0 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
        %1 = mulf %arg1, %0 : f32
        affine.store %1, %arg2[%arg5, %arg6] : memref<32x32xf32>
        affine.for %arg7 = 0 to 32 {
          %2 = affine.load %arg3[%arg5, %arg7] : memref<32x32xf32>
          %3 = affine.load %arg4[%arg7, %arg6] : memref<32x32xf32>
          %4 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
          %5 = mulf %arg0, %2 : f32
          %6 = mulf %5, %3 : f32
          %7 = addf %4, %6 : f32
          affine.store %7, %arg2[%arg5, %arg6] : memref<32x32xf32>
        }
      }
    }
    return
  }
""", ctx)

f = open("tmp.cpp", 'w+')
scalehls.emit_hlscpp(mod, f)
f.seek(0)
print(f.read())

# CHECK: void gemm_32(
# CHECK:   float v0,
# CHECK:   float v1,
# CHECK:   float v2[32][32],
# CHECK:   float v3[32][32],
# CHECK:   float v4[32][32]
# CHECK: ) {     // L2
# CHECK:   for (int v5 = 0; v5 < 32; v5 += 1) {  // L3
# CHECK:     for (int v6 = 0; v6 < 32; v6 += 1) {        // L4
# CHECK:       float v7 = v2[v5][v6];    // L5
# CHECK:       float v8 = v1 * v7;       // L6
# CHECK:       v2[v5][v6] = v8;  // L7
# CHECK:       for (int v9 = 0; v9 < 32; v9 += 1) {      // L8
# CHECK:         float v10 = v3[v5][v9]; // L9
# CHECK:         float v11 = v4[v9][v6]; // L10
# CHECK:         float v12 = v2[v5][v6]; // L11
# CHECK:         float v13 = v0 * v10;   // L12
# CHECK:         float v14 = v13 * v11;  // L13
# CHECK:         float v15 = v12 + v14;  // L14
# CHECK:         v2[v5][v6] = v15;       // L15
# CHECK:       }
# CHECK:     }
# CHECK:   }
# CHECK: }
