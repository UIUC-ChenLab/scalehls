// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_integer_compare(%arg0: i32, %arg1: i32) -> i1 {

  // CHECK: bool [[VAL_0:.*]] = [[ARG_0:.*]] == [[ARG_1:.*]];
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

func @test_float_compare(%arg0: f32, %arg1: f32) -> i1 {

  // CHECK: bool [[VAL_0:.*]] = [[ARG_0:.*]] == [[ARG_1:.*]];
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
