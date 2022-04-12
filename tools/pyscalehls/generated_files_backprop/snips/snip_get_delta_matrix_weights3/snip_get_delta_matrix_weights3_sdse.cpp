
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
/// Latency=18, interval=18
/// DSP=72
void get_delta_matrix_weights3(
  double v0[192],
  double v1[3],
  double v2[64]
) {	// L5, [0,18)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v2

  #pragma HLS array_partition variable=v0 cyclic factor=24 dim=1
  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS array_partition variable=v1 cyclic factor=3 dim=1

  #pragma HLS array_partition variable=v2 cyclic factor=8 dim=1
  #pragma HLS resource variable=v2 core=ram_s2p_bram

  for (int v3 = 0; v3 < 8; v3 += 1) {	// L6, [0,16), iterCycle=7, II=1
    #pragma HLS pipeline II=1
    double v4 = v2[(v3 * 8)];	// L7, [0,2)
    double v5 = v1[0];	// L8, [0,2)
    double v6 = v4 * v5;	// L9, [2,6)
    v0[(v3 * 24)] = v6;	// L10, [6,7)
    double v7 = v1[1];	// L11, [0,2)
    double v8 = v4 * v7;	// L12, [2,6)
    v0[((v3 * 24) + 1)] = v8;	// L13, [6,7)
    double v9 = v1[2];	// L14, [0,2)
    double v10 = v4 * v9;	// L15, [2,6)
    v0[((v3 * 24) + 2)] = v10;	// L16, [6,7)
    double v11 = v2[((v3 * 8) + 1)];	// L17, [0,2)
    double v12 = v11 * v5;	// L18, [2,6)
    v0[((v3 * 24) + 3)] = v12;	// L19, [6,7)
    double v13 = v11 * v7;	// L20, [2,6)
    v0[((v3 * 24) + 4)] = v13;	// L21, [6,7)
    double v14 = v11 * v9;	// L22, [2,6)
    v0[((v3 * 24) + 5)] = v14;	// L23, [6,7)
    double v15 = v2[((v3 * 8) + 2)];	// L24, [0,2)
    double v16 = v15 * v5;	// L25, [2,6)
    v0[((v3 * 24) + 6)] = v16;	// L26, [6,7)
    double v17 = v15 * v7;	// L27, [2,6)
    v0[((v3 * 24) + 7)] = v17;	// L28, [6,7)
    double v18 = v15 * v9;	// L29, [2,6)
    v0[((v3 * 24) + 8)] = v18;	// L30, [6,7)
    double v19 = v2[((v3 * 8) + 3)];	// L31, [0,2)
    double v20 = v19 * v5;	// L32, [2,6)
    v0[((v3 * 24) + 9)] = v20;	// L33, [6,7)
    double v21 = v19 * v7;	// L34, [2,6)
    v0[((v3 * 24) + 10)] = v21;	// L35, [6,7)
    double v22 = v19 * v9;	// L36, [2,6)
    v0[((v3 * 24) + 11)] = v22;	// L37, [6,7)
    double v23 = v2[((v3 * 8) + 4)];	// L38, [0,2)
    double v24 = v23 * v5;	// L39, [2,6)
    v0[((v3 * 24) + 12)] = v24;	// L40, [6,7)
    double v25 = v23 * v7;	// L41, [2,6)
    v0[((v3 * 24) + 13)] = v25;	// L42, [6,7)
    double v26 = v23 * v9;	// L43, [2,6)
    v0[((v3 * 24) + 14)] = v26;	// L44, [6,7)
    double v27 = v2[((v3 * 8) + 5)];	// L45, [0,2)
    double v28 = v27 * v5;	// L46, [2,6)
    v0[((v3 * 24) + 15)] = v28;	// L47, [6,7)
    double v29 = v27 * v7;	// L48, [2,6)
    v0[((v3 * 24) + 16)] = v29;	// L49, [6,7)
    double v30 = v27 * v9;	// L50, [2,6)
    v0[((v3 * 24) + 17)] = v30;	// L51, [6,7)
    double v31 = v2[((v3 * 8) + 6)];	// L52, [0,2)
    double v32 = v31 * v5;	// L53, [2,6)
    v0[((v3 * 24) + 18)] = v32;	// L54, [6,7)
    double v33 = v31 * v7;	// L55, [2,6)
    v0[((v3 * 24) + 19)] = v33;	// L56, [6,7)
    double v34 = v31 * v9;	// L57, [2,6)
    v0[((v3 * 24) + 20)] = v34;	// L58, [6,7)
    double v35 = v2[((v3 * 8) + 7)];	// L59, [0,2)
    double v36 = v35 * v5;	// L60, [2,6)
    v0[((v3 * 24) + 21)] = v36;	// L61, [6,7)
    double v37 = v35 * v7;	// L62, [2,6)
    v0[((v3 * 24) + 22)] = v37;	// L63, [6,7)
    double v38 = v35 * v9;	// L64, [2,6)
    v0[((v3 * 24) + 23)] = v38;	// L65, [6,7)
  }
}

