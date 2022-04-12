
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
/// Latency=605, interval=605
/// DSP=43
void get_oracle_activations1(
  double v0[4096],
  double v1[64],
  double v2[64],
  double v3[64]
) {	// L6, [0,605)
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3

  #pragma HLS array_partition variable=v0 cyclic factor=16 dim=1
  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS array_partition variable=v1 cyclic factor=16 dim=1
  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  for (int v4 = 0; v4 < 4; v4 += 1) {	// L8, [0,603), iterCycle=91, II=2
    for (int v5 = 0; v5 < 64; v5 += 1) {	// L9, [0,219), iterCycle=91, II=2
      #pragma HLS pipeline II=2
      double v6 = v1[(v4 * 16)];	// L10, [0,2)
      double v7 = v0[((v5 * 64) + (v4 * 16))];	// L11, [0,2)
      double v8 = v6 * v7;	// L12, [2,6)
      double v9 = v2[v5];	// L13, [4,6)
      double v10;
      if ((v4 * 16) == 0) {	// L14, [6,6)
        v10 = 0.000000;	// L15, [6,6)
      } else {
        v10 = v9;	// L17, [6,6)
      }
      double v11 = v10 + v8;	// L19, [6,11)
      double v12 = v3[v5];	// L20, [84,86)
      double v13 = v1[((v4 * 16) + 1)];	// L21, [5,7)
      double v14 = v0[(((v5 * 64) + (v4 * 16)) + 1)];	// L22, [5,7)
      double v15 = v13 * v14;	// L23, [7,11)
      double v16 = v11 + v15;	// L24, [11,16)
      double v17 = v1[((v4 * 16) + 2)];	// L25, [10,12)
      double v18 = v0[(((v5 * 64) + (v4 * 16)) + 2)];	// L26, [10,12)
      double v19 = v17 * v18;	// L27, [12,16)
      double v20 = v16 + v19;	// L28, [16,21)
      double v21 = v1[((v4 * 16) + 3)];	// L29, [15,17)
      double v22 = v0[(((v5 * 64) + (v4 * 16)) + 3)];	// L30, [15,17)
      double v23 = v21 * v22;	// L31, [17,21)
      double v24 = v20 + v23;	// L32, [21,26)
      double v25 = v1[((v4 * 16) + 4)];	// L33, [20,22)
      double v26 = v0[(((v5 * 64) + (v4 * 16)) + 4)];	// L34, [20,22)
      double v27 = v25 * v26;	// L35, [22,26)
      double v28 = v24 + v27;	// L36, [26,31)
      double v29 = v1[((v4 * 16) + 5)];	// L37, [25,27)
      double v30 = v0[(((v5 * 64) + (v4 * 16)) + 5)];	// L38, [25,27)
      double v31 = v29 * v30;	// L39, [27,31)
      double v32 = v28 + v31;	// L40, [31,36)
      double v33 = v1[((v4 * 16) + 6)];	// L41, [30,32)
      double v34 = v0[(((v5 * 64) + (v4 * 16)) + 6)];	// L42, [30,32)
      double v35 = v33 * v34;	// L43, [32,36)
      double v36 = v32 + v35;	// L44, [36,41)
      double v37 = v1[((v4 * 16) + 7)];	// L45, [35,37)
      double v38 = v0[(((v5 * 64) + (v4 * 16)) + 7)];	// L46, [35,37)
      double v39 = v37 * v38;	// L47, [37,41)
      double v40 = v36 + v39;	// L48, [41,46)
      double v41 = v1[((v4 * 16) + 8)];	// L49, [40,42)
      double v42 = v0[(((v5 * 64) + (v4 * 16)) + 8)];	// L50, [40,42)
      double v43 = v41 * v42;	// L51, [42,46)
      double v44 = v40 + v43;	// L52, [46,51)
      double v45 = v1[((v4 * 16) + 9)];	// L53, [45,47)
      double v46 = v0[(((v5 * 64) + (v4 * 16)) + 9)];	// L54, [45,47)
      double v47 = v45 * v46;	// L55, [47,51)
      double v48 = v44 + v47;	// L56, [51,56)
      double v49 = v1[((v4 * 16) + 10)];	// L57, [50,52)
      double v50 = v0[(((v5 * 64) + (v4 * 16)) + 10)];	// L58, [50,52)
      double v51 = v49 * v50;	// L59, [52,56)
      double v52 = v48 + v51;	// L60, [56,61)
      double v53 = v1[((v4 * 16) + 11)];	// L61, [55,57)
      double v54 = v0[(((v5 * 64) + (v4 * 16)) + 11)];	// L62, [55,57)
      double v55 = v53 * v54;	// L63, [57,61)
      double v56 = v52 + v55;	// L64, [61,66)
      double v57 = v1[((v4 * 16) + 12)];	// L65, [60,62)
      double v58 = v0[(((v5 * 64) + (v4 * 16)) + 12)];	// L66, [60,62)
      double v59 = v57 * v58;	// L67, [62,66)
      double v60 = v56 + v59;	// L68, [66,71)
      double v61 = v1[((v4 * 16) + 13)];	// L69, [65,67)
      double v62 = v0[(((v5 * 64) + (v4 * 16)) + 13)];	// L70, [65,67)
      double v63 = v61 * v62;	// L71, [67,71)
      double v64 = v60 + v63;	// L72, [71,76)
      double v65 = v1[((v4 * 16) + 14)];	// L73, [70,72)
      double v66 = v0[(((v5 * 64) + (v4 * 16)) + 14)];	// L74, [70,72)
      double v67 = v65 * v66;	// L75, [72,76)
      double v68 = v64 + v67;	// L76, [76,81)
      double v69 = v1[((v4 * 16) + 15)];	// L77, [75,77)
      double v70 = v0[(((v5 * 64) + (v4 * 16)) + 15)];	// L78, [75,77)
      double v71 = v69 * v70;	// L79, [77,81)
      double v72 = v68 + v71;	// L80, [81,86)
      v2[v5] = v72;	// L81, [89,90)
      double v73 = v72 * v12;	// L82, [86,90)
      if (((-((v4 * 16) + 15)) + 63) == 0) {	// L83, [90,91)
        v2[v5] = v73;	// L84, [90,91)
      }
    }
  }
}

