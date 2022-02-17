// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_integer_binary(%arg0: i32, %arg1: i32) -> i32 {

  // CHECK: int32_t [[VAL_0:.*]] = [[ARG_0:.*]] + [[ARG_1:.*]];
  %0 = arith.addi %arg0, %arg1 : i32
  // CHECK: -
  %1 = arith.subi %arg0, %0 : i32
  // CHECK: *
  %2 = arith.muli %arg0, %1 : i32
  // CHECK: /
  %3 = arith.divsi %arg0, %2 : i32
  // CHECK: %
  %4 = arith.remsi %arg0, %3 : i32
  // CHECK: /
  %5 = arith.divui %arg0, %4 : i32
  // CHECK: %
  %6 = arith.remui %arg0, %5 : i32
  // CHECK: ^
  %7 = arith.xori %arg0, %6 : i32
  // CHECK: &
  %8 = arith.andi %arg0, %7 : i32
  // CHECK: |
  %9 = arith.ori %arg0, %8 : i32
  // CHECK: <<
  %10 = arith.shli %arg0, %9 : i32
  // CHECK: >>
  %11 = arith.shrsi %arg0, %10 : i32
  // CHECK: >>
  %12 = arith.shrui %arg0, %11 : i32

  // CHECK: int32_t [[VAL_3:.*]] = max([[ARG_0:.*]], [[VAL_2:.*]]);
  %13 = arith.maxsi %arg0, %12 : i32

  // CHECK: *[[VAL_4:.*]] = min([[ARG_0:.*]], [[VAL_3]]);
  %14 = arith.minui %arg0, %13 : i32
  return %14 : i32
}

func @test_float_binary_unary(%arg0: f32, %arg1: f32) -> f32 {

  // CHECK: float [[VAL_0:.*]] = [[ARG_0:.*]] + [[ARG_1:.*]];
  %0 = arith.addf %arg0, %arg1 : f32
  // CHECK: -
  %1 = arith.subf %arg0, %0 : f32
  // CHECK: *
  %2 = arith.mulf %arg0, %1 : f32
  // CHECK: /
  %3 = arith.divf %arg0, %2 : f32
  // CHECK: %
  %4 = arith.remf %arg0, %3 : f32

  // CHECK: float [[VAL_2:.*]] = abs([[VAL_1:.*]]);
  %5 = math.abs %4 : f32
  // CHECK: ceil
  %6 = math.ceil %5 : f32
  // CHECK: -
  %7 = arith.negf %6 : f32
  // CHECK: cos
  %8 = math.cos %7 : f32
  // CHECK: sin
  %9 = math.sin %8 : f32
  // CHECK: tanh
  %10 = math.tanh %9 : f32
  // CHECK: sqrt
  %11 = math.sqrt %10 : f32
  // CHECK: 1.0 / sqrt
  %12 = math.rsqrt %11 : f32
  // CHECK: exp
  %13 = math.exp %12 : f32
  // CHECK: exp2
  %14 = math.exp2 %13 : f32
  // CHECK: log
  %15 = math.log %14 : f32
  // CHECK: log2
  %16 = math.log2 %15 : f32
  // CHECK: log10
  %17 = math.log10 %16 : f32

  // CHECK: float [[VAL_4:.*]] = max([[ARG_0:.*]], [[VAL_3:.*]]);
  %18 = arith.maxf %arg0, %17 : f32

  // CHECK: *[[VAL_5:.*]] = min([[ARG_0:.*]], [[VAL_4]]);
  %19 = arith.minf %arg0, %18 : f32
  return %19 : f32
}

func @test_special_expr(%arg0: i1, %arg1: index, %arg2: index) -> index {

  // CHECK: int [[VAL_0:.*]] = [[ARG_0:.*]] ? [[ARG_1:.*]] : [[ARG_2:.*]];
  %0 = select %arg0, %arg1, %arg2 : i1, index

  // CHECK: int32_t [[VAL_1:.*]] = [[VAL_0:.*]];
  %1 = arith.index_cast %0 : index to i32

  // CHECK: *[[VAL_2:.*]] = [[VAL_0:.*]]
  %2 = arith.index_cast %1 : i32 to index
  return %2 : index
}
