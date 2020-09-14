// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

// CHECK: void test_input(
// CHECK:   float [[ARG_0:.*]],
// CHECK:   double [[ARG_1:.*]],
// CHECK:   float [[ARG_2:.*]][16][8],
// CHECK:   float [[ARG_3:.*]][16][8],
// CHECK:   float [[ARG_4:.*]][16],
// CHECK:   int [[ARG_5:.*]],
// CHECK:   ap_int<1> [[ARG_6:.*]],
// CHECK:   ap_int<11> [[ARG_7:.*]],
// CHECK:   ap_int<32> [[ARG_8:.*]],
// CHECK:   ap_uint<32> [[ARG_9:.*]],
// CHECK:   ap_int<32> [[ARG_1:.*]][16][8],
// CHECK:   ap_int<32> [[ARG_1:.*]][16][8],
// CHECK:   ap_int<32> [[ARG_1:.*]][16]
// CHECK: ) {
// CHECK: }
func @test_input(
  %arg0: f32,
  %arg1: f64,
  %arg2: memref<16x8xf32>,
  %arg3: tensor<16x8xf32>,
  %arg4: vector<16xf32>,
  %arg5: index,
  %arg6: i1,
  %arg7: i11,
  %arg8: i32,
  %arg9: ui32,
  %arg10: memref<16x8xi32>,
  %arg11: tensor<16x8xi32>,
  %arg12: vector<16xi32>)
{
  return
}
