
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
void kernel_2mm(
  float v0,
  float v1,
  float v2[64][64],
  float v3[64][64],
  float v4[64][64],
  float v5[64][64],
  float v6[64][64]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface s_axilite port=v1 bundle=ctrl
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4
  #pragma HLS interface bram port=v5
  #pragma HLS interface bram port=v6

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS resource variable=v4 core=ram_s2p_bram

  #pragma HLS resource variable=v5 core=ram_s2p_bram

  #pragma HLS resource variable=v6 core=ram_s2p_bram

  float v7 = 0;	// L4
  for (int v8 = 0; v8 < 64; v8 += 1) {	// L8
    for (int v9 = 0; v9 < 64; v9 += 1) {	// L5
      for (int v10 = 0; v10 < 64; v10 += 1) {	// L6
        if (v8 == 0) {	// L6
          v2[v9][v10] = v7;	// L7
        }
        float v11 = v3[v9][v8];	// L9
        float v12 = v0 * v11;	// L10
        float v13 = v4[v8][v10];	// L11
        float v14 = v12 * v13;	// L12
        float v15 = v2[v9][v10];	// L13
        float v16 = v15 + v14;	// L14
        v2[v9][v10] = v16;	// L15
      }
    }
  }
  for (int v17 = 0; v17 < 64; v17 += 1) {	// L24
    for (int v18 = 0; v18 < 64; v18 += 1) {	// L19
      for (int v19 = 0; v19 < 64; v19 += 1) {	// L20
        float v20 = v6[v18][v19];	// L21
        float v21 = v20 * v1;	// L22
        if (v17 == 0) {	// L20
          v6[v18][v19] = v21;	// L23
        }
        float v22 = v2[v18][v17];	// L25
        float v23 = v5[v17][v19];	// L26
        float v24 = v22 * v23;	// L27
        float v25 = v6[v18][v19];	// L28
        float v26 = v25 + v24;	// L29
        v6[v18][v19] = v26;	// L30
      }
    }
  }
}

