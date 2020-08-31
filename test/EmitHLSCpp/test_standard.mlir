// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

// CHECK:       void test_integer_op(
// CHECK-NEXT:    ap_int<32> [[VAL_1:.*]],
// CHECK-NEXT:    ap_int<32> [[VAL_2:.*]],
// CHECK-NEXT:    ap_int<32> *[[VAL_3:.*]]
// CHECK-NEXT:  ) {
func @test_integer_op(%arg0: i32, %arg1: i32) -> (i32) {
  %c11 = constant 11 : i32
  // CHECK: ap_int<32> [[VAL_4:.*]] = [[VAL_1:.*]] + [[VAL_2:.*]];
  %0 = addi %arg0, %arg1 : i32
  // CHECK: *[[VAL_3:.*]] = [[VAL_4:.*]] << 11;
  %1 = shift_left %0, %c11 : i32
  return %1 : i32
// CHECK: }
}

// CHECK:       void test_float_op(
// CHECK-NEXT:    float [[FVAL_1:.*]],
// CHECK-NEXT:    float [[FVAL_2:.*]],
// CHECK-NEXT:    float *[[FVAL_3:.*]]
// CHECK-NEXT:  ) {
func @test_float_op(%arg0: f32, %arg1: f32) -> (f32) {
  %c11 = constant 11.0 : f32
  // CHECK: float [[VAL_4:.*]] = [[FVAL_1:.*]] - [[FVAL_2:.*]];
  %0 = subf %arg0, %arg1 : f32
  // CHECK: float [[VAL_5:.*]] = 1.0 / sqrt([[VAL_4:.*]]);
  %1 = rsqrt %0 : f32
  // CHECK: *[[FVAL_3:.*]] = [[VAL_5:.*]] * 11.000000;
  %2 = mulf %1, %c11 : f32
  // CHECK: float [[FVAL_6:.*]][16];
  %3 = alloc() : memref<16xf32>
  return %2 : f32
// CHECK: }
}
