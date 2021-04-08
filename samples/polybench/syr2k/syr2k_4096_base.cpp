
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
/// Latency=756300136450
/// DSP=11
void syr2k_4096(
  float v0,
  float v1,
  float v2[4096][4096],
  float v3[4096][4096],
  float v4[4096][4096]
) {	// L3
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface s_axilite port=v1 bundle=ctrl
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS resource variable=v4 core=ram_s2p_bram

  for (int v5 = 0; v5 < 4096; v5 += 1) {	// L4, S[0,756300136450), latency=184643588
    for (int v6 = 0; v6 < (v5 + 1); v6 += 1) {	// L5, S[0,184643588), latency=90114
      float v7 = v2[v5][v6];	// L6, S[90099,90101)
      float v8 = v1 * v7;	// L7, S[90101,90105)
      v2[v5][v6] = v8;	// L8, S[90105,90106)
      for (int v9 = 0; v9 < 4096; v9 += 1) {	// L9, S[0,90114), latency=22
        float v10 = v3[v5][v9];	// L10, S[0,2)
        float v11 = v4[v6][v9];	// L11, S[0,2)
        float v12 = v4[v5][v9];	// L12, S[1,3)
        float v13 = v3[v6][v9];	// L13, S[1,3)
        float v14 = v2[v5][v6];	// L14, S[14,16)
        float v15 = v10 * v11;	// L15, S[3,7)
        float v16 = v12 * v13;	// L16, S[3,7)
        float v17 = v15 + v16;	// L17, S[7,12)
        float v18 = v0 * v17;	// L18, S[12,16)
        float v19 = v14 + v18;	// L19, S[16,21)
        v2[v5][v6] = v19;	// L20, S[21,22)
      }
    }
  }
}

