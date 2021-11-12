#define N 32
void test_bicg(float A[N][N], float s[N], float q[N], float p[N], float r[N]) {
#pragma scop
  for (int i = 0; i < N; i += 1) {
    for (int j = 0; j < N; j += 1) {
      s[j] += A[i][j] * r[i];
      q[i] += A[i][j] * p[j];
    }
  }
#pragma endscop
}
