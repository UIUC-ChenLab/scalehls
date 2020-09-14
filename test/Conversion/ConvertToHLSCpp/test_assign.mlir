// RUN: scalehls-opt -convert-to-hlscpp %s | FileCheck %s

func @test_assign(%arg0: f32, %arg1: memref<16xf32>) -> (f32, memref<16xf32>, i32, tensor<2x2xi32>) {
  %c11_i32 = constant 11 : i32
  %cst = constant dense<[[11, 0], [0, -42]]> : tensor<2x2xi32>

  // CHECK: %[[VAL_0:.*]] = "hlscpp.assign"(%[[ARG_0:.*]]) : (f32) -> f32
  // CHECK: %[[VAL_1:.*]] = "hlscpp.assign"(%[[ARG_1:.*]]) : (memref<16xf32>) -> memref<16xf32>
  // CHECK: %[[VAL_2:.*]] = "hlscpp.assign"(%c11_i32) : (i32) -> i32
  // CHECK: %[[VAL_3:.*]] = "hlscpp.assign"(%cst) : (tensor<2x2xi32>) -> tensor<2x2xi32>
  // CHECK: return %[[VAL_0:.*]], %[[VAL_1:.*]], %[[VAL_2:.*]], %[[VAL_3:.*]] : f32, memref<16xf32>, i32, tensor<2x2xi32>
  return %arg0, %arg1, %c11_i32, %cst : f32, memref<16xf32>, i32, tensor<2x2xi32>
}
