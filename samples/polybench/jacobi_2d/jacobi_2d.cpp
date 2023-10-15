
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

void kernel_jacobi_2d_node1(
  float v0[250][250],
  float v1[250][250]
) {	// L4
  #pragma HLS inline
  #pragma HLS array_partition variable=v0 cyclic factor=6 dim=1
  #pragma HLS array_partition variable=v0 cyclic factor=6 dim=2

  #pragma HLS array_partition variable=v1 cyclic factor=4 dim=1
  #pragma HLS array_partition variable=v1 cyclic factor=4 dim=2

  for (int v2 = 0; v2 < 248; v2 += 4) {	// L6
    for (int v3 = 0; v3 < 248; v3 += 4) {	// L7
      #pragma HLS pipeline II=1
      float v4 = v0[(v2 + 1)][(v3 + 1)];	// L8
      float v5 = v0[(v2 + 1)][v3];	// L9
      float v6 = v4 + v5;	// L10
      float v7 = v0[(v2 + 1)][(v3 + 2)];	// L11
      float v8 = v6 + v7;	// L12
      float v9 = v0[(v2 + 2)][(v3 + 1)];	// L13
      float v10 = v8 + v9;	// L14
      float v11 = v0[v2][(v3 + 1)];	// L15
      float v12 = v10 + v11;	// L16
      float v13 = v12 * (float)0.200000;	// L17
      v1[(v2 + 1)][(v3 + 1)] = v13;	// L18
      float v14 = v7 + v4;	// L19
      float v15 = v0[(v2 + 1)][(v3 + 3)];	// L20
      float v16 = v14 + v15;	// L21
      float v17 = v0[(v2 + 2)][(v3 + 2)];	// L22
      float v18 = v16 + v17;	// L23
      float v19 = v0[v2][(v3 + 2)];	// L24
      float v20 = v18 + v19;	// L25
      float v21 = v20 * (float)0.200000;	// L26
      v1[(v2 + 1)][(v3 + 2)] = v21;	// L27
      float v22 = v15 + v7;	// L28
      float v23 = v0[(v2 + 1)][(v3 + 4)];	// L29
      float v24 = v22 + v23;	// L30
      float v25 = v0[(v2 + 2)][(v3 + 3)];	// L31
      float v26 = v24 + v25;	// L32
      float v27 = v0[v2][(v3 + 3)];	// L33
      float v28 = v26 + v27;	// L34
      float v29 = v28 * (float)0.200000;	// L35
      v1[(v2 + 1)][(v3 + 3)] = v29;	// L36
      float v30 = v23 + v15;	// L37
      float v31 = v0[(v2 + 1)][(v3 + 5)];	// L38
      float v32 = v30 + v31;	// L39
      float v33 = v0[(v2 + 2)][(v3 + 4)];	// L40
      float v34 = v32 + v33;	// L41
      float v35 = v0[v2][(v3 + 4)];	// L42
      float v36 = v34 + v35;	// L43
      float v37 = v36 * (float)0.200000;	// L44
      v1[(v2 + 1)][(v3 + 4)] = v37;	// L45
      float v38 = v0[(v2 + 2)][v3];	// L46
      float v39 = v9 + v38;	// L47
      float v40 = v39 + v17;	// L48
      float v41 = v0[(v2 + 3)][(v3 + 1)];	// L49
      float v42 = v40 + v41;	// L50
      float v43 = v42 + v4;	// L51
      float v44 = v43 * (float)0.200000;	// L52
      v1[(v2 + 2)][(v3 + 1)] = v44;	// L53
      float v45 = v17 + v9;	// L54
      float v46 = v45 + v25;	// L55
      float v47 = v0[(v2 + 3)][(v3 + 2)];	// L56
      float v48 = v46 + v47;	// L57
      float v49 = v48 + v7;	// L58
      float v50 = v49 * (float)0.200000;	// L59
      v1[(v2 + 2)][(v3 + 2)] = v50;	// L60
      float v51 = v25 + v17;	// L61
      float v52 = v51 + v33;	// L62
      float v53 = v0[(v2 + 3)][(v3 + 3)];	// L63
      float v54 = v52 + v53;	// L64
      float v55 = v54 + v15;	// L65
      float v56 = v55 * (float)0.200000;	// L66
      v1[(v2 + 2)][(v3 + 3)] = v56;	// L67
      float v57 = v33 + v25;	// L68
      float v58 = v0[(v2 + 2)][(v3 + 5)];	// L69
      float v59 = v57 + v58;	// L70
      float v60 = v0[(v2 + 3)][(v3 + 4)];	// L71
      float v61 = v59 + v60;	// L72
      float v62 = v61 + v23;	// L73
      float v63 = v62 * (float)0.200000;	// L74
      v1[(v2 + 2)][(v3 + 4)] = v63;	// L75
      float v64 = v0[(v2 + 3)][v3];	// L76
      float v65 = v41 + v64;	// L77
      float v66 = v65 + v47;	// L78
      float v67 = v0[(v2 + 4)][(v3 + 1)];	// L79
      float v68 = v66 + v67;	// L80
      float v69 = v68 + v9;	// L81
      float v70 = v69 * (float)0.200000;	// L82
      v1[(v2 + 3)][(v3 + 1)] = v70;	// L83
      float v71 = v47 + v41;	// L84
      float v72 = v71 + v53;	// L85
      float v73 = v0[(v2 + 4)][(v3 + 2)];	// L86
      float v74 = v72 + v73;	// L87
      float v75 = v74 + v17;	// L88
      float v76 = v75 * (float)0.200000;	// L89
      v1[(v2 + 3)][(v3 + 2)] = v76;	// L90
      float v77 = v53 + v47;	// L91
      float v78 = v77 + v60;	// L92
      float v79 = v0[(v2 + 4)][(v3 + 3)];	// L93
      float v80 = v78 + v79;	// L94
      float v81 = v80 + v25;	// L95
      float v82 = v81 * (float)0.200000;	// L96
      v1[(v2 + 3)][(v3 + 3)] = v82;	// L97
      float v83 = v60 + v53;	// L98
      float v84 = v0[(v2 + 3)][(v3 + 5)];	// L99
      float v85 = v83 + v84;	// L100
      float v86 = v0[(v2 + 4)][(v3 + 4)];	// L101
      float v87 = v85 + v86;	// L102
      float v88 = v87 + v33;	// L103
      float v89 = v88 * (float)0.200000;	// L104
      v1[(v2 + 3)][(v3 + 4)] = v89;	// L105
      float v90 = v0[(v2 + 4)][v3];	// L106
      float v91 = v67 + v90;	// L107
      float v92 = v91 + v73;	// L108
      float v93 = v0[(v2 + 5)][(v3 + 1)];	// L109
      float v94 = v92 + v93;	// L110
      float v95 = v94 + v41;	// L111
      float v96 = v95 * (float)0.200000;	// L112
      v1[(v2 + 4)][(v3 + 1)] = v96;	// L113
      float v97 = v73 + v67;	// L114
      float v98 = v97 + v79;	// L115
      float v99 = v0[(v2 + 5)][(v3 + 2)];	// L116
      float v100 = v98 + v99;	// L117
      float v101 = v100 + v47;	// L118
      float v102 = v101 * (float)0.200000;	// L119
      v1[(v2 + 4)][(v3 + 2)] = v102;	// L120
      float v103 = v79 + v73;	// L121
      float v104 = v103 + v86;	// L122
      float v105 = v0[(v2 + 5)][(v3 + 3)];	// L123
      float v106 = v104 + v105;	// L124
      float v107 = v106 + v53;	// L125
      float v108 = v107 * (float)0.200000;	// L126
      v1[(v2 + 4)][(v3 + 3)] = v108;	// L127
      float v109 = v86 + v79;	// L128
      float v110 = v0[(v2 + 4)][(v3 + 5)];	// L129
      float v111 = v109 + v110;	// L130
      float v112 = v0[(v2 + 5)][(v3 + 4)];	// L131
      float v113 = v111 + v112;	// L132
      float v114 = v113 + v60;	// L133
      float v115 = v114 * (float)0.200000;	// L134
      v1[(v2 + 4)][(v3 + 4)] = v115;	// L135
    }
  }
}

