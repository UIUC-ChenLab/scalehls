#define N 32
void test_gesummv(float alpha, float beta, float A[N][N], float B[N][N],
                  float tmp[N], float x[N], float y[N]) {
#pragma scop
  for (int i = 0; i < N; i += 1) {
    for (int j = 0; j < N; j += 1) {
      tmp[i] += A[i][j] * x[j];
      y[i] += B[i][j] * x[j];
    }
    y[i] = alpha * tmp[i] + beta * y[i];
  }
#pragma endscop
}
