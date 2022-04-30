
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
#include <string.h>

using namespace std;

void matrix_vector_product_with_bias_output_layer(
  double v0[3],
  double v1[192],
  double v2[3],
  double v3[64],
  double v4[1]
) {	// L2
  for (int v5 = 0; v5 < 2; v5 += 1) {	// L7
    for (int v6 = 0; v6 < 32; v6 += 1) {	// L7
      for (int v7 = 0; v7 < 3; v7 += 1) {	// L7
        v2[v7] = 0.000000;	// L6
        double v8 = v1[(((v7 * 64) + v6) + (v5 * 32))];	// L8
        double v9 = v3[(v6 + (v5 * 32))];	// L9
        double v10 = v8 * v9;	// L10
        double v11 = v2[v7];	// L11
        double v12 = v11 + v10;	// L12
        v2[v7] = v12;	// L13
      }
    }
  }
  v4[0] = 42.424242;	// L16
}

