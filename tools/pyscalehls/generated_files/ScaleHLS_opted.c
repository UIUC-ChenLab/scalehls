
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

  for (int v7 = 0; v7 < 60; v7 += 1) {	// L8
    for (int v8 = 0; v8 < 40; v8 += 1) {	// L5
      for (int v9 = 0; v9 < 50; v9 += 1) {	// L6
        v4[v8][v9] = 0.000000;	// L7
        float v10 = v0[v8][v7];	// L9
        float v11 = v1[v7][v9];	// L10
        float v12 = v10 * v11;	// L11
        float v13 = v4[v8][v9];	// L12
        float v14 = v13 + v12;	// L13
        v4[v8][v9] = v14;	// L14
      }
    }
  }
  for (int v15 = 0; v15 < 80; v15 += 1) {	// L21
    for (int v16 = 0; v16 < 50; v16 += 1) {	// L18
      for (int v17 = 0; v17 < 70; v17 += 1) {	// L19
        v5[v16][v17] = 0.000000;	// L20
        float v18 = v2[v16][v15];	// L22
        float v19 = v3[v15][v17];	// L23
        float v20 = v18 * v19;	// L24
        float v21 = v5[v16][v17];	// L25
        float v22 = v21 + v20;	// L26
        v5[v16][v17] = v22;	// L27
      }
    }
  }
  for (int v23 = 0; v23 < 50; v23 += 1) {	// L34
    for (int v24 = 0; v24 < 40; v24 += 1) {	// L31
      for (int v25 = 0; v25 < 70; v25 += 1) {	// L32
        v6[v24][v25] = 0.000000;	// L33
        float v26 = v4[v24][v23];	// L35
        float v27 = v5[v23][v25];	// L36
        float v28 = v26 * v27;	// L37
        float v29 = v6[v24][v25];	// L38
        float v30 = v29 + v28;	// L39
        v6[v24][v25] = v30;	// L40
      }
    }
  }
}

