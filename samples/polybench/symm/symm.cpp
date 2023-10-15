
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

void kernel_symm_node0(
  float v0[200][200],
  float v1[200][240],
  float v2[200][240],
  float v3,
  float v4,
  float v5
) {	// L6
  #pragma HLS inline
  #pragma HLS array_partition variable=v1 cyclic factor=16 dim=2

  #pragma HLS array_partition variable=v2 cyclic factor=16 dim=2

  for (int v6 = 0; v6 < 200; v6 += 1) {	// L8
    for (int v7 = 0; v7 < 240; v7 += 16) {	// L9
      for (int v8 = 0; v8 < 199; v8 += 1) {	// L10
        #pragma HLS pipeline II=1
        if (((v6 - v8) - 1) >= 0) {	// L11
          float v9 = v3;	// L12
          float v10 = (v8 == 0) ? (float)0.000000 : v9;	// L13
          float v11 = v1[v6][v7];	// L14
          float v12 = v5 * v11;	// L15
          float v13 = v0[v6][v8];	// L16
          float v14 = v12 * v13;	// L17
          float v15 = v2[v8][v7];	// L18
          float v16 = v15 + v14;	// L19
          v2[v8][v7] = v16;	// L20
          float v17 = v1[v8][v7];	// L21
          float v18 = v17 * v13;	// L22
          float v19 = v10 + v18;	// L23
          v3 = v19;	// L24
          float v20 = v2[v6][v7];	// L25
          float v21 = v4 * v20;	// L26
          float v22 = v5 * v11;	// L27
          float v23 = v0[v6][v6];	// L28
          float v24 = v22 * v23;	// L29
          float v25 = v21 + v24;	// L30
          float v26 = v5 * v19;	// L31
          float v27 = v25 + v26;	// L32
          if ((((-v8) + v6) - 1) == 0) {	// L33
            v2[v6][v7] = v27;	// L34
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L37
          float v28 = v3;	// L38
          float v29 = (v8 == 0) ? (float)0.000000 : v28;	// L39
          float v30 = v1[v6][(v7 + 1)];	// L40
          float v31 = v5 * v30;	// L41
          float v32 = v0[v6][v8];	// L42
          float v33 = v31 * v32;	// L43
          float v34 = v2[v8][(v7 + 1)];	// L44
          float v35 = v34 + v33;	// L45
          v2[v8][(v7 + 1)] = v35;	// L46
          float v36 = v1[v8][(v7 + 1)];	// L47
          float v37 = v36 * v32;	// L48
          float v38 = v29 + v37;	// L49
          v3 = v38;	// L50
          float v39 = v2[v6][(v7 + 1)];	// L51
          float v40 = v4 * v39;	// L52
          float v41 = v5 * v30;	// L53
          float v42 = v0[v6][v6];	// L54
          float v43 = v41 * v42;	// L55
          float v44 = v40 + v43;	// L56
          float v45 = v5 * v38;	// L57
          float v46 = v44 + v45;	// L58
          if ((((-v8) + v6) - 1) == 0) {	// L59
            v2[v6][(v7 + 1)] = v46;	// L60
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L63
          float v47 = v3;	// L64
          float v48 = (v8 == 0) ? (float)0.000000 : v47;	// L65
          float v49 = v1[v6][(v7 + 2)];	// L66
          float v50 = v5 * v49;	// L67
          float v51 = v0[v6][v8];	// L68
          float v52 = v50 * v51;	// L69
          float v53 = v2[v8][(v7 + 2)];	// L70
          float v54 = v53 + v52;	// L71
          v2[v8][(v7 + 2)] = v54;	// L72
          float v55 = v1[v8][(v7 + 2)];	// L73
          float v56 = v55 * v51;	// L74
          float v57 = v48 + v56;	// L75
          v3 = v57;	// L76
          float v58 = v2[v6][(v7 + 2)];	// L77
          float v59 = v4 * v58;	// L78
          float v60 = v5 * v49;	// L79
          float v61 = v0[v6][v6];	// L80
          float v62 = v60 * v61;	// L81
          float v63 = v59 + v62;	// L82
          float v64 = v5 * v57;	// L83
          float v65 = v63 + v64;	// L84
          if ((((-v8) + v6) - 1) == 0) {	// L85
            v2[v6][(v7 + 2)] = v65;	// L86
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L89
          float v66 = v3;	// L90
          float v67 = (v8 == 0) ? (float)0.000000 : v66;	// L91
          float v68 = v1[v6][(v7 + 3)];	// L92
          float v69 = v5 * v68;	// L93
          float v70 = v0[v6][v8];	// L94
          float v71 = v69 * v70;	// L95
          float v72 = v2[v8][(v7 + 3)];	// L96
          float v73 = v72 + v71;	// L97
          v2[v8][(v7 + 3)] = v73;	// L98
          float v74 = v1[v8][(v7 + 3)];	// L99
          float v75 = v74 * v70;	// L100
          float v76 = v67 + v75;	// L101
          v3 = v76;	// L102
          float v77 = v2[v6][(v7 + 3)];	// L103
          float v78 = v4 * v77;	// L104
          float v79 = v5 * v68;	// L105
          float v80 = v0[v6][v6];	// L106
          float v81 = v79 * v80;	// L107
          float v82 = v78 + v81;	// L108
          float v83 = v5 * v76;	// L109
          float v84 = v82 + v83;	// L110
          if ((((-v8) + v6) - 1) == 0) {	// L111
            v2[v6][(v7 + 3)] = v84;	// L112
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L115
          float v85 = v3;	// L116
          float v86 = (v8 == 0) ? (float)0.000000 : v85;	// L117
          float v87 = v1[v6][(v7 + 4)];	// L118
          float v88 = v5 * v87;	// L119
          float v89 = v0[v6][v8];	// L120
          float v90 = v88 * v89;	// L121
          float v91 = v2[v8][(v7 + 4)];	// L122
          float v92 = v91 + v90;	// L123
          v2[v8][(v7 + 4)] = v92;	// L124
          float v93 = v1[v8][(v7 + 4)];	// L125
          float v94 = v93 * v89;	// L126
          float v95 = v86 + v94;	// L127
          v3 = v95;	// L128
          float v96 = v2[v6][(v7 + 4)];	// L129
          float v97 = v4 * v96;	// L130
          float v98 = v5 * v87;	// L131
          float v99 = v0[v6][v6];	// L132
          float v100 = v98 * v99;	// L133
          float v101 = v97 + v100;	// L134
          float v102 = v5 * v95;	// L135
          float v103 = v101 + v102;	// L136
          if ((((-v8) + v6) - 1) == 0) {	// L137
            v2[v6][(v7 + 4)] = v103;	// L138
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L141
          float v104 = v3;	// L142
          float v105 = (v8 == 0) ? (float)0.000000 : v104;	// L143
          float v106 = v1[v6][(v7 + 5)];	// L144
          float v107 = v5 * v106;	// L145
          float v108 = v0[v6][v8];	// L146
          float v109 = v107 * v108;	// L147
          float v110 = v2[v8][(v7 + 5)];	// L148
          float v111 = v110 + v109;	// L149
          v2[v8][(v7 + 5)] = v111;	// L150
          float v112 = v1[v8][(v7 + 5)];	// L151
          float v113 = v112 * v108;	// L152
          float v114 = v105 + v113;	// L153
          v3 = v114;	// L154
          float v115 = v2[v6][(v7 + 5)];	// L155
          float v116 = v4 * v115;	// L156
          float v117 = v5 * v106;	// L157
          float v118 = v0[v6][v6];	// L158
          float v119 = v117 * v118;	// L159
          float v120 = v116 + v119;	// L160
          float v121 = v5 * v114;	// L161
          float v122 = v120 + v121;	// L162
          if ((((-v8) + v6) - 1) == 0) {	// L163
            v2[v6][(v7 + 5)] = v122;	// L164
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L167
          float v123 = v3;	// L168
          float v124 = (v8 == 0) ? (float)0.000000 : v123;	// L169
          float v125 = v1[v6][(v7 + 6)];	// L170
          float v126 = v5 * v125;	// L171
          float v127 = v0[v6][v8];	// L172
          float v128 = v126 * v127;	// L173
          float v129 = v2[v8][(v7 + 6)];	// L174
          float v130 = v129 + v128;	// L175
          v2[v8][(v7 + 6)] = v130;	// L176
          float v131 = v1[v8][(v7 + 6)];	// L177
          float v132 = v131 * v127;	// L178
          float v133 = v124 + v132;	// L179
          v3 = v133;	// L180
          float v134 = v2[v6][(v7 + 6)];	// L181
          float v135 = v4 * v134;	// L182
          float v136 = v5 * v125;	// L183
          float v137 = v0[v6][v6];	// L184
          float v138 = v136 * v137;	// L185
          float v139 = v135 + v138;	// L186
          float v140 = v5 * v133;	// L187
          float v141 = v139 + v140;	// L188
          if ((((-v8) + v6) - 1) == 0) {	// L189
            v2[v6][(v7 + 6)] = v141;	// L190
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L193
          float v142 = v3;	// L194
          float v143 = (v8 == 0) ? (float)0.000000 : v142;	// L195
          float v144 = v1[v6][(v7 + 7)];	// L196
          float v145 = v5 * v144;	// L197
          float v146 = v0[v6][v8];	// L198
          float v147 = v145 * v146;	// L199
          float v148 = v2[v8][(v7 + 7)];	// L200
          float v149 = v148 + v147;	// L201
          v2[v8][(v7 + 7)] = v149;	// L202
          float v150 = v1[v8][(v7 + 7)];	// L203
          float v151 = v150 * v146;	// L204
          float v152 = v143 + v151;	// L205
          v3 = v152;	// L206
          float v153 = v2[v6][(v7 + 7)];	// L207
          float v154 = v4 * v153;	// L208
          float v155 = v5 * v144;	// L209
          float v156 = v0[v6][v6];	// L210
          float v157 = v155 * v156;	// L211
          float v158 = v154 + v157;	// L212
          float v159 = v5 * v152;	// L213
          float v160 = v158 + v159;	// L214
          if ((((-v8) + v6) - 1) == 0) {	// L215
            v2[v6][(v7 + 7)] = v160;	// L216
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L219
          float v161 = v3;	// L220
          float v162 = (v8 == 0) ? (float)0.000000 : v161;	// L221
          float v163 = v1[v6][(v7 + 8)];	// L222
          float v164 = v5 * v163;	// L223
          float v165 = v0[v6][v8];	// L224
          float v166 = v164 * v165;	// L225
          float v167 = v2[v8][(v7 + 8)];	// L226
          float v168 = v167 + v166;	// L227
          v2[v8][(v7 + 8)] = v168;	// L228
          float v169 = v1[v8][(v7 + 8)];	// L229
          float v170 = v169 * v165;	// L230
          float v171 = v162 + v170;	// L231
          v3 = v171;	// L232
          float v172 = v2[v6][(v7 + 8)];	// L233
          float v173 = v4 * v172;	// L234
          float v174 = v5 * v163;	// L235
          float v175 = v0[v6][v6];	// L236
          float v176 = v174 * v175;	// L237
          float v177 = v173 + v176;	// L238
          float v178 = v5 * v171;	// L239
          float v179 = v177 + v178;	// L240
          if ((((-v8) + v6) - 1) == 0) {	// L241
            v2[v6][(v7 + 8)] = v179;	// L242
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L245
          float v180 = v3;	// L246
          float v181 = (v8 == 0) ? (float)0.000000 : v180;	// L247
          float v182 = v1[v6][(v7 + 9)];	// L248
          float v183 = v5 * v182;	// L249
          float v184 = v0[v6][v8];	// L250
          float v185 = v183 * v184;	// L251
          float v186 = v2[v8][(v7 + 9)];	// L252
          float v187 = v186 + v185;	// L253
          v2[v8][(v7 + 9)] = v187;	// L254
          float v188 = v1[v8][(v7 + 9)];	// L255
          float v189 = v188 * v184;	// L256
          float v190 = v181 + v189;	// L257
          v3 = v190;	// L258
          float v191 = v2[v6][(v7 + 9)];	// L259
          float v192 = v4 * v191;	// L260
          float v193 = v5 * v182;	// L261
          float v194 = v0[v6][v6];	// L262
          float v195 = v193 * v194;	// L263
          float v196 = v192 + v195;	// L264
          float v197 = v5 * v190;	// L265
          float v198 = v196 + v197;	// L266
          if ((((-v8) + v6) - 1) == 0) {	// L267
            v2[v6][(v7 + 9)] = v198;	// L268
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L271
          float v199 = v3;	// L272
          float v200 = (v8 == 0) ? (float)0.000000 : v199;	// L273
          float v201 = v1[v6][(v7 + 10)];	// L274
          float v202 = v5 * v201;	// L275
          float v203 = v0[v6][v8];	// L276
          float v204 = v202 * v203;	// L277
          float v205 = v2[v8][(v7 + 10)];	// L278
          float v206 = v205 + v204;	// L279
          v2[v8][(v7 + 10)] = v206;	// L280
          float v207 = v1[v8][(v7 + 10)];	// L281
          float v208 = v207 * v203;	// L282
          float v209 = v200 + v208;	// L283
          v3 = v209;	// L284
          float v210 = v2[v6][(v7 + 10)];	// L285
          float v211 = v4 * v210;	// L286
          float v212 = v5 * v201;	// L287
          float v213 = v0[v6][v6];	// L288
          float v214 = v212 * v213;	// L289
          float v215 = v211 + v214;	// L290
          float v216 = v5 * v209;	// L291
          float v217 = v215 + v216;	// L292
          if ((((-v8) + v6) - 1) == 0) {	// L293
            v2[v6][(v7 + 10)] = v217;	// L294
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L297
          float v218 = v3;	// L298
          float v219 = (v8 == 0) ? (float)0.000000 : v218;	// L299
          float v220 = v1[v6][(v7 + 11)];	// L300
          float v221 = v5 * v220;	// L301
          float v222 = v0[v6][v8];	// L302
          float v223 = v221 * v222;	// L303
          float v224 = v2[v8][(v7 + 11)];	// L304
          float v225 = v224 + v223;	// L305
          v2[v8][(v7 + 11)] = v225;	// L306
          float v226 = v1[v8][(v7 + 11)];	// L307
          float v227 = v226 * v222;	// L308
          float v228 = v219 + v227;	// L309
          v3 = v228;	// L310
          float v229 = v2[v6][(v7 + 11)];	// L311
          float v230 = v4 * v229;	// L312
          float v231 = v5 * v220;	// L313
          float v232 = v0[v6][v6];	// L314
          float v233 = v231 * v232;	// L315
          float v234 = v230 + v233;	// L316
          float v235 = v5 * v228;	// L317
          float v236 = v234 + v235;	// L318
          if ((((-v8) + v6) - 1) == 0) {	// L319
            v2[v6][(v7 + 11)] = v236;	// L320
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L323
          float v237 = v3;	// L324
          float v238 = (v8 == 0) ? (float)0.000000 : v237;	// L325
          float v239 = v1[v6][(v7 + 12)];	// L326
          float v240 = v5 * v239;	// L327
          float v241 = v0[v6][v8];	// L328
          float v242 = v240 * v241;	// L329
          float v243 = v2[v8][(v7 + 12)];	// L330
          float v244 = v243 + v242;	// L331
          v2[v8][(v7 + 12)] = v244;	// L332
          float v245 = v1[v8][(v7 + 12)];	// L333
          float v246 = v245 * v241;	// L334
          float v247 = v238 + v246;	// L335
          v3 = v247;	// L336
          float v248 = v2[v6][(v7 + 12)];	// L337
          float v249 = v4 * v248;	// L338
          float v250 = v5 * v239;	// L339
          float v251 = v0[v6][v6];	// L340
          float v252 = v250 * v251;	// L341
          float v253 = v249 + v252;	// L342
          float v254 = v5 * v247;	// L343
          float v255 = v253 + v254;	// L344
          if ((((-v8) + v6) - 1) == 0) {	// L345
            v2[v6][(v7 + 12)] = v255;	// L346
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L349
          float v256 = v3;	// L350
          float v257 = (v8 == 0) ? (float)0.000000 : v256;	// L351
          float v258 = v1[v6][(v7 + 13)];	// L352
          float v259 = v5 * v258;	// L353
          float v260 = v0[v6][v8];	// L354
          float v261 = v259 * v260;	// L355
          float v262 = v2[v8][(v7 + 13)];	// L356
          float v263 = v262 + v261;	// L357
          v2[v8][(v7 + 13)] = v263;	// L358
          float v264 = v1[v8][(v7 + 13)];	// L359
          float v265 = v264 * v260;	// L360
          float v266 = v257 + v265;	// L361
          v3 = v266;	// L362
          float v267 = v2[v6][(v7 + 13)];	// L363
          float v268 = v4 * v267;	// L364
          float v269 = v5 * v258;	// L365
          float v270 = v0[v6][v6];	// L366
          float v271 = v269 * v270;	// L367
          float v272 = v268 + v271;	// L368
          float v273 = v5 * v266;	// L369
          float v274 = v272 + v273;	// L370
          if ((((-v8) + v6) - 1) == 0) {	// L371
            v2[v6][(v7 + 13)] = v274;	// L372
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L375
          float v275 = v3;	// L376
          float v276 = (v8 == 0) ? (float)0.000000 : v275;	// L377
          float v277 = v1[v6][(v7 + 14)];	// L378
          float v278 = v5 * v277;	// L379
          float v279 = v0[v6][v8];	// L380
          float v280 = v278 * v279;	// L381
          float v281 = v2[v8][(v7 + 14)];	// L382
          float v282 = v281 + v280;	// L383
          v2[v8][(v7 + 14)] = v282;	// L384
          float v283 = v1[v8][(v7 + 14)];	// L385
          float v284 = v283 * v279;	// L386
          float v285 = v276 + v284;	// L387
          v3 = v285;	// L388
          float v286 = v2[v6][(v7 + 14)];	// L389
          float v287 = v4 * v286;	// L390
          float v288 = v5 * v277;	// L391
          float v289 = v0[v6][v6];	// L392
          float v290 = v288 * v289;	// L393
          float v291 = v287 + v290;	// L394
          float v292 = v5 * v285;	// L395
          float v293 = v291 + v292;	// L396
          if ((((-v8) + v6) - 1) == 0) {	// L397
            v2[v6][(v7 + 14)] = v293;	// L398
          }
        }
        if (((v6 - v8) - 1) >= 0) {	// L401
          float v294 = v3;	// L402
          float v295 = (v8 == 0) ? (float)0.000000 : v294;	// L403
          float v296 = v1[v6][(v7 + 15)];	// L404
          float v297 = v5 * v296;	// L405
          float v298 = v0[v6][v8];	// L406
          float v299 = v297 * v298;	// L407
          float v300 = v2[v8][(v7 + 15)];	// L408
          float v301 = v300 + v299;	// L409
          v2[v8][(v7 + 15)] = v301;	// L410
          float v302 = v1[v8][(v7 + 15)];	// L411
          float v303 = v302 * v298;	// L412
          float v304 = v295 + v303;	// L413
          v3 = v304;	// L414
          float v305 = v2[v6][(v7 + 15)];	// L415
          float v306 = v4 * v305;	// L416
          float v307 = v5 * v296;	// L417
          float v308 = v0[v6][v6];	// L418
          float v309 = v307 * v308;	// L419
          float v310 = v306 + v309;	// L420
          float v311 = v5 * v304;	// L421
          float v312 = v310 + v311;	// L422
          if ((((-v8) + v6) - 1) == 0) {	// L423
            v2[v6][(v7 + 15)] = v312;	// L424
          }
        }
      }
    }
  }
}

/// This is top function.
void kernel_symm(
  ap_int<32> v313,
  ap_int<32> v314,
  float v315,
  float v316,
  float v317[200][240],
  float v318[200][200],
  float v319[200][240]
) {	// L432
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v319
  #pragma HLS stable variable=v319
  #pragma HLS array_partition variable=v319 cyclic factor=16 dim=2


  #pragma HLS interface ap_memory port=v318
  #pragma HLS stable variable=v318

  #pragma HLS interface ap_memory port=v317
  #pragma HLS stable variable=v317
  #pragma HLS array_partition variable=v317 cyclic factor=16 dim=2


  float v323;	// L439
  kernel_symm_node0(v318, v319, v317, v323, v316, v315);	// L440
}

