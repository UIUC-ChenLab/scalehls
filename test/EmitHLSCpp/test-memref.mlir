// RUN: scalehls-translate -scalehls-emit-hlscpp %s | FileCheck %s

func.func @test_memref() {
  %c0 = arith.constant 0 : index
  %c11 = arith.constant 11 : index
  %c1 = arith.constant 1 : index
  %c12 = arith.constant 12 : index

  // CHECK: int [[VAL_0:.*]][16][8];
  %0 = memref.alloc() : memref<16x8xindex>

  // CHECK: int [[VAL_1:.*]][16];
  %1 = memref.alloca() : memref<16xindex>

  // CHECK: int [[VAL_2:.*]] = [[VAL_0:.*]][(int)11][(int)0];
  %2 = memref.load %0[%c11, %c0] : memref<16x8xindex>

  // CHECK: int [[VAL_3:.*]] = [[VAL_1:.*]][(int)11];
  %3 = memref.load %1[%c11] : memref<16xindex>

  // CHECK: int [[VAL_4:.*]] = [[VAL_0:.*]][((int)11 + [[VAL_2:.*]])][((int)0 + [[VAL_3:.*]])];
  %4 = affine.load %0[%c11 + %2, %c0 + %3] : memref<16x8xindex>

  // CHECK: int [[VAL_5:.*]] = [[VAL_1:.*]][((int)11 + [[VAL_2:.*]])];
  %5 = affine.load %1[%c11 + %2] : memref<16xindex>

  // CHECK: [[VAL_1:.*]][(int)12] = [[VAL_2:.*]];
  memref.store %2, %1[%c12] : memref<16xindex>

  // CHECK: [[VAL_0:.*]][(int)12][(int)1] = [[VAL_3:.*]];
  memref.store %3, %0[%c12, %c1] : memref<16x8xindex>

  // CHECK: [[VAL_1:.*]][((int)12 + [[VAL_4:.*]])] = [[VAL_4:.*]];
  affine.store %4, %1[%c12 + %4] : memref<16xindex>

  // CHECK: [[VAL_0:.*]][((int)12 + [[VAL_4:.*]])][((int)1 + [[VAL_5:.*]])] = [[VAL_5:.*]];
  affine.store %5, %0[%c12 + %4, %c1 + %5] : memref<16x8xindex>
  return
}
