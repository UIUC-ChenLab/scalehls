// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

/// Test function signature.
// CHECK:       void test_standard(
// CHECK-NEXT:    ap_int<32> [[VAL_1:.*]],
// CHECK-NEXT:    ap_int<32> [[VAL_2:.*]][16],
// CHECK-NEXT:    float [[FVAL_1:.*]],
// CHECK-NEXT:    float [[FVAL_2:.*]],
// CHECK-NEXT:    ap_int<32> *[[VAL_3:.*]]
// CHECK-NEXT:    float *[[FVAL_3:.*]]
// CHECK-NEXT:  ) {
func @test_standard(%val1: i32, %val2: memref<16xi32>, %fval1: f32, %fval2: f32) -> (i32, f32) {
  %index3 = constant 3 : index

  /// Test integer expressions.
  %int11 = constant 11 : i32
  // CHECK: ap_int<32> [[VAL_4:.*]] = [[VAL_2:.*]][3];
  %val4 = load %val2[%index3] : memref<16xi32>
  // CHECK: ap_int<32> [[VAL_5:.*]] = [[VAL_1:.*]] + [[VAL_4:.*]];
  %val5 = addi %val1, %val4 : i32
  // CHECK: *[[VAL_3:.*]] = [[VAL_5:.*]] << 11;
  %val3 = shift_left %val5, %int11 : i32

  /// Test float expressions.
  %flt42 = constant 42.0 : f32
  // CHECK: float [[FVAL_4:.*]] = [[FVAL_1:.*]] - [[FVAL_2:.*]];
  %fval4 = subf %fval1, %fval2 : f32
  // CHECK: float [[FVAL_5:.*]] = 1.0 / sqrt([[FVAL_4:.*]]);
  %fval5 = rsqrt %fval4 : f32
  // CHECK: [[FVAL_6:.*]] = [[FVAL_5:.*]] * 42.000000;
  %fval6 = mulf %fval5, %flt42 : f32

  /// Test memref related statements.
  // CHECK: float [[FVAL_7:.*]][16];
  %fval7 = alloc() : memref<16xf32>
  // CHECK: [[FVAL_7:.*]][3] = [[FVAL_6:.*]];
  store %fval6, %fval7[%index3] : memref<16xf32>
  // CHECK: *[[FVAL_3:.*]] = [[FVAL_7:.*]][3];
  %fval3 = load %fval7[%index3] : memref<16xf32>
  return %val3, %fval3 : i32, f32
// CHECK: }
}
