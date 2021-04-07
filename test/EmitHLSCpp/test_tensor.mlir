// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_tensor_expr(%arg0: tensor<16x8xi1>, %arg1: i1, %arg2: tensor<16x8xf32>, %arg3: tensor<16x8xf32>) -> tensor<16x8xf32> {

  // CHECK: float [[VAL_0:.*]][16][8];
  // CHECK: for (int iv0 = 0; iv0 < 16; ++iv0) {
  // CHECK:   for (int iv1 = 0; iv1 < 8; ++iv1) {
  // CHECK:     [[VAL_0:.*]][iv0][iv1] = [[ARG_0:.*]][iv0][iv1] ? [[ARG_2:.*]][iv0][iv1] : [[ARG_3:.*]][iv0][iv1];
  // CHECK:   }
  // CHECK: }
  %0 = select %arg0, %arg2, %arg3 : tensor<16x8xi1>, tensor<16x8xf32>

  // CHECK: [[VAL_1:.*]][iv0][iv1] = [[ARG_1:.*]] ? [[ARG_2:.*]][iv0][iv1] : [[ARG_3:.*]][iv0][iv1];
  %1 = select %arg1, %arg2, %arg3 : i1, tensor<16x8xf32>

  // CHECK: [[VAL_2:.*]][iv0][iv1] = [[ARG_2:.*]][iv0][iv1] + [[VAL_1:.*]][iv0][iv1];
  %2 = addf %arg2, %1 : tensor<16x8xf32>

  // CHECK-NOT: float [[VAL_3:.*]][16][8];
  // CHECK: [[VAL_3:.*]][iv0][iv1] = abs([[VAL_2:.*]][iv0][iv1]);
  %3 = absf %2 : tensor<16x8xf32>
  return %3 : tensor<16x8xf32>
}

func @test_tensor_load_store(%arg0: memref<16x8xi32>) {

  // CHECK: int32_t [[VAL_0:.*]][16][8];
  // CHECK: for (int iv0 = 0; iv0 < 16; ++iv0) {
  // CHECK:   for (int iv1 = 0; iv1 < 8; ++iv1) {
  // CHECK:     [[VAL_0:.*]][iv0][iv1] = [[ARG_0:.*]][iv0][iv1];
  // CHECK:   }
  // CHECK: }
  %0 = memref.tensor_load %arg0 : memref<16x8xi32>

  // CHECK: for (int iv0 = 0; iv0 < 16; ++iv0) {
  // CHECK:   for (int iv1 = 0; iv1 < 8; ++iv1) {
  // CHECK:     [[ARG_0:.*]][iv0][iv1] = [[VAL_0:.*]][iv0][iv1];
  // CHECK:   }
  // CHECK: }
  memref.tensor_store %0, %arg0 : memref<16x8xi32>
  return
}
