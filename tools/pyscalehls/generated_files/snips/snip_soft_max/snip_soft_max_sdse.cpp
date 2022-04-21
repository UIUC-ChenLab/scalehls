
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
/// Latency=69, interval=69
/// DSP=9
void soft_max(
  double v0[3],
  double v1[3]
) {	// L3, [0,69)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  double v2[1];	// L5, [0,0)
  v2[0] = 0.000000;	// L6, [0,1)
  double v3[1];	// L7, [0,0)
  v3[0] = 0.000000;	// L8, [0,1)
  for (int v4 = 0; v4 < 3; v4 += 1) {	// L9, [1,34), iterCycle=17, II=7
    #pragma HLS pipeline II=7
    double v5 = v2[0];	// L10, [10,11)
    double v6 = v1[v4];	// L11, [0,2)
    double v7 = -(v6);	// L12, [2,2)
    double v8 = exp(v7);	// L13, [2,11)
    double v9 = v5 + v8;	// L14, [11,16)
    v2[0] = v9;	// L15, [16,17)
    v3[0] = v9;	// L16, [16,17)
  }
  double v10 = v3[0];	// L18, [34,35)
  for (int v11 = 0; v11 < 3; v11 += 1) {	// L19, [35,67), iterCycle=28, II=1
    #pragma HLS pipeline II=1
    double v12 = v1[v11];	// L20, [0,2)
    double v13 = -(v12);	// L21, [2,2)
    double v14 = exp(v13);	// L22, [2,11)
    double v15 = v14 / v10;	// L23, [11,27)
    v0[v11] = v15;	// L24, [27,28)
  }
}

