// RUN: scalehls-opt -legalize-dataflow="min-gran=3 insert-copy=true" %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
