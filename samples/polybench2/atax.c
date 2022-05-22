# define MEDIUM_DATASET

#  ifdef MINI_DATASET
#   define M 38
#   define N 42
#  endif
#  ifdef SMALL_DATASET
#   define M 116
#   define N 124
#  endif
#  ifdef MEDIUM_DATASET
#   define M 390
#   define N 410
#  endif
#  ifdef LARGE_DATASET
#   define M 1900
#   define N 2100
#  endif
#  ifdef EXTRALARGE_DATASET
#   define M 1800
#   define N 2200
#  endif

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