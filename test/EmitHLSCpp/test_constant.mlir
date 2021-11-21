// RUN: scalehls-opt -legalize-to-hlscpp %s | scalehls-translate -emit-hlscpp | FileCheck %s

func @test_constant(%arg0: i32) -> (i32, tensor<2x2xi32>, vector<2xi32>, i32) {

  // CHECK: int32_t [[VAL_0:.*]][2][2] = {11, 0, 0, -42};
  %0 = arith.constant dense<[[11, 0], [0, -42]]> : tensor<2x2xi32>

  // CHECK: float [[VAL_1:.*]][2][2] = {1.100000e+01, 0.000000e+00, 0.000000e+00, -4.200000e+01};
  %1 = arith.constant dense<[[11.0, 0.0], [0.0, -42.0]]> : tensor<2x2xf32>

  // CHECK: bool [[VAL_2:.*]][2][2] = {1, 0, 0, 1};
  %2 = arith.constant dense<[[1, 0], [0, 1]]> : tensor<2x2xi1>

  // CHECK: int32_t [[VAL_3:.*]][2] = {0, -42};
  %3 = arith.constant dense<[0, -42]> : vector<2xi32>

  // CHECK: float [[VAL_4:.*]][2] = {0.000000e+00, -4.200000e+01};
  %4 = arith.constant dense<[0.0, -42.0]> : vector<2xf32>

  // CHECK: bool [[VAL_5:.*]][2] = {0, 1};
  %5 = arith.constant dense<[0, 1]> : vector<2xi1>

  // CHECK: *[[ARG_1:.*]] = 11 + [[ARG_0:.*]];
  %c11 = arith.constant 11 : i32
  %6 = arith.addi %c11, %arg0 : i32

  // CHECK: for (int iv0 = 0; iv0 < 2; ++iv0) {
  // CHECK:   for (int iv1 = 0; iv1 < 2; ++iv1) {
  // CHECK:     [[ARG_2:.*]][iv0][iv1] = [[VAL_0:.*]][iv0][iv1];
  // CHECK:   }
  // CHECK: }
  // CHECK: for (int iv0 = 0; iv0 < 2; ++iv0) {
  // CHECK:   [[ARG_3:.*]][iv0] = [[VAL_3:.*]][iv0];
  // CHECK: }
  // CHECK: *[[ARG_4:.*]] = 11;
  return %6, %0, %3, %c11 : i32, tensor<2x2xi32>, vector<2xi32>, i32
}
