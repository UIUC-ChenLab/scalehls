#define NI 40
#define NJ 50
#define NK 60
#define NL 70
#define NM 80

void kernel_3mm(float A[NI][NK], float B[NK][NJ], float C[NJ][NM],
                float D[NM][NL], float E[NI][NJ], float F[NJ][NL],
                float G[NI][NL]) {

  int i, j, k;

#pragma scop

  /* F := C*D */
  for (i = 0; i < NJ; i++) {
    for (j = 0; j < NL; j++) {
      F[i][j] = 0;
      for (k = 0; k < NM; ++k) {
        F[i][j] += C[i][k] * D[k][j];
      }
    }
  }

  /* G := E*F */
  for (i = 0; i < NI; i++) {
    for (j = 0; j < NL; j++) {
      G[i][j] = 0;
      for (k = 0; k < NJ; ++k) {
        G[i][j] += E[i][k] * F[k][j];
      }
    }
  }

#pragma endscop
}