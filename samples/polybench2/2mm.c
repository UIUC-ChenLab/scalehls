#define NI 64
#define NJ 64
#define NK 64
#define NL 64

void kernel_2mm(float alpha, float beta, float tmp[NI][NJ], float A[NI][NK],
                float B[NK][NJ], float C[NL][NJ], float D[NI][NL]) {
  int i, j, k;

#pragma scop
  /* D := alpha*A*B*C + beta*D */
  for (i = 0; i < NI; i++)
    for (j = 0; j < NJ; j++) {
      tmp[i][j] = 0;
      for (k = 0; k < NK; ++k)
        tmp[i][j] += alpha * A[i][k] * B[k][j];
    }
  for (i = 0; i < NI; i++)
    for (j = 0; j < NL; j++) {
      D[i][j] *= beta;
      for (k = 0; k < NJ; ++k)
        D[i][j] += tmp[i][k] * C[k][j];
    }
#pragma endscop
}