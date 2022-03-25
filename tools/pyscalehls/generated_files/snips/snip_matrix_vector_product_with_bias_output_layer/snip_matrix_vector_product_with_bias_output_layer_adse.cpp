
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
void matrix_vector_product_with_bias_output_layer(
  double v0[3],
  double v1[192],
  double v2[3],
  double v3[64]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3

  #pragma HLS resource variable=v0 core=ram_1p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  for (int v4 = 0; v4 < 8; v4 += 1) {	// L6
    for (int v5 = 0; v5 < 8; v5 += 1) {	// L6
      int v6 = (v5 + (v4 * 8));	// L6
      for (int v7 = 0; v7 < 3; v7 += 1) {	// L6
        v2[v7] = 0.000000;	// L5
        double v8 = v1[(v6 + (v7 * 64))];	// L7
        double v9 = v3[v6];	// L8
        double v10 = v8 * v9;	// L9
        double v11 = v2[v7];	// L10
        double v12 = v11 + v10;	// L11
        v2[v7] = v12;	// L12
      }
    }
  }
}
