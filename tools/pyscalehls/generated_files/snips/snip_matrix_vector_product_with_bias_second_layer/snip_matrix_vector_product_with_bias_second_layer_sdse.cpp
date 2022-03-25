
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
/// Latency=562, interval=562
/// DSP=40
void matrix_vector_product_with_bias_second_layer(
  double v0[64],
  double v1[4096],
  double v2[64],
  double v3[64]
) {	// L1, [0,562)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3

  #pragma HLS resource variable=v0 core=ram_1p_bram

  #pragma HLS array_partition variable=v1 cyclic factor=8 dim=1
  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS array_partition variable=v3 cyclic factor=8 dim=1
  #pragma HLS resource variable=v3 core=ram_s2p_bram

  for (int v4 = 0; v4 < 8; v4 += 1) {	// L3, [0,560), iterCycle=47, II=1
    for (int v5 = 0; v5 < 64; v5 += 1) {	// L4, [0,112), iterCycle=47, II=1
      #pragma HLS pipeline II=1
      double v6 = v1[((v5 * 64) + (v4 * 8))];	// L5, [0,2)
      double v7 = v3[(v4 * 8)];	// L6, [0,2)
      double v8 = v6 * v7;	// L7, [2,6)
      double v9 = v2[v5];	// L8, [4,6)
      double v10;
      if ((v4 * 8) == 0) {	// L9, [6,6)
        v10 = 0.000000;	// L10, [6,6)
      } else {
        v10 = v9;	// L12, [6,6)
      }
      double v11 = v10 + v8;	// L14, [6,11)
      double v12 = v1[(((v5 * 64) + (v4 * 8)) + 1)];	// L15, [5,7)
      double v13 = v3[((v4 * 8) + 1)];	// L16, [5,7)
      double v14 = v12 * v13;	// L17, [7,11)
      double v15 = v11 + v14;	// L18, [11,16)
      double v16 = v1[(((v5 * 64) + (v4 * 8)) + 2)];	// L19, [10,12)
      double v17 = v3[((v4 * 8) + 2)];	// L20, [10,12)
      double v18 = v16 * v17;	// L21, [12,16)
      double v19 = v15 + v18;	// L22, [16,21)
      double v20 = v1[(((v5 * 64) + (v4 * 8)) + 3)];	// L23, [15,17)
      double v21 = v3[((v4 * 8) + 3)];	// L24, [15,17)
      double v22 = v20 * v21;	// L25, [17,21)
      double v23 = v19 + v22;	// L26, [21,26)
      double v24 = v1[(((v5 * 64) + (v4 * 8)) + 4)];	// L27, [20,22)
      double v25 = v3[((v4 * 8) + 4)];	// L28, [20,22)
      double v26 = v24 * v25;	// L29, [22,26)
      double v27 = v23 + v26;	// L30, [26,31)
      double v28 = v1[(((v5 * 64) + (v4 * 8)) + 5)];	// L31, [25,27)
      double v29 = v3[((v4 * 8) + 5)];	// L32, [25,27)
      double v30 = v28 * v29;	// L33, [27,31)
      double v31 = v27 + v30;	// L34, [31,36)
      double v32 = v1[(((v5 * 64) + (v4 * 8)) + 6)];	// L35, [30,32)
      double v33 = v3[((v4 * 8) + 6)];	// L36, [30,32)
      double v34 = v32 * v33;	// L37, [32,36)
      double v35 = v31 + v34;	// L38, [36,41)
      double v36 = v1[(((v5 * 64) + (v4 * 8)) + 7)];	// L39, [35,37)
      double v37 = v3[((v4 * 8) + 7)];	// L40, [35,37)
      double v38 = v36 * v37;	// L41, [37,41)
      double v39 = v35 + v38;	// L42, [41,46)
      v2[v5] = v39;	// L43, [46,47)
    }
  }
}

