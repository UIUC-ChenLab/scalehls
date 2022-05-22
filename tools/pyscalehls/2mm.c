

void kernel_2mm(float alpha, 
                float tmp[40][50], 
                float A[40][70], 
                float B[70][50], 
                float C[50][80], 
                float D[40][80]) {

  int i, j, k;
  for (i = 0; i < 40; i++) {
    for (j = 0; j < 50; j++) {
      tmp[i][j] = 0;
      for (k = 0; k < 70; ++k) {
        tmp[i][j] += alpha * A[i][k] * B[k][j];
      }
    }
  }
}





