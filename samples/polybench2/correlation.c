# include <math.h>

#define MEDIUM_DATASET

#ifdef MINI_DATASET
#define M 28
#define N 32
#endif

#ifdef SMALL_DATASET
#define M 80
#define N 100
#endif

#ifdef MEDIUM_DATASET
#define M 240
#define N 260
#endif

#ifdef LARGE_DATASET
#define M 1200
#define N 1400
#endif

#ifdef EXTRALARGE_DATASET
#define M 2600
#define N 3000
#endif

void kernel_correlation(int m, int n, float float_n, float data[N][M], float corr[M][M],  float mean[M],  float stddev[M]) {
  int i, j, k;

  float eps = 0.1;

#pragma scop
  for (j = 0; j < M; j++) {
    mean[j] = 0;
    for (i = 0; i < N; i++)
      mean[j] += data[i][j];
    mean[j] /= float_n;
  }

  for (j = 0; j < M; j++) {
    stddev[j] = 0;
    for (i = 0; i < N; i++)
      stddev[j] += (data[i][j] - mean[j]) * (data[i][j] - mean[j]);
    stddev[j] /= float_n;
    stddev[j] = sqrtf(stddev[j]);
    /* The following in an inelegant but usual way to handle
       near-zero std. dev. values, which below would cause a zero-
       divide. */
    stddev[j] = stddev[j] <= eps ? 1 : stddev[j];
  }

  /* Center and reduce the column vectors. */
  for (i = 0; i < N; i++)
    for (j = 0; j < M; j++) {
      data[i][j] -= mean[j];
      data[i][j] /= sqrtf(float_n) * stddev[j];
    }

  /* Calculate the m * m correlation matrix. */
  for (i = 0; i < M - 1; i++) {
    corr[i][i] = 1;
    for (j = i + 1; j < M; j++) {
      corr[i][j] = 0;
      for (k = 0; k < N; k++)
        corr[i][j] += (data[k][i] * data[k][j]);
      corr[j][i] = corr[i][j];
    }
  }
  corr[M - 1][M - 1] = 1;
#pragma endscop
}