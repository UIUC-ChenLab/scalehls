
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
/// Latency=90810014, interval=90810014
/// DSP=69
void SgdLR_sw(
  float v0[4608000],
  int32_t v1[4500],
  float v2[1024]
) {	// L1, [0,90810014)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2

  #pragma HLS array_partition variable=v0 cyclic factor=8 dim=1
  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS array_partition variable=v2 cyclic factor=8 dim=1
  #pragma HLS resource variable=v2 core=ram_s2p_bram

  float v3[1024];	// L5, [0,0)
  #pragma HLS array_partition variable=v3 cyclic factor=8 dim=1
  #pragma HLS resource variable=v3 core=ram_s2p_bram

  for (int v4 = 0; v4 < 5; v4 += 1) {	// L6, [0,90810012), iterCycle=18162002, II=18162002
    for (int v5 = 0; v5 < 4500; v5 += 1) {	// L7, [0,18162002), iterCycle=4036, II=4036
      float v6[1];	// L8, [0,0)
      v6[0] = 0.000000;	// L9, [3724,3725)
      float v7[1];	// L10, [0,0)
      v7[0] = 0.000000;	// L11, [3730,3731)
      for (int v8 = 0; v8 < 128; v8 += 1) {	// L12, [0,3754), iterCycle=69, II=29
        #pragma HLS pipeline II=7
        float v9 = v2[(v8 * 8)];	// L13, [0,2)
        float v10 = v0[((v5 * 1024) + (v8 * 8))];	// L14, [0,2)
        float v11 = v9 * v10;	// L15, [2,6)
        float v12 = v2[((v8 * 8) + 1)];	// L16, [0,2)
        float v13 = v0[(((v5 * 1024) + (v8 * 8)) + 1)];	// L17, [0,2)
        float v14 = v12 * v13;	// L18, [2,6)
        float v15 = v11 + v14;	// L19, [6,11)
        float v16 = v2[((v8 * 8) + 2)];	// L20, [5,7)
        float v17 = v0[(((v5 * 1024) + (v8 * 8)) + 2)];	// L21, [5,7)
        float v18 = v16 * v17;	// L22, [7,11)
        float v19 = v15 + v18;	// L23, [11,16)
        float v20 = v2[((v8 * 8) + 3)];	// L24, [10,12)
        float v21 = v0[(((v5 * 1024) + (v8 * 8)) + 3)];	// L25, [10,12)
        float v22 = v20 * v21;	// L26, [12,16)
        float v23 = v19 + v22;	// L27, [16,21)
        float v24 = v2[((v8 * 8) + 4)];	// L28, [15,17)
        float v25 = v0[(((v5 * 1024) + (v8 * 8)) + 4)];	// L29, [15,17)
        float v26 = v24 * v25;	// L30, [17,21)
        float v27 = v23 + v26;	// L31, [21,26)
        float v28 = v2[((v8 * 8) + 5)];	// L32, [20,22)
        float v29 = v0[(((v5 * 1024) + (v8 * 8)) + 5)];	// L33, [20,22)
        float v30 = v28 * v29;	// L34, [22,26)
        float v31 = v27 + v30;	// L35, [26,31)
        float v32 = v2[((v8 * 8) + 6)];	// L36, [25,27)
        float v33 = v0[(((v5 * 1024) + (v8 * 8)) + 6)];	// L37, [25,27)
        float v34 = v32 * v33;	// L38, [27,31)
        float v35 = v31 + v34;	// L39, [31,36)
        float v36 = v2[((v8 * 8) + 7)];	// L40, [30,32)
        float v37 = v0[(((v5 * 1024) + (v8 * 8)) + 7)];	// L41, [30,32)
        float v38 = v36 * v37;	// L42, [32,36)
        float v39 = v35 + v38;	// L43, [36,41)
        float v40 = v6[0];	// L44, [40,41)
        float v41 = v40 + v39;	// L45, [41,46)
        v6[0] = v41;	// L46, [68,69)
        v7[0] = v41;	// L47, [46,47)
      }
      float v42 = v7[0];	// L49, [3732,3733)
      float v43 = -(v42);	// L50, [3733,3733)
      float v44 = exp(v43);	// L51, [3733,3733)
      float v45 = 1.000000 + v44;	// L52, [3733,3738)
      float v46 = 1.000000 / v45;	// L53, [3738,3754)
      for (int v47 = 0; v47 < 128; v47 += 1) {	// L54, [3754,3895), iterCycle=12, II=1
        #pragma HLS pipeline II=1
        int32_t v48 = v1[v5];	// L55, [0,2)
        float v49 = v48;	// L56, [2,2)
        float v50 = v46 - v49;	// L57, [2,7)
        float v51 = v0[((v5 * 1024) + (v47 * 8))];	// L58, [5,7)
        float v52 = v50 * v51;	// L59, [7,11)
        v3[(v47 * 8)] = v52;	// L60, [11,12)
        float v53 = v0[(((v5 * 1024) + (v47 * 8)) + 1)];	// L61, [5,7)
        float v54 = v50 * v53;	// L62, [7,11)
        v3[((v47 * 8) + 1)] = v54;	// L63, [11,12)
        float v55 = v0[(((v5 * 1024) + (v47 * 8)) + 2)];	// L64, [5,7)
        float v56 = v50 * v55;	// L65, [7,11)
        v3[((v47 * 8) + 2)] = v56;	// L66, [11,12)
        float v57 = v0[(((v5 * 1024) + (v47 * 8)) + 3)];	// L67, [5,7)
        float v58 = v50 * v57;	// L68, [7,11)
        v3[((v47 * 8) + 3)] = v58;	// L69, [11,12)
        float v59 = v0[(((v5 * 1024) + (v47 * 8)) + 4)];	// L70, [5,7)
        float v60 = v50 * v59;	// L71, [7,11)
        v3[((v47 * 8) + 4)] = v60;	// L72, [11,12)
        float v61 = v0[(((v5 * 1024) + (v47 * 8)) + 5)];	// L73, [5,7)
        float v62 = v50 * v61;	// L74, [7,11)
        v3[((v47 * 8) + 5)] = v62;	// L75, [11,12)
        float v63 = v0[(((v5 * 1024) + (v47 * 8)) + 6)];	// L76, [5,7)
        float v64 = v50 * v63;	// L77, [7,11)
        v3[((v47 * 8) + 6)] = v64;	// L78, [11,12)
        float v65 = v0[(((v5 * 1024) + (v47 * 8)) + 7)];	// L79, [5,7)
        float v66 = v50 * v65;	// L80, [7,11)
        v3[((v47 * 8) + 7)] = v66;	// L81, [11,12)
      }
      for (int v67 = 0; v67 < 128; v67 += 1) {	// L83, [3895,4036), iterCycle=12, II=1
        #pragma HLS pipeline II=1
        float v68 = v3[(v67 * 8)];	// L84, [0,2)
        float v69 = -60000.000000 * v68;	// L85, [2,6)
        float v70 = v2[(v67 * 8)];	// L86, [4,6)
        float v71 = v70 + v69;	// L87, [6,11)
        v2[(v67 * 8)] = v71;	// L88, [11,12)
        float v72 = v3[((v67 * 8) + 1)];	// L89, [0,2)
        float v73 = -60000.000000 * v72;	// L90, [2,6)
        float v74 = v2[((v67 * 8) + 1)];	// L91, [4,6)
        float v75 = v74 + v73;	// L92, [6,11)
        v2[((v67 * 8) + 1)] = v75;	// L93, [11,12)
        float v76 = v3[((v67 * 8) + 2)];	// L94, [0,2)
        float v77 = -60000.000000 * v76;	// L95, [2,6)
        float v78 = v2[((v67 * 8) + 2)];	// L96, [4,6)
        float v79 = v78 + v77;	// L97, [6,11)
        v2[((v67 * 8) + 2)] = v79;	// L98, [11,12)
        float v80 = v3[((v67 * 8) + 3)];	// L99, [0,2)
        float v81 = -60000.000000 * v80;	// L100, [2,6)
        float v82 = v2[((v67 * 8) + 3)];	// L101, [4,6)
        float v83 = v82 + v81;	// L102, [6,11)
        v2[((v67 * 8) + 3)] = v83;	// L103, [11,12)
        float v84 = v3[((v67 * 8) + 4)];	// L104, [0,2)
        float v85 = -60000.000000 * v84;	// L105, [2,6)
        float v86 = v2[((v67 * 8) + 4)];	// L106, [4,6)
        float v87 = v86 + v85;	// L107, [6,11)
        v2[((v67 * 8) + 4)] = v87;	// L108, [11,12)
        float v88 = v3[((v67 * 8) + 5)];	// L109, [0,2)
        float v89 = -60000.000000 * v88;	// L110, [2,6)
        float v90 = v2[((v67 * 8) + 5)];	// L111, [4,6)
        float v91 = v90 + v89;	// L112, [6,11)
        v2[((v67 * 8) + 5)] = v91;	// L113, [11,12)
        float v92 = v3[((v67 * 8) + 6)];	// L114, [0,2)
        float v93 = -60000.000000 * v92;	// L115, [2,6)
        float v94 = v2[((v67 * 8) + 6)];	// L116, [4,6)
        float v95 = v94 + v93;	// L117, [6,11)
        v2[((v67 * 8) + 6)] = v95;	// L118, [11,12)
        float v96 = v3[((v67 * 8) + 7)];	// L119, [0,2)
        float v97 = -60000.000000 * v96;	// L120, [2,6)
        float v98 = v2[((v67 * 8) + 7)];	// L121, [4,6)
        float v99 = v98 + v97;	// L122, [6,11)
        v2[((v67 * 8) + 7)] = v99;	// L123, [11,12)
      }
    }
  }
}

