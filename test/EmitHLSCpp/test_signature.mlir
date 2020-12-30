// RUN: scalehls-opt -legalize-to-hlscpp %s | scalehls-translate -emit-hlscpp | FileCheck %s

// CHECK: void test_signature(
// CHECK:   float [[VAL_0:.*]],
// CHECK:   double [[VAL_1:.*]],
// CHECK:   int [[VAL_2:.*]],
// CHECK:   bool [[VAL_3:.*]],
// CHECK:   ap_int<11> [[VAL_4:.*]],
// CHECK:   ap_int<32> [[VAL_5:.*]],
// CHECK:   ap_uint<32> [[VAL_6:.*]],
// CHECK:   float [[VAL_7:.*]][16][8],
// CHECK:   float [[VAL_8:.*]][16][8],
// CHECK:   float [[VAL_9:.*]][16],
// CHECK:   ap_int<32> [[VAL_10:.*]][16][8],
// CHECK:   ap_int<32> [[VAL_11:.*]][16][8],
// CHECK:   ap_int<32> [[VAL_12:.*]][16],
// CHECK:   float *[[VAL_13:.*]],
// CHECK:   double *[[VAL_14:.*]],
// CHECK:   int *[[VAL_15:.*]],
// CHECK:   bool *[[VAL_16:.*]],
// CHECK:   ap_int<11> *[[VAL_17:.*]],
// CHECK:   ap_int<32> *[[VAL_18:.*]],
// CHECK:   ap_uint<32> *[[VAL_19:.*]],
// CHECK:   float [[VAL_20:.*]][16][8],
// CHECK:   float [[VAL_21:.*]][16][8],
// CHECK:   float [[VAL_22:.*]][16],
// CHECK:   ap_int<32> [[VAL_23:.*]][16][8],
// CHECK:   ap_int<32> [[VAL_24:.*]][16][8],
// CHECK:   ap_int<32> [[VAL_25:.*]][16]
// CHECK: ) {
func @test_signature(
  %arg0: f32, %arg1: f64, %arg2: index, %arg3: i1, %arg4: i11, %arg5: i32, %arg6: ui32,
  %arg7: memref<16x8xf32>, %arg8: tensor<16x8xf32>, %arg9: vector<16xf32>,
  %arg10: memref<16x8xi32>, %arg11: tensor<16x8xi32>, %arg12: vector<16xi32>
) -> (
  f32, f64, index, i1, i11, i32, ui32,
  memref<16x8xf32>, tensor<16x8xf32>, vector<16xf32>,
  memref<16x8xi32>, tensor<16x8xi32>, vector<16xi32>
) {
  %c0 = constant 0 : index
  %c1 = constant 1 : index

  // CHECK: int [[VAL_26:.*]] = 16;
  %0 = dim %arg7, %c0 : memref<16x8xf32>

  // CHECK: int [[VAL_27:.*]] = 8;
  %1 = dim %arg8, %c1 : tensor<16x8xf32>

  // CHECK: int [[VAL_28:.*]] = 2;
  %3 = rank %arg7 : memref<16x8xf32>

  // CHECK: int [[VAL_29:.*]] = 2;
  %4 = rank %arg8 : tensor<16x8xf32>

  // CHECK: *[[VAL_13:.*]] = [[VAL_0:.*]];
  // CHECK: for (int idx0 = 0; idx0 < 16; ++idx0) {
  // CHECK:   for (int idx1 = 0; idx1 < 8; ++idx1) {
  // CHECK:     [[VAL_20:.*]][idx0][idx1] = [[VAL_7:.*]][idx0][idx1];
  // CHECK:   }
  // CHECK: }
  return
    %arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6,
    %arg7, %arg8, %arg9,
    %arg10, %arg11, %arg12
    :
    f32, f64, index, i1, i11, i32, ui32,
    memref<16x8xf32>, tensor<16x8xf32>, vector<16xf32>,
    memref<16x8xi32>, tensor<16x8xi32>, vector<16xi32>
}
