
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
/// Latency=44, interval=44
/// DSP=72
void get_oracle_activations2(
  double v0[192],
  double v1[3],
  double v2[64],
  double v3[64]
) {	// L1, [0,44)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3

  #pragma HLS array_partition variable=v0 cyclic factor=24 dim=1
  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS array_partition variable=v1 cyclic factor=3 dim=1

  #pragma HLS array_partition variable=v2 cyclic factor=8 dim=1
  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS array_partition variable=v3 cyclic factor=8 dim=1
  #pragma HLS resource variable=v3 core=ram_s2p_bram

  for (int v4 = 0; v4 < 8; v4 += 1) {	// L3, [0,42), iterCycle=26, II=2
    #pragma HLS pipeline II=2
    double v5 = v1[0];	// L4, [0,2)
    double v6 = v0[(v4 * 24)];	// L5, [0,2)
    double v7 = v5 * v6;	// L6, [2,6)
    double v8 = v7 + 0.000000;	// L7, [6,11)
    double v9 = v3[(v4 * 8)];	// L8, [19,21)
    double v10 = v0[((v4 * 24) + 3)];	// L9, [0,2)
    double v11 = v5 * v10;	// L10, [2,6)
    double v12 = v11 + 0.000000;	// L11, [6,11)
    double v13 = v3[((v4 * 8) + 1)];	// L12, [19,21)
    double v14 = v0[((v4 * 24) + 6)];	// L13, [0,2)
    double v15 = v5 * v14;	// L14, [2,6)
    double v16 = v15 + 0.000000;	// L15, [6,11)
    double v17 = v3[((v4 * 8) + 2)];	// L16, [19,21)
    double v18 = v0[((v4 * 24) + 9)];	// L17, [0,2)
    double v19 = v5 * v18;	// L18, [2,6)
    double v20 = v19 + 0.000000;	// L19, [6,11)
    double v21 = v3[((v4 * 8) + 3)];	// L20, [19,21)
    double v22 = v0[((v4 * 24) + 12)];	// L21, [0,2)
    double v23 = v5 * v22;	// L22, [2,6)
    double v24 = v23 + 0.000000;	// L23, [6,11)
    double v25 = v3[((v4 * 8) + 4)];	// L24, [19,21)
    double v26 = v0[((v4 * 24) + 15)];	// L25, [0,2)
    double v27 = v5 * v26;	// L26, [2,6)
    double v28 = v27 + 0.000000;	// L27, [6,11)
    double v29 = v3[((v4 * 8) + 5)];	// L28, [19,21)
    double v30 = v0[((v4 * 24) + 18)];	// L29, [0,2)
    double v31 = v5 * v30;	// L30, [2,6)
    double v32 = v31 + 0.000000;	// L31, [6,11)
    double v33 = v3[((v4 * 8) + 6)];	// L32, [19,21)
    double v34 = v0[((v4 * 24) + 21)];	// L33, [0,2)
    double v35 = v5 * v34;	// L34, [2,6)
    double v36 = v35 + 0.000000;	// L35, [6,11)
    double v37 = v3[((v4 * 8) + 7)];	// L36, [19,21)
    double v38 = v1[1];	// L37, [5,7)
    double v39 = v0[((v4 * 24) + 1)];	// L38, [5,7)
    double v40 = v38 * v39;	// L39, [7,11)
    double v41 = v8 + v40;	// L40, [11,16)
    double v42 = v0[((v4 * 24) + 4)];	// L41, [5,7)
    double v43 = v38 * v42;	// L42, [7,11)
    double v44 = v12 + v43;	// L43, [11,16)
    double v45 = v0[((v4 * 24) + 7)];	// L44, [5,7)
    double v46 = v38 * v45;	// L45, [7,11)
    double v47 = v16 + v46;	// L46, [11,16)
    double v48 = v0[((v4 * 24) + 10)];	// L47, [5,7)
    double v49 = v38 * v48;	// L48, [7,11)
    double v50 = v20 + v49;	// L49, [11,16)
    double v51 = v0[((v4 * 24) + 13)];	// L50, [5,7)
    double v52 = v38 * v51;	// L51, [7,11)
    double v53 = v24 + v52;	// L52, [11,16)
    double v54 = v0[((v4 * 24) + 16)];	// L53, [5,7)
    double v55 = v38 * v54;	// L54, [7,11)
    double v56 = v28 + v55;	// L55, [11,16)
    double v57 = v0[((v4 * 24) + 19)];	// L56, [5,7)
    double v58 = v38 * v57;	// L57, [7,11)
    double v59 = v32 + v58;	// L58, [11,16)
    double v60 = v0[((v4 * 24) + 22)];	// L59, [5,7)
    double v61 = v38 * v60;	// L60, [7,11)
    double v62 = v36 + v61;	// L61, [11,16)
    double v63 = v1[2];	// L62, [10,12)
    double v64 = v0[((v4 * 24) + 2)];	// L63, [10,12)
    double v65 = v63 * v64;	// L64, [12,16)
    double v66 = v41 + v65;	// L65, [16,21)
    double v67 = v66 * v9;	// L66, [21,25)
    v2[(v4 * 8)] = v67;	// L67, [25,26)
    double v68 = v0[((v4 * 24) + 5)];	// L68, [10,12)
    double v69 = v63 * v68;	// L69, [12,16)
    double v70 = v44 + v69;	// L70, [16,21)
    double v71 = v70 * v13;	// L71, [21,25)
    v2[((v4 * 8) + 1)] = v71;	// L72, [25,26)
    double v72 = v0[((v4 * 24) + 8)];	// L73, [10,12)
    double v73 = v63 * v72;	// L74, [12,16)
    double v74 = v47 + v73;	// L75, [16,21)
    double v75 = v74 * v17;	// L76, [21,25)
    v2[((v4 * 8) + 2)] = v75;	// L77, [25,26)
    double v76 = v0[((v4 * 24) + 11)];	// L78, [10,12)
    double v77 = v63 * v76;	// L79, [12,16)
    double v78 = v50 + v77;	// L80, [16,21)
    double v79 = v78 * v21;	// L81, [21,25)
    v2[((v4 * 8) + 3)] = v79;	// L82, [25,26)
    double v80 = v0[((v4 * 24) + 14)];	// L83, [10,12)
    double v81 = v63 * v80;	// L84, [12,16)
    double v82 = v53 + v81;	// L85, [16,21)
    double v83 = v82 * v25;	// L86, [21,25)
    v2[((v4 * 8) + 4)] = v83;	// L87, [25,26)
    double v84 = v0[((v4 * 24) + 17)];	// L88, [10,12)
    double v85 = v63 * v84;	// L89, [12,16)
    double v86 = v56 + v85;	// L90, [16,21)
    double v87 = v86 * v29;	// L91, [21,25)
    v2[((v4 * 8) + 5)] = v87;	// L92, [25,26)
    double v88 = v0[((v4 * 24) + 20)];	// L93, [10,12)
    double v89 = v63 * v88;	// L94, [12,16)
    double v90 = v59 + v89;	// L95, [16,21)
    double v91 = v90 * v33;	// L96, [21,25)
    v2[((v4 * 8) + 6)] = v91;	// L97, [25,26)
    double v92 = v0[((v4 * 24) + 23)];	// L98, [10,12)
    double v93 = v63 * v92;	// L99, [12,16)
    double v94 = v62 + v93;	// L100, [16,21)
    double v95 = v94 * v37;	// L101, [21,25)
    v2[((v4 * 8) + 7)] = v95;	// L102, [25,26)
  }
}

