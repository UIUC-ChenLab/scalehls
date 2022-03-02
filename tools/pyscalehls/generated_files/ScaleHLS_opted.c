
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
void kernel_doitgen(
  int32_t v0,
  int32_t v1,
  int32_t v2,
  float v3[25][20][30],
  float v4[30][30],
  float v5[30]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface s_axilite port=v1 bundle=ctrl
  #pragma HLS interface s_axilite port=v2 bundle=ctrl
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4
  #pragma HLS interface bram port=v5

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS resource variable=v4 core=ram_s2p_bram

  #pragma HLS resource variable=v5 core=ram_s2p_bram

  for (int v6 = 0; v6 < 25; v6 += 1) {	// L4
    for (int v7 = 0; v7 < 20; v7 += 1) {	// L5
      for (int v8 = 0; v8 < 30; v8 += 1) {	// L6
        for (int v9 = 0; v9 < 30; v9 += 1) {	// L8
          v5[v8] = 0.000000;	// L7
          float v10 = v3[v6][v7][v9];	// L9
          float v11 = v4[v9][v8];	// L10
          float v12 = v10 * v11;	// L11
          float v13 = v5[v8];	// L12
          float v14 = v13 + v12;	// L13
          v5[v8] = v14;	// L14
        }
      }
      for (int v15 = 0; v15 < 30; v15 += 1) {	// L17
        float v16 = v5[v15];	// L18
        v3[v6][v7][v15] = v16;	// L19
      }
    }
  }
}

