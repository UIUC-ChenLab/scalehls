// RUN: scalehls-opt -scalehls-func-duplication %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
