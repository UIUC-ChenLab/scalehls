#define N 32
void test_syr2k(float alpha, float beta, float C[N][N], float A[N][N],
                float B[N][N]) {
#pragma scop
  for (int i = 0; i < N; i += 1) {
    for (int j = 0; j < (i + 1); j += 1) {
      C[i][j] *= beta;
      for (int k = 0; k < N; k += 1) {
        float tmp = A[i][k] * B[j][k] + B[i][k] * A[j][k];
        C[i][j] += alpha * tmp;
      }
    }
  }
#pragma endscop
}
