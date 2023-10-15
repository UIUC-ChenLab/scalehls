
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

void kernel_atax_node1(
  float v0[390][410],
  hls::stream<bool> &v1,
  float v2[390],
  float v3[410],
  int v4
) {	// L4
  #pragma HLS inline
  #pragma HLS array_partition variable=v0 cyclic factor=41 dim=2

  #pragma HLS array_partition variable=v3 cyclic factor=41 dim=1

  v1.read();	// L5
  for (int v5 = 0; v5 < 410; v5 += 41) {	// L6
    #pragma HLS pipeline II=1
    float v6 = v3[v5];	// L7
    float v7 = v0[v4][v5];	// L8
    float v8 = v2[v4];	// L9
    float v9 = v7 * v8;	// L10
    float v10 = v6 + v9;	// L11
    v3[v5] = v10;	// L12
    float v11 = v3[(v5 + 1)];	// L13
    float v12 = v0[v4][(v5 + 1)];	// L14
    float v13 = v12 * v8;	// L15
    float v14 = v11 + v13;	// L16
    v3[(v5 + 1)] = v14;	// L17
    float v15 = v3[(v5 + 2)];	// L18
    float v16 = v0[v4][(v5 + 2)];	// L19
    float v17 = v16 * v8;	// L20
    float v18 = v15 + v17;	// L21
    v3[(v5 + 2)] = v18;	// L22
    float v19 = v3[(v5 + 3)];	// L23
    float v20 = v0[v4][(v5 + 3)];	// L24
    float v21 = v20 * v8;	// L25
    float v22 = v19 + v21;	// L26
    v3[(v5 + 3)] = v22;	// L27
    float v23 = v3[(v5 + 4)];	// L28
    float v24 = v0[v4][(v5 + 4)];	// L29
    float v25 = v24 * v8;	// L30
    float v26 = v23 + v25;	// L31
    v3[(v5 + 4)] = v26;	// L32
    float v27 = v3[(v5 + 5)];	// L33
    float v28 = v0[v4][(v5 + 5)];	// L34
    float v29 = v28 * v8;	// L35
    float v30 = v27 + v29;	// L36
    v3[(v5 + 5)] = v30;	// L37
    float v31 = v3[(v5 + 6)];	// L38
    float v32 = v0[v4][(v5 + 6)];	// L39
    float v33 = v32 * v8;	// L40
    float v34 = v31 + v33;	// L41
    v3[(v5 + 6)] = v34;	// L42
    float v35 = v3[(v5 + 7)];	// L43
    float v36 = v0[v4][(v5 + 7)];	// L44
    float v37 = v36 * v8;	// L45
    float v38 = v35 + v37;	// L46
    v3[(v5 + 7)] = v38;	// L47
    float v39 = v3[(v5 + 8)];	// L48
    float v40 = v0[v4][(v5 + 8)];	// L49
    float v41 = v40 * v8;	// L50
    float v42 = v39 + v41;	// L51
    v3[(v5 + 8)] = v42;	// L52
    float v43 = v3[(v5 + 9)];	// L53
    float v44 = v0[v4][(v5 + 9)];	// L54
    float v45 = v44 * v8;	// L55
    float v46 = v43 + v45;	// L56
    v3[(v5 + 9)] = v46;	// L57
    float v47 = v3[(v5 + 10)];	// L58
    float v48 = v0[v4][(v5 + 10)];	// L59
    float v49 = v48 * v8;	// L60
    float v50 = v47 + v49;	// L61
    v3[(v5 + 10)] = v50;	// L62
    float v51 = v3[(v5 + 11)];	// L63
    float v52 = v0[v4][(v5 + 11)];	// L64
    float v53 = v52 * v8;	// L65
    float v54 = v51 + v53;	// L66
    v3[(v5 + 11)] = v54;	// L67
    float v55 = v3[(v5 + 12)];	// L68
    float v56 = v0[v4][(v5 + 12)];	// L69
    float v57 = v56 * v8;	// L70
    float v58 = v55 + v57;	// L71
    v3[(v5 + 12)] = v58;	// L72
    float v59 = v3[(v5 + 13)];	// L73
    float v60 = v0[v4][(v5 + 13)];	// L74
    float v61 = v60 * v8;	// L75
    float v62 = v59 + v61;	// L76
    v3[(v5 + 13)] = v62;	// L77
    float v63 = v3[(v5 + 14)];	// L78
    float v64 = v0[v4][(v5 + 14)];	// L79
    float v65 = v64 * v8;	// L80
    float v66 = v63 + v65;	// L81
    v3[(v5 + 14)] = v66;	// L82
    float v67 = v3[(v5 + 15)];	// L83
    float v68 = v0[v4][(v5 + 15)];	// L84
    float v69 = v68 * v8;	// L85
    float v70 = v67 + v69;	// L86
    v3[(v5 + 15)] = v70;	// L87
    float v71 = v3[(v5 + 16)];	// L88
    float v72 = v0[v4][(v5 + 16)];	// L89
    float v73 = v72 * v8;	// L90
    float v74 = v71 + v73;	// L91
    v3[(v5 + 16)] = v74;	// L92
    float v75 = v3[(v5 + 17)];	// L93
    float v76 = v0[v4][(v5 + 17)];	// L94
    float v77 = v76 * v8;	// L95
    float v78 = v75 + v77;	// L96
    v3[(v5 + 17)] = v78;	// L97
    float v79 = v3[(v5 + 18)];	// L98
    float v80 = v0[v4][(v5 + 18)];	// L99
    float v81 = v80 * v8;	// L100
    float v82 = v79 + v81;	// L101
    v3[(v5 + 18)] = v82;	// L102
    float v83 = v3[(v5 + 19)];	// L103
    float v84 = v0[v4][(v5 + 19)];	// L104
    float v85 = v84 * v8;	// L105
    float v86 = v83 + v85;	// L106
    v3[(v5 + 19)] = v86;	// L107
    float v87 = v3[(v5 + 20)];	// L108
    float v88 = v0[v4][(v5 + 20)];	// L109
    float v89 = v88 * v8;	// L110
    float v90 = v87 + v89;	// L111
    v3[(v5 + 20)] = v90;	// L112
    float v91 = v3[(v5 + 21)];	// L113
    float v92 = v0[v4][(v5 + 21)];	// L114
    float v93 = v92 * v8;	// L115
    float v94 = v91 + v93;	// L116
    v3[(v5 + 21)] = v94;	// L117
    float v95 = v3[(v5 + 22)];	// L118
    float v96 = v0[v4][(v5 + 22)];	// L119
    float v97 = v96 * v8;	// L120
    float v98 = v95 + v97;	// L121
    v3[(v5 + 22)] = v98;	// L122
    float v99 = v3[(v5 + 23)];	// L123
    float v100 = v0[v4][(v5 + 23)];	// L124
    float v101 = v100 * v8;	// L125
    float v102 = v99 + v101;	// L126
    v3[(v5 + 23)] = v102;	// L127
    float v103 = v3[(v5 + 24)];	// L128
    float v104 = v0[v4][(v5 + 24)];	// L129
    float v105 = v104 * v8;	// L130
    float v106 = v103 + v105;	// L131
    v3[(v5 + 24)] = v106;	// L132
    float v107 = v3[(v5 + 25)];	// L133
    float v108 = v0[v4][(v5 + 25)];	// L134
    float v109 = v108 * v8;	// L135
    float v110 = v107 + v109;	// L136
    v3[(v5 + 25)] = v110;	// L137
    float v111 = v3[(v5 + 26)];	// L138
    float v112 = v0[v4][(v5 + 26)];	// L139
    float v113 = v112 * v8;	// L140
    float v114 = v111 + v113;	// L141
    v3[(v5 + 26)] = v114;	// L142
    float v115 = v3[(v5 + 27)];	// L143
    float v116 = v0[v4][(v5 + 27)];	// L144
    float v117 = v116 * v8;	// L145
    float v118 = v115 + v117;	// L146
    v3[(v5 + 27)] = v118;	// L147
    float v119 = v3[(v5 + 28)];	// L148
    float v120 = v0[v4][(v5 + 28)];	// L149
    float v121 = v120 * v8;	// L150
    float v122 = v119 + v121;	// L151
    v3[(v5 + 28)] = v122;	// L152
    float v123 = v3[(v5 + 29)];	// L153
    float v124 = v0[v4][(v5 + 29)];	// L154
    float v125 = v124 * v8;	// L155
    float v126 = v123 + v125;	// L156
    v3[(v5 + 29)] = v126;	// L157
    float v127 = v3[(v5 + 30)];	// L158
    float v128 = v0[v4][(v5 + 30)];	// L159
    float v129 = v128 * v8;	// L160
    float v130 = v127 + v129;	// L161
    v3[(v5 + 30)] = v130;	// L162
    float v131 = v3[(v5 + 31)];	// L163
    float v132 = v0[v4][(v5 + 31)];	// L164
    float v133 = v132 * v8;	// L165
    float v134 = v131 + v133;	// L166
    v3[(v5 + 31)] = v134;	// L167
    float v135 = v3[(v5 + 32)];	// L168
    float v136 = v0[v4][(v5 + 32)];	// L169
    float v137 = v136 * v8;	// L170
    float v138 = v135 + v137;	// L171
    v3[(v5 + 32)] = v138;	// L172
    float v139 = v3[(v5 + 33)];	// L173
    float v140 = v0[v4][(v5 + 33)];	// L174
    float v141 = v140 * v8;	// L175
    float v142 = v139 + v141;	// L176
    v3[(v5 + 33)] = v142;	// L177
    float v143 = v3[(v5 + 34)];	// L178
    float v144 = v0[v4][(v5 + 34)];	// L179
    float v145 = v144 * v8;	// L180
    float v146 = v143 + v145;	// L181
    v3[(v5 + 34)] = v146;	// L182
    float v147 = v3[(v5 + 35)];	// L183
    float v148 = v0[v4][(v5 + 35)];	// L184
    float v149 = v148 * v8;	// L185
    float v150 = v147 + v149;	// L186
    v3[(v5 + 35)] = v150;	// L187
    float v151 = v3[(v5 + 36)];	// L188
    float v152 = v0[v4][(v5 + 36)];	// L189
    float v153 = v152 * v8;	// L190
    float v154 = v151 + v153;	// L191
    v3[(v5 + 36)] = v154;	// L192
    float v155 = v3[(v5 + 37)];	// L193
    float v156 = v0[v4][(v5 + 37)];	// L194
    float v157 = v156 * v8;	// L195
    float v158 = v155 + v157;	// L196
    v3[(v5 + 37)] = v158;	// L197
    float v159 = v3[(v5 + 38)];	// L198
    float v160 = v0[v4][(v5 + 38)];	// L199
    float v161 = v160 * v8;	// L200
    float v162 = v159 + v161;	// L201
    v3[(v5 + 38)] = v162;	// L202
    float v163 = v3[(v5 + 39)];	// L203
    float v164 = v0[v4][(v5 + 39)];	// L204
    float v165 = v164 * v8;	// L205
    float v166 = v163 + v165;	// L206
    v3[(v5 + 39)] = v166;	// L207
    float v167 = v3[(v5 + 40)];	// L208
    float v168 = v0[v4][(v5 + 40)];	// L209
    float v169 = v168 * v8;	// L210
    float v170 = v167 + v169;	// L211
    v3[(v5 + 40)] = v170;	// L212
  }
}

