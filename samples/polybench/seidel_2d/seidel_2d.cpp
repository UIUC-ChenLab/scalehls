
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

void kernel_seidel_2d_node0(
  float v0[400][400]
) {	// L3
  #pragma HLS inline
  #pragma HLS array_partition variable=v0 cyclic factor=4 dim=1
  #pragma HLS array_partition variable=v0 cyclic factor=4 dim=2

  for (int v1 = 0; v1 < 100; v1 += 4) {	// L5
    for (int v2 = 0; v2 < 398; v2 += 2) {	// L6
      for (int v3 = 0; v3 < 398; v3 += 2) {	// L7
        #pragma HLS pipeline II=1
        float v4 = v0[v2][v3];	// L8
        float v5 = v0[v2][(v3 + 1)];	// L9
        float v6 = v4 + v5;	// L10
        float v7 = v0[v2][(v3 + 2)];	// L11
        float v8 = v6 + v7;	// L12
        float v9 = v0[(v2 + 1)][v3];	// L13
        float v10 = v8 + v9;	// L14
        float v11 = v0[(v2 + 1)][(v3 + 1)];	// L15
        float v12 = v10 + v11;	// L16
        float v13 = v0[(v2 + 1)][(v3 + 2)];	// L17
        float v14 = v12 + v13;	// L18
        float v15 = v0[(v2 + 2)][v3];	// L19
        float v16 = v14 + v15;	// L20
        float v17 = v0[(v2 + 2)][(v3 + 1)];	// L21
        float v18 = v16 + v17;	// L22
        float v19 = v0[(v2 + 2)][(v3 + 2)];	// L23
        float v20 = v18 + v19;	// L24
        float v21 = v20 / (float)9.000000;	// L25
        float v22 = v5 + v7;	// L26
        float v23 = v0[v2][(v3 + 3)];	// L27
        float v24 = v22 + v23;	// L28
        float v25 = v24 + v21;	// L29
        float v26 = v25 + v13;	// L30
        float v27 = v0[(v2 + 1)][(v3 + 3)];	// L31
        float v28 = v26 + v27;	// L32
        float v29 = v28 + v17;	// L33
        float v30 = v29 + v19;	// L34
        float v31 = v0[(v2 + 2)][(v3 + 3)];	// L35
        float v32 = v30 + v31;	// L36
        float v33 = v32 / (float)9.000000;	// L37
        float v34 = v9 + v21;	// L38
        float v35 = v34 + v33;	// L39
        float v36 = v35 + v15;	// L40
        float v37 = v36 + v17;	// L41
        float v38 = v37 + v19;	// L42
        float v39 = v0[(v2 + 3)][v3];	// L43
        float v40 = v38 + v39;	// L44
        float v41 = v0[(v2 + 3)][(v3 + 1)];	// L45
        float v42 = v40 + v41;	// L46
        float v43 = v0[(v2 + 3)][(v3 + 2)];	// L47
        float v44 = v42 + v43;	// L48
        float v45 = v44 / (float)9.000000;	// L49
        float v46 = v21 + v33;	// L50
        float v47 = v46 + v27;	// L51
        float v48 = v47 + v45;	// L52
        float v49 = v48 + v19;	// L53
        float v50 = v49 + v31;	// L54
        float v51 = v50 + v41;	// L55
        float v52 = v51 + v43;	// L56
        float v53 = v0[(v2 + 3)][(v3 + 3)];	// L57
        float v54 = v52 + v53;	// L58
        float v55 = v54 / (float)9.000000;	// L59
        float v56 = v4 + v5;	// L60
        float v57 = v56 + v7;	// L61
        float v58 = v57 + v9;	// L62
        float v59 = v58 + v21;	// L63
        float v60 = v59 + v33;	// L64
        float v61 = v60 + v15;	// L65
        float v62 = v61 + v45;	// L66
        float v63 = v62 + v55;	// L67
        float v64 = v63 / (float)9.000000;	// L68
        float v65 = v5 + v7;	// L69
        float v66 = v65 + v23;	// L70
        float v67 = v66 + v64;	// L71
        float v68 = v67 + v33;	// L72
        float v69 = v68 + v27;	// L73
        float v70 = v69 + v45;	// L74
        float v71 = v70 + v55;	// L75
        float v72 = v71 + v31;	// L76
        float v73 = v72 / (float)9.000000;	// L77
        float v74 = v9 + v64;	// L78
        float v75 = v74 + v73;	// L79
        float v76 = v75 + v15;	// L80
        float v77 = v76 + v45;	// L81
        float v78 = v77 + v55;	// L82
        float v79 = v78 + v39;	// L83
        float v80 = v79 + v41;	// L84
        float v81 = v80 + v43;	// L85
        float v82 = v81 / (float)9.000000;	// L86
        float v83 = v64 + v73;	// L87
        float v84 = v83 + v27;	// L88
        float v85 = v84 + v82;	// L89
        float v86 = v85 + v55;	// L90
        float v87 = v86 + v31;	// L91
        float v88 = v87 + v41;	// L92
        float v89 = v88 + v43;	// L93
        float v90 = v89 + v53;	// L94
        float v91 = v90 / (float)9.000000;	// L95
        float v92 = v4 + v5;	// L96
        float v93 = v92 + v7;	// L97
        float v94 = v93 + v9;	// L98
        float v95 = v94 + v64;	// L99
        float v96 = v95 + v73;	// L100
        float v97 = v96 + v15;	// L101
        float v98 = v97 + v82;	// L102
        float v99 = v98 + v91;	// L103
        float v100 = v99 / (float)9.000000;	// L104
        float v101 = v5 + v7;	// L105
        float v102 = v101 + v23;	// L106
        float v103 = v102 + v100;	// L107
        float v104 = v103 + v73;	// L108
        float v105 = v104 + v27;	// L109
        float v106 = v105 + v82;	// L110
        float v107 = v106 + v91;	// L111
        float v108 = v107 + v31;	// L112
        float v109 = v108 / (float)9.000000;	// L113
        float v110 = v9 + v100;	// L114
        float v111 = v110 + v109;	// L115
        float v112 = v111 + v15;	// L116
        float v113 = v112 + v82;	// L117
        float v114 = v113 + v91;	// L118
        float v115 = v114 + v39;	// L119
        float v116 = v115 + v41;	// L120
        float v117 = v116 + v43;	// L121
        float v118 = v117 / (float)9.000000;	// L122
        float v119 = v100 + v109;	// L123
        float v120 = v119 + v27;	// L124
        float v121 = v120 + v118;	// L125
        float v122 = v121 + v91;	// L126
        float v123 = v122 + v31;	// L127
        float v124 = v123 + v41;	// L128
        float v125 = v124 + v43;	// L129
        float v126 = v125 + v53;	// L130
        float v127 = v126 / (float)9.000000;	// L131
        float v128 = v4 + v5;	// L132
        float v129 = v128 + v7;	// L133
        float v130 = v129 + v9;	// L134
        float v131 = v130 + v100;	// L135
        float v132 = v131 + v109;	// L136
        float v133 = v132 + v15;	// L137
        float v134 = v133 + v118;	// L138
        float v135 = v134 + v127;	// L139
        float v136 = v135 / (float)9.000000;	// L140
        v0[(v2 + 1)][(v3 + 1)] = v136;	// L141
        float v137 = v5 + v7;	// L142
        float v138 = v137 + v23;	// L143
        float v139 = v138 + v136;	// L144
        float v140 = v139 + v109;	// L145
        float v141 = v140 + v27;	// L146
        float v142 = v141 + v118;	// L147
        float v143 = v142 + v127;	// L148
        float v144 = v143 + v31;	// L149
        float v145 = v144 / (float)9.000000;	// L150
        v0[(v2 + 1)][(v3 + 2)] = v145;	// L151
        float v146 = v9 + v136;	// L152
        float v147 = v146 + v145;	// L153
        float v148 = v147 + v15;	// L154
        float v149 = v148 + v118;	// L155
        float v150 = v149 + v127;	// L156
        float v151 = v150 + v39;	// L157
        float v152 = v151 + v41;	// L158
        float v153 = v152 + v43;	// L159
        float v154 = v153 / (float)9.000000;	// L160
        v0[(v2 + 2)][(v3 + 1)] = v154;	// L161
        float v155 = v136 + v145;	// L162
        float v156 = v155 + v27;	// L163
        float v157 = v156 + v154;	// L164
        float v158 = v157 + v127;	// L165
        float v159 = v158 + v31;	// L166
        float v160 = v159 + v41;	// L167
        float v161 = v160 + v43;	// L168
        float v162 = v161 + v53;	// L169
        float v163 = v162 / (float)9.000000;	// L170
        v0[(v2 + 2)][(v3 + 2)] = v163;	// L171
      }
    }
  }
}

/// This is top function.
void kernel_seidel_2d(
  ap_int<32> v164,
  ap_int<32> v165,
  float v166[400][400]
) {	// L177
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v166
  #pragma HLS stable variable=v166
  #pragma HLS array_partition variable=v166 cyclic factor=4 dim=1
  #pragma HLS array_partition variable=v166 cyclic factor=4 dim=2


  kernel_seidel_2d_node0(v166);	// L180
}

