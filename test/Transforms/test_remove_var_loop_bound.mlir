// RUN: scalehls-opt -remove-var-loop-bound %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for() {
  return
}
