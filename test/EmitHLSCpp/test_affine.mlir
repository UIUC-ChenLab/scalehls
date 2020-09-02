// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

/// Test function signature.
// CHECK:       void test_standard(
// CHECK-NEXT:    ap_int<32> [[VAL_1:.*]],
// CHECK-NEXT:    ap_int<32> [[VAL_2:.*]][16]
// CHECK-NEXT:  ) {
func @test_standard(%val1: i32, %val2: memref<16xi32>) -> () {
  affine.for %i = 0 to 16 {
    affine.for %j = 0 to 16 step 2 {
      %val3 = load %val2[%i] : memref<16xi32>
      %val4 = addi %val1, %val3 : i32
      store %val4, %val2[%j] : memref<16xi32>
    }
  }
  return
// CHECK: }
}
