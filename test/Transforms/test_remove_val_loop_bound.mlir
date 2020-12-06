// RUN: scalehls-opt -remove-val-loop-bound %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for() {
  return
}
