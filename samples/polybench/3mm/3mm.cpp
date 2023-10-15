
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

void kernel_3mm_node0(
  hls::stream<bool> &v0,
  float v1[180][190],
  hls::stream<bool> &v2,
  float v3[190][210],
  float v4[180][210]
) {	// L8
  #pragma HLS inline
  #pragma HLS array_partition variable=v3 cyclic factor=14 dim=2

  #pragma HLS array_partition variable=v4 cyclic factor=14 dim=2

  v2.read();	// L10
  v0.read();	// L11
  for (int v5 = 0; v5 < 190; v5 += 1) {	// L12
    for (int v6 = 0; v6 < 180; v6 += 1) {	// L13
      for (int v7 = 0; v7 < 210; v7 += 14) {	// L14
        #pragma HLS pipeline II=1
        float v8 = v4[v6][v7];	// L15
        float v9 = (v5 == 0) ? (float)0.000000 : v8;	// L16
        float v10 = v1[v6][v5];	// L17
        float v11 = v3[v5][v7];	// L18
        float v12 = v10 * v11;	// L19
        float v13 = v9 + v12;	// L20
        v4[v6][v7] = v13;	// L21
        float v14 = v4[v6][(v7 + 1)];	// L22
        float v15 = (v5 == 0) ? (float)0.000000 : v14;	// L23
        float v16 = v3[v5][(v7 + 1)];	// L24
        float v17 = v10 * v16;	// L25
        float v18 = v15 + v17;	// L26
        v4[v6][(v7 + 1)] = v18;	// L27
        float v19 = v4[v6][(v7 + 2)];	// L28
        float v20 = (v5 == 0) ? (float)0.000000 : v19;	// L29
        float v21 = v3[v5][(v7 + 2)];	// L30
        float v22 = v10 * v21;	// L31
        float v23 = v20 + v22;	// L32
        v4[v6][(v7 + 2)] = v23;	// L33
        float v24 = v4[v6][(v7 + 3)];	// L34
        float v25 = (v5 == 0) ? (float)0.000000 : v24;	// L35
        float v26 = v3[v5][(v7 + 3)];	// L36
        float v27 = v10 * v26;	// L37
        float v28 = v25 + v27;	// L38
        v4[v6][(v7 + 3)] = v28;	// L39
        float v29 = v4[v6][(v7 + 4)];	// L40
        float v30 = (v5 == 0) ? (float)0.000000 : v29;	// L41
        float v31 = v3[v5][(v7 + 4)];	// L42
        float v32 = v10 * v31;	// L43
        float v33 = v30 + v32;	// L44
        v4[v6][(v7 + 4)] = v33;	// L45
        float v34 = v4[v6][(v7 + 5)];	// L46
        float v35 = (v5 == 0) ? (float)0.000000 : v34;	// L47
        float v36 = v3[v5][(v7 + 5)];	// L48
        float v37 = v10 * v36;	// L49
        float v38 = v35 + v37;	// L50
        v4[v6][(v7 + 5)] = v38;	// L51
        float v39 = v4[v6][(v7 + 6)];	// L52
        float v40 = (v5 == 0) ? (float)0.000000 : v39;	// L53
        float v41 = v3[v5][(v7 + 6)];	// L54
        float v42 = v10 * v41;	// L55
        float v43 = v40 + v42;	// L56
        v4[v6][(v7 + 6)] = v43;	// L57
        float v44 = v4[v6][(v7 + 7)];	// L58
        float v45 = (v5 == 0) ? (float)0.000000 : v44;	// L59
        float v46 = v3[v5][(v7 + 7)];	// L60
        float v47 = v10 * v46;	// L61
        float v48 = v45 + v47;	// L62
        v4[v6][(v7 + 7)] = v48;	// L63
        float v49 = v4[v6][(v7 + 8)];	// L64
        float v50 = (v5 == 0) ? (float)0.000000 : v49;	// L65
        float v51 = v3[v5][(v7 + 8)];	// L66
        float v52 = v10 * v51;	// L67
        float v53 = v50 + v52;	// L68
        v4[v6][(v7 + 8)] = v53;	// L69
        float v54 = v4[v6][(v7 + 9)];	// L70
        float v55 = (v5 == 0) ? (float)0.000000 : v54;	// L71
        float v56 = v3[v5][(v7 + 9)];	// L72
        float v57 = v10 * v56;	// L73
        float v58 = v55 + v57;	// L74
        v4[v6][(v7 + 9)] = v58;	// L75
        float v59 = v4[v6][(v7 + 10)];	// L76
        float v60 = (v5 == 0) ? (float)0.000000 : v59;	// L77
        float v61 = v3[v5][(v7 + 10)];	// L78
        float v62 = v10 * v61;	// L79
        float v63 = v60 + v62;	// L80
        v4[v6][(v7 + 10)] = v63;	// L81
        float v64 = v4[v6][(v7 + 11)];	// L82
        float v65 = (v5 == 0) ? (float)0.000000 : v64;	// L83
        float v66 = v3[v5][(v7 + 11)];	// L84
        float v67 = v10 * v66;	// L85
        float v68 = v65 + v67;	// L86
        v4[v6][(v7 + 11)] = v68;	// L87
        float v69 = v4[v6][(v7 + 12)];	// L88
        float v70 = (v5 == 0) ? (float)0.000000 : v69;	// L89
        float v71 = v3[v5][(v7 + 12)];	// L90
        float v72 = v10 * v71;	// L91
        float v73 = v70 + v72;	// L92
        v4[v6][(v7 + 12)] = v73;	// L93
        float v74 = v4[v6][(v7 + 13)];	// L94
        float v75 = (v5 == 0) ? (float)0.000000 : v74;	// L95
        float v76 = v3[v5][(v7 + 13)];	// L96
        float v77 = v10 * v76;	// L97
        float v78 = v75 + v77;	// L98
        v4[v6][(v7 + 13)] = v78;	// L99
      }
    }
  }
}

