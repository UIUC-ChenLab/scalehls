
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

void test_gemm(
  float v0,
  float v1,
  float v2[32][32],
  float v3[32][32],
  float v4[32][32]
) {	// L2
  for (int v5 = 0; v5 < 32; v5 += 1) {	// L3
    for (int v6 = 0; v6 < 32; v6 += 1) {	// L4
      float v7 = v2[v5][v6];	// L5
      float v8 = v7 * v1;	// L6
      v2[v5][v6] = v8;	// L7
      for (int v9 = 0; v9 < 32; v9 += 1) {	// L8
        float v10 = v3[v5][v9];	// L9
        float v11 = v0 * v10;	// L10
        float v12 = v4[v9][v6];	// L11
        float v13 = v11 * v12;	// L12
        float v14 = v2[v5][v6];	// L13
        float v15 = v14 + v13;	// L14
        v2[v5][v6] = v15;	// L15
      }
    }
  }
}

