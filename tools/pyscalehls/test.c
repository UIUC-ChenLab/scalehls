
void FW_core(float C[200][200], float A[200][200], float B[200][200]) {

    int i, j, k;
    float newpath = 0;

    for (k = 0; k < 200; k++) {
        for (i = 0; i < 200; i++) {
            for (j = 0; j < 200; j++) {
                // only when valid path
                if ((A[i][k] != 65535) && (B[k][j] != 65535)){
                    newpath = A[i][k] + B[k][j];

                    if (newpath < C[i][j]) {
                        C[i][j] = newpath;
                    }
                }
            }
        }
    }
}
