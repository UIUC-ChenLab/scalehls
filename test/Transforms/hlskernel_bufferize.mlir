// RUN: scalehls-opt -hlskernel-bufferize %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
