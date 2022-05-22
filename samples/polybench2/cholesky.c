# include <math.h>

#define MEDIUM_DATASET

#ifdef MINI_DATASET
#define N 40
#endif

#ifdef SMALL_DATASET
#define N 120
#endif

#ifdef MEDIUM_DATASET
#define N 400
#endif

#ifdef LARGE_DATASET
#define N 2000
#endif

#ifdef EXTRALARGE_DATASET
#define N 4000
#endif

void kernel_cholesky(int n, float A[N][N]) {
  int i, j, k;

#pragma scop
  for (i = 0; i < N; i++) {
    // j<i
    for (j = 0; j < i; j++) {
      for (k = 0; k < j; k++) {
        A[i][j] -= A[i][k] * A[j][k];
      }
      A[i][j] /= A[j][j];
    }
    // i==j case
    for (k = 0; k < i; k++) {
      A[i][i] -= A[i][k] * A[i][k];
    }
    A[i][i] = sqrtf(A[i][i]);
  }
#pragma endscop
}