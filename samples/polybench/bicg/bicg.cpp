
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

void kernel_bicg_node0(
  float v0[390],
  float v1[410],
  float v2[410][390],
  float v3[390],
  float v4[410]
) {	// L16
  #pragma HLS array_partition variable=v0 cyclic factor=10 dim=1

  #pragma HLS array_partition variable=v1 cyclic factor=2 dim=1

  #pragma HLS array_partition variable=v2 cyclic factor=2 dim=1
  #pragma HLS array_partition variable=v2 cyclic factor=10 dim=2

  #pragma HLS array_partition variable=v3 cyclic factor=26 dim=1

  #pragma HLS array_partition variable=v4 cyclic factor=2 dim=1

  for (int v5 = 0; v5 < 390; v5 += 26) {	// L18
    #pragma HLS pipeline II=1
    v3[v5] = (float)0.000000;	// L19
    v3[(v5 + 1)] = (float)0.000000;	// L20
    v3[(v5 + 2)] = (float)0.000000;	// L21
    v3[(v5 + 3)] = (float)0.000000;	// L22
    v3[(v5 + 4)] = (float)0.000000;	// L23
    v3[(v5 + 5)] = (float)0.000000;	// L24
    v3[(v5 + 6)] = (float)0.000000;	// L25
    v3[(v5 + 7)] = (float)0.000000;	// L26
    v3[(v5 + 8)] = (float)0.000000;	// L27
    v3[(v5 + 9)] = (float)0.000000;	// L28
    v3[(v5 + 10)] = (float)0.000000;	// L29
    v3[(v5 + 11)] = (float)0.000000;	// L30
    v3[(v5 + 12)] = (float)0.000000;	// L31
    v3[(v5 + 13)] = (float)0.000000;	// L32
    v3[(v5 + 14)] = (float)0.000000;	// L33
    v3[(v5 + 15)] = (float)0.000000;	// L34
    v3[(v5 + 16)] = (float)0.000000;	// L35
    v3[(v5 + 17)] = (float)0.000000;	// L36
    v3[(v5 + 18)] = (float)0.000000;	// L37
    v3[(v5 + 19)] = (float)0.000000;	// L38
    v3[(v5 + 20)] = (float)0.000000;	// L39
    v3[(v5 + 21)] = (float)0.000000;	// L40
    v3[(v5 + 22)] = (float)0.000000;	// L41
    v3[(v5 + 23)] = (float)0.000000;	// L42
    v3[(v5 + 24)] = (float)0.000000;	// L43
    v3[(v5 + 25)] = (float)0.000000;	// L44
  }
  for (int v6 = 0; v6 < 390; v6 += 10) {	// L46
    for (int v7 = 0; v7 < 410; v7 += 2) {	// L47
      #pragma HLS pipeline II=1
      float v8 = v4[v7];	// L48
      float v9 = (v6 == 0) ? (float)0.000000 : v8;	// L49
      float v10 = v1[v7];	// L50
      float v11 = v2[v7][v6];	// L51
      float v12 = v10 * v11;	// L52
      float v13 = v0[v6];	// L53
      float v14 = v11 * v13;	// L54
      float v15 = v9 + v14;	// L55
      float v16 = v4[(v7 + 1)];	// L56
      float v17 = (v6 == 0) ? (float)0.000000 : v16;	// L57
      float v18 = v1[(v7 + 1)];	// L58
      float v19 = v2[(v7 + 1)][v6];	// L59
      float v20 = v18 * v19;	// L60
      float v21 = v12 + v20;	// L61
      float v22 = v3[v6];	// L62
      float v23 = v22 + v21;	// L63
      v3[v6] = v23;	// L64
      float v24 = v19 * v13;	// L65
      float v25 = v17 + v24;	// L66
      int v26 = (v6 + 1);	// L67
      float v27 = (v26 == 0) ? (float)0.000000 : v15;	// L68
      float v28 = v2[v7][(v6 + 1)];	// L69
      float v29 = v10 * v28;	// L70
      float v30 = v0[(v6 + 1)];	// L71
      float v31 = v28 * v30;	// L72
      float v32 = v27 + v31;	// L73
      float v33 = (v26 == 0) ? (float)0.000000 : v25;	// L74
      float v34 = v2[(v7 + 1)][(v6 + 1)];	// L75
      float v35 = v18 * v34;	// L76
      float v36 = v29 + v35;	// L77
      float v37 = v3[(v6 + 1)];	// L78
      float v38 = v37 + v36;	// L79
      v3[(v6 + 1)] = v38;	// L80
      float v39 = v34 * v30;	// L81
      float v40 = v33 + v39;	// L82
      int v41 = (v6 + 2);	// L83
      float v42 = (v41 == 0) ? (float)0.000000 : v32;	// L84
      float v43 = v2[v7][(v6 + 2)];	// L85
      float v44 = v10 * v43;	// L86
      float v45 = v0[(v6 + 2)];	// L87
      float v46 = v43 * v45;	// L88
      float v47 = v42 + v46;	// L89
      float v48 = (v41 == 0) ? (float)0.000000 : v40;	// L90
      float v49 = v2[(v7 + 1)][(v6 + 2)];	// L91
      float v50 = v18 * v49;	// L92
      float v51 = v44 + v50;	// L93
      float v52 = v3[(v6 + 2)];	// L94
      float v53 = v52 + v51;	// L95
      v3[(v6 + 2)] = v53;	// L96
      float v54 = v49 * v45;	// L97
      float v55 = v48 + v54;	// L98
      int v56 = (v6 + 3);	// L99
      float v57 = (v56 == 0) ? (float)0.000000 : v47;	// L100
      float v58 = v2[v7][(v6 + 3)];	// L101
      float v59 = v10 * v58;	// L102
      float v60 = v0[(v6 + 3)];	// L103
      float v61 = v58 * v60;	// L104
      float v62 = v57 + v61;	// L105
      float v63 = (v56 == 0) ? (float)0.000000 : v55;	// L106
      float v64 = v2[(v7 + 1)][(v6 + 3)];	// L107
      float v65 = v18 * v64;	// L108
      float v66 = v59 + v65;	// L109
      float v67 = v3[(v6 + 3)];	// L110
      float v68 = v67 + v66;	// L111
      v3[(v6 + 3)] = v68;	// L112
      float v69 = v64 * v60;	// L113
      float v70 = v63 + v69;	// L114
      int v71 = (v6 + 4);	// L115
      float v72 = (v71 == 0) ? (float)0.000000 : v62;	// L116
      float v73 = v2[v7][(v6 + 4)];	// L117
      float v74 = v10 * v73;	// L118
      float v75 = v0[(v6 + 4)];	// L119
      float v76 = v73 * v75;	// L120
      float v77 = v72 + v76;	// L121
      float v78 = (v71 == 0) ? (float)0.000000 : v70;	// L122
      float v79 = v2[(v7 + 1)][(v6 + 4)];	// L123
      float v80 = v18 * v79;	// L124
      float v81 = v74 + v80;	// L125
      float v82 = v3[(v6 + 4)];	// L126
      float v83 = v82 + v81;	// L127
      v3[(v6 + 4)] = v83;	// L128
      float v84 = v79 * v75;	// L129
      float v85 = v78 + v84;	// L130
      int v86 = (v6 + 5);	// L131
      float v87 = (v86 == 0) ? (float)0.000000 : v77;	// L132
      float v88 = v2[v7][(v6 + 5)];	// L133
      float v89 = v10 * v88;	// L134
      float v90 = v0[(v6 + 5)];	// L135
      float v91 = v88 * v90;	// L136
      float v92 = v87 + v91;	// L137
      float v93 = (v86 == 0) ? (float)0.000000 : v85;	// L138
      float v94 = v2[(v7 + 1)][(v6 + 5)];	// L139
      float v95 = v18 * v94;	// L140
      float v96 = v89 + v95;	// L141
      float v97 = v3[(v6 + 5)];	// L142
      float v98 = v97 + v96;	// L143
      v3[(v6 + 5)] = v98;	// L144
      float v99 = v94 * v90;	// L145
      float v100 = v93 + v99;	// L146
      int v101 = (v6 + 6);	// L147
      float v102 = (v101 == 0) ? (float)0.000000 : v92;	// L148
      float v103 = v2[v7][(v6 + 6)];	// L149
      float v104 = v10 * v103;	// L150
      float v105 = v0[(v6 + 6)];	// L151
      float v106 = v103 * v105;	// L152
      float v107 = v102 + v106;	// L153
      float v108 = (v101 == 0) ? (float)0.000000 : v100;	// L154
      float v109 = v2[(v7 + 1)][(v6 + 6)];	// L155
      float v110 = v18 * v109;	// L156
      float v111 = v104 + v110;	// L157
      float v112 = v3[(v6 + 6)];	// L158
      float v113 = v112 + v111;	// L159
      v3[(v6 + 6)] = v113;	// L160
      float v114 = v109 * v105;	// L161
      float v115 = v108 + v114;	// L162
      int v116 = (v6 + 7);	// L163
      float v117 = (v116 == 0) ? (float)0.000000 : v107;	// L164
      float v118 = v2[v7][(v6 + 7)];	// L165
      float v119 = v10 * v118;	// L166
      float v120 = v0[(v6 + 7)];	// L167
      float v121 = v118 * v120;	// L168
      float v122 = v117 + v121;	// L169
      float v123 = (v116 == 0) ? (float)0.000000 : v115;	// L170
      float v124 = v2[(v7 + 1)][(v6 + 7)];	// L171
      float v125 = v18 * v124;	// L172
      float v126 = v119 + v125;	// L173
      float v127 = v3[(v6 + 7)];	// L174
      float v128 = v127 + v126;	// L175
      v3[(v6 + 7)] = v128;	// L176
      float v129 = v124 * v120;	// L177
      float v130 = v123 + v129;	// L178
      int v131 = (v6 + 8);	// L179
      float v132 = (v131 == 0) ? (float)0.000000 : v122;	// L180
      float v133 = v2[v7][(v6 + 8)];	// L181
      float v134 = v10 * v133;	// L182
      float v135 = v0[(v6 + 8)];	// L183
      float v136 = v133 * v135;	// L184
      float v137 = v132 + v136;	// L185
      float v138 = (v131 == 0) ? (float)0.000000 : v130;	// L186
      float v139 = v2[(v7 + 1)][(v6 + 8)];	// L187
      float v140 = v18 * v139;	// L188
      float v141 = v134 + v140;	// L189
      float v142 = v3[(v6 + 8)];	// L190
      float v143 = v142 + v141;	// L191
      v3[(v6 + 8)] = v143;	// L192
      float v144 = v139 * v135;	// L193
      float v145 = v138 + v144;	// L194
      int v146 = (v6 + 9);	// L195
      float v147 = (v146 == 0) ? (float)0.000000 : v137;	// L196
      float v148 = v2[v7][(v6 + 9)];	// L197
      float v149 = v10 * v148;	// L198
      float v150 = v0[(v6 + 9)];	// L199
      float v151 = v148 * v150;	// L200
      float v152 = v147 + v151;	// L201
      v4[v7] = v152;	// L202
      float v153 = (v146 == 0) ? (float)0.000000 : v145;	// L203
      float v154 = v2[(v7 + 1)][(v6 + 9)];	// L204
      float v155 = v18 * v154;	// L205
      float v156 = v149 + v155;	// L206
      float v157 = v3[(v6 + 9)];	// L207
      float v158 = v157 + v156;	// L208
      v3[(v6 + 9)] = v158;	// L209
      float v159 = v154 * v150;	// L210
      float v160 = v153 + v159;	// L211
      v4[(v7 + 1)] = v160;	// L212
    }
  }
}

/// This is top function.
void kernel_bicg(
  ap_int<32> v161,
  ap_int<32> v162,
  float v163[410][390],
  float v164[390],
  float v165[410],
  float v166[390],
  float v167[410]
) {	// L217
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v167
  #pragma HLS stable variable=v167
  #pragma HLS array_partition variable=v167 cyclic factor=2 dim=1


  #pragma HLS interface ap_memory port=v166
  #pragma HLS stable variable=v166
  #pragma HLS array_partition variable=v166 cyclic factor=10 dim=1


  #pragma HLS interface ap_memory port=v165
  #pragma HLS stable variable=v165
  #pragma HLS array_partition variable=v165 cyclic factor=2 dim=1


  #pragma HLS interface ap_memory port=v164
  #pragma HLS stable variable=v164
  #pragma HLS array_partition variable=v164 cyclic factor=26 dim=1


  #pragma HLS interface ap_memory port=v163
  #pragma HLS stable variable=v163
  #pragma HLS array_partition variable=v163 cyclic factor=2 dim=1
  #pragma HLS array_partition variable=v163 cyclic factor=10 dim=2


  kernel_bicg_node0(v166, v167, v163, v164, v165);	// L228
}

