// REQUIRES: bindings_python
// RUN: pyscalehls.py %s -f test_syrk | FileCheck %s

// CHECK: void test_syrk
// CHECK: float [[A:.*]][16][16]
// CHECK: float [[C:.*]][16][16]
// CHECK: #pragma HLS array_partition variable=[[A]] cyclic factor=2 dim=2

void test_syrk(float alpha, float beta, float A[16][16], float C[16][16]) {
  for (int k = 0; k < 16; k += 2) {
    for (int i = 0; i < 16; i++) {
      for (int j = 0; j < 16; j++) {
        if (i >= j) {
          float partial = C[i][j];
          if (k == 0)
            partial *= beta;
          C[i][j] = partial + alpha * A[i][k] * A[j][k] +
                    alpha * A[i][k + 1] * A[j][k + 1];
        }
      }
    }
  }
}
