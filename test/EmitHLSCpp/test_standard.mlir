// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

// CHECK: void test_standard () {
func @test_standard(%arg0: index, %arg1: index) -> (index) {
  
  // CHECK: uint val2 = val0 + val1;
  %0 = addi %arg0, %arg1 : index
  return %0 : index

// CHECK-NEXT: }
}
