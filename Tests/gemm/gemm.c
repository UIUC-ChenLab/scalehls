#define N 64
void test_gemm(float alpha, float beta, float C[N][N], float A[N][N],
               float B[N][N]) {
#pragma scop
  for (int i = 0; i < N; i++) {
    for (int j = 0; j < N; j++) {
      C[i][j] *= beta;
      for (int k = 0; k < N; k++) {
        C[i][j] += alpha * A[i][k] * B[k][j];
      }
    }
  }
#pragma endscop
}