void kernel_jacobi_2d_node2(
  float v116[250][250],
  float v117[250][250]
) {	// L140
  #pragma HLS inline
  #pragma HLS array_partition variable=v116 cyclic factor=6 dim=1
  #pragma HLS array_partition variable=v116 cyclic factor=6 dim=2

  #pragma HLS array_partition variable=v117 cyclic factor=4 dim=1
  #pragma HLS array_partition variable=v117 cyclic factor=4 dim=2

  for (int v118 = 0; v118 < 248; v118 += 4) {	// L142
    for (int v119 = 0; v119 < 248; v119 += 4) {	// L143
      #pragma HLS pipeline II=1
      float v120 = v116[(v118 + 1)][(v119 + 1)];	// L144
      float v121 = v116[(v118 + 1)][v119];	// L145
      float v122 = v120 + v121;	// L146
      float v123 = v116[(v118 + 1)][(v119 + 2)];	// L147
      float v124 = v122 + v123;	// L148
      float v125 = v116[(v118 + 2)][(v119 + 1)];	// L149
      float v126 = v124 + v125;	// L150
      float v127 = v116[v118][(v119 + 1)];	// L151
      float v128 = v126 + v127;	// L152
      float v129 = v128 * (float)0.200000;	// L153
      v117[(v118 + 1)][(v119 + 1)] = v129;	// L154
      float v130 = v123 + v120;	// L155
      float v131 = v116[(v118 + 1)][(v119 + 3)];	// L156
      float v132 = v130 + v131;	// L157
      float v133 = v116[(v118 + 2)][(v119 + 2)];	// L158
      float v134 = v132 + v133;	// L159
      float v135 = v116[v118][(v119 + 2)];	// L160
      float v136 = v134 + v135;	// L161
      float v137 = v136 * (float)0.200000;	// L162
      v117[(v118 + 1)][(v119 + 2)] = v137;	// L163
      float v138 = v131 + v123;	// L164
      float v139 = v116[(v118 + 1)][(v119 + 4)];	// L165
      float v140 = v138 + v139;	// L166
      float v141 = v116[(v118 + 2)][(v119 + 3)];	// L167
      float v142 = v140 + v141;	// L168
      float v143 = v116[v118][(v119 + 3)];	// L169
      float v144 = v142 + v143;	// L170
      float v145 = v144 * (float)0.200000;	// L171
      v117[(v118 + 1)][(v119 + 3)] = v145;	// L172
      float v146 = v139 + v131;	// L173
      float v147 = v116[(v118 + 1)][(v119 + 5)];	// L174
      float v148 = v146 + v147;	// L175
      float v149 = v116[(v118 + 2)][(v119 + 4)];	// L176
      float v150 = v148 + v149;	// L177
      float v151 = v116[v118][(v119 + 4)];	// L178
      float v152 = v150 + v151;	// L179
      float v153 = v152 * (float)0.200000;	// L180
      v117[(v118 + 1)][(v119 + 4)] = v153;	// L181
      float v154 = v116[(v118 + 2)][v119];	// L182
      float v155 = v125 + v154;	// L183
      float v156 = v155 + v133;	// L184
      float v157 = v116[(v118 + 3)][(v119 + 1)];	// L185
      float v158 = v156 + v157;	// L186
      float v159 = v158 + v120;	// L187
      float v160 = v159 * (float)0.200000;	// L188
      v117[(v118 + 2)][(v119 + 1)] = v160;	// L189
      float v161 = v133 + v125;	// L190
      float v162 = v161 + v141;	// L191
      float v163 = v116[(v118 + 3)][(v119 + 2)];	// L192
      float v164 = v162 + v163;	// L193
      float v165 = v164 + v123;	// L194
      float v166 = v165 * (float)0.200000;	// L195
      v117[(v118 + 2)][(v119 + 2)] = v166;	// L196
      float v167 = v141 + v133;	// L197
      float v168 = v167 + v149;	// L198
      float v169 = v116[(v118 + 3)][(v119 + 3)];	// L199
      float v170 = v168 + v169;	// L200
      float v171 = v170 + v131;	// L201
      float v172 = v171 * (float)0.200000;	// L202
      v117[(v118 + 2)][(v119 + 3)] = v172;	// L203
      float v173 = v149 + v141;	// L204
      float v174 = v116[(v118 + 2)][(v119 + 5)];	// L205
      float v175 = v173 + v174;	// L206
      float v176 = v116[(v118 + 3)][(v119 + 4)];	// L207
      float v177 = v175 + v176;	// L208
      float v178 = v177 + v139;	// L209
      float v179 = v178 * (float)0.200000;	// L210
      v117[(v118 + 2)][(v119 + 4)] = v179;	// L211
      float v180 = v116[(v118 + 3)][v119];	// L212
      float v181 = v157 + v180;	// L213
      float v182 = v181 + v163;	// L214
      float v183 = v116[(v118 + 4)][(v119 + 1)];	// L215
      float v184 = v182 + v183;	// L216
      float v185 = v184 + v125;	// L217
      float v186 = v185 * (float)0.200000;	// L218
      v117[(v118 + 3)][(v119 + 1)] = v186;	// L219
      float v187 = v163 + v157;	// L220
      float v188 = v187 + v169;	// L221
      float v189 = v116[(v118 + 4)][(v119 + 2)];	// L222
      float v190 = v188 + v189;	// L223
      float v191 = v190 + v133;	// L224
      float v192 = v191 * (float)0.200000;	// L225
      v117[(v118 + 3)][(v119 + 2)] = v192;	// L226
      float v193 = v169 + v163;	// L227
      float v194 = v193 + v176;	// L228
      float v195 = v116[(v118 + 4)][(v119 + 3)];	// L229
      float v196 = v194 + v195;	// L230
      float v197 = v196 + v141;	// L231
      float v198 = v197 * (float)0.200000;	// L232
      v117[(v118 + 3)][(v119 + 3)] = v198;	// L233
      float v199 = v176 + v169;	// L234
      float v200 = v116[(v118 + 3)][(v119 + 5)];	// L235
      float v201 = v199 + v200;	// L236
      float v202 = v116[(v118 + 4)][(v119 + 4)];	// L237
      float v203 = v201 + v202;	// L238
      float v204 = v203 + v149;	// L239
      float v205 = v204 * (float)0.200000;	// L240
      v117[(v118 + 3)][(v119 + 4)] = v205;	// L241
      float v206 = v116[(v118 + 4)][v119];	// L242
      float v207 = v183 + v206;	// L243
      float v208 = v207 + v189;	// L244
      float v209 = v116[(v118 + 5)][(v119 + 1)];	// L245
      float v210 = v208 + v209;	// L246
      float v211 = v210 + v157;	// L247
      float v212 = v211 * (float)0.200000;	// L248
      v117[(v118 + 4)][(v119 + 1)] = v212;	// L249
      float v213 = v189 + v183;	// L250
      float v214 = v213 + v195;	// L251
      float v215 = v116[(v118 + 5)][(v119 + 2)];	// L252
      float v216 = v214 + v215;	// L253
      float v217 = v216 + v163;	// L254
      float v218 = v217 * (float)0.200000;	// L255
      v117[(v118 + 4)][(v119 + 2)] = v218;	// L256
      float v219 = v195 + v189;	// L257
      float v220 = v219 + v202;	// L258
      float v221 = v116[(v118 + 5)][(v119 + 3)];	// L259
      float v222 = v220 + v221;	// L260
      float v223 = v222 + v169;	// L261
      float v224 = v223 * (float)0.200000;	// L262
      v117[(v118 + 4)][(v119 + 3)] = v224;	// L263
      float v225 = v202 + v195;	// L264
      float v226 = v116[(v118 + 4)][(v119 + 5)];	// L265
      float v227 = v225 + v226;	// L266
      float v228 = v116[(v118 + 5)][(v119 + 4)];	// L267
      float v229 = v227 + v228;	// L268
      float v230 = v229 + v176;	// L269
      float v231 = v230 * (float)0.200000;	// L270
      v117[(v118 + 4)][(v119 + 4)] = v231;	// L271
    }
  }
}

