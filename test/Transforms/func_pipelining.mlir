// RUN: scalehls-opt -func-pipelining %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for() {
  return
}
