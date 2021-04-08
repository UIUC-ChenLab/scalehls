
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
/// Latency=201334786
/// DSP=10
void bicg_4096(
  float v0[4096][4096],
  float v1[4096],
  float v2[4096],
  float v3[4096],
  float v4[4096]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS resource variable=v4 core=ram_s2p_bram

  for (int v5 = 0; v5 < 4096; v5 += 1) {	// L3, S[0,201334786), latency=49154
    for (int v6 = 0; v6 < 4096; v6 += 1) {	// L4, S[0,49154), latency=12
      float v7 = v1[v6];	// L5, S[4,6)
      float v8 = v4[v5];	// L6, S[0,2)
      float v9 = v0[v5][v6];	// L7, S[0,2)
      float v10 = v8 * v9;	// L8, S[2,6)
      float v11 = v7 + v10;	// L9, S[6,11)
      v1[v6] = v11;	// L10, S[11,12)
      float v12 = v2[v5];	// L11, S[4,6)
      float v13 = v3[v6];	// L12, S[0,2)
      float v14 = v9 * v13;	// L13, S[2,6)
      float v15 = v12 + v14;	// L14, S[6,11)
      v2[v5] = v15;	// L15, S[11,12)
    }
  }
}

