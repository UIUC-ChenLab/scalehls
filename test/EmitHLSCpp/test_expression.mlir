// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_integer_binary(%arg0: i32, %arg1: i32) -> i32 {

  // CHECK: ap_int<32> [[VAL_0:.*]] = [[ARG_0:.*]] + [[ARG_1:.*]];
  %0 = addi %arg0, %arg1 : i32
  // CHECK: -
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

  // CHECK: *[[VAL_2:.*]] = [[ARG_0:.*]] >> [[VAL_1:.*]];
  %12 = shift_right_unsigned %arg0, %11 : i32
  return %12 : i32
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
  // CHECK: log10
  %17 = log10 %16 : f32
  return %17 : f32
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
