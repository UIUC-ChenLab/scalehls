
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

void dataflow7(
  float v0,
  float v1[1][64][32][32],
  float v2[64][64][3][3],
  float v3[1][64][32][32],
  float v4[128][64][3][3],
  float v5[1][128][16][16],
  float v6[1][64][32][32]
) {	// L8
  float v7[1][64][34][34];	// L9
  #pragma HLS resource variable=v7 core=ram_s2p_bram

  float v8[1][64][34][34];	// L10
  #pragma HLS resource variable=v8 core=ram_s2p_bram

  float v9[1][128][16][16];	// L11
  #pragma HLS resource variable=v9 core=ram_s2p_bram

  float v10[1][64][32][32];	// L12
  #pragma HLS resource variable=v10 core=ram_s2p_bram

  float v11[1][64][32][32];	// L13
  #pragma HLS resource variable=v11 core=ram_s2p_bram

  float v12[1][64][32][32];	// L14
  #pragma HLS resource variable=v12 core=ram_s2p_bram

  for (int v13 = 0; v13 < 64; v13 += 1) {	// L15
    for (int v14 = 0; v14 < 34; v14 += 1) {	// L16
      for (int v15 = 0; v15 < 34; v15 += 1) {	// L17
        v7[0][v13][v14][v15] = v0;	// L18
      }
    }
  }
  for (int v16 = 0; v16 < 64; v16 += 1) {	// L22
    for (int v17 = 0; v17 < 32; v17 += 1) {	// L23
      for (int v18 = 0; v18 < 32; v18 += 1) {	// L24
        float v19 = v1[0][v16][v17][v18];	// L25
        v7[0][v16][(v17 + 1)][(v18 + 1)] = v19;	// L26
      }
    }
  }
  for (int v20 = 0; v20 < 64; v20 += 1) {	// L30
    for (int v21 = 0; v21 < 32; v21 += 1) {	// L31
      for (int v22 = 0; v22 < 32; v22 += 1) {	// L32
        for (int v23 = 0; v23 < 64; v23 += 1) {	// L33
          for (int v24 = 0; v24 < 3; v24 += 1) {	// L34
            for (int v25 = 0; v25 < 3; v25 += 1) {	// L35
              float v26 = v7[0][v23][(v21 + v24)][(v22 + v25)];	// L36
              float v27 = v2[v20][v23][v24][v25];	// L37
              float v28 = v11[0][v20][v21][v22];	// L38
              float v29;
              if (v23 == 0 && v24 == 0 && v25 == 0) {	// L39
                v29 = v0;	// L40
              } else {
                v29 = v28;	// L42
              }
              float v30 = v26 * v27;	// L44
              float v31 = v29 + v30;	// L45
              v11[0][v20][v21][v22] = v31;	// L46
            }
          }
        }
      }
    }
  }
  for (int v32 = 0; v32 < 64; v32 += 1) {	// L53
    for (int v33 = 0; v33 < 32; v33 += 1) {	// L54
      for (int v34 = 0; v34 < 32; v34 += 1) {	// L55
        float v35 = v11[0][v32][v33][v34];	// L56
        float v36 = v3[0][v32][v33][v34];	// L57
        float v37 = v35 + v36;	// L58
        v10[0][v32][v33][v34] = v37;	// L59
      }
    }
  }
  for (int v38 = 0; v38 < 64; v38 += 1) {	// L63
    for (int v39 = 0; v39 < 32; v39 += 1) {	// L64
      for (int v40 = 0; v40 < 32; v40 += 1) {	// L65
        float v41 = v10[0][v38][v39][v40];	// L66
        bool v42 = v41 < v0;	// L67
        float v43 = v42 ? (float)v0 : (float)v41;	// L68
        v12[0][v38][v39][v40] = v43;	// L69
      }
    }
  }
  for (int v44 = 0; v44 < 64; v44 += 1) {	// L73
    for (int v45 = 0; v45 < 34; v45 += 1) {	// L74
      for (int v46 = 0; v46 < 34; v46 += 1) {	// L75
        v8[0][v44][v45][v46] = v0;	// L76
      }
    }
  }
  for (int v47 = 0; v47 < 64; v47 += 1) {	// L80
    for (int v48 = 0; v48 < 32; v48 += 1) {	// L81
      for (int v49 = 0; v49 < 32; v49 += 1) {	// L82
        float v50 = v12[0][v47][v48][v49];	// L83
        v8[0][v47][(v48 + 1)][(v49 + 1)] = v50;	// L84
      }
    }
  }
  for (int v51 = 0; v51 < 128; v51 += 1) {	// L88
    for (int v52 = 0; v52 < 16; v52 += 1) {	// L89
      for (int v53 = 0; v53 < 16; v53 += 1) {	// L90
        for (int v54 = 0; v54 < 64; v54 += 1) {	// L91
          for (int v55 = 0; v55 < 3; v55 += 1) {	// L92
            for (int v56 = 0; v56 < 3; v56 += 1) {	// L93
              float v57 = v8[0][v54][((v52 * 2) + v55)][((v53 * 2) + v56)];	// L94
              float v58 = v4[v51][v54][v55][v56];	// L95
              float v59 = v9[0][v51][v52][v53];	// L96
              float v60;
              if (v54 == 0 && v55 == 0 && v56 == 0) {	// L97
                v60 = v0;	// L98
              } else {
                v60 = v59;	// L100
              }
              float v61 = v57 * v58;	// L102
              float v62 = v60 + v61;	// L103
              v9[0][v51][v52][v53] = v62;	// L104
            }
          }
        }
      }
    }
  }
  for (int v63 = 0; v63 < 128; v63 += 1) {	// L111
    for (int v64 = 0; v64 < 16; v64 += 1) {	// L112
      for (int v65 = 0; v65 < 16; v65 += 1) {	// L113
        float v66 = v9[0][v63][v64][v65];	// L114
        bool v67 = v66 < v0;	// L115
        float v68 = v67 ? (float)v0 : (float)v66;	// L116
        v5[0][v63][v64][v65] = v68;	// L117
      }
    }
  }
  for (int v69 = 0; v69 < 1; v69 += 1) {	// L121
    for (int v70 = 0; v70 < 64; v70 += 1) {	// L122
      for (int v71 = 0; v71 < 32; v71 += 1) {	// L123
        for (int v72 = 0; v72 < 32; v72 += 1) {	// L124
          float v73 = v12[v69][v70][v71][v72];	// L125
          v6[v69][v70][v71][v72] = v73;	// L126
        }
      }
    }
  }
}

