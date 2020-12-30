// RUN: scalehls-opt -legalize-to-hlscpp="top-function=test_array_assign" %s | FileCheck %s

// CHECK-LABEL: func @test_array_assign(
// CHECK-SAME:  %arg0: f32, %arg1: memref<16xf32>) -> (f32, memref<16xf32>, i32, memref<2x2xi32>) attributes {dataflow = false, top_function = true} {
func @test_array_assign(%arg0: f32, %arg1: memref<16xf32>) -> (f32, memref<16xf32>, i32, memref<2x2xi32>) {
  // CHECK: %0 = "hlscpp.array"(%arg1) {interface = true, partition = false, storage = true, storage_type = "ram_1p_bram"} : (memref<16xf32>) -> memref<16xf32>
  
  %c11_i32 = constant 11 : i32
  %cst = constant dense<[[11, 0], [0, -42]]> : tensor<2x2xi32>
  
  // CHECK: %2 = "hlscpp.array"(%1) {interface = true, partition = false, storage = true, storage_type = "ram_1p_bram"} : (memref<2x2xi32>) -> memref<2x2xi32>
  %cst_memref = tensor_to_memref %cst : memref<2x2xi32>

  // CHECK: %3 = "hlscpp.assign"(%arg0) : (f32) -> f32
  // CHECK: %4 = "hlscpp.assign"(%0) : (memref<16xf32>) -> memref<16xf32>
  // CHECK: %5 = "hlscpp.assign"(%c11_i32) : (i32) -> i32
  // CHECK: return %3, %4, %5, %2 : f32, memref<16xf32>, i32, memref<2x2xi32>
  return %arg0, %arg1, %c11_i32, %cst_memref : f32, memref<16xf32>, i32, memref<2x2xi32>
}
