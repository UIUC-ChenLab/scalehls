// RUN: scalehls-opt -convert-to-hlscpp="top-function=test_estimator" -qor-estimation="target-spec=../../config/target-spec.ini" %s | FileCheck %s

// CHECK-LABEL: func @test_estimator
func @test_estimator() {
  return
}
