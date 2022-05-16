// Loop band 0: Loop tiling & pipelining (3,8,2,2)
// Loop band 1: Loop tiling & pipelining (1,5,14,2)
// Loop band 2: Loop tiling & pipelining (1,4,14,2)

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
  /* E := A*B */
  for (i = 0; i < NI; i++) {
    for (j = 0; j < NJ; j++) {
      E[i][j] = 0;
      for (k = 0; k < NK; ++k) {
        E[i][j] += A[i][k] * B[k][j];
      }
    }
  }
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