
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

void soft_max(
  double v0[3],
  double v1[3]
) {	// L2
  for (int v2 = 0; v2 < 3; v2 += 1) {	// L4
    double v3 = v1[v2];	// L5
    double v4 = -(v3);	// L6
    double v5 = exp(v4);	// L7
    double v6 = double v7 + v5;	// L8
  }
  for (int v8 = 0; v8 < 3; v8 += 1) {	// L11
    double v9 = v1[v8];	// L12
    double v10 = -(v9);	// L13
    double v11 = exp(v10);	// L14
    double v12 = v11 / double v13;	// L15
    v0[v8] = v12;	// L16
  }
}

