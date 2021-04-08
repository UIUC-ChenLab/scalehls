
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
/// Latency=653187358722
/// DSP=8
void trmm_4096(
  float v0,
  float v1[4096][4096],
  float v2[4096][4096]
) {	// L3
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  for (int v3 = 0; v3 < 4096; v3 += 1) {	// L4, S[0,653187358722), latency=159469570
    for (int v4 = 0; v4 < 4096; v4 += 1) {	// L5, S[0,159469570), latency=38933
      for (int v5 = 0; v5 < (v3 + 1); v5 += 1) {	// L6, S[0,38933), latency=19
        float v6 = v1[v3][v5];	// L7, S[0,2)
        float v7 = v2[v5][v4];	// L8, S[0,2)
        float v8 = v2[v3][v4];	// L9, S[4,6)
        float v9 = v6 * v7;	// L10, S[2,6)
        float v10 = v8 + v9;	// L11, S[6,11)
        v2[v3][v4] = v10;	// L12, S[11,12)
      }
      float v11 = v2[v3][v4];	// L14, S[38926,38928)
      float v12 = v0 * v11;	// L15, S[38928,38932)
      v2[v3][v4] = v12;	// L16, S[38932,38933)
    }
  }
}

