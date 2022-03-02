
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
/// Latency=2726656, interval=2726656
/// DSP=70
void kernel_atax(
  float v0,
  float v1,
  float v2[1900][2100],
  float v3[2100],
  float v4[2100],
  float v5[1900]
) {	// L1, [0,2726656)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface s_axilite port=v1 bundle=ctrl
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4
  #pragma HLS interface bram port=v5

  #pragma HLS array_partition variable=v2 cyclic factor=14 dim=2
  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS array_partition variable=v3 cyclic factor=14 dim=1
  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS array_partition variable=v4 cyclic factor=14 dim=1
  #pragma HLS resource variable=v4 core=ram_s2p_bram

  #pragma HLS resource variable=v5 core=ram_s2p_bram

  for (int v6 = 0; v6 < 150; v6 += 1) {	// L3, [0,152), iterCycle=1, II=1
    #pragma HLS pipeline II=1
    v4[(v6 * 14)] = 0.000000;	// L4, [0,1)
    v4[((v6 * 14) + 1)] = 0.000000;	// L5, [0,1)
    v4[((v6 * 14) + 2)] = 0.000000;	// L6, [0,1)
    v4[((v6 * 14) + 3)] = 0.000000;	// L7, [0,1)
    v4[((v6 * 14) + 4)] = 0.000000;	// L8, [0,1)
    v4[((v6 * 14) + 5)] = 0.000000;	// L9, [0,1)
    v4[((v6 * 14) + 6)] = 0.000000;	// L10, [0,1)
    v4[((v6 * 14) + 7)] = 0.000000;	// L11, [0,1)
    v4[((v6 * 14) + 8)] = 0.000000;	// L12, [0,1)
    v4[((v6 * 14) + 9)] = 0.000000;	// L13, [0,1)
    v4[((v6 * 14) + 10)] = 0.000000;	// L14, [0,1)
    v4[((v6 * 14) + 11)] = 0.000000;	// L15, [0,1)
    v4[((v6 * 14) + 12)] = 0.000000;	// L16, [0,1)
    v4[((v6 * 14) + 13)] = 0.000000;	// L17, [0,1)
  }
  for (int v7 = 0; v7 < 1900; v7 += 1) {	// L19, [152,2726654), iterCycle=1435, II=1435
    v5[v7] = 0.000000;	// L20, [0,1)
    for (int v8 = 0; v8 < 150; v8 += 1) {	// L21, [1,1272), iterCycle=77, II=8
      #pragma HLS pipeline II=8
      float v9 = v2[v7][(v8 * 14)];	// L22, [0,2)
      float v10 = v3[(v8 * 14)];	// L23, [0,2)
      float v11 = v9 * v10;	// L24, [2,6)
      float v12 = v2[v7][((v8 * 14) + 1)];	// L25, [0,2)
      float v13 = v3[((v8 * 14) + 1)];	// L26, [0,2)
      float v14 = v12 * v13;	// L27, [2,6)
      float v15 = v11 + v14;	// L28, [6,11)
      float v16 = v2[v7][((v8 * 14) + 2)];	// L29, [5,7)
      float v17 = v3[((v8 * 14) + 2)];	// L30, [5,7)
      float v18 = v16 * v17;	// L31, [7,11)
      float v19 = v15 + v18;	// L32, [11,16)
      float v20 = v2[v7][((v8 * 14) + 3)];	// L33, [10,12)
      float v21 = v3[((v8 * 14) + 3)];	// L34, [10,12)
      float v22 = v20 * v21;	// L35, [12,16)
      float v23 = v19 + v22;	// L36, [16,21)
      float v24 = v2[v7][((v8 * 14) + 4)];	// L37, [15,17)
      float v25 = v3[((v8 * 14) + 4)];	// L38, [15,17)
      float v26 = v24 * v25;	// L39, [17,21)
      float v27 = v23 + v26;	// L40, [21,26)
      float v28 = v2[v7][((v8 * 14) + 5)];	// L41, [20,22)
      float v29 = v3[((v8 * 14) + 5)];	// L42, [20,22)
      float v30 = v28 * v29;	// L43, [22,26)
      float v31 = v27 + v30;	// L44, [26,31)
      float v32 = v2[v7][((v8 * 14) + 6)];	// L45, [25,27)
      float v33 = v3[((v8 * 14) + 6)];	// L46, [25,27)
      float v34 = v32 * v33;	// L47, [27,31)
      float v35 = v31 + v34;	// L48, [31,36)
      float v36 = v2[v7][((v8 * 14) + 7)];	// L49, [30,32)
      float v37 = v3[((v8 * 14) + 7)];	// L50, [30,32)
      float v38 = v36 * v37;	// L51, [32,36)
      float v39 = v35 + v38;	// L52, [36,41)
      float v40 = v2[v7][((v8 * 14) + 8)];	// L53, [35,37)
      float v41 = v3[((v8 * 14) + 8)];	// L54, [35,37)
      float v42 = v40 * v41;	// L55, [37,41)
      float v43 = v39 + v42;	// L56, [41,46)
      float v44 = v2[v7][((v8 * 14) + 9)];	// L57, [40,42)
      float v45 = v3[((v8 * 14) + 9)];	// L58, [40,42)
      float v46 = v44 * v45;	// L59, [42,46)
      float v47 = v43 + v46;	// L60, [46,51)
      float v48 = v2[v7][((v8 * 14) + 10)];	// L61, [45,47)
      float v49 = v3[((v8 * 14) + 10)];	// L62, [45,47)
      float v50 = v48 * v49;	// L63, [47,51)
      float v51 = v47 + v50;	// L64, [51,56)
      float v52 = v2[v7][((v8 * 14) + 11)];	// L65, [50,52)
      float v53 = v3[((v8 * 14) + 11)];	// L66, [50,52)
      float v54 = v52 * v53;	// L67, [52,56)
      float v55 = v51 + v54;	// L68, [56,61)
      float v56 = v2[v7][((v8 * 14) + 12)];	// L69, [55,57)
      float v57 = v3[((v8 * 14) + 12)];	// L70, [55,57)
      float v58 = v56 * v57;	// L71, [57,61)
      float v59 = v55 + v58;	// L72, [61,66)
      float v60 = v2[v7][((v8 * 14) + 13)];	// L73, [60,62)
      float v61 = v3[((v8 * 14) + 13)];	// L74, [60,62)
      float v62 = v60 * v61;	// L75, [62,66)
      float v63 = v59 + v62;	// L76, [66,71)
      float v64 = v5[v7];	// L77, [69,71)
      float v65 = v64 + v63;	// L78, [71,76)
      v5[v7] = v65;	// L79, [76,77)
    }
    for (int v66 = 0; v66 < 150; v66 += 1) {	// L81, [1272,1435), iterCycle=12, II=1
      #pragma HLS pipeline II=1
      float v67 = v4[(v66 * 14)];	// L82, [4,6)
      float v68 = v2[v7][(v66 * 14)];	// L83, [0,2)
      float v69 = v5[v7];	// L84, [0,2)
      float v70 = v68 * v69;	// L85, [2,6)
      float v71 = v67 + v70;	// L86, [6,11)
      v4[(v66 * 14)] = v71;	// L87, [11,12)
      float v72 = v4[((v66 * 14) + 1)];	// L88, [4,6)
      float v73 = v2[v7][((v66 * 14) + 1)];	// L89, [0,2)
      float v74 = v73 * v69;	// L90, [2,6)
      float v75 = v72 + v74;	// L91, [6,11)
      v4[((v66 * 14) + 1)] = v75;	// L92, [11,12)
      float v76 = v4[((v66 * 14) + 2)];	// L93, [4,6)
      float v77 = v2[v7][((v66 * 14) + 2)];	// L94, [0,2)
      float v78 = v77 * v69;	// L95, [2,6)
      float v79 = v76 + v78;	// L96, [6,11)
      v4[((v66 * 14) + 2)] = v79;	// L97, [11,12)
      float v80 = v4[((v66 * 14) + 3)];	// L98, [4,6)
      float v81 = v2[v7][((v66 * 14) + 3)];	// L99, [0,2)
      float v82 = v81 * v69;	// L100, [2,6)
      float v83 = v80 + v82;	// L101, [6,11)
      v4[((v66 * 14) + 3)] = v83;	// L102, [11,12)
      float v84 = v4[((v66 * 14) + 4)];	// L103, [4,6)
      float v85 = v2[v7][((v66 * 14) + 4)];	// L104, [0,2)
      float v86 = v85 * v69;	// L105, [2,6)
      float v87 = v84 + v86;	// L106, [6,11)
      v4[((v66 * 14) + 4)] = v87;	// L107, [11,12)
      float v88 = v4[((v66 * 14) + 5)];	// L108, [4,6)
      float v89 = v2[v7][((v66 * 14) + 5)];	// L109, [0,2)
      float v90 = v89 * v69;	// L110, [2,6)
      float v91 = v88 + v90;	// L111, [6,11)
      v4[((v66 * 14) + 5)] = v91;	// L112, [11,12)
      float v92 = v4[((v66 * 14) + 6)];	// L113, [4,6)
      float v93 = v2[v7][((v66 * 14) + 6)];	// L114, [0,2)
      float v94 = v93 * v69;	// L115, [2,6)
      float v95 = v92 + v94;	// L116, [6,11)
      v4[((v66 * 14) + 6)] = v95;	// L117, [11,12)
      float v96 = v4[((v66 * 14) + 7)];	// L118, [4,6)
      float v97 = v2[v7][((v66 * 14) + 7)];	// L119, [0,2)
      float v98 = v97 * v69;	// L120, [2,6)
      float v99 = v96 + v98;	// L121, [6,11)
      v4[((v66 * 14) + 7)] = v99;	// L122, [11,12)
      float v100 = v4[((v66 * 14) + 8)];	// L123, [4,6)
      float v101 = v2[v7][((v66 * 14) + 8)];	// L124, [0,2)
      float v102 = v101 * v69;	// L125, [2,6)
      float v103 = v100 + v102;	// L126, [6,11)
      v4[((v66 * 14) + 8)] = v103;	// L127, [11,12)
      float v104 = v4[((v66 * 14) + 9)];	// L128, [4,6)
      float v105 = v2[v7][((v66 * 14) + 9)];	// L129, [0,2)
      float v106 = v105 * v69;	// L130, [2,6)
      float v107 = v104 + v106;	// L131, [6,11)
      v4[((v66 * 14) + 9)] = v107;	// L132, [11,12)
      float v108 = v4[((v66 * 14) + 10)];	// L133, [4,6)
      float v109 = v2[v7][((v66 * 14) + 10)];	// L134, [0,2)
      float v110 = v109 * v69;	// L135, [2,6)
      float v111 = v108 + v110;	// L136, [6,11)
      v4[((v66 * 14) + 10)] = v111;	// L137, [11,12)
      float v112 = v4[((v66 * 14) + 11)];	// L138, [4,6)
      float v113 = v2[v7][((v66 * 14) + 11)];	// L139, [0,2)
      float v114 = v113 * v69;	// L140, [2,6)
      float v115 = v112 + v114;	// L141, [6,11)
      v4[((v66 * 14) + 11)] = v115;	// L142, [11,12)
      float v116 = v4[((v66 * 14) + 12)];	// L143, [4,6)
      float v117 = v2[v7][((v66 * 14) + 12)];	// L144, [0,2)
      float v118 = v117 * v69;	// L145, [2,6)
      float v119 = v116 + v118;	// L146, [6,11)
      v4[((v66 * 14) + 12)] = v119;	// L147, [11,12)
      float v120 = v4[((v66 * 14) + 13)];	// L148, [4,6)
      float v121 = v2[v7][((v66 * 14) + 13)];	// L149, [0,2)
      float v122 = v121 * v69;	// L150, [2,6)
      float v123 = v120 + v122;	// L151, [6,11)
      v4[((v66 * 14) + 13)] = v123;	// L152, [11,12)
    }
  }
}

