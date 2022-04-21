
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
void get_delta_matrix_weights3(
  double v0[192],
  double v1[3],
  double v2[64]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  for (int v3 = 0; v3 < 8; v3 += 1) {	// L3
    for (int v4 = 0; v4 < 8; v4 += 1) {	// L3
      int v5 = (v4 + (v3 * 8));	// L3
      for (int v6 = 0; v6 < 3; v6 += 1) {	// L3
        double v7 = v2[v5];	// L5
        double v8 = v1[v6];	// L6
        double v9 = v7 * v8;	// L7
        v0[(v6 + (v5 * 3))] = v9;	// L8
      }
    }
  }
}

