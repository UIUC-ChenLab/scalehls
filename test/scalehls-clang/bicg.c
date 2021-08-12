// RUN: scalehls-clang %s | scalehls-opt -cse -canonicalize | FileCheck %s

// CHECK: func @bicg(
void bicg(float A[32][32], float s[32], float q[32], float p[32], float r[32]) {
  for (int i = 0; i < 32; i += 1) {
    for (int j = 0; j < 32; j += 1) {
      s[j] += A[i][j] * r[i];
      q[i] += A[i][j] * p[j];
    }
  }
}