void dataflow2(
  float v74,
  float v75[1][512][4][4],
  float v76[512][512][3][3],
  float v77[1][256][8][8],
  float v78[512][256][1][1],
  float v79[512][512][3][3],
  float v80[1][512][4][4],
  float v81[1][512][4][4]
) {	// L133
  float v82[1][512][6][6];	// L134
  #pragma HLS resource variable=v82 core=ram_s2p_bram

  float v83[1][512][4][4];	// L135
  #pragma HLS resource variable=v83 core=ram_s2p_bram

  float v84[1][512][4][4];	// L136
  #pragma HLS resource variable=v84 core=ram_s2p_bram

  float v85[1][512][4][4];	// L137
  #pragma HLS resource variable=v85 core=ram_s2p_bram

  float v86[1][512][6][6];	// L138
  #pragma HLS resource variable=v86 core=ram_s2p_bram

  float v87[1][512][4][4];	// L139
  #pragma HLS resource variable=v87 core=ram_s2p_bram

  float v88[1][512][4][4];	// L140
  #pragma HLS resource variable=v88 core=ram_s2p_bram

  for (int v89 = 0; v89 < 512; v89 += 1) {	// L141
    for (int v90 = 0; v90 < 6; v90 += 1) {	// L142
      for (int v91 = 0; v91 < 6; v91 += 1) {	// L143
        v82[0][v89][v90][v91] = v74;	// L144
      }
    }
  }
  for (int v92 = 0; v92 < 512; v92 += 1) {	// L148
    for (int v93 = 0; v93 < 4; v93 += 1) {	// L149
      for (int v94 = 0; v94 < 4; v94 += 1) {	// L150
        float v95 = v75[0][v92][v93][v94];	// L151
        v82[0][v92][(v93 + 1)][(v94 + 1)] = v95;	// L152
      }
    }
  }
  for (int v96 = 0; v96 < 512; v96 += 1) {	// L156
    for (int v97 = 0; v97 < 4; v97 += 1) {	// L157
      for (int v98 = 0; v98 < 4; v98 += 1) {	// L158
        for (int v99 = 0; v99 < 512; v99 += 1) {	// L159
          for (int v100 = 0; v100 < 3; v100 += 1) {	// L160
            for (int v101 = 0; v101 < 3; v101 += 1) {	// L161
              float v102 = v82[0][v99][(v97 + v100)][(v98 + v101)];	// L162
              float v103 = v76[v96][v99][v100][v101];	// L163
              float v104 = v83[0][v96][v97][v98];	// L164
              float v105;
              if (v99 == 0 && v100 == 0 && v101 == 0) {	// L165
                v105 = v74;	// L166
              } else {
                v105 = v104;	// L168
              }
              float v106 = v102 * v103;	// L170
              float v107 = v105 + v106;	// L171
              v83[0][v96][v97][v98] = v107;	// L172
            }
          }
        }
      }
    }
  }
  for (int v108 = 0; v108 < 512; v108 += 1) {	// L179
    for (int v109 = 0; v109 < 4; v109 += 1) {	// L180
      for (int v110 = 0; v110 < 4; v110 += 1) {	// L181
        for (int v111 = 0; v111 < 256; v111 += 1) {	// L182
          float v112 = v77[0][v111][(v109 * 2)][(v110 * 2)];	// L183
          float v113 = v78[v108][v111][0][0];	// L184
          float v114 = v84[0][v108][v109][v110];	// L185
          float v115;
          if (v111 == 0) {	// L186
            v115 = v74;	// L187
          } else {
            v115 = v114;	// L189
          }
          float v116 = v112 * v113;	// L191
          float v117 = v115 + v116;	// L192
          v84[0][v108][v109][v110] = v117;	// L193
        }
      }
    }
  }
  for (int v118 = 0; v118 < 512; v118 += 1) {	// L198
    for (int v119 = 0; v119 < 4; v119 += 1) {	// L199
      for (int v120 = 0; v120 < 4; v120 += 1) {	// L200
        float v121 = v83[0][v118][v119][v120];	// L201
        float v122 = v84[0][v118][v119][v120];	// L202
        float v123 = v121 + v122;	// L203
        v85[0][v118][v119][v120] = v123;	// L204
      }
    }
  }
  for (int v124 = 0; v124 < 512; v124 += 1) {	// L208
    for (int v125 = 0; v125 < 4; v125 += 1) {	// L209
      for (int v126 = 0; v126 < 4; v126 += 1) {	// L210
        float v127 = v85[0][v124][v125][v126];	// L211
        bool v128 = v127 < v74;	// L212
        float v129 = v128 ? (float)v74 : (float)v127;	// L213
        v88[0][v124][v125][v126] = v129;	// L214
      }
    }
  }
  for (int v130 = 0; v130 < 512; v130 += 1) {	// L218
    for (int v131 = 0; v131 < 6; v131 += 1) {	// L219
      for (int v132 = 0; v132 < 6; v132 += 1) {	// L220
        v86[0][v130][v131][v132] = v74;	// L221
      }
    }
  }
  for (int v133 = 0; v133 < 512; v133 += 1) {	// L225
    for (int v134 = 0; v134 < 4; v134 += 1) {	// L226
      for (int v135 = 0; v135 < 4; v135 += 1) {	// L227
        float v136 = v88[0][v133][v134][v135];	// L228
        v86[0][v133][(v134 + 1)][(v135 + 1)] = v136;	// L229
      }
    }
  }
  for (int v137 = 0; v137 < 512; v137 += 1) {	// L233
    for (int v138 = 0; v138 < 4; v138 += 1) {	// L234
      for (int v139 = 0; v139 < 4; v139 += 1) {	// L235
        for (int v140 = 0; v140 < 512; v140 += 1) {	// L236
          for (int v141 = 0; v141 < 3; v141 += 1) {	// L237
            for (int v142 = 0; v142 < 3; v142 += 1) {	// L238
              float v143 = v86[0][v140][(v138 + v141)][(v139 + v142)];	// L239
              float v144 = v79[v137][v140][v141][v142];	// L240
              float v145 = v87[0][v137][v138][v139];	// L241
              float v146;
              if (v140 == 0 && v141 == 0 && v142 == 0) {	// L242
                v146 = v74;	// L243
              } else {
                v146 = v145;	// L245
              }
              float v147 = v143 * v144;	// L247
              float v148 = v146 + v147;	// L248
              v87[0][v137][v138][v139] = v148;	// L249
            }
          }
        }
      }
    }
  }
  for (int v149 = 0; v149 < 512; v149 += 1) {	// L256
    for (int v150 = 0; v150 < 4; v150 += 1) {	// L257
      for (int v151 = 0; v151 < 4; v151 += 1) {	// L258
        float v152 = v87[0][v149][v150][v151];	// L259
        bool v153 = v152 < v74;	// L260
        float v154 = v153 ? (float)v74 : (float)v152;	// L261
        v80[0][v149][v150][v151] = v154;	// L262
      }
    }
  }
  for (int v155 = 0; v155 < 1; v155 += 1) {	// L266
    for (int v156 = 0; v156 < 512; v156 += 1) {	// L267
      for (int v157 = 0; v157 < 4; v157 += 1) {	// L268
        for (int v158 = 0; v158 < 4; v158 += 1) {	// L269
          float v159 = v88[v155][v156][v157][v158];	// L270
          v81[v155][v156][v157][v158] = v159;	// L271
        }
      }
    }
  }
}