void kernel_3mm_node1(
  float v79[190][220],
  float v80[220][210],
  hls::stream<bool> &v81,
  float v82[190][210]
) {	// L105
  #pragma HLS inline
  #pragma HLS array_partition variable=v80 cyclic factor=21 dim=2

  #pragma HLS array_partition variable=v82 cyclic factor=21 dim=2

  for (int v83 = 0; v83 < 220; v83 += 1) {	// L108
    for (int v84 = 0; v84 < 190; v84 += 1) {	// L109
      for (int v85 = 0; v85 < 210; v85 += 21) {	// L110
        #pragma HLS pipeline II=1
        float v86 = v82[v84][v85];	// L111
        float v87 = (v83 == 0) ? (float)0.000000 : v86;	// L112
        float v88 = v79[v84][v83];	// L113
        float v89 = v80[v83][v85];	// L114
        float v90 = v88 * v89;	// L115
        float v91 = v87 + v90;	// L116
        v82[v84][v85] = v91;	// L117
        float v92 = v82[v84][(v85 + 1)];	// L118
        float v93 = (v83 == 0) ? (float)0.000000 : v92;	// L119
        float v94 = v80[v83][(v85 + 1)];	// L120
        float v95 = v88 * v94;	// L121
        float v96 = v93 + v95;	// L122
        v82[v84][(v85 + 1)] = v96;	// L123
        float v97 = v82[v84][(v85 + 2)];	// L124
        float v98 = (v83 == 0) ? (float)0.000000 : v97;	// L125
        float v99 = v80[v83][(v85 + 2)];	// L126
        float v100 = v88 * v99;	// L127
        float v101 = v98 + v100;	// L128
        v82[v84][(v85 + 2)] = v101;	// L129
        float v102 = v82[v84][(v85 + 3)];	// L130
        float v103 = (v83 == 0) ? (float)0.000000 : v102;	// L131
        float v104 = v80[v83][(v85 + 3)];	// L132
        float v105 = v88 * v104;	// L133
        float v106 = v103 + v105;	// L134
        v82[v84][(v85 + 3)] = v106;	// L135
        float v107 = v82[v84][(v85 + 4)];	// L136
        float v108 = (v83 == 0) ? (float)0.000000 : v107;	// L137
        float v109 = v80[v83][(v85 + 4)];	// L138
        float v110 = v88 * v109;	// L139
        float v111 = v108 + v110;	// L140
        v82[v84][(v85 + 4)] = v111;	// L141
        float v112 = v82[v84][(v85 + 5)];	// L142
        float v113 = (v83 == 0) ? (float)0.000000 : v112;	// L143
        float v114 = v80[v83][(v85 + 5)];	// L144
        float v115 = v88 * v114;	// L145
        float v116 = v113 + v115;	// L146
        v82[v84][(v85 + 5)] = v116;	// L147
        float v117 = v82[v84][(v85 + 6)];	// L148
        float v118 = (v83 == 0) ? (float)0.000000 : v117;	// L149
        float v119 = v80[v83][(v85 + 6)];	// L150
        float v120 = v88 * v119;	// L151
        float v121 = v118 + v120;	// L152
        v82[v84][(v85 + 6)] = v121;	// L153
        float v122 = v82[v84][(v85 + 7)];	// L154
        float v123 = (v83 == 0) ? (float)0.000000 : v122;	// L155
        float v124 = v80[v83][(v85 + 7)];	// L156
        float v125 = v88 * v124;	// L157
        float v126 = v123 + v125;	// L158
        v82[v84][(v85 + 7)] = v126;	// L159
        float v127 = v82[v84][(v85 + 8)];	// L160
        float v128 = (v83 == 0) ? (float)0.000000 : v127;	// L161
        float v129 = v80[v83][(v85 + 8)];	// L162
        float v130 = v88 * v129;	// L163
        float v131 = v128 + v130;	// L164
        v82[v84][(v85 + 8)] = v131;	// L165
        float v132 = v82[v84][(v85 + 9)];	// L166
        float v133 = (v83 == 0) ? (float)0.000000 : v132;	// L167
        float v134 = v80[v83][(v85 + 9)];	// L168
        float v135 = v88 * v134;	// L169
        float v136 = v133 + v135;	// L170
        v82[v84][(v85 + 9)] = v136;	// L171
        float v137 = v82[v84][(v85 + 10)];	// L172
        float v138 = (v83 == 0) ? (float)0.000000 : v137;	// L173
        float v139 = v80[v83][(v85 + 10)];	// L174
        float v140 = v88 * v139;	// L175
        float v141 = v138 + v140;	// L176
        v82[v84][(v85 + 10)] = v141;	// L177
        float v142 = v82[v84][(v85 + 11)];	// L178
        float v143 = (v83 == 0) ? (float)0.000000 : v142;	// L179
        float v144 = v80[v83][(v85 + 11)];	// L180
        float v145 = v88 * v144;	// L181
        float v146 = v143 + v145;	// L182
        v82[v84][(v85 + 11)] = v146;	// L183
        float v147 = v82[v84][(v85 + 12)];	// L184
        float v148 = (v83 == 0) ? (float)0.000000 : v147;	// L185
        float v149 = v80[v83][(v85 + 12)];	// L186
        float v150 = v88 * v149;	// L187
        float v151 = v148 + v150;	// L188
        v82[v84][(v85 + 12)] = v151;	// L189
        float v152 = v82[v84][(v85 + 13)];	// L190
        float v153 = (v83 == 0) ? (float)0.000000 : v152;	// L191
        float v154 = v80[v83][(v85 + 13)];	// L192
        float v155 = v88 * v154;	// L193
        float v156 = v153 + v155;	// L194
        v82[v84][(v85 + 13)] = v156;	// L195
        float v157 = v82[v84][(v85 + 14)];	// L196
        float v158 = (v83 == 0) ? (float)0.000000 : v157;	// L197
        float v159 = v80[v83][(v85 + 14)];	// L198
        float v160 = v88 * v159;	// L199
        float v161 = v158 + v160;	// L200
        v82[v84][(v85 + 14)] = v161;	// L201
        float v162 = v82[v84][(v85 + 15)];	// L202
        float v163 = (v83 == 0) ? (float)0.000000 : v162;	// L203
        float v164 = v80[v83][(v85 + 15)];	// L204
        float v165 = v88 * v164;	// L205
        float v166 = v163 + v165;	// L206
        v82[v84][(v85 + 15)] = v166;	// L207
        float v167 = v82[v84][(v85 + 16)];	// L208
        float v168 = (v83 == 0) ? (float)0.000000 : v167;	// L209
        float v169 = v80[v83][(v85 + 16)];	// L210
        float v170 = v88 * v169;	// L211
        float v171 = v168 + v170;	// L212
        v82[v84][(v85 + 16)] = v171;	// L213
        float v172 = v82[v84][(v85 + 17)];	// L214
        float v173 = (v83 == 0) ? (float)0.000000 : v172;	// L215
        float v174 = v80[v83][(v85 + 17)];	// L216
        float v175 = v88 * v174;	// L217
        float v176 = v173 + v175;	// L218
        v82[v84][(v85 + 17)] = v176;	// L219
        float v177 = v82[v84][(v85 + 18)];	// L220
        float v178 = (v83 == 0) ? (float)0.000000 : v177;	// L221
        float v179 = v80[v83][(v85 + 18)];	// L222
        float v180 = v88 * v179;	// L223
        float v181 = v178 + v180;	// L224
        v82[v84][(v85 + 18)] = v181;	// L225
        float v182 = v82[v84][(v85 + 19)];	// L226
        float v183 = (v83 == 0) ? (float)0.000000 : v182;	// L227
        float v184 = v80[v83][(v85 + 19)];	// L228
        float v185 = v88 * v184;	// L229
        float v186 = v183 + v185;	// L230
        v82[v84][(v85 + 19)] = v186;	// L231
        float v187 = v82[v84][(v85 + 20)];	// L232
        float v188 = (v83 == 0) ? (float)0.000000 : v187;	// L233
        float v189 = v80[v83][(v85 + 20)];	// L234
        float v190 = v88 * v189;	// L235
        float v191 = v188 + v190;	// L236
        v82[v84][(v85 + 20)] = v191;	// L237
      }
    }
  }
  v81.write(true);	// L241
}

