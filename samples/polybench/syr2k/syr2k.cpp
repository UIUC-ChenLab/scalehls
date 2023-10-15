
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

void kernel_syr2k_node1(
  float v0[240][200],
  float v1[240][200],
  float v2[240][240],
  int v3,
  float v4,
  float v5
) {	// L20
  #pragma HLS array_partition variable=v0 cyclic factor=2 dim=1

  #pragma HLS array_partition variable=v1 cyclic factor=2 dim=1

  #pragma HLS array_partition variable=v2 cyclic factor=16 dim=2

  for (int v6 = 0; v6 < 240; v6 += 16) {	// L21
    #pragma HLS pipeline II=1
    if (((-v6) + v3) >= 0) {	// L22
      float v7 = v2[v3][v6];	// L23
      float v8 = v7 * v4;	// L24
      v2[v3][v6] = v8;	// L25
    }
    if ((((-v6) + v3) - 1) >= 0) {	// L27
      float v9 = v2[v3][(v6 + 1)];	// L28
      float v10 = v9 * v4;	// L29
      v2[v3][(v6 + 1)] = v10;	// L30
    }
    if ((((-v6) + v3) - 2) >= 0) {	// L32
      float v11 = v2[v3][(v6 + 2)];	// L33
      float v12 = v11 * v4;	// L34
      v2[v3][(v6 + 2)] = v12;	// L35
    }
    if ((((-v6) + v3) - 3) >= 0) {	// L37
      float v13 = v2[v3][(v6 + 3)];	// L38
      float v14 = v13 * v4;	// L39
      v2[v3][(v6 + 3)] = v14;	// L40
    }
    if ((((-v6) + v3) - 4) >= 0) {	// L42
      float v15 = v2[v3][(v6 + 4)];	// L43
      float v16 = v15 * v4;	// L44
      v2[v3][(v6 + 4)] = v16;	// L45
    }
    if ((((-v6) + v3) - 5) >= 0) {	// L47
      float v17 = v2[v3][(v6 + 5)];	// L48
      float v18 = v17 * v4;	// L49
      v2[v3][(v6 + 5)] = v18;	// L50
    }
    if ((((-v6) + v3) - 6) >= 0) {	// L52
      float v19 = v2[v3][(v6 + 6)];	// L53
      float v20 = v19 * v4;	// L54
      v2[v3][(v6 + 6)] = v20;	// L55
    }
    if ((((-v6) + v3) - 7) >= 0) {	// L57
      float v21 = v2[v3][(v6 + 7)];	// L58
      float v22 = v21 * v4;	// L59
      v2[v3][(v6 + 7)] = v22;	// L60
    }
    if ((((-v6) + v3) - 8) >= 0) {	// L62
      float v23 = v2[v3][(v6 + 8)];	// L63
      float v24 = v23 * v4;	// L64
      v2[v3][(v6 + 8)] = v24;	// L65
    }
    if ((((-v6) + v3) - 9) >= 0) {	// L67
      float v25 = v2[v3][(v6 + 9)];	// L68
      float v26 = v25 * v4;	// L69
      v2[v3][(v6 + 9)] = v26;	// L70
    }
    if ((((-v6) + v3) - 10) >= 0) {	// L72
      float v27 = v2[v3][(v6 + 10)];	// L73
      float v28 = v27 * v4;	// L74
      v2[v3][(v6 + 10)] = v28;	// L75
    }
    if ((((-v6) + v3) - 11) >= 0) {	// L77
      float v29 = v2[v3][(v6 + 11)];	// L78
      float v30 = v29 * v4;	// L79
      v2[v3][(v6 + 11)] = v30;	// L80
    }
    if ((((-v6) + v3) - 12) >= 0) {	// L82
      float v31 = v2[v3][(v6 + 12)];	// L83
      float v32 = v31 * v4;	// L84
      v2[v3][(v6 + 12)] = v32;	// L85
    }
    if ((((-v6) + v3) - 13) >= 0) {	// L87
      float v33 = v2[v3][(v6 + 13)];	// L88
      float v34 = v33 * v4;	// L89
      v2[v3][(v6 + 13)] = v34;	// L90
    }
    if ((((-v6) + v3) - 14) >= 0) {	// L92
      float v35 = v2[v3][(v6 + 14)];	// L93
      float v36 = v35 * v4;	// L94
      v2[v3][(v6 + 14)] = v36;	// L95
    }
    if ((((-v6) + v3) - 15) >= 0) {	// L97
      float v37 = v2[v3][(v6 + 15)];	// L98
      float v38 = v37 * v4;	// L99
      v2[v3][(v6 + 15)] = v38;	// L100
    }
  }
  for (int v39 = 0; v39 < 200; v39 += 1) {	// L103
    for (int v40 = 0; v40 < 240; v40 += 16) {	// L104
      #pragma HLS pipeline II=1
      if (((-v40) + v3) >= 0) {	// L105
        float v41 = v0[v40][v39];	// L106
        float v42 = v41 * v5;	// L107
        float v43 = v1[v3][v39];	// L108
        float v44 = v42 * v43;	// L109
        float v45 = v1[v40][v39];	// L110
        float v46 = v45 * v5;	// L111
        float v47 = v0[v3][v39];	// L112
        float v48 = v46 * v47;	// L113
        float v49 = v44 + v48;	// L114
        float v50 = v2[v3][v40];	// L115
        float v51 = v50 + v49;	// L116
        v2[v3][v40] = v51;	// L117
      }
      if ((((-v40) + v3) - 1) >= 0) {	// L119
        float v52 = v0[(v40 + 1)][v39];	// L120
        float v53 = v52 * v5;	// L121
        float v54 = v1[v3][v39];	// L122
        float v55 = v53 * v54;	// L123
        float v56 = v1[(v40 + 1)][v39];	// L124
        float v57 = v56 * v5;	// L125
        float v58 = v0[v3][v39];	// L126
        float v59 = v57 * v58;	// L127
        float v60 = v55 + v59;	// L128
        float v61 = v2[v3][(v40 + 1)];	// L129
        float v62 = v61 + v60;	// L130
        v2[v3][(v40 + 1)] = v62;	// L131
      }
      if ((((-v40) + v3) - 2) >= 0) {	// L133
        float v63 = v0[(v40 + 2)][v39];	// L134
        float v64 = v63 * v5;	// L135
        float v65 = v1[v3][v39];	// L136
        float v66 = v64 * v65;	// L137
        float v67 = v1[(v40 + 2)][v39];	// L138
        float v68 = v67 * v5;	// L139
        float v69 = v0[v3][v39];	// L140
        float v70 = v68 * v69;	// L141
        float v71 = v66 + v70;	// L142
        float v72 = v2[v3][(v40 + 2)];	// L143
        float v73 = v72 + v71;	// L144
        v2[v3][(v40 + 2)] = v73;	// L145
      }
      if ((((-v40) + v3) - 3) >= 0) {	// L147
        float v74 = v0[(v40 + 3)][v39];	// L148
        float v75 = v74 * v5;	// L149
        float v76 = v1[v3][v39];	// L150
        float v77 = v75 * v76;	// L151
        float v78 = v1[(v40 + 3)][v39];	// L152
        float v79 = v78 * v5;	// L153
        float v80 = v0[v3][v39];	// L154
        float v81 = v79 * v80;	// L155
        float v82 = v77 + v81;	// L156
        float v83 = v2[v3][(v40 + 3)];	// L157
        float v84 = v83 + v82;	// L158
        v2[v3][(v40 + 3)] = v84;	// L159
      }
      if ((((-v40) + v3) - 4) >= 0) {	// L161
        float v85 = v0[(v40 + 4)][v39];	// L162
        float v86 = v85 * v5;	// L163
        float v87 = v1[v3][v39];	// L164
        float v88 = v86 * v87;	// L165
        float v89 = v1[(v40 + 4)][v39];	// L166
        float v90 = v89 * v5;	// L167
        float v91 = v0[v3][v39];	// L168
        float v92 = v90 * v91;	// L169
        float v93 = v88 + v92;	// L170
        float v94 = v2[v3][(v40 + 4)];	// L171
        float v95 = v94 + v93;	// L172
        v2[v3][(v40 + 4)] = v95;	// L173
      }
      if ((((-v40) + v3) - 5) >= 0) {	// L175
        float v96 = v0[(v40 + 5)][v39];	// L176
        float v97 = v96 * v5;	// L177
        float v98 = v1[v3][v39];	// L178
        float v99 = v97 * v98;	// L179
        float v100 = v1[(v40 + 5)][v39];	// L180
        float v101 = v100 * v5;	// L181
        float v102 = v0[v3][v39];	// L182
        float v103 = v101 * v102;	// L183
        float v104 = v99 + v103;	// L184
        float v105 = v2[v3][(v40 + 5)];	// L185
        float v106 = v105 + v104;	// L186
        v2[v3][(v40 + 5)] = v106;	// L187
      }
      if ((((-v40) + v3) - 6) >= 0) {	// L189
        float v107 = v0[(v40 + 6)][v39];	// L190
        float v108 = v107 * v5;	// L191
        float v109 = v1[v3][v39];	// L192
        float v110 = v108 * v109;	// L193
        float v111 = v1[(v40 + 6)][v39];	// L194
        float v112 = v111 * v5;	// L195
        float v113 = v0[v3][v39];	// L196
        float v114 = v112 * v113;	// L197
        float v115 = v110 + v114;	// L198
        float v116 = v2[v3][(v40 + 6)];	// L199
        float v117 = v116 + v115;	// L200
        v2[v3][(v40 + 6)] = v117;	// L201
      }
      if ((((-v40) + v3) - 7) >= 0) {	// L203
        float v118 = v0[(v40 + 7)][v39];	// L204
        float v119 = v118 * v5;	// L205
        float v120 = v1[v3][v39];	// L206
        float v121 = v119 * v120;	// L207
        float v122 = v1[(v40 + 7)][v39];	// L208
        float v123 = v122 * v5;	// L209
        float v124 = v0[v3][v39];	// L210
        float v125 = v123 * v124;	// L211
        float v126 = v121 + v125;	// L212
        float v127 = v2[v3][(v40 + 7)];	// L213
        float v128 = v127 + v126;	// L214
        v2[v3][(v40 + 7)] = v128;	// L215
      }
      if ((((-v40) + v3) - 8) >= 0) {	// L217
        float v129 = v0[(v40 + 8)][v39];	// L218
        float v130 = v129 * v5;	// L219
        float v131 = v1[v3][v39];	// L220
        float v132 = v130 * v131;	// L221
        float v133 = v1[(v40 + 8)][v39];	// L222
        float v134 = v133 * v5;	// L223
        float v135 = v0[v3][v39];	// L224
        float v136 = v134 * v135;	// L225
        float v137 = v132 + v136;	// L226
        float v138 = v2[v3][(v40 + 8)];	// L227
        float v139 = v138 + v137;	// L228
        v2[v3][(v40 + 8)] = v139;	// L229
      }
      if ((((-v40) + v3) - 9) >= 0) {	// L231
        float v140 = v0[(v40 + 9)][v39];	// L232
        float v141 = v140 * v5;	// L233
        float v142 = v1[v3][v39];	// L234
        float v143 = v141 * v142;	// L235
        float v144 = v1[(v40 + 9)][v39];	// L236
        float v145 = v144 * v5;	// L237
        float v146 = v0[v3][v39];	// L238
        float v147 = v145 * v146;	// L239
        float v148 = v143 + v147;	// L240
        float v149 = v2[v3][(v40 + 9)];	// L241
        float v150 = v149 + v148;	// L242
        v2[v3][(v40 + 9)] = v150;	// L243
      }
      if ((((-v40) + v3) - 10) >= 0) {	// L245
        float v151 = v0[(v40 + 10)][v39];	// L246
        float v152 = v151 * v5;	// L247
        float v153 = v1[v3][v39];	// L248
        float v154 = v152 * v153;	// L249
        float v155 = v1[(v40 + 10)][v39];	// L250
        float v156 = v155 * v5;	// L251
        float v157 = v0[v3][v39];	// L252
        float v158 = v156 * v157;	// L253
        float v159 = v154 + v158;	// L254
        float v160 = v2[v3][(v40 + 10)];	// L255
        float v161 = v160 + v159;	// L256
        v2[v3][(v40 + 10)] = v161;	// L257
      }
      if ((((-v40) + v3) - 11) >= 0) {	// L259
        float v162 = v0[(v40 + 11)][v39];	// L260
        float v163 = v162 * v5;	// L261
        float v164 = v1[v3][v39];	// L262
        float v165 = v163 * v164;	// L263
        float v166 = v1[(v40 + 11)][v39];	// L264
        float v167 = v166 * v5;	// L265
        float v168 = v0[v3][v39];	// L266
        float v169 = v167 * v168;	// L267
        float v170 = v165 + v169;	// L268
        float v171 = v2[v3][(v40 + 11)];	// L269
        float v172 = v171 + v170;	// L270
        v2[v3][(v40 + 11)] = v172;	// L271
      }
      if ((((-v40) + v3) - 12) >= 0) {	// L273
        float v173 = v0[(v40 + 12)][v39];	// L274
        float v174 = v173 * v5;	// L275
        float v175 = v1[v3][v39];	// L276
        float v176 = v174 * v175;	// L277
        float v177 = v1[(v40 + 12)][v39];	// L278
        float v178 = v177 * v5;	// L279
        float v179 = v0[v3][v39];	// L280
        float v180 = v178 * v179;	// L281
        float v181 = v176 + v180;	// L282
        float v182 = v2[v3][(v40 + 12)];	// L283
        float v183 = v182 + v181;	// L284
        v2[v3][(v40 + 12)] = v183;	// L285
      }
      if ((((-v40) + v3) - 13) >= 0) {	// L287
        float v184 = v0[(v40 + 13)][v39];	// L288
        float v185 = v184 * v5;	// L289
        float v186 = v1[v3][v39];	// L290
        float v187 = v185 * v186;	// L291
        float v188 = v1[(v40 + 13)][v39];	// L292
        float v189 = v188 * v5;	// L293
        float v190 = v0[v3][v39];	// L294
        float v191 = v189 * v190;	// L295
        float v192 = v187 + v191;	// L296
        float v193 = v2[v3][(v40 + 13)];	// L297
        float v194 = v193 + v192;	// L298
        v2[v3][(v40 + 13)] = v194;	// L299
      }
      if ((((-v40) + v3) - 14) >= 0) {	// L301
        float v195 = v0[(v40 + 14)][v39];	// L302
        float v196 = v195 * v5;	// L303
        float v197 = v1[v3][v39];	// L304
        float v198 = v196 * v197;	// L305
        float v199 = v1[(v40 + 14)][v39];	// L306
        float v200 = v199 * v5;	// L307
        float v201 = v0[v3][v39];	// L308
        float v202 = v200 * v201;	// L309
        float v203 = v198 + v202;	// L310
        float v204 = v2[v3][(v40 + 14)];	// L311
        float v205 = v204 + v203;	// L312
        v2[v3][(v40 + 14)] = v205;	// L313
      }
      if ((((-v40) + v3) - 15) >= 0) {	// L315
        float v206 = v0[(v40 + 15)][v39];	// L316
        float v207 = v206 * v5;	// L317
        float v208 = v1[v3][v39];	// L318
        float v209 = v207 * v208;	// L319
        float v210 = v1[(v40 + 15)][v39];	// L320
        float v211 = v210 * v5;	// L321
        float v212 = v0[v3][v39];	// L322
        float v213 = v211 * v212;	// L323
        float v214 = v209 + v213;	// L324
        float v215 = v2[v3][(v40 + 15)];	// L325
        float v216 = v215 + v214;	// L326
        v2[v3][(v40 + 15)] = v216;	// L327
      }
    }
  }
}

