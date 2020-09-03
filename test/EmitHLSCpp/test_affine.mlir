// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

#map0 = affine_map<(d0)[s0] -> (d0 + s0, d0, d0 - s0)>

// CHECK:       void test_affine(
// CHECK-NEXT:    ap_int<32> val[[INT1:.*]],
// CHECK-NEXT:    ap_int<32> val[[INT2:.*]][16],
// CHECK-NEXT:    int val[[INT3:.*]]
// CHECK-NEXT:  ) {
func @test_affine(%arg0: i32, %arg1: memref<16xi32>, %arg2: index) -> () {
  %c11 = constant 11 : index
  // CHECK: for (int val[[INT4:.*]] = 0; val[[INT4:.*]] < min(min((val[[INT3:.*]] + 11), val[[INT3:.*]]), (val[[INT3:.*]] + (11 * (-1)))); val[[INT4:.*]] += 1) {
  affine.for %i = 0 to min #map0(%arg2)[%c11] {
    // CHECK: for (int val[[INT5:.*]] = 0; val[[INT5:.*]] < 16; val[[INT5:.*]] += 2) {
    affine.for %j = 0 to 16 step 2 {
      //  ap_int<32> val[[INT6:.*]] = val[[INT2:.*]][val[[INT4:.*]]];
      %0 = load %arg1[%i] : memref<16xi32>
      // CHECK: ap_int<32> val[[INT7:.*]] = val[[INT1:.*]] + val[[INT6:.*]];
      %1 = addi %arg0, %0 : i32
      // CHECK: val[[INT2:.*]][val[[INT5:.*]]] = val[[INT7:.*]];
      store %1, %arg1[%j] : memref<16xi32>
    // CHECK: }
    }
  // CHECK: }
  }
  return
// CHECK: }
}