void kernel_atax_node2(
  float v171[390][410],
  float v172[410],
  hls::stream<bool> &v173,
  float v174[390],
  int v175
) {	// L216
  #pragma HLS inline
  #pragma HLS array_partition variable=v171 cyclic factor=41 dim=2

  #pragma HLS array_partition variable=v172 cyclic factor=41 dim=1

  v174[v175] = (float)0.000000;	// L219
  for (int v176 = 0; v176 < 410; v176 += 41) {	// L220
    #pragma HLS pipeline II=1
    float v177 = v171[v175][v176];	// L221
    float v178 = v172[v176];	// L222
    float v179 = v177 * v178;	// L223
    float v180 = v171[v175][(v176 + 1)];	// L224
    float v181 = v172[(v176 + 1)];	// L225
    float v182 = v180 * v181;	// L226
    float v183 = v179 + v182;	// L227
    float v184 = v171[v175][(v176 + 2)];	// L228
    float v185 = v172[(v176 + 2)];	// L229
    float v186 = v184 * v185;	// L230
    float v187 = v183 + v186;	// L231
    float v188 = v171[v175][(v176 + 3)];	// L232
    float v189 = v172[(v176 + 3)];	// L233
    float v190 = v188 * v189;	// L234
    float v191 = v187 + v190;	// L235
    float v192 = v171[v175][(v176 + 4)];	// L236
    float v193 = v172[(v176 + 4)];	// L237
    float v194 = v192 * v193;	// L238
    float v195 = v191 + v194;	// L239
    float v196 = v171[v175][(v176 + 5)];	// L240
    float v197 = v172[(v176 + 5)];	// L241
    float v198 = v196 * v197;	// L242
    float v199 = v195 + v198;	// L243
    float v200 = v171[v175][(v176 + 6)];	// L244
    float v201 = v172[(v176 + 6)];	// L245
    float v202 = v200 * v201;	// L246
    float v203 = v199 + v202;	// L247
    float v204 = v171[v175][(v176 + 7)];	// L248
    float v205 = v172[(v176 + 7)];	// L249
    float v206 = v204 * v205;	// L250
    float v207 = v203 + v206;	// L251
    float v208 = v171[v175][(v176 + 8)];	// L252
    float v209 = v172[(v176 + 8)];	// L253
    float v210 = v208 * v209;	// L254
    float v211 = v207 + v210;	// L255
    float v212 = v171[v175][(v176 + 9)];	// L256
    float v213 = v172[(v176 + 9)];	// L257
    float v214 = v212 * v213;	// L258
    float v215 = v211 + v214;	// L259
    float v216 = v171[v175][(v176 + 10)];	// L260
    float v217 = v172[(v176 + 10)];	// L261
    float v218 = v216 * v217;	// L262
    float v219 = v215 + v218;	// L263
    float v220 = v171[v175][(v176 + 11)];	// L264
    float v221 = v172[(v176 + 11)];	// L265
    float v222 = v220 * v221;	// L266
    float v223 = v219 + v222;	// L267
    float v224 = v171[v175][(v176 + 12)];	// L268
    float v225 = v172[(v176 + 12)];	// L269
    float v226 = v224 * v225;	// L270
    float v227 = v223 + v226;	// L271
    float v228 = v171[v175][(v176 + 13)];	// L272
    float v229 = v172[(v176 + 13)];	// L273
    float v230 = v228 * v229;	// L274
    float v231 = v227 + v230;	// L275
    float v232 = v171[v175][(v176 + 14)];	// L276
    float v233 = v172[(v176 + 14)];	// L277
    float v234 = v232 * v233;	// L278
    float v235 = v231 + v234;	// L279
    float v236 = v171[v175][(v176 + 15)];	// L280
    float v237 = v172[(v176 + 15)];	// L281
    float v238 = v236 * v237;	// L282
    float v239 = v235 + v238;	// L283
    float v240 = v171[v175][(v176 + 16)];	// L284
    float v241 = v172[(v176 + 16)];	// L285
    float v242 = v240 * v241;	// L286
    float v243 = v239 + v242;	// L287
    float v244 = v171[v175][(v176 + 17)];	// L288
    float v245 = v172[(v176 + 17)];	// L289
    float v246 = v244 * v245;	// L290
    float v247 = v243 + v246;	// L291
    float v248 = v171[v175][(v176 + 18)];	// L292
    float v249 = v172[(v176 + 18)];	// L293
    float v250 = v248 * v249;	// L294
    float v251 = v247 + v250;	// L295
    float v252 = v171[v175][(v176 + 19)];	// L296
    float v253 = v172[(v176 + 19)];	// L297
    float v254 = v252 * v253;	// L298
    float v255 = v251 + v254;	// L299
    float v256 = v171[v175][(v176 + 20)];	// L300
    float v257 = v172[(v176 + 20)];	// L301
    float v258 = v256 * v257;	// L302
    float v259 = v255 + v258;	// L303
    float v260 = v171[v175][(v176 + 21)];	// L304
    float v261 = v172[(v176 + 21)];	// L305
    float v262 = v260 * v261;	// L306
    float v263 = v259 + v262;	// L307
    float v264 = v171[v175][(v176 + 22)];	// L308
    float v265 = v172[(v176 + 22)];	// L309
    float v266 = v264 * v265;	// L310
    float v267 = v263 + v266;	// L311
    float v268 = v171[v175][(v176 + 23)];	// L312
    float v269 = v172[(v176 + 23)];	// L313
    float v270 = v268 * v269;	// L314
    float v271 = v267 + v270;	// L315
    float v272 = v171[v175][(v176 + 24)];	// L316
    float v273 = v172[(v176 + 24)];	// L317
    float v274 = v272 * v273;	// L318
    float v275 = v271 + v274;	// L319
    float v276 = v171[v175][(v176 + 25)];	// L320
    float v277 = v172[(v176 + 25)];	// L321
    float v278 = v276 * v277;	// L322
    float v279 = v275 + v278;	// L323
    float v280 = v171[v175][(v176 + 26)];	// L324
    float v281 = v172[(v176 + 26)];	// L325
    float v282 = v280 * v281;	// L326
    float v283 = v279 + v282;	// L327
    float v284 = v171[v175][(v176 + 27)];	// L328
    float v285 = v172[(v176 + 27)];	// L329
    float v286 = v284 * v285;	// L330
    float v287 = v283 + v286;	// L331
    float v288 = v171[v175][(v176 + 28)];	// L332
    float v289 = v172[(v176 + 28)];	// L333
    float v290 = v288 * v289;	// L334
    float v291 = v287 + v290;	// L335
    float v292 = v171[v175][(v176 + 29)];	// L336
    float v293 = v172[(v176 + 29)];	// L337
    float v294 = v292 * v293;	// L338
    float v295 = v291 + v294;	// L339
    float v296 = v171[v175][(v176 + 30)];	// L340
    float v297 = v172[(v176 + 30)];	// L341
    float v298 = v296 * v297;	// L342
    float v299 = v295 + v298;	// L343
    float v300 = v171[v175][(v176 + 31)];	// L344
    float v301 = v172[(v176 + 31)];	// L345
    float v302 = v300 * v301;	// L346
    float v303 = v299 + v302;	// L347
    float v304 = v171[v175][(v176 + 32)];	// L348
    float v305 = v172[(v176 + 32)];	// L349
    float v306 = v304 * v305;	// L350
    float v307 = v303 + v306;	// L351
    float v308 = v171[v175][(v176 + 33)];	// L352
    float v309 = v172[(v176 + 33)];	// L353
    float v310 = v308 * v309;	// L354
    float v311 = v307 + v310;	// L355
    float v312 = v171[v175][(v176 + 34)];	// L356
    float v313 = v172[(v176 + 34)];	// L357
    float v314 = v312 * v313;	// L358
    float v315 = v311 + v314;	// L359
    float v316 = v171[v175][(v176 + 35)];	// L360
    float v317 = v172[(v176 + 35)];	// L361
    float v318 = v316 * v317;	// L362
    float v319 = v315 + v318;	// L363
    float v320 = v171[v175][(v176 + 36)];	// L364
    float v321 = v172[(v176 + 36)];	// L365
    float v322 = v320 * v321;	// L366
    float v323 = v319 + v322;	// L367
    float v324 = v171[v175][(v176 + 37)];	// L368
    float v325 = v172[(v176 + 37)];	// L369
    float v326 = v324 * v325;	// L370
    float v327 = v323 + v326;	// L371
    float v328 = v171[v175][(v176 + 38)];	// L372
    float v329 = v172[(v176 + 38)];	// L373
    float v330 = v328 * v329;	// L374
    float v331 = v327 + v330;	// L375
    float v332 = v171[v175][(v176 + 39)];	// L376
    float v333 = v172[(v176 + 39)];	// L377
    float v334 = v332 * v333;	// L378
    float v335 = v331 + v334;	// L379
    float v336 = v171[v175][(v176 + 40)];	// L380
    float v337 = v172[(v176 + 40)];	// L381
    float v338 = v336 * v337;	// L382
    float v339 = v335 + v338;	// L383
    float v340 = v174[v175];	// L384
    float v341 = v340 + v339;	// L385
    v174[v175] = v341;	// L386
  }
  v173.write(true);	// L388
}