void dataflow9(
  float v160,
  float v161[1][3][32][32],
  float v162[64][3][3][3],
  float v163[64][64][3][3],
  float v164[1][64][32][32],
  float v165[1][64][32][32]
) {	// L278
  float v166[1][64][34][34];	// L279
  #pragma HLS resource variable=v166 core=ram_s2p_bram

  float v167[1][64][32][32];	// L280
  #pragma HLS resource variable=v167 core=ram_s2p_bram

  float v168[1][64][32][32];	// L281
  #pragma HLS resource variable=v168 core=ram_s2p_bram

  float v169[1][64][32][32];	// L282
  #pragma HLS resource variable=v169 core=ram_s2p_bram

  float v170[1][3][34][34];	// L283
  #pragma HLS resource variable=v170 core=ram_s2p_bram

  for (int v171 = 0; v171 < 3; v171 += 1) {	// L284
    for (int v172 = 0; v172 < 34; v172 += 1) {	// L285
      for (int v173 = 0; v173 < 34; v173 += 1) {	// L286
        v170[0][v171][v172][v173] = v160;	// L287
      }
    }
  }
  for (int v174 = 0; v174 < 3; v174 += 1) {	// L291
    for (int v175 = 0; v175 < 32; v175 += 1) {	// L292
      for (int v176 = 0; v176 < 32; v176 += 1) {	// L293
        float v177 = v161[0][v174][v175][v176];	// L294
        v170[0][v174][(v175 + 1)][(v176 + 1)] = v177;	// L295
      }
    }
  }
  for (int v178 = 0; v178 < 64; v178 += 1) {	// L299
    for (int v179 = 0; v179 < 32; v179 += 1) {	// L300
      for (int v180 = 0; v180 < 32; v180 += 1) {	// L301
        for (int v181 = 0; v181 < 3; v181 += 1) {	// L302
          for (int v182 = 0; v182 < 3; v182 += 1) {	// L303
            for (int v183 = 0; v183 < 3; v183 += 1) {	// L304
              float v184 = v170[0][v181][(v179 + v182)][(v180 + v183)];	// L305
              float v185 = v162[v178][v181][v182][v183];	// L306
              float v186 = v169[0][v178][v179][v180];	// L307
              float v187;
              if (v181 == 0 && v182 == 0 && v183 == 0) {	// L308
                v187 = v160;	// L309
              } else {
                v187 = v186;	// L311
              }
              float v188 = v184 * v185;	// L313
              float v189 = v187 + v188;	// L314
              v169[0][v178][v179][v180] = v189;	// L315
            }
          }
        }
      }
    }
  }
  for (int v190 = 0; v190 < 64; v190 += 1) {	// L322
    for (int v191 = 0; v191 < 32; v191 += 1) {	// L323
      for (int v192 = 0; v192 < 32; v192 += 1) {	// L324
        float v193 = v169[0][v190][v191][v192];	// L325
        bool v194 = v193 < v160;	// L326
        float v195 = v194 ? (float)v160 : (float)v193;	// L327
        v168[0][v190][v191][v192] = v195;	// L328
      }
    }
  }
  for (int v196 = 0; v196 < 64; v196 += 1) {	// L332
    for (int v197 = 0; v197 < 34; v197 += 1) {	// L333
      for (int v198 = 0; v198 < 34; v198 += 1) {	// L334
        v166[0][v196][v197][v198] = v160;	// L335
      }
    }
  }
  for (int v199 = 0; v199 < 64; v199 += 1) {	// L339
    for (int v200 = 0; v200 < 32; v200 += 1) {	// L340
      for (int v201 = 0; v201 < 32; v201 += 1) {	// L341
        float v202 = v168[0][v199][v200][v201];	// L342
        v166[0][v199][(v200 + 1)][(v201 + 1)] = v202;	// L343
      }
    }
  }
  for (int v203 = 0; v203 < 64; v203 += 1) {	// L347
    for (int v204 = 0; v204 < 32; v204 += 1) {	// L348
      for (int v205 = 0; v205 < 32; v205 += 1) {	// L349
        for (int v206 = 0; v206 < 64; v206 += 1) {	// L350
          for (int v207 = 0; v207 < 3; v207 += 1) {	// L351
            for (int v208 = 0; v208 < 3; v208 += 1) {	// L352
              float v209 = v166[0][v206][(v204 + v207)][(v205 + v208)];	// L353
              float v210 = v163[v203][v206][v207][v208];	// L354
              float v211 = v167[0][v203][v204][v205];	// L355
              float v212;
              if (v206 == 0 && v207 == 0 && v208 == 0) {	// L356
                v212 = v160;	// L357
              } else {
                v212 = v211;	// L359
              }
              float v213 = v209 * v210;	// L361
              float v214 = v212 + v213;	// L362
              v167[0][v203][v204][v205] = v214;	// L363
            }
          }
        }
      }
    }
  }
  for (int v215 = 0; v215 < 64; v215 += 1) {	// L370
    for (int v216 = 0; v216 < 32; v216 += 1) {	// L371
      for (int v217 = 0; v217 < 32; v217 += 1) {	// L372
        float v218 = v167[0][v215][v216][v217];	// L373
        bool v219 = v218 < v160;	// L374
        float v220 = v219 ? (float)v160 : (float)v218;	// L375
        v164[0][v215][v216][v217] = v220;	// L376
      }
    }
  }
  for (int v221 = 0; v221 < 1; v221 += 1) {	// L380
    for (int v222 = 0; v222 < 64; v222 += 1) {	// L381
      for (int v223 = 0; v223 < 32; v223 += 1) {	// L382
        for (int v224 = 0; v224 < 32; v224 += 1) {	// L383
          float v225 = v168[v221][v222][v223][v224];	// L384
          v165[v221][v222][v223][v224] = v225;	// L385
        }
      }
    }
  }
}

void dataflow4(
  float v226,
  float v227[1][256][8][8],
  float v228[256][256][3][3],
  float v229[1][128][16][16],
  float v230[256][128][1][1],
  float v231[256][256][3][3],
  float v232[1][256][8][8],
  float v233[1][256][8][8]
) {	// L392
  float v234[1][256][8][8];	// L393
  #pragma HLS resource variable=v234 core=ram_s2p_bram

  float v235[1][256][10][10];	// L394
  #pragma HLS resource variable=v235 core=ram_s2p_bram

  float v236[1][256][8][8];	// L395
  #pragma HLS resource variable=v236 core=ram_s2p_bram

  float v237[1][256][8][8];	// L396
  #pragma HLS resource variable=v237 core=ram_s2p_bram

  float v238[1][256][8][8];	// L397
  #pragma HLS resource variable=v238 core=ram_s2p_bram

  float v239[1][256][10][10];	// L398
  #pragma HLS resource variable=v239 core=ram_s2p_bram

  float v240[1][256][8][8];	// L399
  #pragma HLS resource variable=v240 core=ram_s2p_bram

  for (int v241 = 0; v241 < 256; v241 += 1) {	// L400
    for (int v242 = 0; v242 < 10; v242 += 1) {	// L401
      for (int v243 = 0; v243 < 10; v243 += 1) {	// L402
        v239[0][v241][v242][v243] = v226;	// L403
      }
    }
  }
  for (int v244 = 0; v244 < 256; v244 += 1) {	// L407
    for (int v245 = 0; v245 < 8; v245 += 1) {	// L408
      for (int v246 = 0; v246 < 8; v246 += 1) {	// L409
        float v247 = v227[0][v244][v245][v246];	// L410
        v239[0][v244][(v245 + 1)][(v246 + 1)] = v247;	// L411
      }
    }
  }
  for (int v248 = 0; v248 < 256; v248 += 1) {	// L415
    for (int v249 = 0; v249 < 8; v249 += 1) {	// L416
      for (int v250 = 0; v250 < 8; v250 += 1) {	// L417
        for (int v251 = 0; v251 < 256; v251 += 1) {	// L418
          for (int v252 = 0; v252 < 3; v252 += 1) {	// L419
            for (int v253 = 0; v253 < 3; v253 += 1) {	// L420
              float v254 = v239[0][v251][(v249 + v252)][(v250 + v253)];	// L421
              float v255 = v228[v248][v251][v252][v253];	// L422
              float v256 = v234[0][v248][v249][v250];	// L423
              float v257;
              if (v251 == 0 && v252 == 0 && v253 == 0) {	// L424
                v257 = v226;	// L425
              } else {
                v257 = v256;	// L427
              }
              float v258 = v254 * v255;	// L429
              float v259 = v257 + v258;	// L430
              v234[0][v248][v249][v250] = v259;	// L431
            }
          }
        }
      }
    }
  }
  for (int v260 = 0; v260 < 256; v260 += 1) {	// L438
    for (int v261 = 0; v261 < 8; v261 += 1) {	// L439
      for (int v262 = 0; v262 < 8; v262 += 1) {	// L440
        for (int v263 = 0; v263 < 128; v263 += 1) {	// L441
          float v264 = v229[0][v263][(v261 * 2)][(v262 * 2)];	// L442
          float v265 = v230[v260][v263][0][0];	// L443
          float v266 = v236[0][v260][v261][v262];	// L444
          float v267;
          if (v263 == 0) {	// L445
            v267 = v226;	// L446
          } else {
            v267 = v266;	// L448
          }
          float v268 = v264 * v265;	// L450
          float v269 = v267 + v268;	// L451
          v236[0][v260][v261][v262] = v269;	// L452
        }
      }
    }
  }
  for (int v270 = 0; v270 < 256; v270 += 1) {	// L457
    for (int v271 = 0; v271 < 8; v271 += 1) {	// L458
      for (int v272 = 0; v272 < 8; v272 += 1) {	// L459
        float v273 = v234[0][v270][v271][v272];	// L460
        float v274 = v236[0][v270][v271][v272];	// L461
        float v275 = v273 + v274;	// L462
        v238[0][v270][v271][v272] = v275;	// L463
      }
    }
  }
  for (int v276 = 0; v276 < 256; v276 += 1) {	// L467
    for (int v277 = 0; v277 < 8; v277 += 1) {	// L468
      for (int v278 = 0; v278 < 8; v278 += 1) {	// L469
        float v279 = v238[0][v276][v277][v278];	// L470
        bool v280 = v279 < v226;	// L471
        float v281 = v280 ? (float)v226 : (float)v279;	// L472
        v237[0][v276][v277][v278] = v281;	// L473
      }
    }
  }
  for (int v282 = 0; v282 < 256; v282 += 1) {	// L477
    for (int v283 = 0; v283 < 10; v283 += 1) {	// L478
      for (int v284 = 0; v284 < 10; v284 += 1) {	// L479
        v235[0][v282][v283][v284] = v226;	// L480
      }
    }
  }
  for (int v285 = 0; v285 < 256; v285 += 1) {	// L484
    for (int v286 = 0; v286 < 8; v286 += 1) {	// L485
      for (int v287 = 0; v287 < 8; v287 += 1) {	// L486
        float v288 = v237[0][v285][v286][v287];	// L487
        v235[0][v285][(v286 + 1)][(v287 + 1)] = v288;	// L488
      }
    }
  }
  for (int v289 = 0; v289 < 256; v289 += 1) {	// L492
    for (int v290 = 0; v290 < 8; v290 += 1) {	// L493
      for (int v291 = 0; v291 < 8; v291 += 1) {	// L494
        for (int v292 = 0; v292 < 256; v292 += 1) {	// L495
          for (int v293 = 0; v293 < 3; v293 += 1) {	// L496
            for (int v294 = 0; v294 < 3; v294 += 1) {	// L497
              float v295 = v235[0][v292][(v290 + v293)][(v291 + v294)];	// L498
              float v296 = v231[v289][v292][v293][v294];	// L499
              float v297 = v240[0][v289][v290][v291];	// L500
              float v298;
              if (v292 == 0 && v293 == 0 && v294 == 0) {	// L501
                v298 = v226;	// L502
              } else {
                v298 = v297;	// L504
              }
              float v299 = v295 * v296;	// L506
              float v300 = v298 + v299;	// L507
              v240[0][v289][v290][v291] = v300;	// L508
            }
          }
        }
      }
    }
  }
  for (int v301 = 0; v301 < 256; v301 += 1) {	// L515
    for (int v302 = 0; v302 < 8; v302 += 1) {	// L516
      for (int v303 = 0; v303 < 8; v303 += 1) {	// L517
        float v304 = v240[0][v301][v302][v303];	// L518
        bool v305 = v304 < v226;	// L519
        float v306 = v305 ? (float)v226 : (float)v304;	// L520
        v232[0][v301][v302][v303] = v306;	// L521
      }
    }
  }
  for (int v307 = 0; v307 < 1; v307 += 1) {	// L525
    for (int v308 = 0; v308 < 256; v308 += 1) {	// L526
      for (int v309 = 0; v309 < 8; v309 += 1) {	// L527
        for (int v310 = 0; v310 < 8; v310 += 1) {	// L528
          float v311 = v237[v307][v308][v309][v310];	// L529
          v233[v307][v308][v309][v310] = v311;	// L530
        }
      }
    }
  }
}

