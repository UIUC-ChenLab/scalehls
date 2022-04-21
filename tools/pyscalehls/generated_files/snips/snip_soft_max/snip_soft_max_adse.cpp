
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
void soft_max(
  double v0[3],
  double v1[3]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  double v2[1];	// L4
  v2[0] = 0.000000;	// L5
  double v3[1];	// L6
  v3[0] = 0.000000;	// L7
  for (int v4 = 0; v4 < 3; v4 += 1) {	// L8
    double v5 = v2[0];	// L9
    double v6 = v1[v4];	// L10
    double v7 = -(v6);	// L11
    double v8 = exp(v7);	// L12
    double v9 = v5 + v8;	// L13
    v2[0] = v9;	// L14
    v3[0] = v9;	// L15
  }
  double v10 = v3[0];	// L17
  for (int v11 = 0; v11 < 3; v11 += 1) {	// L18
    double v12 = v1[v11];	// L19
    double v13 = -(v12);	// L20
    double v14 = exp(v13);	// L21
    double v15 = v14 / v10;	// L22
    v0[v11] = v15;	// L23
  }
}

