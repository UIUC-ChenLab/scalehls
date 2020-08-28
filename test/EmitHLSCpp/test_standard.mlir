// RUN: hlsld-translate -emit-hlscpp %s | FileCheck %s

// CHECK: void test_standard (
// CHECK: ) {
func @test_standard() {
  
  // CHECK: new op:std.constant;
  %c1 = constant 1 : index
  return
// CHECK: }
}