void kernel_jacobi_2d_node0(
  float v232[250][250],
  float v233[250][250],
  float v234[250][250],
  float v235[250][250]
) {	// L276
  #pragma HLS array_partition variable=v232 cyclic factor=6 dim=1
  #pragma HLS array_partition variable=v232 cyclic factor=6 dim=2

  #pragma HLS array_partition variable=v233 cyclic factor=6 dim=1
  #pragma HLS array_partition variable=v233 cyclic factor=6 dim=2

  #pragma HLS array_partition variable=v234 cyclic factor=4 dim=1
  #pragma HLS array_partition variable=v234 cyclic factor=4 dim=2

  #pragma HLS array_partition variable=v235 cyclic factor=4 dim=1
  #pragma HLS array_partition variable=v235 cyclic factor=4 dim=2

  for (int v236 = 0; v236 < 100; v236 += 1) {	// L277
    kernel_jacobi_2d_node2(v233, v234);	// L278
    kernel_jacobi_2d_node1(v232, v235);	// L279
  }
}

/// This is top function.
void kernel_jacobi_2d(
  ap_int<32> v237,
  ap_int<32> v238,
  float v239[250][250],
  float v240[250][250],
  float v241[250][250],
  float v242[250][250]
) {	// L283
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v242
  #pragma HLS stable variable=v242
  #pragma HLS array_partition variable=v242 cyclic factor=4 dim=1
  #pragma HLS array_partition variable=v242 cyclic factor=4 dim=2


  #pragma HLS interface ap_memory port=v241
  #pragma HLS stable variable=v241
  #pragma HLS array_partition variable=v241 cyclic factor=6 dim=1
  #pragma HLS array_partition variable=v241 cyclic factor=6 dim=2


  #pragma HLS interface ap_memory port=v240
  #pragma HLS stable variable=v240
  #pragma HLS array_partition variable=v240 cyclic factor=4 dim=1
  #pragma HLS array_partition variable=v240 cyclic factor=4 dim=2


  #pragma HLS interface ap_memory port=v239
  #pragma HLS stable variable=v239
  #pragma HLS array_partition variable=v239 cyclic factor=6 dim=1
  #pragma HLS array_partition variable=v239 cyclic factor=6 dim=2


  kernel_jacobi_2d_node0(v241, v239, v242, v240);	// L292
}

