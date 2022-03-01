#define N 120

void kernel_mvt(int n, float x1[N], float x2[N], float y_1[N], float y_2[N],
                float A[N][N]) {
                  
  int i, j;

#pragma scop
  for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
      x1[i] = x1[i] + A[i][j] * y_1[j];

  for (i = 0; i < N; i++)
    for (j = 0; j < N; j++)
      x2[i] = x2[i] + A[j][i] * y_2[j];
#pragma endscop
}