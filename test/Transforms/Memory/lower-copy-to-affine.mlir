// RUN: scalehls-opt -scalehls-lower-copy-to-affine %s | FileCheck %s

// CHECK: func.func @forward(%arg0: memref<1x64x56x56xi8>) {
// CHECK:   %c0 = arith.constant 0 : index
// CHECK:   hls.dataflow.dispatch {
// CHECK:     hls.dataflow.task {
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x58x58xi8>
// CHECK:       %subview = memref.subview %0[0, 0, 1, 1] [1, 64, 56, 56] [1, 1, 1, 1] : memref<1x64x58x58xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
// CHECK:       affine.for %arg1 = 0 to 64 {
// CHECK:         affine.for %arg2 = 0 to 56 {
// CHECK:           affine.for %arg3 = 0 to 56 {
// CHECK:             %1 = affine.load %arg0[%c0, %arg1, %arg2, %arg3] : memref<1x64x56x56xi8>
// CHECK:             affine.store %1, %subview[%c0, %arg1, %arg2, %arg3] : memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
// CHECK:           } {parallel, point}
// CHECK:         } {parallel, point}
// CHECK:       } {parallel, point}
// CHECK:     }
// CHECK:   }
// CHECK:   return
// CHECK: }

func.func @forward(%arg0: memref<1x64x56x56xi8>) {
  %c-24_i8 = arith.constant -24 : i8
  hls.dataflow.dispatch {
    %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
    hls.dataflow.task {
      %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x58x58xi8>
      %subview = memref.subview %4[0, 0, 1, 1] [1, 64, 56, 56] [1, 1, 1, 1] : memref<1x64x58x58xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
      memref.copy %arg0, %subview : memref<1x64x56x56xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
    }
  }
  return
}
