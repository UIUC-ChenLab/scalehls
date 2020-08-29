// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

// CHECK:       void test_standard(
// CHECK-NEXT:    ap_int<32> val1,
// CHECK-NEXT:    ap_int<32> val2,
// CHECK-NEXT:    ap_int<32> *val3
// CHECK-NEXT:  ) {
func @test_standard(%arg0: i32, %arg1: i32) -> (i32) {
  
  // CHECK: *val3 = val1 + val2;
  %0 = addi %arg0, %arg1 : i32
  return %0 : i32

// CHECK: }
}
