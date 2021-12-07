void syr2k_32(float alpha, float beta, float C[32][32], float A[32][32],
              float B[32][32]) {
    for (int i = 0; i < 32; i += 1) {
        for (int j = 0; j < (i + 1); j += 1) {
            C[i][j] *= beta;
            for (int k = 0; k < 32; k += 1) {
                float tmp = A[i][k] * B[j][k] + B[i][k] * A[j][k];
                C[i][j] += alpha * tmp;
            }
        }
    }
}
