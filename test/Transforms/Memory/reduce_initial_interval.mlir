// RUN: scalehls-opt -scalehls-reduce-initial-interval %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
