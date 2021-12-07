
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
void syr2k_32(
  float v0,
  float v1,
  float v2[32][32],
  float v3[32][32],
  float v4[32][32]
) {	// L3
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface s_axilite port=v1 bundle=ctrl
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4

  #pragma HLS array_partition variable=v2 cyclic factor=8 dim=2
  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS array_partition variable=v3 cyclic factor=8 dim=2
  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS array_partition variable=v4 cyclic factor=8 dim=2
  #pragma HLS resource variable=v4 core=ram_s2p_bram

  for (int v5 = 0; v5 < 32; v5 += 1) {	// L9
    for (int v6 = 0; v6 < 32; v6 += 1) {	// L9
      for (int v7 = 0; v7 < 4; v7 += 1) {	// L9
        #pragma HLS pipeline II=3
        if ((v6 + (v7 * -8)) >= 0) {	// L5
          float v8 = v2[v6][(v7 * 8)];	// L6
          float v9 = v8 * v1;	// L7
          if (v5 == 0) {	// L5
            v2[v6][(v7 * 8)] = v9;	// L8
          }
          float v10 = v3[v6][v5];	// L10
          float v11 = v4[(v7 * 8)][v5];	// L11
          float v12 = v10 * v11;	// L12
          float v13 = v4[v6][v5];	// L13
          float v14 = v3[(v7 * 8)][v5];	// L14
          float v15 = v13 * v14;	// L15
          float v16 = v12 + v15;	// L16
          float v17 = v0 * v16;	// L17
          float v18 = v2[v6][(v7 * 8)];	// L18
          float v19 = v18 + v17;	// L19
          v2[v6][(v7 * 8)] = v19;	// L20
        }
        if ((v6 - ((v7 * 8) + 1)) >= 0) {	// L5
          float v20 = v2[v6][((v7 * 8) + 1)];	// L6
          float v21 = v20 * v1;	// L7
          if (v5 == 0) {	// L5
            v2[v6][((v7 * 8) + 1)] = v21;	// L8
          }
          float v22 = v3[v6][v5];	// L10
          float v23 = v4[((v7 * 8) + 1)][v5];	// L11
          float v24 = v22 * v23;	// L12
          float v25 = v4[v6][v5];	// L13
          float v26 = v3[((v7 * 8) + 1)][v5];	// L14
          float v27 = v25 * v26;	// L15
          float v28 = v24 + v27;	// L16
          float v29 = v0 * v28;	// L17
          float v30 = v2[v6][((v7 * 8) + 1)];	// L18
          float v31 = v30 + v29;	// L19
          v2[v6][((v7 * 8) + 1)] = v31;	// L20
        }
        if ((v6 - ((v7 * 8) + 2)) >= 0) {	// L5
          float v32 = v2[v6][((v7 * 8) + 2)];	// L6
          float v33 = v32 * v1;	// L7
          if (v5 == 0) {	// L5
            v2[v6][((v7 * 8) + 2)] = v33;	// L8
          }
          float v34 = v3[v6][v5];	// L10
          float v35 = v4[((v7 * 8) + 2)][v5];	// L11
          float v36 = v34 * v35;	// L12
          float v37 = v4[v6][v5];	// L13
          float v38 = v3[((v7 * 8) + 2)][v5];	// L14
          float v39 = v37 * v38;	// L15
          float v40 = v36 + v39;	// L16
          float v41 = v0 * v40;	// L17
          float v42 = v2[v6][((v7 * 8) + 2)];	// L18
          float v43 = v42 + v41;	// L19
          v2[v6][((v7 * 8) + 2)] = v43;	// L20
        }
        if ((v6 - ((v7 * 8) + 3)) >= 0) {	// L5
          float v44 = v2[v6][((v7 * 8) + 3)];	// L6
          float v45 = v44 * v1;	// L7
          if (v5 == 0) {	// L5
            v2[v6][((v7 * 8) + 3)] = v45;	// L8
          }
          float v46 = v3[v6][v5];	// L10
          float v47 = v4[((v7 * 8) + 3)][v5];	// L11
          float v48 = v46 * v47;	// L12
          float v49 = v4[v6][v5];	// L13
          float v50 = v3[((v7 * 8) + 3)][v5];	// L14
          float v51 = v49 * v50;	// L15
          float v52 = v48 + v51;	// L16
          float v53 = v0 * v52;	// L17
          float v54 = v2[v6][((v7 * 8) + 3)];	// L18
          float v55 = v54 + v53;	// L19
          v2[v6][((v7 * 8) + 3)] = v55;	// L20
        }
        if ((v6 - ((v7 * 8) + 4)) >= 0) {	// L5
          float v56 = v2[v6][((v7 * 8) + 4)];	// L6
          float v57 = v56 * v1;	// L7
          if (v5 == 0) {	// L5
            v2[v6][((v7 * 8) + 4)] = v57;	// L8
          }
          float v58 = v3[v6][v5];	// L10
          float v59 = v4[((v7 * 8) + 4)][v5];	// L11
          float v60 = v58 * v59;	// L12
          float v61 = v4[v6][v5];	// L13
          float v62 = v3[((v7 * 8) + 4)][v5];	// L14
          float v63 = v61 * v62;	// L15
          float v64 = v60 + v63;	// L16
          float v65 = v0 * v64;	// L17
          float v66 = v2[v6][((v7 * 8) + 4)];	// L18
          float v67 = v66 + v65;	// L19
          v2[v6][((v7 * 8) + 4)] = v67;	// L20
        }
        if ((v6 - ((v7 * 8) + 5)) >= 0) {	// L5
          float v68 = v2[v6][((v7 * 8) + 5)];	// L6
          float v69 = v68 * v1;	// L7
          if (v5 == 0) {	// L5
            v2[v6][((v7 * 8) + 5)] = v69;	// L8
          }
          float v70 = v3[v6][v5];	// L10
          float v71 = v4[((v7 * 8) + 5)][v5];	// L11
          float v72 = v70 * v71;	// L12
          float v73 = v4[v6][v5];	// L13
          float v74 = v3[((v7 * 8) + 5)][v5];	// L14
          float v75 = v73 * v74;	// L15
          float v76 = v72 + v75;	// L16
          float v77 = v0 * v76;	// L17
          float v78 = v2[v6][((v7 * 8) + 5)];	// L18
          float v79 = v78 + v77;	// L19
          v2[v6][((v7 * 8) + 5)] = v79;	// L20
        }
        if ((v6 - ((v7 * 8) + 6)) >= 0) {	// L5
          float v80 = v2[v6][((v7 * 8) + 6)];	// L6
          float v81 = v80 * v1;	// L7
          if (v5 == 0) {	// L5
            v2[v6][((v7 * 8) + 6)] = v81;	// L8
          }
          float v82 = v3[v6][v5];	// L10
          float v83 = v4[((v7 * 8) + 6)][v5];	// L11
          float v84 = v82 * v83;	// L12
          float v85 = v4[v6][v5];	// L13
          float v86 = v3[((v7 * 8) + 6)][v5];	// L14
          float v87 = v85 * v86;	// L15
          float v88 = v84 + v87;	// L16
          float v89 = v0 * v88;	// L17
          float v90 = v2[v6][((v7 * 8) + 6)];	// L18
          float v91 = v90 + v89;	// L19
          v2[v6][((v7 * 8) + 6)] = v91;	// L20
        }
        if ((v6 - ((v7 * 8) + 7)) >= 0) {	// L5
          float v92 = v2[v6][((v7 * 8) + 7)];	// L6
          float v93 = v92 * v1;	// L7
          if (v5 == 0) {	// L5
            v2[v6][((v7 * 8) + 7)] = v93;	// L8
          }
          float v94 = v3[v6][v5];	// L10
          float v95 = v4[((v7 * 8) + 7)][v5];	// L11
          float v96 = v94 * v95;	// L12
          float v97 = v4[v6][v5];	// L13
          float v98 = v3[((v7 * 8) + 7)][v5];	// L14
          float v99 = v97 * v98;	// L15
          float v100 = v96 + v99;	// L16
          float v101 = v0 * v100;	// L17
          float v102 = v2[v6][((v7 * 8) + 7)];	// L18
          float v103 = v102 + v101;	// L19
          v2[v6][((v7 * 8) + 7)] = v103;	// L20
        }
      }
    }
  }
}

