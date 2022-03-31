// RUN: scalehls-opt -scalehls-dataflow-bufferize %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
