void kernel_3mm(float A[40][60], float B[60][50], float C[50][80],
                float D[80][70], float E[40][50], float F[50][70],
                float G[40][70]) {

  int i, j, k;

#pragma scop
  /* E := A*B */
  for (i = 0; i < 40; i++) {
    for (j = 0; j < 50; j++) {
      E[i][j] = 0;
      for (k = 0; k < 60; ++k) {
        E[i][j] += A[i][k] * B[k][j];
      }
    }
  }
  /* F := C*D */
  for (i = 0; i < 50; i++) {
    for (j = 0; j < 70; j++) {
      F[i][j] = 0;
      for (k = 0; k < 80; ++k) {
        F[i][j] += C[i][k] * D[k][j];
      }
    }
  }
  /* G := E*F */
  for (i = 0; i < 40; i++) {
    for (j = 0; j < 70; j++) {
      G[i][j] = 0;
      for (k = 0; k < 50; ++k) {
        G[i][j] += E[i][k] * F[k][j];
      }
    }
  }
#pragma endscop
}
