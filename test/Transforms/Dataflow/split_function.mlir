// RUN: scalehls-opt -split-function %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
