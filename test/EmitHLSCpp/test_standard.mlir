// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

// CHECK: void test_standard () {
func @test_standard(%arg0: i32, %arg1: i32) -> (i32) {
  
  // CHECK: ap_int<32> val2 = val0 + val1;
  %0 = addi %arg0, %arg1 : i32
  return %0 : i32

// CHECK-NEXT: }
}
