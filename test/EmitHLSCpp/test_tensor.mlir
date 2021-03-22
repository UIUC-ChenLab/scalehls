// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_tensor_expr(%arg0: tensor<16x8xi1>, %arg1: i1, %arg2: tensor<16x8xf32>, %arg3: tensor<16x8xf32>) -> tensor<16x8xf32> {

  // CHECK: float [[VAL_0:.*]][16][8];
  // CHECK: for (int idx0 = 0; idx0 < 16; ++idx0) {
  // CHECK:   for (int idx1 = 0; idx1 < 8; ++idx1) {
  // CHECK:     [[VAL_0:.*]][idx0][idx1] = [[ARG_0:.*]][idx0][idx1] ? [[ARG_2:.*]][idx0][idx1] : [[ARG_3:.*]][idx0][idx1];
  // CHECK:   }
  // CHECK: }
  %0 = select %arg0, %arg2, %arg3 : tensor<16x8xi1>, tensor<16x8xf32>

  // CHECK: [[VAL_1:.*]][idx0][idx1] = [[ARG_1:.*]] ? [[ARG_2:.*]][idx0][idx1] : [[ARG_3:.*]][idx0][idx1];
  %1 = select %arg1, %arg2, %arg3 : i1, tensor<16x8xf32>

  // CHECK: [[VAL_2:.*]][idx0][idx1] = [[ARG_2:.*]][idx0][idx1] + [[VAL_1:.*]][idx0][idx1];
  %2 = addf %arg2, %1 : tensor<16x8xf32>

  // CHECK-NOT: float [[VAL_3:.*]][16][8];
  // CHECK: [[VAL_3:.*]][idx0][idx1] = abs([[VAL_2:.*]][idx0][idx1]);
  %3 = absf %2 : tensor<16x8xf32>
  return %3 : tensor<16x8xf32>
}

func @test_tensor_load_store(%arg0: memref<16x8xi32>) {

  // CHECK: ap_int<32> [[VAL_0:.*]][16][8];
  // CHECK: for (int idx0 = 0; idx0 < 16; ++idx0) {
  // CHECK:   for (int idx1 = 0; idx1 < 8; ++idx1) {
  // CHECK:     [[VAL_0:.*]][idx0][idx1] = [[ARG_0:.*]][idx0][idx1];
  // CHECK:   }
  // CHECK: }
  %0 = memref.tensor_load %arg0 : memref<16x8xi32>

  // CHECK: for (int idx0 = 0; idx0 < 16; ++idx0) {
  // CHECK:   for (int idx1 = 0; idx1 < 8; ++idx1) {
  // CHECK:     [[ARG_0:.*]][idx0][idx1] = [[VAL_0:.*]][idx0][idx1];
  // CHECK:   }
  // CHECK: }
  memref.tensor_store %0, %arg0 : memref<16x8xi32>
  return
}
