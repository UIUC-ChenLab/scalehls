
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

void SgdLR_sw(
  float v0[4608000],
  int32_t v1[4500],
  float v2[1024]
) {	// L2
  float v3[1024];	// L6
  #pragma HLS resource variable=v3 core=ram_1p_bram

  for (int v4 = 0; v4 < 5; v4 += 1) {	// L7
    for (int v5 = 0; v5 < 4500; v5 += 1) {	// L8
      float v6[1];	// L9
      v6[0] = 0.000000;	// L10
      float v7[1];	// L11
      v7[0] = 0.000000;	// L12
      for (int v8 = 0; v8 < 1024; v8 += 1) {	// L13
        float v9 = v2[v8];	// L14
        float v10 = v0[(v8 + (v5 * 1024))];	// L15
        float v11 = v9 * v10;	// L16
        float v12 = v6[0];	// L17
        float v13 = v12 + v11;	// L18
        v6[0] = v13;	// L19
        v7[0] = v13;	// L20
      }
      float v14 = v7[0];	// L22
      float v15 = -(v14);	// L23
      float v16 = exp(v15);	// L24
      float v17 = 1.000000 + v16;	// L25
      float v18 = 1.000000 / v17;	// L26
      for (int v19 = 0; v19 < 1024; v19 += 1) {	// L27
        int32_t v20 = v1[v5];	// L28
        float v21 = v20;	// L29
        float v22 = v18 - v21;	// L30
        float v23 = v0[(v19 + (v5 * 1024))];	// L31
        float v24 = v22 * v23;	// L32
        v3[v19] = v24;	// L33
      }
      for (int v25 = 0; v25 < 1024; v25 += 1) {	// L35
        float v26 = v3[v25];	// L36
        float v27 = -60000.000000 * v26;	// L37
        float v28 = v2[v25];	// L38
        float v29 = v28 + v27;	// L39
        v2[v25] = v29;	// L40
      }
    }
  }
}

