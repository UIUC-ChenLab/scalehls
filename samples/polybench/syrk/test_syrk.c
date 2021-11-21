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