void kernel_3mm_node2(
  float v192[180][200],
  float v193[200][190],
  hls::stream<bool> &v194,
  float v195[180][190]
) {	// L244
  #pragma HLS inline
  #pragma HLS array_partition variable=v192 cyclic factor=6 dim=1

  #pragma HLS array_partition variable=v193 cyclic factor=2 dim=2

  #pragma HLS array_partition variable=v195 cyclic factor=6 dim=1
  #pragma HLS array_partition variable=v195 cyclic factor=2 dim=2

  for (int v196 = 0; v196 < 200; v196 += 1) {	// L247
    for (int v197 = 0; v197 < 180; v197 += 6) {	// L248
      for (int v198 = 0; v198 < 190; v198 += 2) {	// L249
        #pragma HLS pipeline II=1
        float v199 = v195[v197][v198];	// L250
        float v200 = (v196 == 0) ? (float)0.000000 : v199;	// L251
        float v201 = v192[v197][v196];	// L252
        float v202 = v193[v196][v198];	// L253
        float v203 = v201 * v202;	// L254
        float v204 = v200 + v203;	// L255
        v195[v197][v198] = v204;	// L256
        float v205 = v195[v197][(v198 + 1)];	// L257
        float v206 = (v196 == 0) ? (float)0.000000 : v205;	// L258
        float v207 = v193[v196][(v198 + 1)];	// L259
        float v208 = v201 * v207;	// L260
        float v209 = v206 + v208;	// L261
        v195[v197][(v198 + 1)] = v209;	// L262
        float v210 = v195[(v197 + 1)][v198];	// L263
        float v211 = (v196 == 0) ? (float)0.000000 : v210;	// L264
        float v212 = v192[(v197 + 1)][v196];	// L265
        float v213 = v212 * v202;	// L266
        float v214 = v211 + v213;	// L267
        v195[(v197 + 1)][v198] = v214;	// L268
        float v215 = v195[(v197 + 1)][(v198 + 1)];	// L269
        float v216 = (v196 == 0) ? (float)0.000000 : v215;	// L270
        float v217 = v212 * v207;	// L271
        float v218 = v216 + v217;	// L272
        v195[(v197 + 1)][(v198 + 1)] = v218;	// L273
        float v219 = v195[(v197 + 2)][v198];	// L274
        float v220 = (v196 == 0) ? (float)0.000000 : v219;	// L275
        float v221 = v192[(v197 + 2)][v196];	// L276
        float v222 = v221 * v202;	// L277
        float v223 = v220 + v222;	// L278
        v195[(v197 + 2)][v198] = v223;	// L279
        float v224 = v195[(v197 + 2)][(v198 + 1)];	// L280
        float v225 = (v196 == 0) ? (float)0.000000 : v224;	// L281
        float v226 = v221 * v207;	// L282
        float v227 = v225 + v226;	// L283
        v195[(v197 + 2)][(v198 + 1)] = v227;	// L284
        float v228 = v195[(v197 + 3)][v198];	// L285
        float v229 = (v196 == 0) ? (float)0.000000 : v228;	// L286
        float v230 = v192[(v197 + 3)][v196];	// L287
        float v231 = v230 * v202;	// L288
        float v232 = v229 + v231;	// L289
        v195[(v197 + 3)][v198] = v232;	// L290
        float v233 = v195[(v197 + 3)][(v198 + 1)];	// L291
        float v234 = (v196 == 0) ? (float)0.000000 : v233;	// L292
        float v235 = v230 * v207;	// L293
        float v236 = v234 + v235;	// L294
        v195[(v197 + 3)][(v198 + 1)] = v236;	// L295
        float v237 = v195[(v197 + 4)][v198];	// L296
        float v238 = (v196 == 0) ? (float)0.000000 : v237;	// L297
        float v239 = v192[(v197 + 4)][v196];	// L298
        float v240 = v239 * v202;	// L299
        float v241 = v238 + v240;	// L300
        v195[(v197 + 4)][v198] = v241;	// L301
        float v242 = v195[(v197 + 4)][(v198 + 1)];	// L302
        float v243 = (v196 == 0) ? (float)0.000000 : v242;	// L303
        float v244 = v239 * v207;	// L304
        float v245 = v243 + v244;	// L305
        v195[(v197 + 4)][(v198 + 1)] = v245;	// L306
        float v246 = v195[(v197 + 5)][v198];	// L307
        float v247 = (v196 == 0) ? (float)0.000000 : v246;	// L308
        float v248 = v192[(v197 + 5)][v196];	// L309
        float v249 = v248 * v202;	// L310
        float v250 = v247 + v249;	// L311
        v195[(v197 + 5)][v198] = v250;	// L312
        float v251 = v195[(v197 + 5)][(v198 + 1)];	// L313
        float v252 = (v196 == 0) ? (float)0.000000 : v251;	// L314
        float v253 = v248 * v207;	// L315
        float v254 = v252 + v253;	// L316
        v195[(v197 + 5)][(v198 + 1)] = v254;	// L317
      }
    }
  }
  v194.write(true);	// L321
}

