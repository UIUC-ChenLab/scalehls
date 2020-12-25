// RUN: scalehls-opt -convert-to-hlscpp %s | scalehls-translate -emit-hlscpp | FileCheck %s

func @test_constant(%arg0: i32) -> (i32, tensor<2x2xi32>, vector<2xi32>, i32) {

  // CHECK: ap_int<32> [[VAL_0:.*]][2][2] = {11, 0, 0, -42};
  %0 = constant dense<[[11, 0], [0, -42]]> : tensor<2x2xi32>

  // CHECK: float [[VAL_1:.*]][2][2] = {1.100000e+01, 0.000000e+00, 0.000000e+00, -4.200000e+01};
  %1 = constant dense<[[11.0, 0.0], [0.0, -42.0]]> : tensor<2x2xf32>

  // CHECK: bool [[VAL_2:.*]][2][2] = {1, 0, 0, 1};
  %2 = constant dense<[[1, 0], [0, 1]]> : tensor<2x2xi1>

  // CHECK: ap_int<32> [[VAL_3:.*]][2] = {0, -42};
  %3 = constant dense<[0, -42]> : vector<2xi32>

  // CHECK: float [[VAL_4:.*]][2] = {0.000000e+00, -4.200000e+01};
  %4 = constant dense<[0.0, -42.0]> : vector<2xf32>

  // CHECK: bool [[VAL_5:.*]][2] = {0, 1};
  %5 = constant dense<[0, 1]> : vector<2xi1>

  // CHECK: *[[ARG_1:.*]] = 11 + [[ARG_0:.*]];
  %c11 = constant 11 : i32
  %6 = addi %c11, %arg0 : i32

  // CHECK: for (int idx0 = 0; idx0 < 2; ++idx0) {
  // CHECK:   for (int idx1 = 0; idx1 < 2; ++idx1) {
  // CHECK:     [[ARG_2:.*]][idx0][idx1] = [[VAL_0:.*]][idx0][idx1];
  // CHECK:   }
  // CHECK: }
  // CHECK: for (int idx0 = 0; idx0 < 2; ++idx0) {
  // CHECK:   [[ARG_3:.*]][idx0] = [[VAL_3:.*]][idx0];
  // CHECK: }
  // CHECK: *[[ARG_4:.*]] = 11;
  return %6, %0, %3, %c11 : i32, tensor<2x2xi32>, vector<2xi32>, i32
}
