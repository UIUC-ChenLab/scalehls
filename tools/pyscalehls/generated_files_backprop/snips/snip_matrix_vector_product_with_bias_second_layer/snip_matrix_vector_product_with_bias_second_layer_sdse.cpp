
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
/// Latency=563, interval=563
/// DSP=40
void matrix_vector_product_with_bias_second_layer(
  double v0[64],
  double v1[4096],
  double v2[64],
  double v3[64],
  double v4[1]
) {	// L5, [0,563)
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

  for (int v5 = 0; v5 < 8; v5 += 1) {	// L8, [0,560), iterCycle=47, II=1
    for (int v6 = 0; v6 < 64; v6 += 1) {	// L9, [1,113), iterCycle=47, II=1
      #pragma HLS pipeline II=1
      double v7 = v1[((v6 * 64) + (v5 * 8))];	// L10, [0,2)
      double v8 = v3[(v5 * 8)];	// L11, [0,2)
      double v9 = v7 * v8;	// L12, [2,6)
      double v10 = v2[v6];	// L13, [4,6)
      double v11;
      if ((v5 * 8) == 0) {	// L14, [6,6)
        v11 = 0.000000;	// L15, [6,6)
      } else {
        v11 = v10;	// L17, [6,6)
      }
      double v12 = v11 + v9;	// L19, [6,11)
      double v13 = v1[(((v6 * 64) + (v5 * 8)) + 1)];	// L20, [5,7)
      double v14 = v3[((v5 * 8) + 1)];	// L21, [5,7)
      double v15 = v13 * v14;	// L22, [7,11)
      double v16 = v12 + v15;	// L23, [11,16)
      double v17 = v1[(((v6 * 64) + (v5 * 8)) + 2)];	// L24, [10,12)
      double v18 = v3[((v5 * 8) + 2)];	// L25, [10,12)
      double v19 = v17 * v18;	// L26, [12,16)
      double v20 = v16 + v19;	// L27, [16,21)
      double v21 = v1[(((v6 * 64) + (v5 * 8)) + 3)];	// L28, [15,17)
      double v22 = v3[((v5 * 8) + 3)];	// L29, [15,17)
      double v23 = v21 * v22;	// L30, [17,21)
      double v24 = v20 + v23;	// L31, [21,26)
      double v25 = v1[(((v6 * 64) + (v5 * 8)) + 4)];	// L32, [20,22)
      double v26 = v3[((v5 * 8) + 4)];	// L33, [20,22)
      double v27 = v25 * v26;	// L34, [22,26)
      double v28 = v24 + v27;	// L35, [26,31)
      double v29 = v1[(((v6 * 64) + (v5 * 8)) + 5)];	// L36, [25,27)
      double v30 = v3[((v5 * 8) + 5)];	// L37, [25,27)
      double v31 = v29 * v30;	// L38, [27,31)
      double v32 = v28 + v31;	// L39, [31,36)
      double v33 = v1[(((v6 * 64) + (v5 * 8)) + 6)];	// L40, [30,32)
      double v34 = v3[((v5 * 8) + 6)];	// L41, [30,32)
      double v35 = v33 * v34;	// L42, [32,36)
      double v36 = v32 + v35;	// L43, [36,41)
      double v37 = v1[(((v6 * 64) + (v5 * 8)) + 7)];	// L44, [35,37)
      double v38 = v3[((v5 * 8) + 7)];	// L45, [35,37)
      double v39 = v37 * v38;	// L46, [37,41)
      double v40 = v36 + v39;	// L47, [41,46)
      v2[v6] = v40;	// L48, [46,47)
    }
  }
  v4[0] = 42.424242;	// L51, [560,561)
}

