
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
/// Latency=138, interval=138
/// DSP=24
void computeGradient(
  float v0[1024],
  float v1[1024],
  float v2
) {	// L1, [0,138)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface s_axilite port=v2 bundle=ctrl

  #pragma HLS array_partition variable=v0 cyclic factor=8 dim=1
  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS array_partition variable=v1 cyclic factor=8 dim=1
  #pragma HLS resource variable=v1 core=ram_s2p_bram

  for (int v3 = 0; v3 < 128; v3 += 1) {	// L2, [0,136), iterCycle=7, II=1
    #pragma HLS pipeline II=1
    float v4 = v1[(v3 * 8)];	// L3, [0,2)
    float v5 = v2 * v4;	// L4, [2,6)
    v0[(v3 * 8)] = v5;	// L5, [6,7)
    float v6 = v1[((v3 * 8) + 1)];	// L6, [0,2)
    float v7 = v2 * v6;	// L7, [2,6)
    v0[((v3 * 8) + 1)] = v7;	// L8, [6,7)
    float v8 = v1[((v3 * 8) + 2)];	// L9, [0,2)
    float v9 = v2 * v8;	// L10, [2,6)
    v0[((v3 * 8) + 2)] = v9;	// L11, [6,7)
    float v10 = v1[((v3 * 8) + 3)];	// L12, [0,2)
    float v11 = v2 * v10;	// L13, [2,6)
    v0[((v3 * 8) + 3)] = v11;	// L14, [6,7)
    float v12 = v1[((v3 * 8) + 4)];	// L15, [0,2)
    float v13 = v2 * v12;	// L16, [2,6)
    v0[((v3 * 8) + 4)] = v13;	// L17, [6,7)
    float v14 = v1[((v3 * 8) + 5)];	// L18, [0,2)
    float v15 = v2 * v14;	// L19, [2,6)
    v0[((v3 * 8) + 5)] = v15;	// L20, [6,7)
    float v16 = v1[((v3 * 8) + 6)];	// L21, [0,2)
    float v17 = v2 * v16;	// L22, [2,6)
    v0[((v3 * 8) + 6)] = v17;	// L23, [6,7)
    float v18 = v1[((v3 * 8) + 7)];	// L24, [0,2)
    float v19 = v2 * v18;	// L25, [2,6)
    v0[((v3 * 8) + 7)] = v19;	// L26, [6,7)
  }
}

