# define size 1000

void FW(float A[size][size],  float B[size][size], float C[size][size]) {

    int i, j, k;

	for (k = 0; k < size; k++) {
		for (i = 0; i < size; i++) {
			for (j = 0; j < size; j++) {
				int newpath = A[i][k] + B[k][j];

				if (newpath < C[i][j]) {
					C[i][j] = newpath;
				}
			}
		}
	}
}