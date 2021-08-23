void gemm_32(float alpha, float beta, float C[32][32], float A[32][32],
             float B[32][32]) {
#pragma scop
  for (int i = 0; i < 32; i++) {
    for (int j = 0; j < 32; j++) {
      C[i][j] *= beta;
      for (int k = 0; k < 32; k++) {
        C[i][j] += alpha * A[i][k] * B[k][j];
      }
    }
  }
#pragma endscop
}
