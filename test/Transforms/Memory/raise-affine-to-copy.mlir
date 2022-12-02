// RUN: scalehls-opt -scalehls-raise-implicit-copy %s | FileCheck %s

// CHECK: func.func @forward_node2(%arg0: memref<1x32x32x64xi8>) {
func.func @forward_node2(%arg0: memref<1x32x32x64xi8>) {
  %1 = memref.alloc() : memref<1x32x32x64xi8>
  // CHECK: memref.copy %arg0, %0 : memref<1x32x32x64xi8> to memref<1x32x32x64xi8>
  affine.for %arg7 = 0 to 32 {
    affine.for %arg8 = 0 to 32 {
      affine.for %arg9 = 0 to 64 {
        %7 = affine.load %arg0[0, %arg7, %arg8, %arg9] : memref<1x32x32x64xi8>
        affine.store %7, %1[0, %arg7, %arg8, %arg9] : memref<1x32x32x64xi8>
      }
    }
  }
  return
}