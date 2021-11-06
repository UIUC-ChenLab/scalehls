// REQUIRES: bindings_python
// RUN: pyscalehls.py %s -f test_syrk | FileCheck %s

// CHECK: void test_syrk(
// CHECK: float [[A:.*]][32][32]
// CHECK: float [[C:.*]][32][32]

// CHECK: #pragma HLS array_partition variable=[[A]] cyclic factor=2 dim=2
// CHECK: #pragma HLS array_partition variable=[[C]] cyclic factor=2 dim=2

// CHECK: for (int [[k:.*]] = 0; [[k]] < 32; [[k]] += 1) {
// CHECK-NEXT: for (int [[i:.*]] = 0; [[i]] < 32; [[i]] += 1) {
// CHECK-NEXT: for (int [[j:.*]] = 0; [[j]] < 32; [[j]] += 2) {
// CHECK-NEXT: #pragma HLS pipeline II=3

void test_syrk(float alpha, float beta, float C[32][32], float A[32][32]) {
  for (int i = 0; i < 32; i++) {
    for (int j = 0; j <= i; j++) {
      C[i][j] *= beta;
      for (int k = 0; k < 32; k++) {
        C[i][j] += alpha * A[i][k] * A[j][k];
      }
    }
  }
}
