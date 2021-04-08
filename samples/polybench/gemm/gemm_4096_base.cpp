
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
/// Latency=1099545190402
/// DSP=8
void gemm_4096(
  float v0,
  float v1,
  float v2[4096][4096],
  float v3[4096][4096],
  float v4[4096][4096]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface s_axilite port=v1 bundle=ctrl
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS resource variable=v4 core=ram_s2p_bram

  for (int v5 = 0; v5 < 4096; v5 += 1) {	// L3, S[0,1099545190402), latency=268443650
    for (int v6 = 0; v6 < 4096; v6 += 1) {	// L4, S[0,268443650), latency=65538
      float v7 = v2[v5][v6];	// L5, S[65523,65525)
      float v8 = v1 * v7;	// L6, S[65525,65529)
      v2[v5][v6] = v8;	// L7, S[65529,65530)
      for (int v9 = 0; v9 < 4096; v9 += 1) {	// L8, S[0,65538), latency=16
        float v10 = v3[v5][v9];	// L9, S[0,2)
        float v11 = v4[v9][v6];	// L10, S[4,6)
        float v12 = v2[v5][v6];	// L11, S[8,10)
        float v13 = v0 * v10;	// L12, S[2,6)
        float v14 = v13 * v11;	// L13, S[6,10)
        float v15 = v12 + v14;	// L14, S[10,15)
        v2[v5][v6] = v15;	// L15, S[15,16)
      }
    }
  }
}

