
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
void dotProduct(
  float v0[1024],
  float v1[1024],
  float *v2
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface s_axilite port=v2 bundle=ctrl

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  float v3[1];	// L4
  v3[0] = 0.000000;	// L5
  float v4[1];	// L6
  v4[0] = 0.000000;	// L7
  for (int v5 = 0; v5 < 16; v5 += 1) {	// L8
    for (int v6 = 0; v6 < 64; v6 += 1) {	// L8
      int v7 = (v6 + (v5 * 64));	// L8
      float v8 = v3[0];	// L9
      float v9 = v0[v7];	// L10
      float v10 = v1[v7];	// L11
      float v11 = v9 * v10;	// L12
      float v12 = v8 + v11;	// L13
      v3[0] = v12;	// L14
      v4[0] = v12;	// L15
    }
  }
  *v2 = v4[0];	// L17
}

