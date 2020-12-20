// RUN: scalehls-opt -qor-estimation="target-spec=../../config/target-spec.ini" %s | FileCheck %s

// CHECK-LABEL: func @test_estimator
func @test_estimator() {
  return
}
