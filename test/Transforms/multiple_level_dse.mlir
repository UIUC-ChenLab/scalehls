// RUN: scalehls-opt -multiple-level-dse %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
