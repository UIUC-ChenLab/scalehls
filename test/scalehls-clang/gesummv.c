// RUN: scalehls-clang %s | FileCheck %s

// CHECK: func @gesummv(
void gesummv(float alpha, float beta, float A[32][32], float B[32][32],
             float tmp[32], float x[32], float y[32]) {
  for (int i = 0; i < 32; i += 1) {
    for (int j = 0; j < 32; j += 1) {
      tmp[i] += A[i][j] * x[j];
      y[i] += B[i][j] * x[j];
    }
    y[i] = alpha * tmp[i] + beta * y[i];
  }
}