void dataflow6(
  float v312,
  float v313[1][128][16][16],
  float v314[128][128][3][3],
  float v315[1][64][32][32],
  float v316[128][64][1][1],
  float v317[128][128][3][3],
  float v318[1][128][16][16],
  float v319[1][128][16][16]
) {	// L537
  float v320[1][128][16][16];	// L538
  #pragma HLS resource variable=v320 core=ram_s2p_bram

  float v321[1][128][16][16];	// L539
  #pragma HLS resource variable=v321 core=ram_s2p_bram

  float v322[1][128][16][16];	// L540
  #pragma HLS resource variable=v322 core=ram_s2p_bram

  float v323[1][128][18][18];	// L541
  #pragma HLS resource variable=v323 core=ram_s2p_bram

  float v324[1][128][18][18];	// L542
  #pragma HLS resource variable=v324 core=ram_s2p_bram

  float v325[1][128][16][16];	// L543
  #pragma HLS resource variable=v325 core=ram_s2p_bram

  float v326[1][128][16][16];	// L544
  #pragma HLS resource variable=v326 core=ram_s2p_bram

  for (int v327 = 0; v327 < 128; v327 += 1) {	// L545
    for (int v328 = 0; v328 < 18; v328 += 1) {	// L546
      for (int v329 = 0; v329 < 18; v329 += 1) {	// L547
        v323[0][v327][v328][v329] = v312;	// L548
      }
    }
  }
  for (int v330 = 0; v330 < 128; v330 += 1) {	// L552
    for (int v331 = 0; v331 < 16; v331 += 1) {	// L553
      for (int v332 = 0; v332 < 16; v332 += 1) {	// L554
        float v333 = v313[0][v330][v331][v332];	// L555
        v323[0][v330][(v331 + 1)][(v332 + 1)] = v333;	// L556
      }
    }
  }
  for (int v334 = 0; v334 < 128; v334 += 1) {	// L560
    for (int v335 = 0; v335 < 16; v335 += 1) {	// L561
      for (int v336 = 0; v336 < 16; v336 += 1) {	// L562
        for (int v337 = 0; v337 < 128; v337 += 1) {	// L563
          for (int v338 = 0; v338 < 3; v338 += 1) {	// L564
            for (int v339 = 0; v339 < 3; v339 += 1) {	// L565
              float v340 = v323[0][v337][(v335 + v338)][(v336 + v339)];	// L566
              float v341 = v314[v334][v337][v338][v339];	// L567
              float v342 = v325[0][v334][v335][v336];	// L568
              float v343;
              if (v337 == 0 && v338 == 0 && v339 == 0) {	// L569
                v343 = v312;	// L570
              } else {
                v343 = v342;	// L572
              }
              float v344 = v340 * v341;	// L574
              float v345 = v343 + v344;	// L575
              v325[0][v334][v335][v336] = v345;	// L576
            }
          }
        }
      }
    }
  }
  for (int v346 = 0; v346 < 128; v346 += 1) {	// L583
    for (int v347 = 0; v347 < 16; v347 += 1) {	// L584
      for (int v348 = 0; v348 < 16; v348 += 1) {	// L585
        for (int v349 = 0; v349 < 64; v349 += 1) {	// L586
          float v350 = v315[0][v349][(v347 * 2)][(v348 * 2)];	// L587
          float v351 = v316[v346][v349][0][0];	// L588
          float v352 = v321[0][v346][v347][v348];	// L589
          float v353;
          if (v349 == 0) {	// L590
            v353 = v312;	// L591
          } else {
            v353 = v352;	// L593
          }
          float v354 = v350 * v351;	// L595
          float v355 = v353 + v354;	// L596
          v321[0][v346][v347][v348] = v355;	// L597
        }
      }
    }
  }
  for (int v356 = 0; v356 < 128; v356 += 1) {	// L602
    for (int v357 = 0; v357 < 16; v357 += 1) {	// L603
      for (int v358 = 0; v358 < 16; v358 += 1) {	// L604
        float v359 = v325[0][v356][v357][v358];	// L605
        float v360 = v321[0][v356][v357][v358];	// L606
        float v361 = v359 + v360;	// L607
        v326[0][v356][v357][v358] = v361;	// L608
      }
    }
  }
  for (int v362 = 0; v362 < 128; v362 += 1) {	// L612
    for (int v363 = 0; v363 < 16; v363 += 1) {	// L613
      for (int v364 = 0; v364 < 16; v364 += 1) {	// L614
        float v365 = v326[0][v362][v363][v364];	// L615
        bool v366 = v365 < v312;	// L616
        float v367 = v366 ? (float)v312 : (float)v365;	// L617
        v322[0][v362][v363][v364] = v367;	// L618
      }
    }
  }
  for (int v368 = 0; v368 < 128; v368 += 1) {	// L622
    for (int v369 = 0; v369 < 18; v369 += 1) {	// L623
      for (int v370 = 0; v370 < 18; v370 += 1) {	// L624
        v324[0][v368][v369][v370] = v312;	// L625
      }
    }
  }
  for (int v371 = 0; v371 < 128; v371 += 1) {	// L629
    for (int v372 = 0; v372 < 16; v372 += 1) {	// L630
      for (int v373 = 0; v373 < 16; v373 += 1) {	// L631
        float v374 = v322[0][v371][v372][v373];	// L632
        v324[0][v371][(v372 + 1)][(v373 + 1)] = v374;	// L633
      }
    }
  }
  for (int v375 = 0; v375 < 128; v375 += 1) {	// L637
    for (int v376 = 0; v376 < 16; v376 += 1) {	// L638
      for (int v377 = 0; v377 < 16; v377 += 1) {	// L639
        for (int v378 = 0; v378 < 128; v378 += 1) {	// L640
          for (int v379 = 0; v379 < 3; v379 += 1) {	// L641
            for (int v380 = 0; v380 < 3; v380 += 1) {	// L642
              float v381 = v324[0][v378][(v376 + v379)][(v377 + v380)];	// L643
              float v382 = v317[v375][v378][v379][v380];	// L644
              float v383 = v320[0][v375][v376][v377];	// L645
              float v384;
              if (v378 == 0 && v379 == 0 && v380 == 0) {	// L646
                v384 = v312;	// L647
              } else {
                v384 = v383;	// L649
              }
              float v385 = v381 * v382;	// L651
              float v386 = v384 + v385;	// L652
              v320[0][v375][v376][v377] = v386;	// L653
            }
          }
        }
      }
    }
  }
  for (int v387 = 0; v387 < 128; v387 += 1) {	// L660
    for (int v388 = 0; v388 < 16; v388 += 1) {	// L661
      for (int v389 = 0; v389 < 16; v389 += 1) {	// L662
        float v390 = v320[0][v387][v388][v389];	// L663
        bool v391 = v390 < v312;	// L664
        float v392 = v391 ? (float)v312 : (float)v390;	// L665
        v318[0][v387][v388][v389] = v392;	// L666
      }
    }
  }
  for (int v393 = 0; v393 < 1; v393 += 1) {	// L670
    for (int v394 = 0; v394 < 128; v394 += 1) {	// L671
      for (int v395 = 0; v395 < 16; v395 += 1) {	// L672
        for (int v396 = 0; v396 < 16; v396 += 1) {	// L673
          float v397 = v322[v393][v394][v395][v396];	// L674
          v319[v393][v394][v395][v396] = v397;	// L675
        }
      }
    }
  }
}

