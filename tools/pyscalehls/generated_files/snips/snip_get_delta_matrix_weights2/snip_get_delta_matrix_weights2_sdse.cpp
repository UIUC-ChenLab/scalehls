
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
/// Latency=266, interval=266
/// DSP=48
void get_delta_matrix_weights2(
  double v0[4096],
  double v1[64],
  double v2[64]
) {	// L1, [0,266)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2

  #pragma HLS array_partition variable=v0 cyclic factor=16 dim=1
  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS array_partition variable=v1 cyclic factor=16 dim=1
  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  for (int v3 = 0; v3 < 64; v3 += 1) {	// L2, [0,264), iterCycle=7, II=1
    for (int v4 = 0; v4 < 4; v4 += 1) {	// L3, [0,12), iterCycle=7, II=1
      #pragma HLS pipeline II=1
      double v5 = v2[v3];	// L4, [0,2)
      double v6 = v1[(v4 * 16)];	// L5, [0,2)
      double v7 = v5 * v6;	// L6, [2,6)
      v0[((v3 * 64) + (v4 * 16))] = v7;	// L7, [6,7)
      double v8 = v1[((v4 * 16) + 1)];	// L8, [0,2)
      double v9 = v5 * v8;	// L9, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 1)] = v9;	// L10, [6,7)
      double v10 = v1[((v4 * 16) + 2)];	// L11, [0,2)
      double v11 = v5 * v10;	// L12, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 2)] = v11;	// L13, [6,7)
      double v12 = v1[((v4 * 16) + 3)];	// L14, [0,2)
      double v13 = v5 * v12;	// L15, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 3)] = v13;	// L16, [6,7)
      double v14 = v1[((v4 * 16) + 4)];	// L17, [0,2)
      double v15 = v5 * v14;	// L18, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 4)] = v15;	// L19, [6,7)
      double v16 = v1[((v4 * 16) + 5)];	// L20, [0,2)
      double v17 = v5 * v16;	// L21, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 5)] = v17;	// L22, [6,7)
      double v18 = v1[((v4 * 16) + 6)];	// L23, [0,2)
      double v19 = v5 * v18;	// L24, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 6)] = v19;	// L25, [6,7)
      double v20 = v1[((v4 * 16) + 7)];	// L26, [0,2)
      double v21 = v5 * v20;	// L27, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 7)] = v21;	// L28, [6,7)
      double v22 = v1[((v4 * 16) + 8)];	// L29, [0,2)
      double v23 = v5 * v22;	// L30, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 8)] = v23;	// L31, [6,7)
      double v24 = v1[((v4 * 16) + 9)];	// L32, [0,2)
      double v25 = v5 * v24;	// L33, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 9)] = v25;	// L34, [6,7)
      double v26 = v1[((v4 * 16) + 10)];	// L35, [0,2)
      double v27 = v5 * v26;	// L36, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 10)] = v27;	// L37, [6,7)
      double v28 = v1[((v4 * 16) + 11)];	// L38, [0,2)
      double v29 = v5 * v28;	// L39, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 11)] = v29;	// L40, [6,7)
      double v30 = v1[((v4 * 16) + 12)];	// L41, [0,2)
      double v31 = v5 * v30;	// L42, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 12)] = v31;	// L43, [6,7)
      double v32 = v1[((v4 * 16) + 13)];	// L44, [0,2)
      double v33 = v5 * v32;	// L45, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 13)] = v33;	// L46, [6,7)
      double v34 = v1[((v4 * 16) + 14)];	// L47, [0,2)
      double v35 = v5 * v34;	// L48, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 14)] = v35;	// L49, [6,7)
      double v36 = v1[((v4 * 16) + 15)];	// L50, [0,2)
      double v37 = v5 * v36;	// L51, [2,6)
      v0[(((v3 * 64) + (v4 * 16)) + 15)] = v37;	// L52, [6,7)
    }
  }
}

