
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

void get_delta_matrix_weights1(
  double v0[832],
  double v1[64],
  double v2[13]
) {	// L2
  for (int v3 = 0; v3 < 13; v3 += 1) {	// L3
    for (int v4 = 0; v4 < 64; v4 += 1) {	// L3
      double v5 = v2[v3];	// L5
      double v6 = v1[v4];	// L6
      double v7 = v5 * v6;	// L7
      v0[(v4 + (v3 * 64))] = v7;	// L8
    }
  }
}

