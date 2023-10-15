
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

void kernel_gesummv_node0(
  float v0[250],
  float v1[250][250],
  float v2[250][250],
  float v3[250],
  float v4[250],
  float v5,
  float v6
) {	// L9
  #pragma HLS inline
  #pragma HLS array_partition variable=v0 cyclic factor=2 dim=1

  #pragma HLS array_partition variable=v1 cyclic factor=10 dim=1
  #pragma HLS array_partition variable=v1 cyclic factor=2 dim=2

  #pragma HLS array_partition variable=v2 cyclic factor=10 dim=1

  #pragma HLS array_partition variable=v3 cyclic factor=10 dim=1

  #pragma HLS array_partition variable=v4 cyclic factor=10 dim=1

  for (int v7 = 0; v7 < 250; v7 += 2) {	// L11
    for (int v8 = 0; v8 < 250; v8 += 10) {	// L12
      #pragma HLS pipeline II=1
      float v9 = v3[v8];	// L13
      float v10 = (v7 == 0) ? (float)0.000000 : v9;	// L14
      float v11 = v4[v8];	// L15
      float v12 = (v7 == 0) ? (float)0.000000 : v11;	// L16
      float v13 = v1[v8][v7];	// L17
      float v14 = v0[v7];	// L18
      float v15 = v13 * v14;	// L19
      float v16 = v15 + v10;	// L20
      float v17 = v3[(v8 + 1)];	// L21
      float v18 = (v7 == 0) ? (float)0.000000 : v17;	// L22
      float v19 = v4[(v8 + 1)];	// L23
      float v20 = (v7 == 0) ? (float)0.000000 : v19;	// L24
      float v21 = v1[(v8 + 1)][v7];	// L25
      float v22 = v21 * v14;	// L26
      float v23 = v22 + v18;	// L27
      float v24 = v3[(v8 + 2)];	// L28
      float v25 = (v7 == 0) ? (float)0.000000 : v24;	// L29
      float v26 = v4[(v8 + 2)];	// L30
      float v27 = (v7 == 0) ? (float)0.000000 : v26;	// L31
      float v28 = v1[(v8 + 2)][v7];	// L32
      float v29 = v28 * v14;	// L33
      float v30 = v29 + v25;	// L34
      float v31 = v3[(v8 + 3)];	// L35
      float v32 = (v7 == 0) ? (float)0.000000 : v31;	// L36
      float v33 = v4[(v8 + 3)];	// L37
      float v34 = (v7 == 0) ? (float)0.000000 : v33;	// L38
      float v35 = v1[(v8 + 3)][v7];	// L39
      float v36 = v35 * v14;	// L40
      float v37 = v36 + v32;	// L41
      float v38 = v3[(v8 + 4)];	// L42
      float v39 = (v7 == 0) ? (float)0.000000 : v38;	// L43
      float v40 = v4[(v8 + 4)];	// L44
      float v41 = (v7 == 0) ? (float)0.000000 : v40;	// L45
      float v42 = v1[(v8 + 4)][v7];	// L46
      float v43 = v42 * v14;	// L47
      float v44 = v43 + v39;	// L48
      float v45 = v3[(v8 + 5)];	// L49
      float v46 = (v7 == 0) ? (float)0.000000 : v45;	// L50
      float v47 = v4[(v8 + 5)];	// L51
      float v48 = (v7 == 0) ? (float)0.000000 : v47;	// L52
      float v49 = v1[(v8 + 5)][v7];	// L53
      float v50 = v49 * v14;	// L54
      float v51 = v50 + v46;	// L55
      float v52 = v3[(v8 + 6)];	// L56
      float v53 = (v7 == 0) ? (float)0.000000 : v52;	// L57
      float v54 = v4[(v8 + 6)];	// L58
      float v55 = (v7 == 0) ? (float)0.000000 : v54;	// L59
      float v56 = v1[(v8 + 6)][v7];	// L60
      float v57 = v56 * v14;	// L61
      float v58 = v57 + v53;	// L62
      float v59 = v3[(v8 + 7)];	// L63
      float v60 = (v7 == 0) ? (float)0.000000 : v59;	// L64
      float v61 = v4[(v8 + 7)];	// L65
      float v62 = (v7 == 0) ? (float)0.000000 : v61;	// L66
      float v63 = v1[(v8 + 7)][v7];	// L67
      float v64 = v63 * v14;	// L68
      float v65 = v64 + v60;	// L69
      float v66 = v3[(v8 + 8)];	// L70
      float v67 = (v7 == 0) ? (float)0.000000 : v66;	// L71
      float v68 = v4[(v8 + 8)];	// L72
      float v69 = (v7 == 0) ? (float)0.000000 : v68;	// L73
      float v70 = v1[(v8 + 8)][v7];	// L74
      float v71 = v70 * v14;	// L75
      float v72 = v71 + v67;	// L76
      float v73 = v3[(v8 + 9)];	// L77
      float v74 = (v7 == 0) ? (float)0.000000 : v73;	// L78
      float v75 = v4[(v8 + 9)];	// L79
      float v76 = (v7 == 0) ? (float)0.000000 : v75;	// L80
      float v77 = v1[(v8 + 9)][v7];	// L81
      float v78 = v77 * v14;	// L82
      float v79 = v78 + v74;	// L83
      int v80 = (v7 + 1);	// L84
      float v81 = (v80 == 0) ? (float)0.000000 : v16;	// L85
      float v82 = (v80 == 0) ? (float)0.000000 : v12;	// L86
      float v83 = v1[v8][(v7 + 1)];	// L87
      float v84 = v0[(v7 + 1)];	// L88
      float v85 = v83 * v84;	// L89
      float v86 = v85 + v81;	// L90
      v3[v8] = v86;	// L91
      float v87 = v2[v8][(v7 + 1)];	// L92
      float v88 = v87 * v84;	// L93
      float v89 = v88 + v82;	// L94
      float v90 = v5 * v86;	// L95
      float v91 = v6 * v89;	// L96
      float v92 = v90 + v91;	// L97
      float v93 = (((-v80) + 249) == 0) ? v92 : v82;	// L98
      v4[v8] = v93;	// L99
      float v94 = (v80 == 0) ? (float)0.000000 : v23;	// L100
      float v95 = (v80 == 0) ? (float)0.000000 : v20;	// L101
      float v96 = v1[(v8 + 1)][(v7 + 1)];	// L102
      float v97 = v96 * v84;	// L103
      float v98 = v97 + v94;	// L104
      v3[(v8 + 1)] = v98;	// L105
      float v99 = v2[(v8 + 1)][(v7 + 1)];	// L106
      float v100 = v99 * v84;	// L107
      float v101 = v100 + v95;	// L108
      float v102 = v5 * v98;	// L109
      float v103 = v6 * v101;	// L110
      float v104 = v102 + v103;	// L111
      float v105 = (((-v80) + 249) == 0) ? v104 : v95;	// L112
      v4[(v8 + 1)] = v105;	// L113
      float v106 = (v80 == 0) ? (float)0.000000 : v30;	// L114
      float v107 = (v80 == 0) ? (float)0.000000 : v27;	// L115
      float v108 = v1[(v8 + 2)][(v7 + 1)];	// L116
      float v109 = v108 * v84;	// L117
      float v110 = v109 + v106;	// L118
      v3[(v8 + 2)] = v110;	// L119
      float v111 = v2[(v8 + 2)][(v7 + 1)];	// L120
      float v112 = v111 * v84;	// L121
      float v113 = v112 + v107;	// L122
      float v114 = v5 * v110;	// L123
      float v115 = v6 * v113;	// L124
      float v116 = v114 + v115;	// L125
      float v117 = (((-v80) + 249) == 0) ? v116 : v107;	// L126
      v4[(v8 + 2)] = v117;	// L127
      float v118 = (v80 == 0) ? (float)0.000000 : v37;	// L128
      float v119 = (v80 == 0) ? (float)0.000000 : v34;	// L129
      float v120 = v1[(v8 + 3)][(v7 + 1)];	// L130
      float v121 = v120 * v84;	// L131
      float v122 = v121 + v118;	// L132
      v3[(v8 + 3)] = v122;	// L133
      float v123 = v2[(v8 + 3)][(v7 + 1)];	// L134
      float v124 = v123 * v84;	// L135
      float v125 = v124 + v119;	// L136
      float v126 = v5 * v122;	// L137
      float v127 = v6 * v125;	// L138
      float v128 = v126 + v127;	// L139
      float v129 = (((-v80) + 249) == 0) ? v128 : v119;	// L140
      v4[(v8 + 3)] = v129;	// L141
      float v130 = (v80 == 0) ? (float)0.000000 : v44;	// L142
      float v131 = (v80 == 0) ? (float)0.000000 : v41;	// L143
      float v132 = v1[(v8 + 4)][(v7 + 1)];	// L144
      float v133 = v132 * v84;	// L145
      float v134 = v133 + v130;	// L146
      v3[(v8 + 4)] = v134;	// L147
      float v135 = v2[(v8 + 4)][(v7 + 1)];	// L148
      float v136 = v135 * v84;	// L149
      float v137 = v136 + v131;	// L150
      float v138 = v5 * v134;	// L151
      float v139 = v6 * v137;	// L152
      float v140 = v138 + v139;	// L153
      float v141 = (((-v80) + 249) == 0) ? v140 : v131;	// L154
      v4[(v8 + 4)] = v141;	// L155
      float v142 = (v80 == 0) ? (float)0.000000 : v51;	// L156
      float v143 = (v80 == 0) ? (float)0.000000 : v48;	// L157
      float v144 = v1[(v8 + 5)][(v7 + 1)];	// L158
      float v145 = v144 * v84;	// L159
      float v146 = v145 + v142;	// L160
      v3[(v8 + 5)] = v146;	// L161
      float v147 = v2[(v8 + 5)][(v7 + 1)];	// L162
      float v148 = v147 * v84;	// L163
      float v149 = v148 + v143;	// L164
      float v150 = v5 * v146;	// L165
      float v151 = v6 * v149;	// L166
      float v152 = v150 + v151;	// L167
      float v153 = (((-v80) + 249) == 0) ? v152 : v143;	// L168
      v4[(v8 + 5)] = v153;	// L169
      float v154 = (v80 == 0) ? (float)0.000000 : v58;	// L170
      float v155 = (v80 == 0) ? (float)0.000000 : v55;	// L171
      float v156 = v1[(v8 + 6)][(v7 + 1)];	// L172
      float v157 = v156 * v84;	// L173
      float v158 = v157 + v154;	// L174
      v3[(v8 + 6)] = v158;	// L175
      float v159 = v2[(v8 + 6)][(v7 + 1)];	// L176
      float v160 = v159 * v84;	// L177
      float v161 = v160 + v155;	// L178
      float v162 = v5 * v158;	// L179
      float v163 = v6 * v161;	// L180
      float v164 = v162 + v163;	// L181
      float v165 = (((-v80) + 249) == 0) ? v164 : v155;	// L182
      v4[(v8 + 6)] = v165;	// L183
      float v166 = (v80 == 0) ? (float)0.000000 : v65;	// L184
      float v167 = (v80 == 0) ? (float)0.000000 : v62;	// L185
      float v168 = v1[(v8 + 7)][(v7 + 1)];	// L186
      float v169 = v168 * v84;	// L187
      float v170 = v169 + v166;	// L188
      v3[(v8 + 7)] = v170;	// L189
      float v171 = v2[(v8 + 7)][(v7 + 1)];	// L190
      float v172 = v171 * v84;	// L191
      float v173 = v172 + v167;	// L192
      float v174 = v5 * v170;	// L193
      float v175 = v6 * v173;	// L194
      float v176 = v174 + v175;	// L195
      float v177 = (((-v80) + 249) == 0) ? v176 : v167;	// L196
      v4[(v8 + 7)] = v177;	// L197
      float v178 = (v80 == 0) ? (float)0.000000 : v72;	// L198
      float v179 = (v80 == 0) ? (float)0.000000 : v69;	// L199
      float v180 = v1[(v8 + 8)][(v7 + 1)];	// L200
      float v181 = v180 * v84;	// L201
      float v182 = v181 + v178;	// L202
      v3[(v8 + 8)] = v182;	// L203
      float v183 = v2[(v8 + 8)][(v7 + 1)];	// L204
      float v184 = v183 * v84;	// L205
      float v185 = v184 + v179;	// L206
      float v186 = v5 * v182;	// L207
      float v187 = v6 * v185;	// L208
      float v188 = v186 + v187;	// L209
      float v189 = (((-v80) + 249) == 0) ? v188 : v179;	// L210
      v4[(v8 + 8)] = v189;	// L211
      float v190 = (v80 == 0) ? (float)0.000000 : v79;	// L212
      float v191 = (v80 == 0) ? (float)0.000000 : v76;	// L213
      float v192 = v1[(v8 + 9)][(v7 + 1)];	// L214
      float v193 = v192 * v84;	// L215
      float v194 = v193 + v190;	// L216
      v3[(v8 + 9)] = v194;	// L217
      float v195 = v2[(v8 + 9)][(v7 + 1)];	// L218
      float v196 = v195 * v84;	// L219
      float v197 = v196 + v191;	// L220
      float v198 = v5 * v194;	// L221
      float v199 = v6 * v197;	// L222
      float v200 = v198 + v199;	// L223
      float v201 = (((-v80) + 249) == 0) ? v200 : v191;	// L224
      v4[(v8 + 9)] = v201;	// L225
    }
  }
}

/// This is top function.
void kernel_gesummv(
  ap_int<32> v202,
  float v203,
  float v204,
  float v205[250][250],
  float v206[250][250],
  float v207[250],
  float v208[250],
  float v209[250]
) {	// L230
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v209
  #pragma HLS stable variable=v209
  #pragma HLS array_partition variable=v209 cyclic factor=10 dim=1


  #pragma HLS interface ap_memory port=v208
  #pragma HLS stable variable=v208
  #pragma HLS array_partition variable=v208 cyclic factor=2 dim=1


  #pragma HLS interface ap_memory port=v207
  #pragma HLS stable variable=v207
  #pragma HLS array_partition variable=v207 cyclic factor=10 dim=1


  #pragma HLS interface ap_memory port=v206
  #pragma HLS stable variable=v206
  #pragma HLS array_partition variable=v206 cyclic factor=10 dim=1


  #pragma HLS interface ap_memory port=v205
  #pragma HLS stable variable=v205
  #pragma HLS array_partition variable=v205 cyclic factor=10 dim=1
  #pragma HLS array_partition variable=v205 cyclic factor=2 dim=2


  kernel_gesummv_node0(v208, v205, v206, v207, v209, v203, v204);	// L241
}

