
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
/// Latency=355, interval=355
/// DSP=5
void matrix_vector_product_with_bias_output_layer(
  double v0[3],
  double v1[192],
  double v2[3],
  double v3[64],
  double v4[1]
) {	// L6, [0,355)
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

  for (int v5 = 0; v5 < 8; v5 += 1) {	// L9, [0,352), iterCycle=49, II=43
    #pragma HLS pipeline II=43
    double v6 = v1[(v5 * 8)];	// L10, [0,2)
    double v7 = v3[(v5 * 8)];	// L11, [2,4)
    double v8 = v6 * v7;	// L12, [4,8)
    double v9 = v2[0];	// L13, [6,8)
    double v10;
    if ((v5 * 8) == 0) {	// L14, [8,8)
      v10 = 0.000000;	// L15, [8,8)
    } else {
      v10 = v9;	// L17, [8,8)
    }
    double v11 = v10 + v8;	// L19, [8,13)
    double v12 = v1[((v5 * 8) + 64)];	// L20, [1,3)
    double v13 = v12 * v7;	// L21, [4,8)
    double v14 = v2[1];	// L22, [6,8)
    double v15;
    if ((v5 * 8) == 0) {	// L23, [8,8)
      v15 = 0.000000;	// L24, [8,8)
    } else {
      v15 = v14;	// L26, [8,8)
    }
    double v16 = v15 + v13;	// L28, [8,13)
    double v17 = v1[((v5 * 8) + 128)];	// L29, [2,4)
    double v18 = v17 * v7;	// L30, [4,8)
    double v19 = v2[2];	// L31, [6,8)
    double v20;
    if ((v5 * 8) == 0) {	// L32, [8,8)
      v20 = 0.000000;	// L33, [8,8)
    } else {
      v20 = v19;	// L35, [8,8)
    }
    double v21 = v20 + v18;	// L37, [8,13)
    double v22 = v1[((v5 * 8) + 1)];	// L38, [5,7)
    double v23 = v3[((v5 * 8) + 1)];	// L39, [7,9)
    double v24 = v22 * v23;	// L40, [9,13)
    double v25 = v11 + v24;	// L41, [13,18)
    double v26 = v1[((v5 * 8) + 65)];	// L42, [6,8)
    double v27 = v26 * v23;	// L43, [9,13)
    double v28 = v16 + v27;	// L44, [13,18)
    double v29 = v1[((v5 * 8) + 129)];	// L45, [7,9)
    double v30 = v29 * v23;	// L46, [9,13)
    double v31 = v21 + v30;	// L47, [13,18)
    double v32 = v1[((v5 * 8) + 2)];	// L48, [10,12)
    double v33 = v3[((v5 * 8) + 2)];	// L49, [12,14)
    double v34 = v32 * v33;	// L50, [14,18)
    double v35 = v25 + v34;	// L51, [18,23)
    double v36 = v1[((v5 * 8) + 66)];	// L52, [11,13)
    double v37 = v36 * v33;	// L53, [14,18)
    double v38 = v28 + v37;	// L54, [18,23)
    double v39 = v1[((v5 * 8) + 130)];	// L55, [12,14)
    double v40 = v39 * v33;	// L56, [14,18)
    double v41 = v31 + v40;	// L57, [18,23)
    double v42 = v1[((v5 * 8) + 3)];	// L58, [15,17)
    double v43 = v3[((v5 * 8) + 3)];	// L59, [17,19)
    double v44 = v42 * v43;	// L60, [19,23)
    double v45 = v35 + v44;	// L61, [23,28)
    double v46 = v1[((v5 * 8) + 67)];	// L62, [16,18)
    double v47 = v46 * v43;	// L63, [19,23)
    double v48 = v38 + v47;	// L64, [23,28)
    double v49 = v1[((v5 * 8) + 131)];	// L65, [17,19)
    double v50 = v49 * v43;	// L66, [19,23)
    double v51 = v41 + v50;	// L67, [23,28)
    double v52 = v1[((v5 * 8) + 4)];	// L68, [20,22)
    double v53 = v3[((v5 * 8) + 4)];	// L69, [22,24)
    double v54 = v52 * v53;	// L70, [24,28)
    double v55 = v45 + v54;	// L71, [28,33)
    double v56 = v1[((v5 * 8) + 68)];	// L72, [21,23)
    double v57 = v56 * v53;	// L73, [24,28)
    double v58 = v48 + v57;	// L74, [28,33)
    double v59 = v1[((v5 * 8) + 132)];	// L75, [22,24)
    double v60 = v59 * v53;	// L76, [24,28)
    double v61 = v51 + v60;	// L77, [28,33)
    double v62 = v1[((v5 * 8) + 5)];	// L78, [25,27)
    double v63 = v3[((v5 * 8) + 5)];	// L79, [27,29)
    double v64 = v62 * v63;	// L80, [29,33)
    double v65 = v55 + v64;	// L81, [33,38)
    double v66 = v1[((v5 * 8) + 69)];	// L82, [26,28)
    double v67 = v66 * v63;	// L83, [29,33)
    double v68 = v58 + v67;	// L84, [33,38)
    double v69 = v1[((v5 * 8) + 133)];	// L85, [27,29)
    double v70 = v69 * v63;	// L86, [29,33)
    double v71 = v61 + v70;	// L87, [33,38)
    double v72 = v1[((v5 * 8) + 6)];	// L88, [30,32)
    double v73 = v3[((v5 * 8) + 6)];	// L89, [32,34)
    double v74 = v72 * v73;	// L90, [34,38)
    double v75 = v65 + v74;	// L91, [38,43)
    double v76 = v1[((v5 * 8) + 70)];	// L92, [31,33)
    double v77 = v76 * v73;	// L93, [34,38)
    double v78 = v68 + v77;	// L94, [38,43)
    double v79 = v1[((v5 * 8) + 134)];	// L95, [32,34)
    double v80 = v79 * v73;	// L96, [34,38)
    double v81 = v71 + v80;	// L97, [38,43)
    double v82 = v1[((v5 * 8) + 7)];	// L98, [35,37)
    double v83 = v3[((v5 * 8) + 7)];	// L99, [37,39)
    double v84 = v82 * v83;	// L100, [39,43)
    double v85 = v75 + v84;	// L101, [43,48)
    v2[0] = v85;	// L102, [48,49)
    double v86 = v1[((v5 * 8) + 71)];	// L103, [36,38)
    double v87 = v86 * v83;	// L104, [39,43)
    double v88 = v78 + v87;	// L105, [43,48)
    v2[1] = v88;	// L106, [48,49)
    double v89 = v1[((v5 * 8) + 135)];	// L107, [37,39)
    double v90 = v89 * v83;	// L108, [39,43)
    double v91 = v81 + v90;	// L109, [43,48)
    v2[2] = v91;	// L110, [48,49)
  }
  v4[0] = 42.424242;	// L112, [352,353)
}

