// RUN: scalehls-opt -materialize-reduction %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
