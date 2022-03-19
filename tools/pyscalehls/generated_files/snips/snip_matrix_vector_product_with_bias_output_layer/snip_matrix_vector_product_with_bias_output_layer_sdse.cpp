
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
/// Latency=354, interval=354
/// DSP=5
void matrix_vector_product_with_bias_output_layer(
  double v0[3],
  double v1[192],
  double v2[3],
  double v3[64]
) {	// L1, [0,354)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v3

  #pragma HLS resource variable=v0 core=ram_1p_bram

  #pragma HLS array_partition variable=v1 block factor=24 dim=1
  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS array_partition variable=v2 cyclic factor=3 dim=1

  #pragma HLS array_partition variable=v3 cyclic factor=8 dim=1
  #pragma HLS resource variable=v3 core=ram_s2p_bram

  for (int v4 = 0; v4 < 8; v4 += 1) {	// L3, [0,352), iterCycle=49, II=43
    #pragma HLS pipeline II=43
    double v5 = v1[(v4 * 8)];	// L4, [0,2)
    double v6 = v3[(v4 * 8)];	// L5, [2,4)
    double v7 = v5 * v6;	// L6, [4,8)
    double v8 = v2[0];	// L7, [6,8)
    double v9;
    if ((v4 * 8) == 0) {	// L8, [8,8)
      v9 = 0.000000;	// L9, [8,8)
    } else {
      v9 = v8;	// L11, [8,8)
    }
    double v10 = v9 + v7;	// L13, [8,13)
    double v11 = v1[((v4 * 8) + 64)];	// L14, [1,3)
    double v12 = v11 * v6;	// L15, [4,8)
    double v13 = v2[1];	// L16, [6,8)
    double v14;
    if ((v4 * 8) == 0) {	// L17, [8,8)
      v14 = 0.000000;	// L18, [8,8)
    } else {
      v14 = v13;	// L20, [8,8)
    }
    double v15 = v14 + v12;	// L22, [8,13)
    double v16 = v1[((v4 * 8) + 128)];	// L23, [2,4)
    double v17 = v16 * v6;	// L24, [4,8)
    double v18 = v2[2];	// L25, [6,8)
    double v19;
    if ((v4 * 8) == 0) {	// L26, [8,8)
      v19 = 0.000000;	// L27, [8,8)
    } else {
      v19 = v18;	// L29, [8,8)
    }
    double v20 = v19 + v17;	// L31, [8,13)
    double v21 = v1[((v4 * 8) + 1)];	// L32, [5,7)
    double v22 = v3[((v4 * 8) + 1)];	// L33, [7,9)
    double v23 = v21 * v22;	// L34, [9,13)
    double v24 = v10 + v23;	// L35, [13,18)
    double v25 = v1[((v4 * 8) + 65)];	// L36, [6,8)
    double v26 = v25 * v22;	// L37, [9,13)
    double v27 = v15 + v26;	// L38, [13,18)
    double v28 = v1[((v4 * 8) + 129)];	// L39, [7,9)
    double v29 = v28 * v22;	// L40, [9,13)
    double v30 = v20 + v29;	// L41, [13,18)
    double v31 = v1[((v4 * 8) + 2)];	// L42, [10,12)
    double v32 = v3[((v4 * 8) + 2)];	// L43, [12,14)
    double v33 = v31 * v32;	// L44, [14,18)
    double v34 = v24 + v33;	// L45, [18,23)
    double v35 = v1[((v4 * 8) + 66)];	// L46, [11,13)
    double v36 = v35 * v32;	// L47, [14,18)
    double v37 = v27 + v36;	// L48, [18,23)
    double v38 = v1[((v4 * 8) + 130)];	// L49, [12,14)
    double v39 = v38 * v32;	// L50, [14,18)
    double v40 = v30 + v39;	// L51, [18,23)
    double v41 = v1[((v4 * 8) + 3)];	// L52, [15,17)
    double v42 = v3[((v4 * 8) + 3)];	// L53, [17,19)
    double v43 = v41 * v42;	// L54, [19,23)
    double v44 = v34 + v43;	// L55, [23,28)
    double v45 = v1[((v4 * 8) + 67)];	// L56, [16,18)
    double v46 = v45 * v42;	// L57, [19,23)
    double v47 = v37 + v46;	// L58, [23,28)
    double v48 = v1[((v4 * 8) + 131)];	// L59, [17,19)
    double v49 = v48 * v42;	// L60, [19,23)
    double v50 = v40 + v49;	// L61, [23,28)
    double v51 = v1[((v4 * 8) + 4)];	// L62, [20,22)
    double v52 = v3[((v4 * 8) + 4)];	// L63, [22,24)
    double v53 = v51 * v52;	// L64, [24,28)
    double v54 = v44 + v53;	// L65, [28,33)
    double v55 = v1[((v4 * 8) + 68)];	// L66, [21,23)
    double v56 = v55 * v52;	// L67, [24,28)
    double v57 = v47 + v56;	// L68, [28,33)
    double v58 = v1[((v4 * 8) + 132)];	// L69, [22,24)
    double v59 = v58 * v52;	// L70, [24,28)
    double v60 = v50 + v59;	// L71, [28,33)
    double v61 = v1[((v4 * 8) + 5)];	// L72, [25,27)
    double v62 = v3[((v4 * 8) + 5)];	// L73, [27,29)
    double v63 = v61 * v62;	// L74, [29,33)
    double v64 = v54 + v63;	// L75, [33,38)
    double v65 = v1[((v4 * 8) + 69)];	// L76, [26,28)
    double v66 = v65 * v62;	// L77, [29,33)
    double v67 = v57 + v66;	// L78, [33,38)
    double v68 = v1[((v4 * 8) + 133)];	// L79, [27,29)
    double v69 = v68 * v62;	// L80, [29,33)
    double v70 = v60 + v69;	// L81, [33,38)
    double v71 = v1[((v4 * 8) + 6)];	// L82, [30,32)
    double v72 = v3[((v4 * 8) + 6)];	// L83, [32,34)
    double v73 = v71 * v72;	// L84, [34,38)
    double v74 = v64 + v73;	// L85, [38,43)
    double v75 = v1[((v4 * 8) + 70)];	// L86, [31,33)
    double v76 = v75 * v72;	// L87, [34,38)
    double v77 = v67 + v76;	// L88, [38,43)
    double v78 = v1[((v4 * 8) + 134)];	// L89, [32,34)
    double v79 = v78 * v72;	// L90, [34,38)
    double v80 = v70 + v79;	// L91, [38,43)
    double v81 = v1[((v4 * 8) + 7)];	// L92, [35,37)
    double v82 = v3[((v4 * 8) + 7)];	// L93, [37,39)
    double v83 = v81 * v82;	// L94, [39,43)
    double v84 = v74 + v83;	// L95, [43,48)
    v2[0] = v84;	// L96, [48,49)
    double v85 = v1[((v4 * 8) + 71)];	// L97, [36,38)
    double v86 = v85 * v82;	// L98, [39,43)
    double v87 = v77 + v86;	// L99, [43,48)
    v2[1] = v87;	// L100, [48,49)
    double v88 = v1[((v4 * 8) + 135)];	// L101, [37,39)
    double v89 = v88 * v82;	// L102, [39,43)
    double v90 = v80 + v89;	// L103, [43,48)
    v2[2] = v90;	// L104, [48,49)
  }
}

