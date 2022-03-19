
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
/// Latency=143, interval=143
/// DSP=40
void updateParameter(
  float v0[1024],
  float v1[1024],
  float v2
) {	// L1, [0,143)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface s_axilite port=v2 bundle=ctrl

  #pragma HLS array_partition variable=v0 cyclic factor=8 dim=1
  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS array_partition variable=v1 cyclic factor=8 dim=1
  #pragma HLS resource variable=v1 core=ram_s2p_bram

  for (int v3 = 0; v3 < 128; v3 += 1) {	// L2, [0,141), iterCycle=12, II=1
    #pragma HLS pipeline II=1
    float v4 = v1[(v3 * 8)];	// L3, [0,2)
    float v5 = v2 * v4;	// L4, [2,6)
    float v6 = v0[(v3 * 8)];	// L5, [4,6)
    float v7 = v6 + v5;	// L6, [6,11)
    v0[(v3 * 8)] = v7;	// L7, [11,12)
    float v8 = v1[((v3 * 8) + 1)];	// L8, [0,2)
    float v9 = v2 * v8;	// L9, [2,6)
    float v10 = v0[((v3 * 8) + 1)];	// L10, [4,6)
    float v11 = v10 + v9;	// L11, [6,11)
    v0[((v3 * 8) + 1)] = v11;	// L12, [11,12)
    float v12 = v1[((v3 * 8) + 2)];	// L13, [0,2)
    float v13 = v2 * v12;	// L14, [2,6)
    float v14 = v0[((v3 * 8) + 2)];	// L15, [4,6)
    float v15 = v14 + v13;	// L16, [6,11)
    v0[((v3 * 8) + 2)] = v15;	// L17, [11,12)
    float v16 = v1[((v3 * 8) + 3)];	// L18, [0,2)
    float v17 = v2 * v16;	// L19, [2,6)
    float v18 = v0[((v3 * 8) + 3)];	// L20, [4,6)
    float v19 = v18 + v17;	// L21, [6,11)
    v0[((v3 * 8) + 3)] = v19;	// L22, [11,12)
    float v20 = v1[((v3 * 8) + 4)];	// L23, [0,2)
    float v21 = v2 * v20;	// L24, [2,6)
    float v22 = v0[((v3 * 8) + 4)];	// L25, [4,6)
    float v23 = v22 + v21;	// L26, [6,11)
    v0[((v3 * 8) + 4)] = v23;	// L27, [11,12)
    float v24 = v1[((v3 * 8) + 5)];	// L28, [0,2)
    float v25 = v2 * v24;	// L29, [2,6)
    float v26 = v0[((v3 * 8) + 5)];	// L30, [4,6)
    float v27 = v26 + v25;	// L31, [6,11)
    v0[((v3 * 8) + 5)] = v27;	// L32, [11,12)
    float v28 = v1[((v3 * 8) + 6)];	// L33, [0,2)
    float v29 = v2 * v28;	// L34, [2,6)
    float v30 = v0[((v3 * 8) + 6)];	// L35, [4,6)
    float v31 = v30 + v29;	// L36, [6,11)
    v0[((v3 * 8) + 6)] = v31;	// L37, [11,12)
    float v32 = v1[((v3 * 8) + 7)];	// L38, [0,2)
    float v33 = v2 * v32;	// L39, [2,6)
    float v34 = v0[((v3 * 8) + 7)];	// L40, [4,6)
    float v35 = v34 + v33;	// L41, [6,11)
    v0[((v3 * 8) + 7)] = v35;	// L42, [11,12)
  }
}

