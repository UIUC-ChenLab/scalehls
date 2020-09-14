// RUN: scalehls-opt -convert-to-hlscpp %s | FileCheck %s

func @test_input(%arg0: f32, %arg1: memref<16xf32>) -> (f32, memref<16xf32>) {
  // CHECK: %[[VAL_0:.*]] = "hlscpp.assign"(%[[ARG_0:.*]]) : (f32) -> f32
  // CHECK: %[[VAL_1:.*]] = "hlscpp.assign"(%[[ARG_1:.*]]) : (memref<16xf32>) -> memref<16xf32>
  // CHECK: return %[[VAL_0:.*]], %[[VAL_1:.*]] : f32, memref<16xf32>
  return %arg0, %arg1 : f32, memref<16xf32>
}
