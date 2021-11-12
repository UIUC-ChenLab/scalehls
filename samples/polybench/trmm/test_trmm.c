#define N 32
void test_trmm(float alpha, float A[N][N], float B[N][N]) {
#pragma scop
  for (int i = 0; i < N; i += 1) {
    for (int j = 0; j < N; j += 1) {
      for (int k = 0; k < (i + 1); k += 1) {
        B[i][j] += A[i][k] * B[k][j];
      }
      B[i][j] *= alpha;
    }
  }
#pragma endscop
}
