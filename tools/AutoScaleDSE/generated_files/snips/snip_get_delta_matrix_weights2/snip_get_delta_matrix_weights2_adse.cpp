
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

void get_delta_matrix_weights2(
  double v0[4096],
  double v1[64],
  double v2[64]
) {	// L2
  for (int v3 = 0; v3 < 32; v3 += 1) {	// L3
    for (int v4 = 0; v4 < 2; v4 += 1) {	// L3
      for (int v5 = 0; v5 < 64; v5 += 1) {	// L3
        double v6 = v2[(v4 + (v3 * 2))];	// L5
        double v7 = v1[v5];	// L6
        double v8 = v6 * v7;	// L7
        v0[((v5 + (v4 * 64)) + (v3 * 128))] = v8;	// L8
      }
    }
  }
}

