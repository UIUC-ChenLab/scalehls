
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

/// Latency=526404, interval=526404
/// DSP=5
void test_gemm(
  float v0,
  float v1,
  float v2[32][32],
  float v3[32][32],
  float v4[32][32]
) {	// L3, [0,526404)
  for (int v5 = 0; v5 < 32; v5 += 1) {	// L4, [0,526402), iterCycle=16450, II=16450
    for (int v6 = 0; v6 < 32; v6 += 1) {	// L5, [0,16450), iterCycle=514, II=514
      for (int v7 = 0; v7 < 32; v7 += 1) {	// L6, [0,514), iterCycle=16, II=16
        float v8 = v2[v6][v7];	// L7, [8,10)
        float v9 = v8 * v1;	// L8, [10,14)
        if (v5 == 0) {	// L9, [14,16)
          v2[v6][v7] = v9;	// L10, [14,15)
        }
        float v10 = v3[v6][v5];	// L12, [0,2)
        float v11 = v0 * v10;	// L13, [2,6)
        float v12 = v4[v5][v7];	// L14, [4,6)
        float v13 = v11 * v12;	// L15, [6,10)
        float v14 = v2[v6][v7];	// L16, [8,10)
        float v15 = v14 + v13;	// L17, [10,15)
        v2[v6][v7] = v15;	// L18, [15,16)
      }
    }
  }
}