/// This is top function.
void kernel_3mm(
  ap_int<32> v255,
  ap_int<32> v256,
  ap_int<32> v257,
  ap_int<32> v258,
  ap_int<32> v259,
  float v260[180][190],
  float v261[180][190],
  float v262[180][200],
  float v263[200][190],
  float v264[190][210],
  float v265[190][210],
  float v266[190][220],
  float v267[220][210],
  float v268[180][210]
) {	// L324
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v268
  #pragma HLS stable variable=v268
  #pragma HLS array_partition variable=v268 cyclic factor=14 dim=2


  #pragma HLS interface ap_memory port=v267
  #pragma HLS stable variable=v267
  #pragma HLS array_partition variable=v267 cyclic factor=21 dim=2


  #pragma HLS interface ap_memory port=v266
  #pragma HLS stable variable=v266

  #pragma HLS interface ap_memory port=v265
  #pragma HLS stable variable=v265
  #pragma HLS array_partition variable=v265 cyclic factor=21 dim=2


  #pragma HLS interface ap_memory port=v264
  #pragma HLS stable variable=v264
  #pragma HLS array_partition variable=v264 cyclic factor=14 dim=2


  #pragma HLS interface ap_memory port=v263
  #pragma HLS stable variable=v263
  #pragma HLS array_partition variable=v263 cyclic factor=2 dim=2


  #pragma HLS interface ap_memory port=v262
  #pragma HLS stable variable=v262
  #pragma HLS array_partition variable=v262 cyclic factor=6 dim=1


  #pragma HLS interface ap_memory port=v261
  #pragma HLS stable variable=v261
  #pragma HLS array_partition variable=v261 cyclic factor=6 dim=1
  #pragma HLS array_partition variable=v261 cyclic factor=2 dim=2


  #pragma HLS interface ap_memory port=v260
  #pragma HLS stable variable=v260

  hls::stream<bool> v278;	// L343
  hls::stream<bool> v279;	// L344
  kernel_3mm_node2(v262, v263, v279, v261);	// L345
  kernel_3mm_node1(v266, v267, v278, v265);	// L346
  kernel_3mm_node0(v279, v260, v278, v264, v268);	// L347
}

