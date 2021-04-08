
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
/// Latency=402661378
/// DSP=18
void gesummv_4096(
  float v0,
  float v1,
  float v2[4096][4096],
  float v3[4096][4096],
  float v4[4096],
  float v5[4096],
  float v6[4096]
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

  for (int v7 = 0; v7 < 4096; v7 += 1) {	// L3, S[0,402661378), latency=98306
    for (int v8 = 0; v8 < 4096; v8 += 1) {	// L4, S[0,98306), latency=24
      float v9 = v2[v7][v8];	// L5, S[0,2)
      float v10 = v5[v8];	// L6, S[0,2)
      float v11 = v4[v7];	// L7, S[4,6)
      float v12 = v9 * v10;	// L8, S[2,6)
      float v13 = v11 + v12;	// L9, S[6,11)
      v4[v7] = v13;	// L10, S[11,12)
      float v14 = v3[v7][v8];	// L11, S[0,2)
      float v15 = v5[v8];	// L12, S[0,2)
      float v16 = v6[v7];	// L13, S[4,6)
      float v17 = v14 * v15;	// L14, S[2,6)
      float v18 = v16 + v17;	// L15, S[6,11)
      v6[v7] = v18;	// L16, S[11,12)
    }
    float v19 = v4[v7];	// L18, S[98294,98296)
    float v20 = v6[v7];	// L19, S[98294,98296)
    float v21 = v0 * v19;	// L20, S[98296,98300)
    float v22 = v1 * v20;	// L21, S[98296,98300)
    float v23 = v21 + v22;	// L22, S[98300,98305)
    v6[v7] = v23;	// L23, S[98305,98306)
  }
}

