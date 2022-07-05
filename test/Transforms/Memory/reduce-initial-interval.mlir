// RUN: scalehls-opt -scalehls-reduce-initial-interval %s | FileCheck %s

// CHECK-LABEL: func.func @test
func.func @test() {
  return
}