void dataflow1(
  float v398,
  float v399[1][512][4][4],
  float v400[512][512][3][3],
  float v401[1][512][4][4],
  float v402,
  float v403,
  float v404[10][512],
  float v405[1][10],
  float v406[10]
) {	// L682
  float v407[1][512][6][6];	// L683
  #pragma HLS resource variable=v407 core=ram_s2p_bram

  float v408[1][512];	// L684
  #pragma HLS resource variable=v408 core=ram_s2p_bram

  float v409[1][512][4][4];	// L685
  #pragma HLS resource variable=v409 core=ram_s2p_bram

  float v410[1][512][4][4];	// L686
  #pragma HLS resource variable=v410 core=ram_s2p_bram

  float v411[1][512][4][4];	// L687
  #pragma HLS resource variable=v411 core=ram_s2p_bram

  float v412[1][512][1][1];	// L688
  #pragma HLS resource variable=v412 core=ram_s2p_bram

  for (int v413 = 0; v413 < 512; v413 += 1) {	// L689
    for (int v414 = 0; v414 < 6; v414 += 1) {	// L690
      for (int v415 = 0; v415 < 6; v415 += 1) {	// L691
        v407[0][v413][v414][v415] = v398;	// L692
      }
    }
  }
  for (int v416 = 0; v416 < 512; v416 += 1) {	// L696
    for (int v417 = 0; v417 < 4; v417 += 1) {	// L697
      for (int v418 = 0; v418 < 4; v418 += 1) {	// L698
        float v419 = v399[0][v416][v417][v418];	// L699
        v407[0][v416][(v417 + 1)][(v418 + 1)] = v419;	// L700
      }
    }
  }
  for (int v420 = 0; v420 < 512; v420 += 1) {	// L704
    for (int v421 = 0; v421 < 4; v421 += 1) {	// L705
      for (int v422 = 0; v422 < 4; v422 += 1) {	// L706
        for (int v423 = 0; v423 < 512; v423 += 1) {	// L707
          for (int v424 = 0; v424 < 3; v424 += 1) {	// L708
            for (int v425 = 0; v425 < 3; v425 += 1) {	// L709
              float v426 = v407[0][v423][(v421 + v424)][(v422 + v425)];	// L710
              float v427 = v400[v420][v423][v424][v425];	// L711
              float v428 = v410[0][v420][v421][v422];	// L712
              float v429;
              if (v423 == 0 && v424 == 0 && v425 == 0) {	// L713
                v429 = v398;	// L714
              } else {
                v429 = v428;	// L716
              }
              float v430 = v426 * v427;	// L718
              float v431 = v429 + v430;	// L719
              v410[0][v420][v421][v422] = v431;	// L720
            }
          }
        }
      }
    }
  }
  for (int v432 = 0; v432 < 512; v432 += 1) {	// L727
    for (int v433 = 0; v433 < 4; v433 += 1) {	// L728
      for (int v434 = 0; v434 < 4; v434 += 1) {	// L729
        float v435 = v410[0][v432][v433][v434];	// L730
        float v436 = v401[0][v432][v433][v434];	// L731
        float v437 = v435 + v436;	// L732
        v409[0][v432][v433][v434] = v437;	// L733
      }
    }
  }
  for (int v438 = 0; v438 < 512; v438 += 1) {	// L737
    for (int v439 = 0; v439 < 4; v439 += 1) {	// L738
      for (int v440 = 0; v440 < 4; v440 += 1) {	// L739
        float v441 = v409[0][v438][v439][v440];	// L740
        bool v442 = v441 < v398;	// L741
        float v443 = v442 ? (float)v398 : (float)v441;	// L742
        v411[0][v438][v439][v440] = v443;	// L743
      }
    }
  }
  for (int v444 = 0; v444 < 512; v444 += 1) {	// L747
    v412[0][v444][0][0] = v398;	// L748
  }
  for (int v445 = 0; v445 < 512; v445 += 1) {	// L750
    for (int v446 = 0; v446 < 4; v446 += 1) {	// L751
      for (int v447 = 0; v447 < 4; v447 += 1) {	// L752
        float v448 = v411[0][v445][v446][v447];	// L753
        float v449 = v412[0][v445][0][0];	// L754
        float v450 = v449 + v448;	// L755
        v412[0][v445][0][0] = v450;	// L756
      }
    }
  }
  for (int v451 = 0; v451 < 512; v451 += 1) {	// L760
    float v452 = v412[0][v451][0][0];	// L761
    float v453 = v452 / v402;	// L762
    v412[0][v451][0][0] = v453;	// L763
  }
  for (int v454 = 0; v454 < 512; v454 += 1) {	// L765
    float v455 = v412[0][v454][0][0];	// L766
    v408[0][v454] = v455;	// L767
  }
  for (int v456 = 0; v456 < 10; v456 += 1) {	// L769
    for (int v457 = 0; v457 < 512; v457 += 1) {	// L770
      float v458 = v408[0][v457];	// L771
      float v459 = v404[v456][v457];	// L772
      float v460 = v405[0][v456];	// L773
      float v461;
      if (v457 == 0) {	// L774
        v461 = v398;	// L775
      } else {
        v461 = v460;	// L777
      }
      float v462 = v458 * v459;	// L779
      float v463 = v461 + v462;	// L780
      v405[0][v456] = v463;	// L781
      float v464 = v403 * v463;	// L782
      float v465 = v406[v456];	// L783
      float v466 = v403 * v465;	// L784
      float v467 = v464 + v466;	// L785
      if (((-v457) + 511) == 0) {	// L786
        v405[0][v456] = v467;	// L787
      }
    }
  }
}

