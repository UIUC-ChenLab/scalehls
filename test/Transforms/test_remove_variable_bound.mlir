// RUN: scalehls-opt -remove-variable-bound %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for() {
  return
}
