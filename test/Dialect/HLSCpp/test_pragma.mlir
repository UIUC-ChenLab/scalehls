// RUN: scalehls-opt -hlscpp-static-analysis -hlscpp-pragma-dse %s | FileCheck %s

// CHECK-LABEL: func @test_pragma()
func @test_pragma() {
  return
}