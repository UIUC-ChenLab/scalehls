
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
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4
  #pragma HLS interface bram port=v5
  #pragma HLS interface bram port=v6
  #pragma HLS interface bram port=v7
  #pragma HLS interface bram port=v8
  #pragma HLS interface bram port=v9
  #pragma HLS interface bram port=v10
  #pragma HLS interface bram port=v11

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS resource variable=v4 core=ram_s2p_bram

  #pragma HLS resource variable=v5 core=ram_s2p_bram

  #pragma HLS resource variable=v6 core=ram_s2p_bram

  #pragma HLS resource variable=v7 core=ram_s2p_bram

  #pragma HLS resource variable=v8 core=ram_s2p_bram

  #pragma HLS resource variable=v9 core=ram_s2p_bram

  #pragma HLS resource variable=v10 core=ram_s2p_bram

  #pragma HLS resource variable=v11 core=ram_s2p_bram

  double v12[1];	// L5
  v12[0] = 0.000000;	// L6
  double v13[1];	// L7
  v13[0] = 0.000000;	// L8
  double v14[1];	// L11
  double v15[1];	// L13
  for (int v16 = 0; v16 < 13; v16 += 1) {	// L9
    for (int v17 = 0; v17 < 64; v17 += 1) {	// L9
      double v18 = v12[0];	// L10
      v14[0] = v18;	// L12
      v15[0] = v18;	// L14
      double v19 = v14[0];	// L16
      double v20 = v3[(v17 + (v16 * 64))];	// L17
      double v21 = v20 * 0.010000;	// L18
      double v22 = v0[(v17 + (v16 * 64))];	// L19
      double v23 = v22 - v21;	// L20
      v0[(v17 + (v16 * 64))] = v23;	// L21
      double v24 = v23 * v23;	// L22
      double v25 = v19 + v24;	// L23
      v14[0] = v25;	// L24
      v15[0] = v25;	// L25
      double v26 = v15[0];	// L27
      v12[0] = v26;	// L28
      v13[0] = v26;	// L29
    }
  }
  double v27 = v13[0];	// L31
  double v28[1];	// L32
  v28[0] = 0.000000;	// L33
  double v29[1];	// L34
  v29[0] = 0.000000;	// L35
  for (int v30 = 0; v30 < 8; v30 += 1) {	// L36
    for (int v31 = 0; v31 < 8; v31 += 1) {	// L36
      int v32 = (v31 + (v30 * 8));	// L36
      double v33 = v28[0];	// L37
      double v34 = v9[v32];	// L38
      double v35 = v34 * 0.010000;	// L39
      double v36 = v6[v32];	// L40
      double v37 = v36 - v35;	// L41
      v6[v32] = v37;	// L42
      double v38 = v37 * v37;	// L43
      double v39 = v33 + v38;	// L44
      v28[0] = v39;	// L45
      v29[0] = v39;	// L46
    }
  }
  double v40 = v29[0];	// L48
  double v41 = sqrt(v27);	// L49
  double v42 = sqrt(v40);	// L50
  for (int v43 = 0; v43 < 13; v43 += 1) {	// L51
    for (int v44 = 0; v44 < 64; v44 += 1) {	// L51
      double v45 = v0[(v44 + (v43 * 64))];	// L53
      double v46 = v45 / v41;	// L54
      v0[(v44 + (v43 * 64))] = v46;	// L55
    }
  }
  for (int v47 = 0; v47 < 2; v47 += 1) {	// L58
    for (int v48 = 0; v48 < 32; v48 += 1) {	// L58
      int v49 = (v48 + (v47 * 32));	// L58
      double v50 = v6[v49];	// L59
      double v51 = v50 / v42;	// L60
      v6[v49] = v51;	// L61
    }
  }
  double v52[1];	// L63
  v52[0] = 0.000000;	// L64
  double v53[1];	// L65
  v53[0] = 0.000000;	// L66
  double v54[1];	// L69
  double v55[1];	// L71
  for (int v56 = 0; v56 < 64; v56 += 1) {	// L67
    for (int v57 = 0; v57 < 64; v57 += 1) {	// L67
      double v58 = v52[0];	// L68
      v54[0] = v58;	// L70
      v55[0] = v58;	// L72
      double v59 = v54[0];	// L74
      double v60 = v4[(v57 + (v56 * 64))];	// L75
      double v61 = v60 * 0.010000;	// L76
      double v62 = v1[(v57 + (v56 * 64))];	// L77
      double v63 = v62 - v61;	// L78
      v1[(v57 + (v56 * 64))] = v63;	// L79
      double v64 = v63 * v63;	// L80
      double v65 = v59 + v64;	// L81
      v54[0] = v65;	// L82
      v55[0] = v65;	// L83
      double v66 = v55[0];	// L85
      v52[0] = v66;	// L86
      v53[0] = v66;	// L87
    }
  }
  double v67 = v53[0];	// L89
  double v68[1];	// L90
  v68[0] = 0.000000;	// L91
  double v69[1];	// L92
  v69[0] = 0.000000;	// L93
  for (int v70 = 0; v70 < 8; v70 += 1) {	// L94
    for (int v71 = 0; v71 < 8; v71 += 1) {	// L94
      int v72 = (v71 + (v70 * 8));	// L94
      double v73 = v68[0];	// L95
      double v74 = v10[v72];	// L96
      double v75 = v74 * 0.010000;	// L97
      double v76 = v7[v72];	// L98
      double v77 = v76 - v75;	// L99
      v7[v72] = v77;	// L100
      double v78 = v77 * v77;	// L101
      double v79 = v73 + v78;	// L102
      v68[0] = v79;	// L103
      v69[0] = v79;	// L104
    }
  }
  double v80 = v69[0];	// L106
  double v81 = sqrt(v67);	// L107
  double v82 = sqrt(v80);	// L108
  for (int v83 = 0; v83 < 32; v83 += 1) {	// L109
    for (int v84 = 0; v84 < 2; v84 += 1) {	// L109
      int v85 = (v84 + (v83 * 2));	// L109
      for (int v86 = 0; v86 < 64; v86 += 1) {	// L109
        double v87 = v1[(v86 + (v85 * 64))];	// L111
        double v88 = v87 / v81;	// L112
        v1[(v86 + (v85 * 64))] = v88;	// L113
      }
    }
  }
  for (int v89 = 0; v89 < 2; v89 += 1) {	// L116
    for (int v90 = 0; v90 < 32; v90 += 1) {	// L116
      int v91 = (v90 + (v89 * 32));	// L116
      double v92 = v7[v91];	// L117
      double v93 = v92 / v82;	// L118
      v7[v91] = v93;	// L119
    }
  }
  double v94[1];	// L121
  v94[0] = 0.000000;	// L122
  double v95[1];	// L123
  v95[0] = 0.000000;	// L124
  double v96[1];	// L127
  double v97[1];	// L129
  for (int v98 = 0; v98 < 16; v98 += 1) {	// L125
    for (int v99 = 0; v99 < 4; v99 += 1) {	// L125
      int v100 = (v99 + (v98 * 4));	// L125
      for (int v101 = 0; v101 < 3; v101 += 1) {	// L125
        double v102 = v94[0];	// L126
        v96[0] = v102;	// L128
        v97[0] = v102;	// L130
        double v103 = v96[0];	// L132
        double v104 = v5[(v101 + (v100 * 3))];	// L133
        double v105 = v104 * 0.010000;	// L134
        double v106 = v2[(v101 + (v100 * 3))];	// L135
        double v107 = v106 - v105;	// L136
        v2[(v101 + (v100 * 3))] = v107;	// L137
        double v108 = v107 * v107;	// L138
        double v109 = v103 + v108;	// L139
        v96[0] = v109;	// L140
        v97[0] = v109;	// L141
        double v110 = v97[0];	// L143
        v94[0] = v110;	// L144
        v95[0] = v110;	// L145
      }
    }
  }
  double v111 = v95[0];	// L147
  double v112[1];	// L148
  v112[0] = 0.000000;	// L149
  double v113[1];	// L150
  v113[0] = 0.000000;	// L151
  for (int v114 = 0; v114 < 3; v114 += 1) {	// L152
    double v115 = v112[0];	// L153
    double v116 = v11[v114];	// L154
    double v117 = v116 * 0.010000;	// L155
    double v118 = v8[v114];	// L156
    double v119 = v118 - v117;	// L157
    v8[v114] = v119;	// L158
    double v120 = v119 * v119;	// L159
    double v121 = v115 + v120;	// L160
    v112[0] = v121;	// L161
    v113[0] = v121;	// L162
  }
  double v122 = v113[0];	// L164
  double v123 = sqrt(v111);	// L165
  double v124 = sqrt(v122);	// L166
  for (int v125 = 0; v125 < 2; v125 += 1) {	// L167
    for (int v126 = 0; v126 < 32; v126 += 1) {	// L167
      int v127 = (v126 + (v125 * 32));	// L167
      for (int v128 = 0; v128 < 3; v128 += 1) {	// L167
        double v129 = v2[(v128 + (v127 * 3))];	// L169
        double v130 = v129 / v123;	// L170
        v2[(v128 + (v127 * 3))] = v130;	// L171
      }
    }
  }
  for (int v131 = 0; v131 < 3; v131 += 1) {	// L174
    double v132 = v8[v131];	// L175
    double v133 = v132 / v124;	// L176
    v8[v131] = v133;	// L177
  }
}

