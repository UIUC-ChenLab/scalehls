void trmm_32(float alpha, float A[32][32], float B[32][32]) {
#pragma scop
  for (int i = 0; i < 32; i += 1) {
    for (int j = 0; j < 32; j += 1) {
      for (int k = 0; k < (i + 1); k += 1) {
        B[i][j] += A[i][k] * B[k][j];
      }
      B[i][j] *= alpha;
    }
  }
#pragma endscop
}
