// RUN: scalehls-opt -multiple-level-dse %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for() {
  return
}
