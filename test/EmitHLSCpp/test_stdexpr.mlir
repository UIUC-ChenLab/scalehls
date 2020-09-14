// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_integer_binary(%arg0: i32, %arg1: i32) -> i32 {
  // CHECK: ap_int<32> [[VAL_0:.*]] = [[ARG_0:.*]] + [[ARG_1:.*]];
  %0 = addi %arg0, %arg1 : i32
  // CHECK: ap_int<32> [[VAL_1:.*]] = [[ARG_0:.*]] - [[VAL_0:.*]];
  %1 = subi %arg0, %0 : i32
  // CHECK: *
  %2 = muli %arg0, %1 : i32
  // CHECK: /
  %3 = divi_signed %arg0, %2 : i32
  // CHECK: %
  %4 = remi_signed %arg0, %3 : i32
  // CHECK: /
  %5 = divi_unsigned %arg0, %4 : i32
  // CHECK: %
  %6 = remi_unsigned %arg0, %5 : i32
  // CHECK: ^
  %7 = xor %arg0, %6 : i32
  // CHECK: &
  %8 = and %arg0, %7 : i32
  // CHECK: |
  %9 = or %arg0, %8 : i32
  // CHECK: <<
  %10 = shift_left %arg0, %9 : i32
  // CHECK: >>
  %11 = shift_right_signed %arg0, %10 : i32
  // CHECK: *[[VAL_3:.*]] = [[ARG_0:.*]] >> [[VAL_2:.*]];
  %12 = shift_right_unsigned %arg0, %11 : i32
  return %12 : i32
}

func @test_integer_compare(%arg0: i32, %arg1: i32) -> i1 {
  // CHECK: ==
  %0 = cmpi "eq", %arg0, %arg1 : i32
  // CHECK: !=
  %1 = cmpi "ne", %arg0, %arg1 : i32
  // CHECK: <
  %2 = cmpi "slt", %arg0, %arg1 : i32
  // CHECK: <
  %3 = cmpi "ult", %arg0, %arg1 : i32
  // CHECK: <=
  %4 = cmpi "sle", %arg0, %arg1 : i32
  // CHECK: <=
  %5 = cmpi "ule", %arg0, %arg1 : i32
  // CHECK: >
  %6 = cmpi "sgt", %arg0, %arg1 : i32
  // CHECK: >
  %7 = cmpi "ugt", %arg0, %arg1 : i32
  // CHECK: >=
  %8 = cmpi "sge", %arg0, %arg1 : i32
  // CHECK: >=
  %9 = cmpi "uge", %arg0, %arg1 : i32
  return %9 : i1
}

func @test_float_binary_unary(%arg0: f32, %arg1: f32) -> f32 {
  // CHECK: float [[VAL_0:.*]] = [[ARG_0:.*]] + [[ARG_1:.*]];
  %0 = addf %arg0, %arg1 : f32
  // CHECK: -
  %1 = subf %arg0, %0 : f32
  // CHECK: *
  %2 = mulf %arg0, %1 : f32
  // CHECK: /
  %3 = divf %arg0, %2 : f32
  // CHECK: %
  %4 = remf %arg0, %3 : f32
  // CHECK: float [[VAL_2:.*]] = abs([[VAL_1:.*]]);
  %5 = absf %4 : f32
  // CHECK: ceil
  %6 = ceilf %5 : f32
  // CHECK: -
  %7 = negf %6 : f32
  // CHECK: cos
  %8 = cos %7 : f32
  // CHECK: sin
  %9 = sin %8 : f32
  // CHECK: tanh
  %10 = tanh %9 : f32
  // CHECK: sqrt
  %11 = sqrt %10 : f32
  // CHECK: 1.0 / sqrt
  %12 = rsqrt %11 : f32
  // CHECK: exp
  %13 = exp %12 : f32
  // CHECK: exp2
  %14 = exp2 %13 : f32
  // CHECK: log
  %15 = log %14 : f32
  // CHECK: log2
  %16 = log2 %15 : f32
  // CHECK: *[[VAL_4:.*]] = log10([[VAL_3:.*]]);
  %17 = log10 %16 : f32
  return %17 : f32
}

func @test_float_compare(%arg0: f32, %arg1: f32) -> i1 {
  // CHECK: ==
  %0 = cmpf "oeq", %arg0, %arg1 : f32
  // CHECK: ==
  %1 = cmpf "ueq", %arg0, %arg1 : f32
  // CHECK: !=
  %2 = cmpf "one", %arg0, %arg1 : f32
  // CHECK: !=
  %3 = cmpf "une", %arg0, %arg1 : f32
  // CHECK: <
  %4 = cmpf "olt", %arg0, %arg1 : f32
  // CHECK: <
  %5 = cmpf "ult", %arg0, %arg1 : f32
  // CHECK: <=
  %6 = cmpf "ole", %arg0, %arg1 : f32
  // CHECK: <=
  %7 = cmpf "ule", %arg0, %arg1 : f32
  // CHECK: >
  %8 = cmpf "ogt", %arg0, %arg1 : f32
  // CHECK: >
  %9 = cmpf "ugt", %arg0, %arg1 : f32
  // CHECK: >=
  %10 = cmpf "oge", %arg0, %arg1 : f32
  // CHECK: >=
  %11 = cmpf "uge", %arg0, %arg1 : f32
  return %11 : i1
}

func @test_special_expr(%arg0: i1, %arg1: index, %arg2: index) -> index {
  // CHECK: int [[VAL_0:.*]] = [[ARG_0:.*]] ? [[ARG_1:.*]] : [[ARG_2:.*]];
  %0 = select %arg0, %arg1, %arg2 : i1, index
  // CHECK: ap_int<32> [[VAL_1:.*]] = [[VAL_0:.*]];
  %1 = index_cast %0 : index to i32
  // CHECK: *[[VAL_2:.*]] = [[VAL_0:.*]]
  %2 = index_cast %1 : i32 to index
  return %2 : index
}

func @test_tensor_expr(%arg0: tensor<16x8xi1>, %arg1: i1, %arg2: tensor<16x8xf32>, %arg3: tensor<16x8xf32>) -> tensor<16x8xf32> {
  // CHECK: float [[VAL_0:.*]][16][8];
  // CHECK: for (int idx0 = 0; idx0 < 16; ++idx0) {
  // CHECK:   for (int idx1 = 0; idx1 < 8; ++idx1) {
  // CHECK:     [[VAL_0:.*]][idx0][idx1] = [[ARG_0:.*]][idx0][idx1] ? [[ARG_2:.*]][idx0][idx1] : [[ARG_3:.*]][idx0][idx1];
  // CHECK:   }
  // CHECK: }
  %0 = select %arg0, %arg2, %arg3 : tensor<16x8xi1>, tensor<16x8xf32>
  // CHECK: [[VAL_1:.*]][idx0][idx1] = [[ARG_1:.*]] ? [[ARG_2:.*]][idx0][idx1] : [[ARG_3:.*]][idx0][idx1];
  %1 = select %arg1, %arg2, %arg3 : i1, tensor<16x8xf32>
  // CHECK: [[VAL_2:.*]][idx0][idx1] = [[ARG_2:.*]][idx0][idx1] + [[VAL_1:.*]][idx0][idx1];
  %2 = addf %arg2, %1 : tensor<16x8xf32>
  // CHECK-NOT: float [[VAL_3:.*]][16][8];
  // CHECK: [[VAL_3:.*]][idx0][idx1] = abs([[VAL_2:.*]][idx0][idx1]);
  %3 = absf %2 : tensor<16x8xf32>
  return %3 : tensor<16x8xf32>
}
