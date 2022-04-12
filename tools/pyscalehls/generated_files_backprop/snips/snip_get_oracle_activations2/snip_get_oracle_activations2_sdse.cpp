
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
/// Latency=37, interval=37
/// DSP=144
void get_oracle_activations2(
  double v0[192],
  double v1[3],
  double v2[64],
  double v3[64]
) {	// L5, [0,37)
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

  for (int v4 = 0; v4 < 8; v4 += 1) {	// L7, [0,35), iterCycle=26, II=1
    #pragma HLS pipeline II=1
    double v5 = v1[0];	// L8, [0,2)
    double v6 = v0[(v4 * 24)];	// L9, [0,2)
    double v7 = v5 * v6;	// L10, [2,6)
    double v8 = v7 + 0.000000;	// L11, [6,11)
    double v9 = v3[(v4 * 8)];	// L12, [19,21)
    double v10 = v0[((v4 * 24) + 3)];	// L13, [0,2)
    double v11 = v5 * v10;	// L14, [2,6)
    double v12 = v11 + 0.000000;	// L15, [6,11)
    double v13 = v3[((v4 * 8) + 1)];	// L16, [19,21)
    double v14 = v0[((v4 * 24) + 6)];	// L17, [0,2)
    double v15 = v5 * v14;	// L18, [2,6)
    double v16 = v15 + 0.000000;	// L19, [6,11)
    double v17 = v3[((v4 * 8) + 2)];	// L20, [19,21)
    double v18 = v0[((v4 * 24) + 9)];	// L21, [0,2)
    double v19 = v5 * v18;	// L22, [2,6)
    double v20 = v19 + 0.000000;	// L23, [6,11)
    double v21 = v3[((v4 * 8) + 3)];	// L24, [19,21)
    double v22 = v0[((v4 * 24) + 12)];	// L25, [0,2)
    double v23 = v5 * v22;	// L26, [2,6)
    double v24 = v23 + 0.000000;	// L27, [6,11)
    double v25 = v3[((v4 * 8) + 4)];	// L28, [19,21)
    double v26 = v0[((v4 * 24) + 15)];	// L29, [0,2)
    double v27 = v5 * v26;	// L30, [2,6)
    double v28 = v27 + 0.000000;	// L31, [6,11)
    double v29 = v3[((v4 * 8) + 5)];	// L32, [19,21)
    double v30 = v0[((v4 * 24) + 18)];	// L33, [0,2)
    double v31 = v5 * v30;	// L34, [2,6)
    double v32 = v31 + 0.000000;	// L35, [6,11)
    double v33 = v3[((v4 * 8) + 6)];	// L36, [19,21)
    double v34 = v0[((v4 * 24) + 21)];	// L37, [0,2)
    double v35 = v5 * v34;	// L38, [2,6)
    double v36 = v35 + 0.000000;	// L39, [6,11)
    double v37 = v3[((v4 * 8) + 7)];	// L40, [19,21)
    double v38 = v1[1];	// L41, [5,7)
    double v39 = v0[((v4 * 24) + 1)];	// L42, [5,7)
    double v40 = v38 * v39;	// L43, [7,11)
    double v41 = v8 + v40;	// L44, [11,16)
    double v42 = v0[((v4 * 24) + 4)];	// L45, [5,7)
    double v43 = v38 * v42;	// L46, [7,11)
    double v44 = v12 + v43;	// L47, [11,16)
    double v45 = v0[((v4 * 24) + 7)];	// L48, [5,7)
    double v46 = v38 * v45;	// L49, [7,11)
    double v47 = v16 + v46;	// L50, [11,16)
    double v48 = v0[((v4 * 24) + 10)];	// L51, [5,7)
    double v49 = v38 * v48;	// L52, [7,11)
    double v50 = v20 + v49;	// L53, [11,16)
    double v51 = v0[((v4 * 24) + 13)];	// L54, [5,7)
    double v52 = v38 * v51;	// L55, [7,11)
    double v53 = v24 + v52;	// L56, [11,16)
    double v54 = v0[((v4 * 24) + 16)];	// L57, [5,7)
    double v55 = v38 * v54;	// L58, [7,11)
    double v56 = v28 + v55;	// L59, [11,16)
    double v57 = v0[((v4 * 24) + 19)];	// L60, [5,7)
    double v58 = v38 * v57;	// L61, [7,11)
    double v59 = v32 + v58;	// L62, [11,16)
    double v60 = v0[((v4 * 24) + 22)];	// L63, [5,7)
    double v61 = v38 * v60;	// L64, [7,11)
    double v62 = v36 + v61;	// L65, [11,16)
    double v63 = v1[2];	// L66, [10,12)
    double v64 = v0[((v4 * 24) + 2)];	// L67, [10,12)
    double v65 = v63 * v64;	// L68, [12,16)
    double v66 = v41 + v65;	// L69, [16,21)
    double v67 = v66 * v9;	// L70, [21,25)
    v2[(v4 * 8)] = v67;	// L71, [25,26)
    double v68 = v0[((v4 * 24) + 5)];	// L72, [10,12)
    double v69 = v63 * v68;	// L73, [12,16)
    double v70 = v44 + v69;	// L74, [16,21)
    double v71 = v70 * v13;	// L75, [21,25)
    v2[((v4 * 8) + 1)] = v71;	// L76, [25,26)
    double v72 = v0[((v4 * 24) + 8)];	// L77, [10,12)
    double v73 = v63 * v72;	// L78, [12,16)
    double v74 = v47 + v73;	// L79, [16,21)
    double v75 = v74 * v17;	// L80, [21,25)
    v2[((v4 * 8) + 2)] = v75;	// L81, [25,26)
    double v76 = v0[((v4 * 24) + 11)];	// L82, [10,12)
    double v77 = v63 * v76;	// L83, [12,16)
    double v78 = v50 + v77;	// L84, [16,21)
    double v79 = v78 * v21;	// L85, [21,25)
    v2[((v4 * 8) + 3)] = v79;	// L86, [25,26)
    double v80 = v0[((v4 * 24) + 14)];	// L87, [10,12)
    double v81 = v63 * v80;	// L88, [12,16)
    double v82 = v53 + v81;	// L89, [16,21)
    double v83 = v82 * v25;	// L90, [21,25)
    v2[((v4 * 8) + 4)] = v83;	// L91, [25,26)
    double v84 = v0[((v4 * 24) + 17)];	// L92, [10,12)
    double v85 = v63 * v84;	// L93, [12,16)
    double v86 = v56 + v85;	// L94, [16,21)
    double v87 = v86 * v29;	// L95, [21,25)
    v2[((v4 * 8) + 5)] = v87;	// L96, [25,26)
    double v88 = v0[((v4 * 24) + 20)];	// L97, [10,12)
    double v89 = v63 * v88;	// L98, [12,16)
    double v90 = v59 + v89;	// L99, [16,21)
    double v91 = v90 * v33;	// L100, [21,25)
    v2[((v4 * 8) + 6)] = v91;	// L101, [25,26)
    double v92 = v0[((v4 * 24) + 23)];	// L102, [10,12)
    double v93 = v63 * v92;	// L103, [12,16)
    double v94 = v62 + v93;	// L104, [16,21)
    double v95 = v94 * v37;	// L105, [21,25)
    v2[((v4 * 8) + 7)] = v95;	// L106, [25,26)
  }
}

