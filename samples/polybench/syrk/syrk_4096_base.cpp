
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
/// Latency=550041042946
/// DSP=8
void syrk_4096(
  float v0,
  float v1,
  float v2[4096][4096],
  float v3[4096][4096]
) {	// L3
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface s_axilite port=v1 bundle=ctrl
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  for (int v4 = 0; v4 < 4096; v4 += 1) {	// L4, S[0,550041042946), latency=134287364
    for (int v5 = 0; v5 < (v4 + 1); v5 += 1) {	// L5, S[0,134287364), latency=65538
      float v6 = v2[v4][v5];	// L6, S[65523,65525)
      float v7 = v1 * v6;	// L7, S[65525,65529)
      v2[v4][v5] = v7;	// L8, S[65529,65530)
      for (int v8 = 0; v8 < 4096; v8 += 1) {	// L9, S[0,65538), latency=16
        float v9 = v3[v4][v8];	// L10, S[0,2)
        float v10 = v3[v5][v8];	// L11, S[4,6)
        float v11 = v2[v4][v5];	// L12, S[8,10)
        float v12 = v0 * v9;	// L13, S[2,6)
        float v13 = v12 * v10;	// L14, S[6,10)
        float v14 = v11 + v13;	// L15, S[10,15)
        v2[v4][v5] = v14;	// L16, S[15,16)
      }
    }
  }
}

