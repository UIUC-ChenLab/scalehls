// RUN: scalehls-opt -insert-pipeline-pragma %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for() {
  return
}
