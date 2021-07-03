// RUN: scalehls-opt --raise-scf-for --raise-memref-ops %s | FileCheck %s

// CHECK-LABEL: func @gemm(%arg0: f64, %arg1: f64, %arg2: memref<32x32xf64>, %arg3: memref<32x32xf64>, %arg4: memref<32x32xf64>) {
// CHECK:   %c32 = constant 32 : index
// CHECK:   %c0 = constant 0 : index
// CHECK:   %c1 = constant 1 : index
// CHECK:   affine.for %arg5 = %c0 to %c32 {
// CHECK:     affine.for %arg6 = %c0 to %c32 {
// CHECK:       %0 = affine.load %arg2[%arg6, %arg5] : memref<32x32xf64>
// CHECK:       %1 = mulf %0, %arg1 : f64
// CHECK:       affine.store %1, %arg2[%arg6, %arg5] : memref<32x32xf64>
// CHECK:       affine.for %arg7 = %c0 to %c32 {
// CHECK:         %2 = affine.load %arg3[%arg7, %arg5] : memref<32x32xf64>
// CHECK:         %3 = mulf %arg0, %2 : f64
// CHECK:         %4 = affine.load %arg4[%arg6, %arg7] : memref<32x32xf64>
// CHECK:         %5 = mulf %3, %4 : f64
// CHECK:         %6 = affine.load %arg2[%arg6, %arg5] : memref<32x32xf64>
// CHECK:         %7 = addf %6, %5 : f64
// CHECK:         affine.store %7, %arg2[%arg6, %arg5] : memref<32x32xf64>
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK:   return
// CHECK: }

module  {
  func @gemm(%arg0: f64, %arg1: f64, %arg2: memref<32x32xf64>, %arg3: memref<32x32xf64>, %arg4: memref<32x32xf64>) {
    %c32 = constant 32 : index
    %c0 = constant 0 : index
    %c1 = constant 1 : index
    scf.for %arg5 = %c0 to %c32 step %c1 {
      scf.for %arg6 = %c0 to %c32 step %c1 {
        %0 = memref.load %arg2[%arg6, %arg5] : memref<32x32xf64>
        %1 = mulf %0, %arg1 : f64
        memref.store %1, %arg2[%arg6, %arg5] : memref<32x32xf64>
        scf.for %arg7 = %c0 to %c32 step %c1 {
          %2 = memref.load %arg3[%arg7, %arg5] : memref<32x32xf64>
          %3 = mulf %arg0, %2 : f64
          %4 = memref.load %arg4[%arg6, %arg7] : memref<32x32xf64>
          %5 = mulf %3, %4 : f64
          %6 = memref.load %arg2[%arg6, %arg5] : memref<32x32xf64>
          %7 = addf %6, %5 : f64
          memref.store %7, %arg2[%arg6, %arg5] : memref<32x32xf64>
        }
      }
    }
    return
  }
}

