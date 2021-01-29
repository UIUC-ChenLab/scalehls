// RUN: scalehls-opt -redundant-op-removal %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for() {
  return
}
