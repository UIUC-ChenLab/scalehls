// RUN: scalehls-opt -convert-to-hlscpp %s | FileCheck %s

// CHECK-LABEL: func @test_conversion(
// CHECK-SAME:  %arg0: f32, %arg1: memref<16xf32>) -> (f32, memref<16xf32>, i32, tensor<2x2xi32>) attributes {dataflow = false} {
func @test_conversion(%arg0: f32, %arg1: memref<16xf32>) -> (f32, memref<16xf32>, i32, tensor<2x2xi32>) {
  // CHECK: %[[VAL_0:.*]] = "hlscpp.array"(%[[ARG_1:.*]]) {interface = false, partition = false, storage_impl = "bram", storage_type = "ram_1p"} : (memref<16xf32>) -> memref<16xf32>
  %c11_i32 = constant 11 : i32
  %cst = constant dense<[[11, 0], [0, -42]]> : tensor<2x2xi32>

  // CHECK: %[[VAL_1:.*]] = "hlscpp.array"(%cst) {interface = false, partition = false, storage_impl = "bram", storage_type = "ram_1p"} : (tensor<2x2xi32>) -> tensor<2x2xi32>
  // CHECK: %[[VAL_2:.*]] = "hlscpp.assign"(%[[ARG_0:.*]]) : (f32) -> f32
  // CHECK: %[[VAL_2:.*]] = "hlscpp.assign"(%c11_i32) : (i32) -> i32
  // CHECK: return %[[VAL_2:.*]], %[[VAL_0:.*]], %[[VAL_3:.*]], %[[VAL_1:.*]] : f32, memref<16xf32>, i32, tensor<2x2xi32>
  return %arg0, %arg1, %c11_i32, %cst : f32, memref<16xf32>, i32, tensor<2x2xi32>
}
