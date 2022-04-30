
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

void take_difference(
  double v0[3],
  double v1[3],
  double v2[3],
  double v3[3]
) {	// L2
  for (int v4 = 0; v4 < 3; v4 += 1) {	// L4
    double v5 = v0[v4];	// L5
    double v6 = v1[v4];	// L6
    double v7 = v5 - v6;	// L7
    double v8 = v7 * -1.000000;	// L8
    double v9 = v3[v4];	// L9
    double v10 = v8 * v9;	// L10
    v2[v4] = v10;	// L11
  }
}