void kernel_atax_node0(
  float v342[390][410],
  float v343[410],
  float v344[390][410],
  float v345[390],
  float v346[410],
  float v347[390]
) {	// L391
  #pragma HLS array_partition variable=v342 cyclic factor=41 dim=2

  #pragma HLS array_partition variable=v343 cyclic factor=41 dim=1

  #pragma HLS array_partition variable=v344 cyclic factor=41 dim=2

  #pragma HLS array_partition variable=v346 cyclic factor=41 dim=1

  for (int v348 = 0; v348 < 410; v348 += 41) {	// L393
    #pragma HLS pipeline II=1
    v346[v348] = (float)0.000000;	// L394
    v346[(v348 + 1)] = (float)0.000000;	// L395
    v346[(v348 + 2)] = (float)0.000000;	// L396
    v346[(v348 + 3)] = (float)0.000000;	// L397
    v346[(v348 + 4)] = (float)0.000000;	// L398
    v346[(v348 + 5)] = (float)0.000000;	// L399
    v346[(v348 + 6)] = (float)0.000000;	// L400
    v346[(v348 + 7)] = (float)0.000000;	// L401
    v346[(v348 + 8)] = (float)0.000000;	// L402
    v346[(v348 + 9)] = (float)0.000000;	// L403
    v346[(v348 + 10)] = (float)0.000000;	// L404
    v346[(v348 + 11)] = (float)0.000000;	// L405
    v346[(v348 + 12)] = (float)0.000000;	// L406
    v346[(v348 + 13)] = (float)0.000000;	// L407
    v346[(v348 + 14)] = (float)0.000000;	// L408
    v346[(v348 + 15)] = (float)0.000000;	// L409
    v346[(v348 + 16)] = (float)0.000000;	// L410
    v346[(v348 + 17)] = (float)0.000000;	// L411
    v346[(v348 + 18)] = (float)0.000000;	// L412
    v346[(v348 + 19)] = (float)0.000000;	// L413
    v346[(v348 + 20)] = (float)0.000000;	// L414
    v346[(v348 + 21)] = (float)0.000000;	// L415
    v346[(v348 + 22)] = (float)0.000000;	// L416
    v346[(v348 + 23)] = (float)0.000000;	// L417
    v346[(v348 + 24)] = (float)0.000000;	// L418
    v346[(v348 + 25)] = (float)0.000000;	// L419
    v346[(v348 + 26)] = (float)0.000000;	// L420
    v346[(v348 + 27)] = (float)0.000000;	// L421
    v346[(v348 + 28)] = (float)0.000000;	// L422
    v346[(v348 + 29)] = (float)0.000000;	// L423
    v346[(v348 + 30)] = (float)0.000000;	// L424
    v346[(v348 + 31)] = (float)0.000000;	// L425
    v346[(v348 + 32)] = (float)0.000000;	// L426
    v346[(v348 + 33)] = (float)0.000000;	// L427
    v346[(v348 + 34)] = (float)0.000000;	// L428
    v346[(v348 + 35)] = (float)0.000000;	// L429
    v346[(v348 + 36)] = (float)0.000000;	// L430
    v346[(v348 + 37)] = (float)0.000000;	// L431
    v346[(v348 + 38)] = (float)0.000000;	// L432
    v346[(v348 + 39)] = (float)0.000000;	// L433
    v346[(v348 + 40)] = (float)0.000000;	// L434
  }
  for (int v349 = 0; v349 < 390; v349 += 1) {	// L436
    #pragma HLS dataflow
    hls::stream<bool> v350;	// L437
    kernel_atax_node2(v342, v343, v350, v347, v349);	// L438
    kernel_atax_node1(v344, v350, v345, v346, v349);	// L439
  }
}

/// This is top function.
void kernel_atax(
  ap_int<32> v351,
  ap_int<32> v352,
  float v353[390][410],
  float v354[390][410],
  float v355[410],
  float v356[410],
  float v357[390],
  float v358[390]
) {	// L443
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v358
  #pragma HLS stable variable=v358

  #pragma HLS interface ap_memory port=v357
  #pragma HLS stable variable=v357

  #pragma HLS interface ap_memory port=v356
  #pragma HLS stable variable=v356
  #pragma HLS array_partition variable=v356 cyclic factor=41 dim=1


  #pragma HLS interface ap_memory port=v355
  #pragma HLS stable variable=v355
  #pragma HLS array_partition variable=v355 cyclic factor=41 dim=1


  #pragma HLS interface ap_memory port=v354
  #pragma HLS stable variable=v354
  #pragma HLS array_partition variable=v354 cyclic factor=41 dim=2


  #pragma HLS interface ap_memory port=v353
  #pragma HLS stable variable=v353
  #pragma HLS array_partition variable=v353 cyclic factor=41 dim=2


  kernel_atax_node0(v353, v355, v354, v357, v356, v358);	// L456
}

