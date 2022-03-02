#define NQ 20
#define NR 25
#define NP 30

void kernel_doitgen(int nr, int nq, int np, float A[NR][NQ][NP],
                    float C4[NP][NP], float sum[NP]) {
  int r, q, p, s;

  for (r = 0; r < NR; r++) {
    for (q = 0; q < NQ; q++) {
      for (p = 0; p < NP; p++) {
        sum[p] = 0;
        for (s = 0; s < NP; s++) {
          sum[p] += A[r][q][s] * C4[s][p];
        }
      }
    }
  }
}