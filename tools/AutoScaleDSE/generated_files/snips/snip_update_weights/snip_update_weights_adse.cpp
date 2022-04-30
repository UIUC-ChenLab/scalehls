
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
#include <string.h>

using namespace std;

void update_weights(
  double v0[832],
  double v1[4096],
  double v2[192],
  double v3[832],
  double v4[4096],
  double v5[192],
  double v6[64],
  double v7[64],
  double v8[3],
  double v9[64],
  double v10[64],
  double v11[3]
) {	// L2
  for (int v12 = 0; v12 < 13; v12 += 1) {	// L5
    for (int v13 = 0; v13 < 64; v13 += 1) {	// L6
      double v14 = v3[(v13 + (v12 * 64))];	// L7
      double v15 = v14 * 0.010000;	// L8
      double v16 = v0[(v13 + (v12 * 64))];	// L9
      double v17 = v16 - v15;	// L10
      v0[(v13 + (v12 * 64))] = v17;	// L11
      double v18 = v17 * v17;	// L12
      double v19 = double v20 + v18;	// L13
    }
  }
  for (int v21 = 0; v21 < 64; v21 += 1) {	// L18
    double v22 = v9[v21];	// L19
    double v23 = v22 * 0.010000;	// L20
    double v24 = v6[v21];	// L21
    double v25 = v24 - v23;	// L22
    v6[v21] = v25;	// L23
    double v26 = v25 * v25;	// L24
    double v27 = double v28 + v26;	// L25
  }
  double v29 = sqrt(double v30);	// L28
  double v31 = sqrt(double v32);	// L29
  for (int v33 = 0; v33 < 13; v33 += 1) {	// L30
    for (int v34 = 0; v34 < 64; v34 += 1) {	// L30
      double v35 = v0[(v34 + (v33 * 64))];	// L32
      double v36 = v35 / v29;	// L33
      v0[(v34 + (v33 * 64))] = v36;	// L34
    }
  }
  for (int v37 = 0; v37 < 2; v37 += 1) {	// L37
    for (int v38 = 0; v38 < 32; v38 += 1) {	// L37
      double v39 = v6[(v38 + (v37 * 32))];	// L38
      double v40 = v39 / v31;	// L39
      v6[(v38 + (v37 * 32))] = v40;	// L40
    }
  }
  for (int v41 = 0; v41 < 64; v41 += 1) {	// L42
    for (int v42 = 0; v42 < 64; v42 += 1) {	// L43
      double v43 = v4[(v42 + (v41 * 64))];	// L44
      double v44 = v43 * 0.010000;	// L45
      double v45 = v1[(v42 + (v41 * 64))];	// L46
      double v46 = v45 - v44;	// L47
      v1[(v42 + (v41 * 64))] = v46;	// L48
      double v47 = v46 * v46;	// L49
      double v48 = double v49 + v47;	// L50
    }
  }
  for (int v50 = 0; v50 < 64; v50 += 1) {	// L55
    double v51 = v10[v50];	// L56
    double v52 = v51 * 0.010000;	// L57
    double v53 = v7[v50];	// L58
    double v54 = v53 - v52;	// L59
    v7[v50] = v54;	// L60
    double v55 = v54 * v54;	// L61
    double v56 = double v57 + v55;	// L62
  }
  double v58 = sqrt(double v59);	// L65
  double v60 = sqrt(double v61);	// L66
  for (int v62 = 0; v62 < 32; v62 += 1) {	// L67
    for (int v63 = 0; v63 < 2; v63 += 1) {	// L67
      for (int v64 = 0; v64 < 64; v64 += 1) {	// L67
        double v65 = v1[((v64 + (v63 * 64)) + (v62 * 128))];	// L69
        double v66 = v65 / v58;	// L70
        v1[((v64 + (v63 * 64)) + (v62 * 128))] = v66;	// L71
      }
    }
  }
  for (int v67 = 0; v67 < 2; v67 += 1) {	// L74
    for (int v68 = 0; v68 < 32; v68 += 1) {	// L74
      double v69 = v7[(v68 + (v67 * 32))];	// L75
      double v70 = v69 / v60;	// L76
      v7[(v68 + (v67 * 32))] = v70;	// L77
    }
  }
  for (int v71 = 0; v71 < 64; v71 += 1) {	// L79
    for (int v72 = 0; v72 < 3; v72 += 1) {	// L80
      double v73 = v5[(v72 + (v71 * 3))];	// L81
      double v74 = v73 * 0.010000;	// L82
      double v75 = v2[(v72 + (v71 * 3))];	// L83
      double v76 = v75 - v74;	// L84
      v2[(v72 + (v71 * 3))] = v76;	// L85
      double v77 = v76 * v76;	// L86
      double v78 = double v79 + v77;	// L87
    }
  }
  for (int v80 = 0; v80 < 3; v80 += 1) {	// L92
    double v81 = v11[v80];	// L93
    double v82 = v81 * 0.010000;	// L94
    double v83 = v8[v80];	// L95
    double v84 = v83 - v82;	// L96
    v8[v80] = v84;	// L97
    double v85 = v84 * v84;	// L98
    double v86 = double v87 + v85;	// L99
  }
  double v88 = sqrt(double v89);	// L102
  double v90 = sqrt(double v91);	// L103
  for (int v92 = 0; v92 < 2; v92 += 1) {	// L104
    for (int v93 = 0; v93 < 32; v93 += 1) {	// L104
      for (int v94 = 0; v94 < 3; v94 += 1) {	// L104
        double v95 = v2[((v94 + (v93 * 3)) + (v92 * 96))];	// L106
        double v96 = v95 / v88;	// L107
        v2[((v94 + (v93 * 3)) + (v92 * 96))] = v96;	// L108
      }
    }
  }
  for (int v97 = 0; v97 < 3; v97 += 1) {	// L111
    double v98 = v8[v97];	// L112
    double v99 = v98 / v90;	// L113
    v8[v97] = v99;	// L114
  }
}

