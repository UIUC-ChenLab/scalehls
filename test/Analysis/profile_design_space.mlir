// RUN: scalehls-opt -profile-design-space="target-spec=../../config/target-spec.ini max-parallel=32" %s | FileCheck %s

// CHECK-LABEL: func @test
func @test() {
  return
}
