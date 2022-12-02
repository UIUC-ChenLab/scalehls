// REQUIRES: bindings_python
// RUN: pyscalehls.py %s -f test_syrk | FileCheck %s
// XFAIL: *

// CHECK: void test_syrk(
// CHECK: float [[A:.*]][32][32]
// CHECK: float [[C:.*]][32][32]

// CHECK: #pragma HLS array_partition variable=[[A]] cyclic factor=8 dim=2
// CHECK: #pragma HLS array_partition variable=[[C]] cyclic factor=8 dim=2

// CHECK: for (int [[k:.*]] = 0; [[k]] < 32; [[k]] += 1) {
// CHECK-NEXT: for (int [[i:.*]] = 0; [[i]] < 32; [[i]] += 1) {
// CHECK-NEXT: for (int [[j:.*]] = 0; [[j]] < 4; [[j]] += 1) {
// CHECK-NEXT: #pragma HLS pipeline II=3

#define N 32
void test_syrk(float alpha, float beta, float C[N][N], float A[N][N]) {
#pragma scop
  for (int i = 0; i < N; i++) {
    for (int j = 0; j <= i; j++) {
      C[i][j] *= beta;
      for (int k = 0; k < N; k++) {
        C[i][j] += alpha * A[i][k] * A[j][k];
      }
    }
  }
#pragma endscop
}
