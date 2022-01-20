
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

using namespace std;

/// This is top function.
void kernel_3mm(
  float v0[40][60],
  float v1[60][50],
  float v2[50][80],
  float v3[80][70],
  float v4[40][50],
  float v5[50][70],
  float v6[40][70]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4
  #pragma HLS interface bram port=v5
  #pragma HLS interface bram port=v6

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS resource variable=v4 core=ram_s2p_bram

  #pragma HLS resource variable=v5 core=ram_s2p_bram

  #pragma HLS resource variable=v6 core=ram_s2p_bram

  float v7 = 0;	// L4
  for (int v8 = 0; v8 < 60; v8 += 1) {	// L8
    for (int v9 = 0; v9 < 40; v9 += 1) {	// L5
      for (int v10 = 0; v10 < 50; v10 += 1) {	// L6
        if (v8 == 0) {	// L6
          v4[v9][v10] = v7;	// L7
        }
        float v11 = v0[v9][v8];	// L9
        float v12 = v1[v8][v10];	// L10
        float v13 = v11 * v12;	// L11
        float v14 = v4[v9][v10];	// L12
        float v15 = v14 + v13;	// L13
        v4[v9][v10] = v15;	// L14
      }
    }
  }
  for (int v16 = 0; v16 < 80; v16 += 1) {	// L21
    for (int v17 = 0; v17 < 50; v17 += 1) {	// L18
      for (int v18 = 0; v18 < 70; v18 += 1) {	// L19
        if (v16 == 0) {	// L19
          v5[v17][v18] = v7;	// L20
        }
        float v19 = v2[v17][v16];	// L22
        float v20 = v3[v16][v18];	// L23
        float v21 = v19 * v20;	// L24
        float v22 = v5[v17][v18];	// L25
        float v23 = v22 + v21;	// L26
        v5[v17][v18] = v23;	// L27
      }
    }
  }
  for (int v24 = 0; v24 < 50; v24 += 1) {	// L34
    for (int v25 = 0; v25 < 40; v25 += 1) {	// L31
      for (int v26 = 0; v26 < 70; v26 += 1) {	// L32
        if (v24 == 0) {	// L32
          v6[v25][v26] = v7;	// L33
        }
        float v27 = v4[v25][v24];	// L35
        float v28 = v5[v24][v26];	// L36
        float v29 = v27 * v28;	// L37
        float v30 = v6[v25][v26];	// L38
        float v31 = v30 + v29;	// L39
        v6[v25][v26] = v31;	// L40
      }
    }
  }
}

