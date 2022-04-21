
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
  double v3[64],
  double v4[1]
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

  for (int v5 = 0; v5 < 2; v5 += 1) {	// L7
    for (int v6 = 0; v6 < 32; v6 += 1) {	// L7
      int v7 = (v6 + (v5 * 32));	// L7
      for (int v8 = 0; v8 < 3; v8 += 1) {	// L7
        v2[v8] = 0.000000;	// L6
        double v9 = v1[(v7 + (v8 * 64))];	// L8
        double v10 = v3[v7];	// L9
        double v11 = v9 * v10;	// L10
        double v12 = v2[v8];	// L11
        double v13 = v12 + v11;	// L12
        v2[v8] = v13;	// L13
      }
    }
  }
  v4[0] = 42.424242;	// L16
}

