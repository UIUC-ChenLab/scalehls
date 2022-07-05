// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func.func @test_integer_compare(%arg0: i32, %arg1: i32) -> i1 {

  // CHECK: bool [[VAL_0:.*]] = [[ARG_0:.*]] == [[ARG_1:.*]];
  %0 = arith.cmpi "eq", %arg0, %arg1 : i32
  // CHECK: !=
  %1 = arith.cmpi "ne", %arg0, %arg1 : i32
  // CHECK: <
  %2 = arith.cmpi "slt", %arg0, %arg1 : i32
  // CHECK: <
  %3 = arith.cmpi "ult", %arg0, %arg1 : i32
  // CHECK: <=
  %4 = arith.cmpi "sle", %arg0, %arg1 : i32
  // CHECK: <=
  %5 = arith.cmpi "ule", %arg0, %arg1 : i32
  // CHECK: >
  %6 = arith.cmpi "sgt", %arg0, %arg1 : i32
  // CHECK: >
  %7 = arith.cmpi "ugt", %arg0, %arg1 : i32
  // CHECK: >=
  %8 = arith.cmpi "sge", %arg0, %arg1 : i32
  // CHECK: >=
  %9 = arith.cmpi "uge", %arg0, %arg1 : i32
  return %9 : i1
}

func.func @test_float_compare(%arg0: f32, %arg1: f32) -> i1 {

  // CHECK: bool [[VAL_0:.*]] = [[ARG_0:.*]] == [[ARG_1:.*]];
  %0 = arith.cmpf "oeq", %arg0, %arg1 : f32
  // CHECK: ==
  %1 = arith.cmpf "ueq", %arg0, %arg1 : f32
  // CHECK: !=
  %2 = arith.cmpf "one", %arg0, %arg1 : f32
  // CHECK: !=
  %3 = arith.cmpf "une", %arg0, %arg1 : f32
  // CHECK: <
  %4 = arith.cmpf "olt", %arg0, %arg1 : f32
  // CHECK: <
  %5 = arith.cmpf "ult", %arg0, %arg1 : f32
  // CHECK: <=
  %6 = arith.cmpf "ole", %arg0, %arg1 : f32
  // CHECK: <=
  %7 = arith.cmpf "ule", %arg0, %arg1 : f32
  // CHECK: >
  %8 = arith.cmpf "ogt", %arg0, %arg1 : f32
  // CHECK: >
  %9 = arith.cmpf "ugt", %arg0, %arg1 : f32
  // CHECK: >=
  %10 = arith.cmpf "oge", %arg0, %arg1 : f32
  // CHECK: >=
  %11 = arith.cmpf "uge", %arg0, %arg1 : f32
  return %11 : i1
}
