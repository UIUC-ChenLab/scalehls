
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
/// Latency=942, interval=942
/// DSP=10
void dotProduct(
  float v0[1024],
  float v1[1024],
  float *v2
) {	// L1, [0,942)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface s_axilite port=v2 bundle=ctrl

  #pragma HLS array_partition variable=v0 cyclic factor=8 dim=1
  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS array_partition variable=v1 cyclic factor=8 dim=1
  #pragma HLS resource variable=v1 core=ram_s2p_bram

  float v3[1];	// L3, [0,0)
  v3[0] = 0.000000;	// L4, [0,1)
  float v4[1];	// L5, [0,0)
  v4[0] = 0.000000;	// L6, [0,1)
  for (int v5 = 0; v5 < 128; v5 += 1) {	// L7, [1,939), iterCycle=47, II=7
    #pragma HLS pipeline II=7
    float v6 = v0[(v5 * 8)];	// L8, [0,2)
    float v7 = v1[(v5 * 8)];	// L9, [0,2)
    float v8 = v6 * v7;	// L10, [2,6)
    float v9 = v0[((v5 * 8) + 1)];	// L11, [0,2)
    float v10 = v1[((v5 * 8) + 1)];	// L12, [0,2)
    float v11 = v9 * v10;	// L13, [2,6)
    float v12 = v8 + v11;	// L14, [6,11)
    float v13 = v0[((v5 * 8) + 2)];	// L15, [5,7)
    float v14 = v1[((v5 * 8) + 2)];	// L16, [5,7)
    float v15 = v13 * v14;	// L17, [7,11)
    float v16 = v12 + v15;	// L18, [11,16)
    float v17 = v0[((v5 * 8) + 3)];	// L19, [10,12)
    float v18 = v1[((v5 * 8) + 3)];	// L20, [10,12)
    float v19 = v17 * v18;	// L21, [12,16)
    float v20 = v16 + v19;	// L22, [16,21)
    float v21 = v0[((v5 * 8) + 4)];	// L23, [15,17)
    float v22 = v1[((v5 * 8) + 4)];	// L24, [15,17)
    float v23 = v21 * v22;	// L25, [17,21)
    float v24 = v20 + v23;	// L26, [21,26)
    float v25 = v0[((v5 * 8) + 5)];	// L27, [20,22)
    float v26 = v1[((v5 * 8) + 5)];	// L28, [20,22)
    float v27 = v25 * v26;	// L29, [22,26)
    float v28 = v24 + v27;	// L30, [26,31)
    float v29 = v0[((v5 * 8) + 6)];	// L31, [25,27)
    float v30 = v1[((v5 * 8) + 6)];	// L32, [25,27)
    float v31 = v29 * v30;	// L33, [27,31)
    float v32 = v28 + v31;	// L34, [31,36)
    float v33 = v0[((v5 * 8) + 7)];	// L35, [30,32)
    float v34 = v1[((v5 * 8) + 7)];	// L36, [30,32)
    float v35 = v33 * v34;	// L37, [32,36)
    float v36 = v32 + v35;	// L38, [36,41)
    float v37 = v3[0];	// L39, [40,41)
    float v38 = v37 + v36;	// L40, [41,46)
    v3[0] = v38;	// L41, [46,47)
    v4[0] = v38;	// L42, [46,47)
  }
  *v2 = v4[0];	// L44, [939,940)
}