void dataflow8(
  float v468,
  float v469[1][64][32][32],
  float v470[64][64][3][3],
  float v471[1][64][32][32],
  float v472[64][64][3][3],
  float v473[1][64][32][32],
  float v474[1][64][32][32]
) {	// L793
  float v475[1][64][32][32];	// L794
  #pragma HLS resource variable=v475 core=ram_s2p_bram

  float v476[1][64][32][32];	// L795
  #pragma HLS resource variable=v476 core=ram_s2p_bram

  float v477[1][64][32][32];	// L796
  #pragma HLS resource variable=v477 core=ram_s2p_bram

  float v478[1][64][32][32];	// L797
  #pragma HLS resource variable=v478 core=ram_s2p_bram

  float v479[1][64][34][34];	// L798
  #pragma HLS resource variable=v479 core=ram_s2p_bram

  float v480[1][64][34][34];	// L799
  #pragma HLS resource variable=v480 core=ram_s2p_bram

  for (int v481 = 0; v481 < 64; v481 += 1) {	// L800
    for (int v482 = 0; v482 < 34; v482 += 1) {	// L801
      for (int v483 = 0; v483 < 34; v483 += 1) {	// L802
        v479[0][v481][v482][v483] = v468;	// L803
      }
    }
  }
  for (int v484 = 0; v484 < 64; v484 += 1) {	// L807
    for (int v485 = 0; v485 < 32; v485 += 1) {	// L808
      for (int v486 = 0; v486 < 32; v486 += 1) {	// L809
        float v487 = v469[0][v484][v485][v486];	// L810
        v479[0][v484][(v485 + 1)][(v486 + 1)] = v487;	// L811
      }
    }
  }
  for (int v488 = 0; v488 < 64; v488 += 1) {	// L815
    for (int v489 = 0; v489 < 32; v489 += 1) {	// L816
      for (int v490 = 0; v490 < 32; v490 += 1) {	// L817
        for (int v491 = 0; v491 < 64; v491 += 1) {	// L818
          for (int v492 = 0; v492 < 3; v492 += 1) {	// L819
            for (int v493 = 0; v493 < 3; v493 += 1) {	// L820
              float v494 = v479[0][v491][(v489 + v492)][(v490 + v493)];	// L821
              float v495 = v470[v488][v491][v492][v493];	// L822
              float v496 = v477[0][v488][v489][v490];	// L823
              float v497;
              if (v491 == 0 && v492 == 0 && v493 == 0) {	// L824
                v497 = v468;	// L825
              } else {
                v497 = v496;	// L827
              }
              float v498 = v494 * v495;	// L829
              float v499 = v497 + v498;	// L830
              v477[0][v488][v489][v490] = v499;	// L831
            }
          }
        }
      }
    }
  }
  for (int v500 = 0; v500 < 64; v500 += 1) {	// L838
    for (int v501 = 0; v501 < 32; v501 += 1) {	// L839
      for (int v502 = 0; v502 < 32; v502 += 1) {	// L840
        float v503 = v477[0][v500][v501][v502];	// L841
        float v504 = v471[0][v500][v501][v502];	// L842
        float v505 = v503 + v504;	// L843
        v475[0][v500][v501][v502] = v505;	// L844
      }
    }
  }
  for (int v506 = 0; v506 < 64; v506 += 1) {	// L848
    for (int v507 = 0; v507 < 32; v507 += 1) {	// L849
      for (int v508 = 0; v508 < 32; v508 += 1) {	// L850
        float v509 = v475[0][v506][v507][v508];	// L851
        bool v510 = v509 < v468;	// L852
        float v511 = v510 ? (float)v468 : (float)v509;	// L853
        v476[0][v506][v507][v508] = v511;	// L854
      }
    }
  }
  for (int v512 = 0; v512 < 64; v512 += 1) {	// L858
    for (int v513 = 0; v513 < 34; v513 += 1) {	// L859
      for (int v514 = 0; v514 < 34; v514 += 1) {	// L860
        v480[0][v512][v513][v514] = v468;	// L861
      }
    }
  }
  for (int v515 = 0; v515 < 64; v515 += 1) {	// L865
    for (int v516 = 0; v516 < 32; v516 += 1) {	// L866
      for (int v517 = 0; v517 < 32; v517 += 1) {	// L867
        float v518 = v476[0][v515][v516][v517];	// L868
        v480[0][v515][(v516 + 1)][(v517 + 1)] = v518;	// L869
      }
    }
  }
  for (int v519 = 0; v519 < 64; v519 += 1) {	// L873
    for (int v520 = 0; v520 < 32; v520 += 1) {	// L874
      for (int v521 = 0; v521 < 32; v521 += 1) {	// L875
        for (int v522 = 0; v522 < 64; v522 += 1) {	// L876
          for (int v523 = 0; v523 < 3; v523 += 1) {	// L877
            for (int v524 = 0; v524 < 3; v524 += 1) {	// L878
              float v525 = v480[0][v522][(v520 + v523)][(v521 + v524)];	// L879
              float v526 = v472[v519][v522][v523][v524];	// L880
              float v527 = v478[0][v519][v520][v521];	// L881
              float v528;
              if (v522 == 0 && v523 == 0 && v524 == 0) {	// L882
                v528 = v468;	// L883
              } else {
                v528 = v527;	// L885
              }
              float v529 = v525 * v526;	// L887
              float v530 = v528 + v529;	// L888
              v478[0][v519][v520][v521] = v530;	// L889
            }
          }
        }
      }
    }
  }
  for (int v531 = 0; v531 < 64; v531 += 1) {	// L896
    for (int v532 = 0; v532 < 32; v532 += 1) {	// L897
      for (int v533 = 0; v533 < 32; v533 += 1) {	// L898
        float v534 = v478[0][v531][v532][v533];	// L899
        bool v535 = v534 < v468;	// L900
        float v536 = v535 ? (float)v468 : (float)v534;	// L901
        v473[0][v531][v532][v533] = v536;	// L902
      }
    }
  }
  for (int v537 = 0; v537 < 1; v537 += 1) {	// L906
    for (int v538 = 0; v538 < 64; v538 += 1) {	// L907
      for (int v539 = 0; v539 < 32; v539 += 1) {	// L908
        for (int v540 = 0; v540 < 32; v540 += 1) {	// L909
          float v541 = v476[v537][v538][v539][v540];	// L910
          v474[v537][v538][v539][v540] = v541;	// L911
        }
      }
    }
  }
}

