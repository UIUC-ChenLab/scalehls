// RUN: scalehls-opt -simplify-affine-if %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for() {
  return
}
