// RUN: scalehls-opt -legalize-to-hlscpp="top-func=test_assign" %s | FileCheck %s

// CHECK-LABEL: func @test_assign(
// CHECK-SAME:  %arg0: f32, %arg1: memref<16xf32, 1>) -> (f32, memref<16xf32, 1>, i32, memref<2x2xi32, 1>) attributes {dataflow = false, top_function = true} {
func @test_assign(%arg0: f32, %arg1: memref<16xf32, 1>) -> (f32, memref<16xf32, 1>, i32, memref<2x2xi32, 1>) {
  %c11_i32 = constant 11 : i32
  %cst = constant dense<[[11, 0], [0, -42]]> : tensor<2x2xi32>
  %cst_memref = memref.buffer_cast %cst : memref<2x2xi32, 1>

  // CHECK: %1 = "hlscpp.assign"(%arg0) : (f32) -> f32
  // CHECK: %2 = "hlscpp.assign"(%arg1) : (memref<16xf32, 1>) -> memref<16xf32, 1>
  // CHECK: %3 = "hlscpp.assign"(%c11_i32) : (i32) -> i32
  // CHECK: return %1, %2, %3, %0 : f32, memref<16xf32, 1>, i32, memref<2x2xi32, 1>
  return %arg0, %arg1, %c11_i32, %cst_memref : f32, memref<16xf32, 1>, i32, memref<2x2xi32, 1>
}