void dataflow3(
  float v542,
  float v543[1][256][8][8],
  float v544[256][256][3][3],
  float v545[1][256][8][8],
  float v546[512][256][3][3],
  float v547[1][512][4][4],
  float v548[1][256][8][8]
) {	// L918
  float v549[1][256][10][10];	// L919
  #pragma HLS resource variable=v549 core=ram_s2p_bram

  float v550[1][256][8][8];	// L920
  #pragma HLS resource variable=v550 core=ram_s2p_bram

  float v551[1][256][8][8];	// L921
  #pragma HLS resource variable=v551 core=ram_s2p_bram

  float v552[1][512][4][4];	// L922
  #pragma HLS resource variable=v552 core=ram_s2p_bram

  float v553[1][256][10][10];	// L923
  #pragma HLS resource variable=v553 core=ram_s2p_bram

  float v554[1][256][8][8];	// L924
  #pragma HLS resource variable=v554 core=ram_s2p_bram

  for (int v555 = 0; v555 < 256; v555 += 1) {	// L925
    for (int v556 = 0; v556 < 10; v556 += 1) {	// L926
      for (int v557 = 0; v557 < 10; v557 += 1) {	// L927
        v553[0][v555][v556][v557] = v542;	// L928
      }
    }
  }
  for (int v558 = 0; v558 < 256; v558 += 1) {	// L932
    for (int v559 = 0; v559 < 8; v559 += 1) {	// L933
      for (int v560 = 0; v560 < 8; v560 += 1) {	// L934
        float v561 = v543[0][v558][v559][v560];	// L935
        v553[0][v558][(v559 + 1)][(v560 + 1)] = v561;	// L936
      }
    }
  }
  for (int v562 = 0; v562 < 256; v562 += 1) {	// L940
    for (int v563 = 0; v563 < 8; v563 += 1) {	// L941
      for (int v564 = 0; v564 < 8; v564 += 1) {	// L942
        for (int v565 = 0; v565 < 256; v565 += 1) {	// L943
          for (int v566 = 0; v566 < 3; v566 += 1) {	// L944
            for (int v567 = 0; v567 < 3; v567 += 1) {	// L945
              float v568 = v553[0][v565][(v563 + v566)][(v564 + v567)];	// L946
              float v569 = v544[v562][v565][v566][v567];	// L947
              float v570 = v551[0][v562][v563][v564];	// L948
              float v571;
              if (v565 == 0 && v566 == 0 && v567 == 0) {	// L949
                v571 = v542;	// L950
              } else {
                v571 = v570;	// L952
              }
              float v572 = v568 * v569;	// L954
              float v573 = v571 + v572;	// L955
              v551[0][v562][v563][v564] = v573;	// L956
            }
          }
        }
      }
    }
  }
  for (int v574 = 0; v574 < 256; v574 += 1) {	// L963
    for (int v575 = 0; v575 < 8; v575 += 1) {	// L964
      for (int v576 = 0; v576 < 8; v576 += 1) {	// L965
        float v577 = v551[0][v574][v575][v576];	// L966
        float v578 = v545[0][v574][v575][v576];	// L967
        float v579 = v577 + v578;	// L968
        v550[0][v574][v575][v576] = v579;	// L969
      }
    }
  }
  for (int v580 = 0; v580 < 256; v580 += 1) {	// L973
    for (int v581 = 0; v581 < 8; v581 += 1) {	// L974
      for (int v582 = 0; v582 < 8; v582 += 1) {	// L975
        float v583 = v550[0][v580][v581][v582];	// L976
        bool v584 = v583 < v542;	// L977
        float v585 = v584 ? (float)v542 : (float)v583;	// L978
        v554[0][v580][v581][v582] = v585;	// L979
      }
    }
  }
  for (int v586 = 0; v586 < 256; v586 += 1) {	// L983
    for (int v587 = 0; v587 < 10; v587 += 1) {	// L984
      for (int v588 = 0; v588 < 10; v588 += 1) {	// L985
        v549[0][v586][v587][v588] = v542;	// L986
      }
    }
  }
  for (int v589 = 0; v589 < 256; v589 += 1) {	// L990
    for (int v590 = 0; v590 < 8; v590 += 1) {	// L991
      for (int v591 = 0; v591 < 8; v591 += 1) {	// L992
        float v592 = v554[0][v589][v590][v591];	// L993
        v549[0][v589][(v590 + 1)][(v591 + 1)] = v592;	// L994
      }
    }
  }
  for (int v593 = 0; v593 < 512; v593 += 1) {	// L998
    for (int v594 = 0; v594 < 4; v594 += 1) {	// L999
      for (int v595 = 0; v595 < 4; v595 += 1) {	// L1000
        for (int v596 = 0; v596 < 256; v596 += 1) {	// L1001
          for (int v597 = 0; v597 < 3; v597 += 1) {	// L1002
            for (int v598 = 0; v598 < 3; v598 += 1) {	// L1003
              float v599 = v549[0][v596][((v594 * 2) + v597)][((v595 * 2) + v598)];	// L1004
              float v600 = v546[v593][v596][v597][v598];	// L1005
              float v601 = v552[0][v593][v594][v595];	// L1006
              float v602;
              if (v596 == 0 && v597 == 0 && v598 == 0) {	// L1007
                v602 = v542;	// L1008
              } else {
                v602 = v601;	// L1010
              }
              float v603 = v599 * v600;	// L1012
              float v604 = v602 + v603;	// L1013
              v552[0][v593][v594][v595] = v604;	// L1014
            }
          }
        }
      }
    }
  }
  for (int v605 = 0; v605 < 512; v605 += 1) {	// L1021
    for (int v606 = 0; v606 < 4; v606 += 1) {	// L1022
      for (int v607 = 0; v607 < 4; v607 += 1) {	// L1023
        float v608 = v552[0][v605][v606][v607];	// L1024
        bool v609 = v608 < v542;	// L1025
        float v610 = v609 ? (float)v542 : (float)v608;	// L1026
        v547[0][v605][v606][v607] = v610;	// L1027
      }
    }
  }
  for (int v611 = 0; v611 < 1; v611 += 1) {	// L1031
    for (int v612 = 0; v612 < 256; v612 += 1) {	// L1032
      for (int v613 = 0; v613 < 8; v613 += 1) {	// L1033
        for (int v614 = 0; v614 < 8; v614 += 1) {	// L1034
          float v615 = v554[v611][v612][v613][v614];	// L1035
          v548[v611][v612][v613][v614] = v615;	// L1036
        }
      }
    }
  }
}

void dataflow5(
  float v616,
  float v617[1][128][16][16],
  float v618[128][128][3][3],
  float v619[1][128][16][16],
  float v620[256][128][3][3],
  float v621[1][256][8][8],
  float v622[1][128][16][16]
) {	// L1043
  float v623[1][128][16][16];	// L1044
  #pragma HLS resource variable=v623 core=ram_s2p_bram

  float v624[1][128][18][18];	// L1045
  #pragma HLS resource variable=v624 core=ram_s2p_bram

  float v625[1][256][8][8];	// L1046
  #pragma HLS resource variable=v625 core=ram_s2p_bram

  float v626[1][128][18][18];	// L1047
  #pragma HLS resource variable=v626 core=ram_s2p_bram

  float v627[1][128][16][16];	// L1048
  #pragma HLS resource variable=v627 core=ram_s2p_bram

  float v628[1][128][16][16];	// L1049
  #pragma HLS resource variable=v628 core=ram_s2p_bram

  for (int v629 = 0; v629 < 128; v629 += 1) {	// L1050
    for (int v630 = 0; v630 < 18; v630 += 1) {	// L1051
      for (int v631 = 0; v631 < 18; v631 += 1) {	// L1052
        v626[0][v629][v630][v631] = v616;	// L1053
      }
    }
  }
  for (int v632 = 0; v632 < 128; v632 += 1) {	// L1057
    for (int v633 = 0; v633 < 16; v633 += 1) {	// L1058
      for (int v634 = 0; v634 < 16; v634 += 1) {	// L1059
        float v635 = v617[0][v632][v633][v634];	// L1060
        v626[0][v632][(v633 + 1)][(v634 + 1)] = v635;	// L1061
      }
    }
  }
  for (int v636 = 0; v636 < 128; v636 += 1) {	// L1065
    for (int v637 = 0; v637 < 16; v637 += 1) {	// L1066
      for (int v638 = 0; v638 < 16; v638 += 1) {	// L1067
        for (int v639 = 0; v639 < 128; v639 += 1) {	// L1068
          for (int v640 = 0; v640 < 3; v640 += 1) {	// L1069
            for (int v641 = 0; v641 < 3; v641 += 1) {	// L1070
              float v642 = v626[0][v639][(v637 + v640)][(v638 + v641)];	// L1071
              float v643 = v618[v636][v639][v640][v641];	// L1072
              float v644 = v627[0][v636][v637][v638];	// L1073
              float v645;
              if (v639 == 0 && v640 == 0 && v641 == 0) {	// L1074
                v645 = v616;	// L1075
              } else {
                v645 = v644;	// L1077
              }
              float v646 = v642 * v643;	// L1079
              float v647 = v645 + v646;	// L1080
              v627[0][v636][v637][v638] = v647;	// L1081
            }
          }
        }
      }
    }
  }
  for (int v648 = 0; v648 < 128; v648 += 1) {	// L1088
    for (int v649 = 0; v649 < 16; v649 += 1) {	// L1089
      for (int v650 = 0; v650 < 16; v650 += 1) {	// L1090
        float v651 = v627[0][v648][v649][v650];	// L1091
        float v652 = v619[0][v648][v649][v650];	// L1092
        float v653 = v651 + v652;	// L1093
        v628[0][v648][v649][v650] = v653;	// L1094
      }
    }
  }
  for (int v654 = 0; v654 < 128; v654 += 1) {	// L1098
    for (int v655 = 0; v655 < 16; v655 += 1) {	// L1099
      for (int v656 = 0; v656 < 16; v656 += 1) {	// L1100
        float v657 = v628[0][v654][v655][v656];	// L1101
        bool v658 = v657 < v616;	// L1102
        float v659 = v658 ? (float)v616 : (float)v657;	// L1103
        v623[0][v654][v655][v656] = v659;	// L1104
      }
    }
  }
  for (int v660 = 0; v660 < 128; v660 += 1) {	// L1108
    for (int v661 = 0; v661 < 18; v661 += 1) {	// L1109
      for (int v662 = 0; v662 < 18; v662 += 1) {	// L1110
        v624[0][v660][v661][v662] = v616;	// L1111
      }
    }
  }
  for (int v663 = 0; v663 < 128; v663 += 1) {	// L1115
    for (int v664 = 0; v664 < 16; v664 += 1) {	// L1116
      for (int v665 = 0; v665 < 16; v665 += 1) {	// L1117
        float v666 = v623[0][v663][v664][v665];	// L1118
        v624[0][v663][(v664 + 1)][(v665 + 1)] = v666;	// L1119
      }
    }
  }
  for (int v667 = 0; v667 < 256; v667 += 1) {	// L1123
    for (int v668 = 0; v668 < 8; v668 += 1) {	// L1124
      for (int v669 = 0; v669 < 8; v669 += 1) {	// L1125
        for (int v670 = 0; v670 < 128; v670 += 1) {	// L1126
          for (int v671 = 0; v671 < 3; v671 += 1) {	// L1127
            for (int v672 = 0; v672 < 3; v672 += 1) {	// L1128
              float v673 = v624[0][v670][((v668 * 2) + v671)][((v669 * 2) + v672)];	// L1129
              float v674 = v620[v667][v670][v671][v672];	// L1130
              float v675 = v625[0][v667][v668][v669];	// L1131
              float v676;
              if (v670 == 0 && v671 == 0 && v672 == 0) {	// L1132
                v676 = v616;	// L1133
              } else {
                v676 = v675;	// L1135
              }
              float v677 = v673 * v674;	// L1137
              float v678 = v676 + v677;	// L1138
              v625[0][v667][v668][v669] = v678;	// L1139
            }
          }
        }
      }
    }
  }
  for (int v679 = 0; v679 < 256; v679 += 1) {	// L1146
    for (int v680 = 0; v680 < 8; v680 += 1) {	// L1147
      for (int v681 = 0; v681 < 8; v681 += 1) {	// L1148
        float v682 = v625[0][v679][v680][v681];	// L1149
        bool v683 = v682 < v616;	// L1150
        float v684 = v683 ? (float)v616 : (float)v682;	// L1151
        v621[0][v679][v680][v681] = v684;	// L1152
      }
    }
  }
  for (int v685 = 0; v685 < 1; v685 += 1) {	// L1156
    for (int v686 = 0; v686 < 128; v686 += 1) {	// L1157
      for (int v687 = 0; v687 < 16; v687 += 1) {	// L1158
        for (int v688 = 0; v688 < 16; v688 += 1) {	// L1159
          float v689 = v623[v685][v686][v687][v688];	// L1160
          v622[v685][v686][v687][v688] = v689;	// L1161
        }
      }
    }
  }
}

