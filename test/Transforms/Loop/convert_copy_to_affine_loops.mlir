// RUN: scalehls-opt -scalehls-convert-copy-to-affine-loops %s | FileCheck %s

#map1 = affine_map<(d0, d1, d2, d3) -> (d0 * 73984 + d1 * 2176 + d2 * 64 + d3 + 2240)>
#map2 = affine_map<(d0, d1) -> (d0 + d1)>
#map3 = affine_map<(d0, d1, d2, d3) -> (d0 * 3468 + d1 * 102 + d2 * 3 + d3 + 105)>
module {
  func @test0(%arg0: memref<1x32x32x64xi8>, %arg1: memref<1x32x32x64xi8>) {
    %c0_i8 = arith.constant 0 : i8
    %c127_i8 = arith.constant 127 : i8

    // CHECK-NOT: %[[VAL0:.*]] = memref.alloc() : memref<1x32x32x64xi8>
    %1 = memref.alloc() : memref<1x32x32x64xi8>
    affine.for %arg2 = 0 to 1 {
      affine.for %arg3 = 0 to 32 {
        affine.for %arg4 = 0 to 32 {
          affine.for %arg5 = 0 to 64 {
            %12 = affine.load %arg0[%arg2, %arg3, %arg4, %arg5] : memref<1x32x32x64xi8>
            %13 = arith.cmpi slt, %12, %c0_i8 : i8
            %14 = arith.select %13, %c0_i8, %12 : i8
            %15 = arith.cmpi slt, %c127_i8, %12 : i8
            %16 = arith.select %15, %c127_i8, %14 : i8

            // CHECK: affine.store %[[VAL1:.*]], %arg1[%arg2, %arg3, %arg4, %arg5] : memref<1x32x32x64xi8>
            affine.store %16, %1[%arg2, %arg3, %arg4, %arg5] : memref<1x32x32x64xi8>
          }
        }
      }
    }

    // CHECK-NOT: %[[VAL2:.*]] = bufferization.to_tensor %[[VAL0:.*]] : memref<1x32x32x64xi8>
    // CHECK-NOT: %[[VAL3:.*]] = "hlscpp.buffer"(%[[VAL2:.*]]) : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    // CHECK-NOT: %[[VAL4:.*]] = bufferization.to_memref %[[VAL3:.*]] : memref<1x32x32x64xi8>
    // CHECK-NOT: memref.copy %[[VAL4:.*]], %arg1 : memref<1x32x32x64xi8> to memref<1x32x32x64xi8>
    %2 = bufferization.to_tensor %1 : memref<1x32x32x64xi8>
    %10 = "hlscpp.buffer"(%2) : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %11 = bufferization.to_memref %10 : memref<1x32x32x64xi8>
    memref.copy %11, %arg1 : memref<1x32x32x64xi8> to memref<1x32x32x64xi8>
    return
  }

  func @test1(%arg0: memref<1x1x64xi8>, %arg1: memref<1x64x10xi8>, %arg2: memref<1x10xi8>) {
    %c0_i8 = arith.constant 0 : i8

    // CHECK-NOT: %cst = arith.constant dense<[1, 10]> : tensor<2xi32>
    %cst = arith.constant dense<[1, 10]> : tensor<2xi32>

    // CHECK: %0 = memref.alloc() : memref<1x1x10xi8>
    %0 = memref.alloc() : memref<1x1x10xi8>
    affine.for %arg3 = 0 to 1 {
      affine.for %arg4 = 0 to 1 {
        affine.for %arg5 = 0 to 10 {
          affine.store %c0_i8, %0[%arg3, %arg4, %arg5] : memref<1x1x10xi8>
        }
      }
    }

    // CHECK-NOT: %[[VAL0:.*]] = memref.alloc() : memref<1x1x10xi8>
    // CHECK-NOT: memref.copy %0, %[[VAL0:.*]] : memref<1x1x10xi8> to memref<1x1x10xi8>    
    %1 = memref.alloc() : memref<1x1x10xi8>
    memref.copy %0, %1 : memref<1x1x10xi8> to memref<1x1x10xi8>
    affine.for %arg3 = 0 to 1 {
      affine.for %arg4 = 0 to 1 {
        affine.for %arg5 = 0 to 10 {
          affine.for %arg6 = 0 to 64 {
            %5 = affine.load %arg0[%arg3, %arg4, %arg6] : memref<1x1x64xi8>
            %6 = affine.load %arg1[%arg3, %arg6, %arg5] : memref<1x64x10xi8>
            %7 = affine.load %1[%arg3, %arg4, %arg5] : memref<1x1x10xi8>
            %8 = arith.muli %5, %6 : i8
            %9 = arith.addi %7, %8 : i8

            // CHECK: affine.store %[[VAL1:.*]], %0[%arg3, %arg4, %arg5] : memref<1x1x10xi8>
            affine.store %9, %1[%arg3, %arg4, %arg5] : memref<1x1x10xi8>
          }
        }
      }
    }

    // CHECK: affine.for %arg3 = 0 to 10 {
    // CHECK:   %1 = affine.load %0[0, 0, %arg3] : memref<1x1x10xi8>
    // CHECK:   affine.store %1, %arg2[0, %arg3] : memref<1x10xi8>
    // CHECK: }
    %2 = bufferization.to_tensor %1 : memref<1x1x10xi8>
    %3 = tensor.reshape %2(%cst) : (tensor<1x1x10xi8>, tensor<2xi32>) -> tensor<1x10xi8>
    %4 = bufferization.to_memref %3 : memref<1x10xi8>
    memref.copy %4, %arg2 : memref<1x10xi8> to memref<1x10xi8>
    return
  }
}
