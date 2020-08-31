// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

// CHECK:       void test_integer_op(
// CHECK-NEXT:    ap_int<32> val1,
// CHECK-NEXT:    ap_int<32> val2,
// CHECK-NEXT:    ap_int<32> *val3
// CHECK-NEXT:  ) {
func @test_integer_op(%arg0: i32, %arg1: i32) -> (i32) {

  // CHECK: *val3 = val1 + val2;
  %0 = addi %arg0, %arg1 : i32
  return %0 : i32

// CHECK: }
}

// CHECK:       void test_float_op(
// CHECK-NEXT:    float val4,
// CHECK-NEXT:    float val5,
// CHECK-NEXT:    float *val6
// CHECK-NEXT:  ) {
func @test_float_op(%arg0: f32, %arg1: f32) -> (f32) {

  // CHECK: float val7 = val4 + val5;
  // CHECK: *val6 = 1.0 / sqrt(val7);
  %0 = addf %arg0, %arg1 : f32
  %1 = rsqrt %0 : f32
  return %1 : f32

// CHECK: }
}
