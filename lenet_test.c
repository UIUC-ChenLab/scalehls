
// void test_syr2k0(float alpha, float beta, float C[32][32], float A[32][32],
//                  float B[32][32]) {
//     for (int i = 0; i < 32; i += 1) {
//         for (int j = 0; j < (i + 1); j += 1) {
//             C[i][j] *= beta;
//             for (int k = 0; k < 32; k += 1) {
//                 float tmp = A[i][k] * B[j][k] + B[i][k] * A[j][k];
//                 C[i][j] += alpha * tmp;
//             }
//         }
//     }
// }

// void test_syr2k1(float alpha, float beta, float C[32][32], float A[32][32],
//                  float B[32][32]) {
//     for (int i = 0; i < 32; i += 1) {
//         for (int j = 0; j < (i + 1); j += 1) {
//             C[i][j] *= beta;
//             for (int k = 0; k < 32; k += 1) {
//                 float tmp = A[i][k] * B[j][k] + B[i][k] * A[j][k];
//                 C[i][j] += alpha * tmp;
//             }
//         }
//     }
// }

void testing(void) {
    float alpha = 1;
    float beta = 1;

    float A[32][32];
    float B[32][32];
    float C0[32][32];
    float C1[32][32];

    int i, j, k;
    for (i = 0; i < 32; i++) {
        for (j = 0; i < 32; i++) {
            A[i][j] = 1;
            B[i][j] = 2;
            C0[i][j] = 3;
            C1[i][j] = 3;
        }
    }

    //test_syr2k0(alpha, beta, C0, A, B);
    // test_syr2k1(alpha, beta, C1, A, B);

    float sum0 = 0, sum1 = 0;
    for (i = 0; i < 32; i++) {
        for (j = 0; i < 32; i++) {
            sum0 += C0[i][j];
            sum1 += C1[i][j];
        }
    }

}