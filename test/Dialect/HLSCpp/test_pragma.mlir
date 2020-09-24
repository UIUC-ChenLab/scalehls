// RUN: scalehls-opt -qor-estimation -pragma-dse %s | FileCheck %s

// CHECK-LABEL: func @test_pragma()
func @test_pragma() {
  return
}