/// This is top function.
void main_graph(
  float v690[1][3][32][32],
  float v691[64][3][3][3],
  float v692[64][64][3][3],
  float v693[64][64][3][3],
  float v694[64][64][3][3],
  float v695[64][64][3][3],
  float v696[128][64][3][3],
  float v697[128][128][3][3],
  float v698[128][64][1][1],
  float v699[128][128][3][3],
  float v700[128][128][3][3],
  float v701[256][128][3][3],
  float v702[256][256][3][3],
  float v703[256][128][1][1],
  float v704[256][256][3][3],
  float v705[256][256][3][3],
  float v706[512][256][3][3],
  float v707[512][512][3][3],
  float v708[512][256][1][1],
  float v709[512][512][3][3],
  float v710[512][512][3][3],
  float v711[10][512],
  float v712[1][10]
) {	// L1168
  #pragma HLS dataflow

  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v690
  #pragma HLS interface bram port=v691
  #pragma HLS interface bram port=v692
  #pragma HLS interface bram port=v693
  #pragma HLS interface bram port=v694
  #pragma HLS interface bram port=v695
  #pragma HLS interface bram port=v696
  #pragma HLS interface bram port=v697
  #pragma HLS interface bram port=v698
  #pragma HLS interface bram port=v699
  #pragma HLS interface bram port=v700
  #pragma HLS interface bram port=v701
  #pragma HLS interface bram port=v702
  #pragma HLS interface bram port=v703
  #pragma HLS interface bram port=v704
  #pragma HLS interface bram port=v705
  #pragma HLS interface bram port=v706
  #pragma HLS interface bram port=v707
  #pragma HLS interface bram port=v708
  #pragma HLS interface bram port=v709
  #pragma HLS interface bram port=v710
  #pragma HLS interface bram port=v711
  #pragma HLS interface bram port=v712

  #pragma HLS resource variable=v690 core=ram_s2p_bram

  #pragma HLS resource variable=v691 core=ram_s2p_bram

  #pragma HLS resource variable=v692 core=ram_s2p_bram

  #pragma HLS resource variable=v693 core=ram_s2p_bram

  #pragma HLS resource variable=v694 core=ram_s2p_bram

  #pragma HLS resource variable=v695 core=ram_s2p_bram

  #pragma HLS resource variable=v696 core=ram_s2p_bram

  #pragma HLS resource variable=v697 core=ram_s2p_bram

  #pragma HLS resource variable=v698 core=ram_s2p_bram

  #pragma HLS resource variable=v699 core=ram_s2p_bram

  #pragma HLS resource variable=v700 core=ram_s2p_bram

  #pragma HLS resource variable=v701 core=ram_s2p_bram

  #pragma HLS resource variable=v702 core=ram_s2p_bram

  #pragma HLS resource variable=v703 core=ram_s2p_bram

  #pragma HLS resource variable=v704 core=ram_s2p_bram

  #pragma HLS resource variable=v705 core=ram_s2p_bram

  #pragma HLS resource variable=v706 core=ram_s2p_bram

  #pragma HLS resource variable=v707 core=ram_s2p_bram

  #pragma HLS resource variable=v708 core=ram_s2p_bram

  #pragma HLS resource variable=v709 core=ram_s2p_bram

  #pragma HLS resource variable=v710 core=ram_s2p_bram

  #pragma HLS resource variable=v711 core=ram_s2p_bram

  #pragma HLS resource variable=v712 core=ram_s2p_bram

  float v713[10] = {-2.781226e-02, -4.107117e-02, -8.704335e-03, -3.831929e-02, -2.075570e-02, 4.087221e-02, 3.640073e-02, 4.095368e-02, 3.038846e-03, -4.327787e-02};	// L1172
  float v714[1][512][4][4];	// L1174
  #pragma HLS resource variable=v714 core=ram_s2p_bram

  float v715[1][512][4][4];	// L1175
  #pragma HLS resource variable=v715 core=ram_s2p_bram

  float v716[1][256][8][8];	// L1176
  #pragma HLS resource variable=v716 core=ram_s2p_bram

  float v717[1][256][8][8];	// L1177
  #pragma HLS resource variable=v717 core=ram_s2p_bram

  float v718[1][128][16][16];	// L1178
  #pragma HLS resource variable=v718 core=ram_s2p_bram

  float v719[1][128][16][16];	// L1179
  #pragma HLS resource variable=v719 core=ram_s2p_bram

  float v720[1][64][32][32];	// L1180
  #pragma HLS resource variable=v720 core=ram_s2p_bram

  float v721[1][64][32][32];	// L1181
  #pragma HLS resource variable=v721 core=ram_s2p_bram

  float v722[1][64][32][32];	// L1182
  #pragma HLS resource variable=v722 core=ram_s2p_bram

  dataflow9(0.000000, v690, v691, v692, v721, v722);	// L1183
  float v723[1][64][32][32];	// L1184
  #pragma HLS resource variable=v723 core=ram_s2p_bram

  dataflow8(0.000000, v721, v693, v722, v694, v720, v723);	// L1185
  float v724[1][64][32][32];	// L1186
  #pragma HLS resource variable=v724 core=ram_s2p_bram

  dataflow7(0.000000, v720, v695, v723, v696, v719, v724);	// L1187
  float v725[1][128][16][16];	// L1188
  #pragma HLS resource variable=v725 core=ram_s2p_bram

  dataflow6(0.000000, v719, v697, v724, v698, v699, v718, v725);	// L1189
  float v726[1][128][16][16];	// L1190
  #pragma HLS resource variable=v726 core=ram_s2p_bram

  dataflow5(0.000000, v718, v700, v725, v701, v717, v726);	// L1191
  float v727[1][256][8][8];	// L1192
  #pragma HLS resource variable=v727 core=ram_s2p_bram

  dataflow4(0.000000, v717, v702, v726, v703, v704, v716, v727);	// L1193
  float v728[1][256][8][8];	// L1194
  #pragma HLS resource variable=v728 core=ram_s2p_bram

  dataflow3(0.000000, v716, v705, v727, v706, v715, v728);	// L1195
  float v729[1][512][4][4];	// L1196
  #pragma HLS resource variable=v729 core=ram_s2p_bram

  dataflow2(0.000000, v715, v707, v728, v708, v709, v714, v729);	// L1197
  #pragma HLS resource variable=v713 core=ram_s2p_bram

  dataflow1(0.000000, v714, v710, v729, 16.000000, 1.000000, v711, v712, v713);	// L1199
}

