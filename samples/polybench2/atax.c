#define M 116
#define N 124

void kernel_atax(float m, float n, float A[M][N], float x[N], float y[N],
                 float tmp[M]) {

  int i, j;

#pragma scop
  for (i = 0; i < N; i++) {
    y[i] = 0;
  }
  for (i = 0; i < M; i++) {
    tmp[i] = 0;
    for (j = 0; j < N; j++) {
      tmp[i] = tmp[i] + A[i][j] * x[j];
    }
    for (j = 0; j < N; j++) {
      y[j] = y[j] + A[i][j] * tmp[i];
    }
  }
#pragma endscop
}