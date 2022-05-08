
//===------------------------------------------------------------*- C++ -*-===//
//
// Automatically generated file for High-level Synthesis (HLS).
//
//===----------------------------------------------------------------------===//

#include <algorithm>
#include <ap_axi_sdata.h>
#include <ap_fixed.h>
#include <ap_int.h>
#include <hls_math.h>
#include <hls_stream.h>
#include <math.h>
#include <stdint.h>
#include <string.h>

using namespace std;

void kernel_3mm(
  float v0[40][60],
  float v1[60][50],
  float v2[50][80],
  float v3[80][70],
  float v4[40][50],
  float v5[50][70],
  float v6[40][70]
) {	// L2
  for (int v7 = 0; v7 < 40; v7 += 1) {	// L4
    for (int v8 = 0; v8 < 50; v8 += 1) {	// L5
      v4[v7][v8] = 0.000000;	// L6
      for (int v9 = 0; v9 < 60; v9 += 1) {	// L7
        float v10 = v0[v7][v9];	// L8
        float v11 = v1[v9][v8];	// L9
        float v12 = v10 * v11;	// L10
        float v13 = v4[v7][v8];	// L11
        float v14 = v13 + v12;	// L12
        v4[v7][v8] = v14;	// L13
      }
    }
  }
  for (int v15 = 0; v15 < 50; v15 += 1) {	// L17
    for (int v16 = 0; v16 < 70; v16 += 1) {	// L18
      v5[v15][v16] = 0.000000;	// L19
      for (int v17 = 0; v17 < 80; v17 += 1) {	// L20
        float v18 = v2[v15][v17];	// L21
        float v19 = v3[v17][v16];	// L22
        float v20 = v18 * v19;	// L23
        float v21 = v5[v15][v16];	// L24
        float v22 = v21 + v20;	// L25
        v5[v15][v16] = v22;	// L26
      }
    }
  }
  for (int v23 = 0; v23 < 40; v23 += 1) {	// L30
    for (int v24 = 0; v24 < 70; v24 += 1) {	// L31
      v6[v23][v24] = 0.000000;	// L32
      for (int v25 = 0; v25 < 50; v25 += 1) {	// L33
        float v26 = v4[v23][v25];	// L34
        float v27 = v5[v25][v24];	// L35
        float v28 = v26 * v27;	// L36
        float v29 = v6[v23][v24];	// L37
        float v30 = v29 + v28;	// L38
        v6[v23][v24] = v30;	// L39
      }
    }
  }
}

