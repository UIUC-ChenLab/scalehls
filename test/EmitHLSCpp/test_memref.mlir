// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_memref() {
  %c0 = constant 0 : index
  %c11 = constant 11 : index
  %c1 = constant 1 : index
  %c12 = constant 12 : index

  // CHECK: float [[VAL_0:.*]][16][8];
  %0 = alloc() : memref<16x8xf32>

  // CHECK: float [[VAL_1:.*]][16];
  %1 = alloca() : memref<16xf32>

  // CHECK: float [[VAL_2:.*]] = [[VAL_0:.*]][11][0];
  %2 = load %0[%c11, %c0] : memref<16x8xf32>

  // CHECK: float [[VAL_3:.*]] = [[VAL_1:.*]][11];
  %3 = load %1[%c11] : memref<16xf32>

  // CHECK: [[VAL_1:.*]][12] = [[VAL_2:.*]];
  store %2, %1[%c12] : memref<16xf32>

  // CHECK: [[VAL_0:.*]][12][1] = [[VAL_3:.*]];
  store %3, %0[%c12, %c1] : memref<16x8xf32>
  return
}
