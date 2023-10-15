
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

void kernel_mvt_node0(
  float v0[400][400],
  float v1[400],
  float v2[400]
) {	// L6
  #pragma HLS inline
  #pragma HLS array_partition variable=v0 cyclic factor=2 dim=1
  #pragma HLS array_partition variable=v0 cyclic factor=8 dim=2

  #pragma HLS array_partition variable=v1 cyclic factor=2 dim=1

  #pragma HLS array_partition variable=v2 cyclic factor=8 dim=1

  for (int v3 = 0; v3 < 400; v3 += 2) {	// L7
    for (int v4 = 0; v4 < 400; v4 += 8) {	// L8
      #pragma HLS pipeline II=1
      float v5 = v0[v3][v4];	// L9
      float v6 = v1[v3];	// L10
      float v7 = v5 * v6;	// L11
      float v8 = v0[v3][(v4 + 1)];	// L12
      float v9 = v8 * v6;	// L13
      float v10 = v0[v3][(v4 + 2)];	// L14
      float v11 = v10 * v6;	// L15
      float v12 = v0[v3][(v4 + 3)];	// L16
      float v13 = v12 * v6;	// L17
      float v14 = v0[v3][(v4 + 4)];	// L18
      float v15 = v14 * v6;	// L19
      float v16 = v0[v3][(v4 + 5)];	// L20
      float v17 = v16 * v6;	// L21
      float v18 = v0[v3][(v4 + 6)];	// L22
      float v19 = v18 * v6;	// L23
      float v20 = v0[v3][(v4 + 7)];	// L24
      float v21 = v20 * v6;	// L25
      float v22 = v0[(v3 + 1)][v4];	// L26
      float v23 = v1[(v3 + 1)];	// L27
      float v24 = v22 * v23;	// L28
      float v25 = v7 + v24;	// L29
      float v26 = v2[v4];	// L30
      float v27 = v26 + v25;	// L31
      v2[v4] = v27;	// L32
      float v28 = v0[(v3 + 1)][(v4 + 1)];	// L33
      float v29 = v28 * v23;	// L34
      float v30 = v9 + v29;	// L35
      float v31 = v2[(v4 + 1)];	// L36
      float v32 = v31 + v30;	// L37
      v2[(v4 + 1)] = v32;	// L38
      float v33 = v0[(v3 + 1)][(v4 + 2)];	// L39
      float v34 = v33 * v23;	// L40
      float v35 = v11 + v34;	// L41
      float v36 = v2[(v4 + 2)];	// L42
      float v37 = v36 + v35;	// L43
      v2[(v4 + 2)] = v37;	// L44
      float v38 = v0[(v3 + 1)][(v4 + 3)];	// L45
      float v39 = v38 * v23;	// L46
      float v40 = v13 + v39;	// L47
      float v41 = v2[(v4 + 3)];	// L48
      float v42 = v41 + v40;	// L49
      v2[(v4 + 3)] = v42;	// L50
      float v43 = v0[(v3 + 1)][(v4 + 4)];	// L51
      float v44 = v43 * v23;	// L52
      float v45 = v15 + v44;	// L53
      float v46 = v2[(v4 + 4)];	// L54
      float v47 = v46 + v45;	// L55
      v2[(v4 + 4)] = v47;	// L56
      float v48 = v0[(v3 + 1)][(v4 + 5)];	// L57
      float v49 = v48 * v23;	// L58
      float v50 = v17 + v49;	// L59
      float v51 = v2[(v4 + 5)];	// L60
      float v52 = v51 + v50;	// L61
      v2[(v4 + 5)] = v52;	// L62
      float v53 = v0[(v3 + 1)][(v4 + 6)];	// L63
      float v54 = v53 * v23;	// L64
      float v55 = v19 + v54;	// L65
      float v56 = v2[(v4 + 6)];	// L66
      float v57 = v56 + v55;	// L67
      v2[(v4 + 6)] = v57;	// L68
      float v58 = v0[(v3 + 1)][(v4 + 7)];	// L69
      float v59 = v58 * v23;	// L70
      float v60 = v21 + v59;	// L71
      float v61 = v2[(v4 + 7)];	// L72
      float v62 = v61 + v60;	// L73
      v2[(v4 + 7)] = v62;	// L74
    }
  }
}

