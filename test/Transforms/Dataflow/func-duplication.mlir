// RUN: scalehls-opt -scalehls-func-duplication %s | FileCheck %s

// CHECK-LABEL: func.func @test
func.func @test() {
  return
}