void kernel_syr2k_node0(
  float v217[240][200],
  float v218[240][200],
  float v219[240][240],
  float v220,
  float v221
) {	// L333
  #pragma HLS array_partition variable=v217 cyclic factor=2 dim=1

  #pragma HLS array_partition variable=v218 cyclic factor=2 dim=1

  #pragma HLS array_partition variable=v219 cyclic factor=16 dim=2

  for (int v222 = 0; v222 < 240; v222 += 1) {	// L334
    #pragma HLS dataflow
    kernel_syr2k_node1(v218, v217, v219, v222, v221, v220);	// L335
  }
}

/// This is top function.
void kernel_syr2k(
  ap_int<32> v223,
  ap_int<32> v224,
  float v225,
  float v226,
  float v227[240][240],
  float v228[240][200],
  float v229[240][200]
) {	// L339
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v229
  #pragma HLS stable variable=v229
  #pragma HLS array_partition variable=v229 cyclic factor=2 dim=1


  #pragma HLS interface ap_memory port=v228
  #pragma HLS stable variable=v228
  #pragma HLS array_partition variable=v228 cyclic factor=2 dim=1


  #pragma HLS interface ap_memory port=v227
  #pragma HLS stable variable=v227
  #pragma HLS array_partition variable=v227 cyclic factor=16 dim=2


  kernel_syr2k_node0(v229, v228, v227, v225, v226);	// L346
}

