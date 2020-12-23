// RUN: scalehls-opt -convert-to-hlscpp="top-function=test_array_assign" %s | FileCheck %s

// CHECK-LABEL: func @test_array_assign(
// CHECK-SAME:  %arg0: f32, %arg1: memref<16xf32>) -> (f32, memref<16xf32>, i32, tensor<2x2xi32>) attributes {dataflow = false, top_function = true} {
func @test_array_assign(%arg0: f32, %arg1: memref<16xf32>) -> (f32, memref<16xf32>, i32, tensor<2x2xi32>) {
  // CHECK: %[[VAL_0:.*]] = "hlscpp.array"(%[[ARG_1:.*]]) {interface = true, partition = false, storage = true, storage_type = "ram_1p_bram"} : (memref<16xf32>) -> memref<16xf32>
  %c11_i32 = constant 11 : i32
  %cst = constant dense<[[11, 0], [0, -42]]> : tensor<2x2xi32>

  // CHECK: %[[VAL_1:.*]] = "hlscpp.array"(%cst) {interface = false, partition = false, storage = true, storage_type = "ram_1p_bram"} : (tensor<2x2xi32>) -> tensor<2x2xi32>
  // CHECK: %[[VAL_2:.*]] = "hlscpp.assign"(%arg0) : (f32) -> f32
  // CHECK: %[[VAL_3:.*]] = "hlscpp.assign"(%[[VAL_0:.*]]) : (memref<16xf32>) -> memref<16xf32>
  // CHECK: %[[VAL_4:.*]] = "hlscpp.assign"(%c11_i32) : (i32) -> i32
  // CHECK: %[[VAL_5:.*]] = "hlscpp.assign"(%[[VAL_1:.*]]) : (tensor<2x2xi32>) -> tensor<2x2xi32>
  // CHECK: return %[[VAL_2:.*]], %[[VAL_3:.*]], %[[VAL_4:.*]], %[[VAL_5:.*]] : f32, memref<16xf32>, i32, tensor<2x2xi32>
  return %arg0, %arg1, %c11_i32, %cst : f32, memref<16xf32>, i32, tensor<2x2xi32>
}
