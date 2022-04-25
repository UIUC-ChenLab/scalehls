
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
void FW_core(
  float v0[200][200],
  float v1[200][200],
  float v2[200][200]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  float v3[1];	// L5
  v3[0] = 0.000000;	// L6
  float v4[1];	// L15
  float v5[1];	// L17
  float v6[1];	// L9
  float v7[1];	// L11
  for (int v8 = 0; v8 < 25; v8 += 1) {	// L7
    for (int v9 = 0; v9 < 100; v9 += 1) {	// L7
      for (int v10 = 0; v10 < 25; v10 += 1) {	// L7
        for (int v11 = 0; v11 < 8; v11 += 1) {	// L7
          for (int v12 = 0; v12 < 2; v12 += 1) {	// L7
            for (int v13 = 0; v13 < 8; v13 += 1) {	// L7
              float v14 = v3[0];	// L8
              v6[0] = v14;	// L10
              v7[0] = v14;	// L12
              float v15 = v6[0];	// L14
              v4[0] = v15;	// L16
              v5[0] = v15;	// L18
              float v16 = v4[0];	// L20
              float v17 = v1[(v12 + (v9 * 2))][(v11 + (v8 * 8))];	// L21
              bool v18 = v17 != 65535.000000;	// L22
              float v19;
              if (v18) {	// L23
                float v20 = v2[(v11 + (v8 * 8))][(v13 + (v10 * 8))];	// L24
                bool v21 = v20 != 65535.000000;	// L25
                float v22;
                if (v21) {	// L26
                  float v23 = v1[(v12 + (v9 * 2))][(v11 + (v8 * 8))];	// L27
                  float v24 = v2[(v11 + (v8 * 8))][(v13 + (v10 * 8))];	// L28
                  float v25 = v23 + v24;	// L29
                  float v26 = v0[(v12 + (v9 * 2))][(v13 + (v10 * 8))];	// L30
                  bool v27 = v25 < v26;	// L31
                  if (v27) {	// L32
                    v0[(v12 + (v9 * 2))][(v13 + (v10 * 8))] = v25;	// L33
                  }
                  v22 = v25;	// L35
                } else {
                  v22 = v16;	// L37
                }
                v19 = v22;	// L39
              } else {
                v19 = v16;	// L41
              }
              v4[0] = v19;	// L43
              v5[0] = v19;	// L44
              float v28 = v5[0];	// L46
              v6[0] = v28;	// L47
              v7[0] = v28;	// L48
              float v29 = v7[0];	// L50
              v3[0] = v29;	// L51
            }
          }
        }
      }
    }
  }
}

