// RUN: scalehls-opt -scalehls-convert-dataflow-to-func %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