void kernel_mvt_node1(
  float v63[400][400],
  float v64[400],
  float v65[400]
) {	// L79
  #pragma HLS inline
  #pragma HLS array_partition variable=v63 cyclic factor=8 dim=1
  #pragma HLS array_partition variable=v63 cyclic factor=2 dim=2

  #pragma HLS array_partition variable=v64 cyclic factor=2 dim=1

  #pragma HLS array_partition variable=v65 cyclic factor=8 dim=1

  for (int v66 = 0; v66 < 400; v66 += 2) {	// L80
    for (int v67 = 0; v67 < 400; v67 += 8) {	// L81
      #pragma HLS pipeline II=1
      float v68 = v63[v67][v66];	// L82
      float v69 = v64[v66];	// L83
      float v70 = v68 * v69;	// L84
      float v71 = v63[(v67 + 1)][v66];	// L85
      float v72 = v71 * v69;	// L86
      float v73 = v63[(v67 + 2)][v66];	// L87
      float v74 = v73 * v69;	// L88
      float v75 = v63[(v67 + 3)][v66];	// L89
      float v76 = v75 * v69;	// L90
      float v77 = v63[(v67 + 4)][v66];	// L91
      float v78 = v77 * v69;	// L92
      float v79 = v63[(v67 + 5)][v66];	// L93
      float v80 = v79 * v69;	// L94
      float v81 = v63[(v67 + 6)][v66];	// L95
      float v82 = v81 * v69;	// L96
      float v83 = v63[(v67 + 7)][v66];	// L97
      float v84 = v83 * v69;	// L98
      float v85 = v63[v67][(v66 + 1)];	// L99
      float v86 = v64[(v66 + 1)];	// L100
      float v87 = v85 * v86;	// L101
      float v88 = v70 + v87;	// L102
      float v89 = v65[v67];	// L103
      float v90 = v89 + v88;	// L104
      v65[v67] = v90;	// L105
      float v91 = v63[(v67 + 1)][(v66 + 1)];	// L106
      float v92 = v91 * v86;	// L107
      float v93 = v72 + v92;	// L108
      float v94 = v65[(v67 + 1)];	// L109
      float v95 = v94 + v93;	// L110
      v65[(v67 + 1)] = v95;	// L111
      float v96 = v63[(v67 + 2)][(v66 + 1)];	// L112
      float v97 = v96 * v86;	// L113
      float v98 = v74 + v97;	// L114
      float v99 = v65[(v67 + 2)];	// L115
      float v100 = v99 + v98;	// L116
      v65[(v67 + 2)] = v100;	// L117
      float v101 = v63[(v67 + 3)][(v66 + 1)];	// L118
      float v102 = v101 * v86;	// L119
      float v103 = v76 + v102;	// L120
      float v104 = v65[(v67 + 3)];	// L121
      float v105 = v104 + v103;	// L122
      v65[(v67 + 3)] = v105;	// L123
      float v106 = v63[(v67 + 4)][(v66 + 1)];	// L124
      float v107 = v106 * v86;	// L125
      float v108 = v78 + v107;	// L126
      float v109 = v65[(v67 + 4)];	// L127
      float v110 = v109 + v108;	// L128
      v65[(v67 + 4)] = v110;	// L129
      float v111 = v63[(v67 + 5)][(v66 + 1)];	// L130
      float v112 = v111 * v86;	// L131
      float v113 = v80 + v112;	// L132
      float v114 = v65[(v67 + 5)];	// L133
      float v115 = v114 + v113;	// L134
      v65[(v67 + 5)] = v115;	// L135
      float v116 = v63[(v67 + 6)][(v66 + 1)];	// L136
      float v117 = v116 * v86;	// L137
      float v118 = v82 + v117;	// L138
      float v119 = v65[(v67 + 6)];	// L139
      float v120 = v119 + v118;	// L140
      v65[(v67 + 6)] = v120;	// L141
      float v121 = v63[(v67 + 7)][(v66 + 1)];	// L142
      float v122 = v121 * v86;	// L143
      float v123 = v84 + v122;	// L144
      float v124 = v65[(v67 + 7)];	// L145
      float v125 = v124 + v123;	// L146
      v65[(v67 + 7)] = v125;	// L147
    }
  }
}

/// This is top function.
void kernel_mvt(
  ap_int<32> v126,
  float v127[400],
  float v128[400],
  float v129[400],
  float v130[400],
  float v131[400][400],
  float v132[400][400]
) {	// L152
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v132
  #pragma HLS stable variable=v132
  #pragma HLS array_partition variable=v132 cyclic factor=8 dim=1
  #pragma HLS array_partition variable=v132 cyclic factor=2 dim=2


  #pragma HLS interface ap_memory port=v131
  #pragma HLS stable variable=v131
  #pragma HLS array_partition variable=v131 cyclic factor=2 dim=1
  #pragma HLS array_partition variable=v131 cyclic factor=8 dim=2


  #pragma HLS interface ap_memory port=v130
  #pragma HLS stable variable=v130
  #pragma HLS array_partition variable=v130 cyclic factor=2 dim=1


  #pragma HLS interface ap_memory port=v129
  #pragma HLS stable variable=v129
  #pragma HLS array_partition variable=v129 cyclic factor=2 dim=1


  #pragma HLS interface ap_memory port=v128
  #pragma HLS stable variable=v128
  #pragma HLS array_partition variable=v128 cyclic factor=8 dim=1


  #pragma HLS interface ap_memory port=v127
  #pragma HLS stable variable=v127
  #pragma HLS array_partition variable=v127 cyclic factor=8 dim=1


  kernel_mvt_node1(v132, v129, v127);	// L165
  kernel_mvt_node0(v131, v130, v128);	// L166
}

