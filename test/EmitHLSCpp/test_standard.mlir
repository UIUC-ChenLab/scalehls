// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

/// Test function signature.
// CHECK:       void test_standard(
// CHECK-NEXT:    ap_int<32> [[VAL_1:.*]],
// CHECK-NEXT:    ap_int<32> [[VAL_2:.*]],
// CHECK-NEXT:    float [[FVAL_1:.*]],
// CHECK-NEXT:    float [[FVAL_2:.*]],
// CHECK-NEXT:    ap_int<32> *[[VAL_3:.*]]
// CHECK-NEXT:    float *[[FVAL_3:.*]]
// CHECK-NEXT:  ) {
func @test_standard(%arg0: i32, %arg1: i32, %arg2: f32, %arg3: f32) -> (i32, f32) {
  
  /// Test integer expressions.
  %int11 = constant 11 : i32
  // CHECK: ap_int<32> [[VAL_4:.*]] = [[VAL_1:.*]] + [[VAL_2:.*]];
  %0 = addi %arg0, %arg1 : i32
  // CHECK: *[[VAL_3:.*]] = [[VAL_4:.*]] << 11;
  %1 = shift_left %0, %int11 : i32

  /// Test float expressions.
  %flt42 = constant 42.0 : f32
  %int3 = constant 3 : index
  // CHECK: float [[FVAL_4:.*]] = [[FVAL_1:.*]] - [[FVAL_2:.*]];
  %2 = subf %arg2, %arg3 : f32
  // CHECK: float [[FVAL_5:.*]] = 1.0 / sqrt([[FVAL_4:.*]]);
  %3 = rsqrt %2 : f32
  // CHECK: [[FVAL_6:.*]] = [[FVAL_5:.*]] * 42.000000;
  %4 = mulf %3, %flt42 : f32

  /// Test memref related statements.
  // CHECK: float [[FVAL_7:.*]][16];
  %5 = alloc() : memref<16xf32>
  // CHECK: [[FVAL_7:.*]][3] = [[FVAL_6:.*]];
  store %4, %5[%int3] : memref<16xf32>
  // CHECK: *[[FVAL_6:.*]] = [[FVAL_7:.*]][3];
  %6 = load %5[%int3] : memref<16xf32>
  return %1, %6 : i32, f32
// CHECK: }
}
