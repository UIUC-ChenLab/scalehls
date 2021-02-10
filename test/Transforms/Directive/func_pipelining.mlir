// RUN: scalehls-opt -func-pipelining="target-func=test" %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
