
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
) {	// L5
  float v7[1][64][32][32];	// L6
  #pragma HLS resource variable=v7 core=ram_s2p_bram

  float v8[1][64][34][34];	// L7
  #pragma HLS resource variable=v8 core=ram_s2p_bram

  float v9[1][128][16][16];	// L8
  #pragma HLS resource variable=v9 core=ram_s2p_bram

  float v10[1][64][34][34];	// L9
  #pragma HLS resource variable=v10 core=ram_s2p_bram

  float v11[1][64][32][32];	// L10
  #pragma HLS resource variable=v11 core=ram_s2p_bram

  float v12[1][64][32][32];	// L11
  #pragma HLS resource variable=v12 core=ram_s2p_bram

  for (int v13 = 0; v13 < 64; v13 += 1) {	// L12
    for (int v14 = 0; v14 < 34; v14 += 1) {	// L13
      for (int v15 = 0; v15 < 34; v15 += 1) {	// L14
        v10[0][v13][v14][v15] = v0;	// L15
      }
    }
  }
  for (int v16 = 0; v16 < 64; v16 += 1) {	// L19
    for (int v17 = 0; v17 < 32; v17 += 1) {	// L20
      for (int v18 = 0; v18 < 32; v18 += 1) {	// L21
        float v19 = v1[0][v16][v17][v18];	// L22
        v10[0][v16][(v17 + 1)][(v18 + 1)] = v19;	// L23
      }
    }
  }
  for (int v20 = 0; v20 < 64; v20 += 1) {	// L27
    for (int v21 = 0; v21 < 32; v21 += 1) {	// L28
      for (int v22 = 0; v22 < 32; v22 += 1) {	// L29
        v7[0][v20][v21][v22] = v0;	// L30
        for (int v23 = 0; v23 < 64; v23 += 1) {	// L31
          for (int v24 = 0; v24 < 3; v24 += 1) {	// L32
            for (int v25 = 0; v25 < 3; v25 += 1) {	// L33
              float v26 = v10[0][v23][(v21 + v24)][(v22 + v25)];	// L34
              float v27 = v2[v20][v23][v24][v25];	// L35
              float v28 = v7[0][v20][v21][v22];	// L36
              float v29 = v26 * v27;	// L37
              float v30 = v28 + v29;	// L38
              v7[0][v20][v21][v22] = v30;	// L39
            }
          }
        }
      }
    }
  }
  for (int v31 = 0; v31 < 64; v31 += 1) {	// L46
    for (int v32 = 0; v32 < 32; v32 += 1) {	// L47
      for (int v33 = 0; v33 < 32; v33 += 1) {	// L48
        float v34 = v7[0][v31][v32][v33];	// L49
        float v35 = v3[0][v31][v32][v33];	// L50
        float v36 = v34 + v35;	// L51
        v12[0][v31][v32][v33] = v36;	// L52
      }
    }
  }
  for (int v37 = 0; v37 < 64; v37 += 1) {	// L56
    for (int v38 = 0; v38 < 32; v38 += 1) {	// L57
      for (int v39 = 0; v39 < 32; v39 += 1) {	// L58
        float v40 = v12[0][v37][v38][v39];	// L59
        bool v41 = v40 < v0;	// L60
        float v42 = v41 ? (float)v0 : (float)v40;	// L61
        v11[0][v37][v38][v39] = v42;	// L62
      }
    }
  }
  for (int v43 = 0; v43 < 64; v43 += 1) {	// L66
    for (int v44 = 0; v44 < 34; v44 += 1) {	// L67
      for (int v45 = 0; v45 < 34; v45 += 1) {	// L68
        v8[0][v43][v44][v45] = v0;	// L69
      }
    }
  }
  for (int v46 = 0; v46 < 64; v46 += 1) {	// L73
    for (int v47 = 0; v47 < 32; v47 += 1) {	// L74
      for (int v48 = 0; v48 < 32; v48 += 1) {	// L75
        float v49 = v11[0][v46][v47][v48];	// L76
        v8[0][v46][(v47 + 1)][(v48 + 1)] = v49;	// L77
      }
    }
  }
  for (int v50 = 0; v50 < 128; v50 += 1) {	// L81
    for (int v51 = 0; v51 < 16; v51 += 1) {	// L82
      for (int v52 = 0; v52 < 16; v52 += 1) {	// L83
        v9[0][v50][v51][v52] = v0;	// L84
        for (int v53 = 0; v53 < 64; v53 += 1) {	// L85
          for (int v54 = 0; v54 < 3; v54 += 1) {	// L86
            for (int v55 = 0; v55 < 3; v55 += 1) {	// L87
              float v56 = v8[0][v53][((v51 * 2) + v54)][((v52 * 2) + v55)];	// L88
              float v57 = v4[v50][v53][v54][v55];	// L89
              float v58 = v9[0][v50][v51][v52];	// L90
              float v59 = v56 * v57;	// L91
              float v60 = v58 + v59;	// L92
              v9[0][v50][v51][v52] = v60;	// L93
            }
          }
        }
      }
    }
  }
  for (int v61 = 0; v61 < 128; v61 += 1) {	// L100
    for (int v62 = 0; v62 < 16; v62 += 1) {	// L101
      for (int v63 = 0; v63 < 16; v63 += 1) {	// L102
        float v64 = v9[0][v61][v62][v63];	// L103
        bool v65 = v64 < v0;	// L104
        float v66 = v65 ? (float)v0 : (float)v64;	// L105
        v5[0][v61][v62][v63] = v66;	// L106
      }
    }
  }
  for (int v67 = 0; v67 < 1; v67 += 1) {	// L110
    for (int v68 = 0; v68 < 64; v68 += 1) {	// L111
      for (int v69 = 0; v69 < 32; v69 += 1) {	// L112
        for (int v70 = 0; v70 < 32; v70 += 1) {	// L113
          float v71 = v11[v67][v68][v69][v70];	// L114
          v6[v67][v68][v69][v70] = v71;	// L115
        }
      }
    }
  }
}

void dataflow2(
  float v72,
  float v73[1][512][4][4],
  float v74[512][512][3][3],
  float v75[1][256][8][8],
  float v76[512][256][1][1],
  float v77[512][512][3][3],
  float v78[1][512][4][4],
  float v79[1][512][4][4]
) {	// L122
  float v80[1][512][4][4];	// L123
  #pragma HLS resource variable=v80 core=ram_s2p_bram

  float v81[1][512][4][4];	// L124
  #pragma HLS resource variable=v81 core=ram_s2p_bram

  float v82[1][512][4][4];	// L125
  #pragma HLS resource variable=v82 core=ram_s2p_bram

  float v83[1][512][4][4];	// L126
  #pragma HLS resource variable=v83 core=ram_s2p_bram

  float v84[1][512][4][4];	// L127
  #pragma HLS resource variable=v84 core=ram_s2p_bram

  float v85[1][512][6][6];	// L128
  #pragma HLS resource variable=v85 core=ram_s2p_bram

  float v86[1][512][6][6];	// L129
  #pragma HLS resource variable=v86 core=ram_s2p_bram

  for (int v87 = 0; v87 < 512; v87 += 1) {	// L130
    for (int v88 = 0; v88 < 6; v88 += 1) {	// L131
      for (int v89 = 0; v89 < 6; v89 += 1) {	// L132
        v85[0][v87][v88][v89] = v72;	// L133
      }
    }
  }
  for (int v90 = 0; v90 < 512; v90 += 1) {	// L137
    for (int v91 = 0; v91 < 4; v91 += 1) {	// L138
      for (int v92 = 0; v92 < 4; v92 += 1) {	// L139
        float v93 = v73[0][v90][v91][v92];	// L140
        v85[0][v90][(v91 + 1)][(v92 + 1)] = v93;	// L141
      }
    }
  }
  for (int v94 = 0; v94 < 512; v94 += 1) {	// L145
    for (int v95 = 0; v95 < 4; v95 += 1) {	// L146
      for (int v96 = 0; v96 < 4; v96 += 1) {	// L147
        v84[0][v94][v95][v96] = v72;	// L148
        for (int v97 = 0; v97 < 512; v97 += 1) {	// L149
          for (int v98 = 0; v98 < 3; v98 += 1) {	// L150
            for (int v99 = 0; v99 < 3; v99 += 1) {	// L151
              float v100 = v85[0][v97][(v95 + v98)][(v96 + v99)];	// L152
              float v101 = v74[v94][v97][v98][v99];	// L153
              float v102 = v84[0][v94][v95][v96];	// L154
              float v103 = v100 * v101;	// L155
              float v104 = v102 + v103;	// L156
              v84[0][v94][v95][v96] = v104;	// L157
            }
          }
        }
      }
    }
  }
  for (int v105 = 0; v105 < 512; v105 += 1) {	// L164
    for (int v106 = 0; v106 < 4; v106 += 1) {	// L165
      for (int v107 = 0; v107 < 4; v107 += 1) {	// L166
        v82[0][v105][v106][v107] = v72;	// L167
        for (int v108 = 0; v108 < 256; v108 += 1) {	// L168
          float v109 = v75[0][v108][(v106 * 2)][(v107 * 2)];	// L169
          float v110 = v76[v105][v108][0][0];	// L170
          float v111 = v82[0][v105][v106][v107];	// L171
          float v112 = v109 * v110;	// L172
          float v113 = v111 + v112;	// L173
          v82[0][v105][v106][v107] = v113;	// L174
        }
      }
    }
  }
  for (int v114 = 0; v114 < 512; v114 += 1) {	// L179
    for (int v115 = 0; v115 < 4; v115 += 1) {	// L180
      for (int v116 = 0; v116 < 4; v116 += 1) {	// L181
        float v117 = v84[0][v114][v115][v116];	// L182
        float v118 = v82[0][v114][v115][v116];	// L183
        float v119 = v117 + v118;	// L184
        v80[0][v114][v115][v116] = v119;	// L185
      }
    }
  }
  for (int v120 = 0; v120 < 512; v120 += 1) {	// L189
    for (int v121 = 0; v121 < 4; v121 += 1) {	// L190
      for (int v122 = 0; v122 < 4; v122 += 1) {	// L191
        float v123 = v80[0][v120][v121][v122];	// L192
        bool v124 = v123 < v72;	// L193
        float v125 = v124 ? (float)v72 : (float)v123;	// L194
        v83[0][v120][v121][v122] = v125;	// L195
      }
    }
  }
  for (int v126 = 0; v126 < 512; v126 += 1) {	// L199
    for (int v127 = 0; v127 < 6; v127 += 1) {	// L200
      for (int v128 = 0; v128 < 6; v128 += 1) {	// L201
        v86[0][v126][v127][v128] = v72;	// L202
      }
    }
  }
  for (int v129 = 0; v129 < 512; v129 += 1) {	// L206
    for (int v130 = 0; v130 < 4; v130 += 1) {	// L207
      for (int v131 = 0; v131 < 4; v131 += 1) {	// L208
        float v132 = v83[0][v129][v130][v131];	// L209
        v86[0][v129][(v130 + 1)][(v131 + 1)] = v132;	// L210
      }
    }
  }
  for (int v133 = 0; v133 < 512; v133 += 1) {	// L214
    for (int v134 = 0; v134 < 4; v134 += 1) {	// L215
      for (int v135 = 0; v135 < 4; v135 += 1) {	// L216
        v81[0][v133][v134][v135] = v72;	// L217
        for (int v136 = 0; v136 < 512; v136 += 1) {	// L218
          for (int v137 = 0; v137 < 3; v137 += 1) {	// L219
            for (int v138 = 0; v138 < 3; v138 += 1) {	// L220
              float v139 = v86[0][v136][(v134 + v137)][(v135 + v138)];	// L221
              float v140 = v77[v133][v136][v137][v138];	// L222
              float v141 = v81[0][v133][v134][v135];	// L223
              float v142 = v139 * v140;	// L224
              float v143 = v141 + v142;	// L225
              v81[0][v133][v134][v135] = v143;	// L226
            }
          }
        }
      }
    }
  }
  for (int v144 = 0; v144 < 512; v144 += 1) {	// L233
    for (int v145 = 0; v145 < 4; v145 += 1) {	// L234
      for (int v146 = 0; v146 < 4; v146 += 1) {	// L235
        float v147 = v81[0][v144][v145][v146];	// L236
        bool v148 = v147 < v72;	// L237
        float v149 = v148 ? (float)v72 : (float)v147;	// L238
        v78[0][v144][v145][v146] = v149;	// L239
      }
    }
  }
  for (int v150 = 0; v150 < 1; v150 += 1) {	// L243
    for (int v151 = 0; v151 < 512; v151 += 1) {	// L244
      for (int v152 = 0; v152 < 4; v152 += 1) {	// L245
        for (int v153 = 0; v153 < 4; v153 += 1) {	// L246
          float v154 = v83[v150][v151][v152][v153];	// L247
          v79[v150][v151][v152][v153] = v154;	// L248
        }
      }
    }
  }
}

void dataflow9(
  float v155,
  float v156[1][3][32][32],
  float v157[64][3][3][3],
  float v158[64][64][3][3],
  float v159[1][64][32][32],
  float v160[1][64][32][32]
) {	// L255
  float v161[1][64][32][32];	// L256
  #pragma HLS resource variable=v161 core=ram_s2p_bram

  float v162[1][64][34][34];	// L257
  #pragma HLS resource variable=v162 core=ram_s2p_bram

  float v163[1][64][32][32];	// L258
  #pragma HLS resource variable=v163 core=ram_s2p_bram

  float v164[1][64][32][32];	// L259
  #pragma HLS resource variable=v164 core=ram_s2p_bram

  float v165[1][3][34][34];	// L260
  #pragma HLS resource variable=v165 core=ram_s2p_bram

  for (int v166 = 0; v166 < 3; v166 += 1) {	// L261
    for (int v167 = 0; v167 < 34; v167 += 1) {	// L262
      for (int v168 = 0; v168 < 34; v168 += 1) {	// L263
        v165[0][v166][v167][v168] = v155;	// L264
      }
    }
  }
  for (int v169 = 0; v169 < 3; v169 += 1) {	// L268
    for (int v170 = 0; v170 < 32; v170 += 1) {	// L269
      for (int v171 = 0; v171 < 32; v171 += 1) {	// L270
        float v172 = v156[0][v169][v170][v171];	// L271
        v165[0][v169][(v170 + 1)][(v171 + 1)] = v172;	// L272
      }
    }
  }
  for (int v173 = 0; v173 < 64; v173 += 1) {	// L276
    for (int v174 = 0; v174 < 32; v174 += 1) {	// L277
      for (int v175 = 0; v175 < 32; v175 += 1) {	// L278
        v163[0][v173][v174][v175] = v155;	// L279
        for (int v176 = 0; v176 < 3; v176 += 1) {	// L280
          for (int v177 = 0; v177 < 3; v177 += 1) {	// L281
            for (int v178 = 0; v178 < 3; v178 += 1) {	// L282
              float v179 = v165[0][v176][(v174 + v177)][(v175 + v178)];	// L283
              float v180 = v157[v173][v176][v177][v178];	// L284
              float v181 = v163[0][v173][v174][v175];	// L285
              float v182 = v179 * v180;	// L286
              float v183 = v181 + v182;	// L287
              v163[0][v173][v174][v175] = v183;	// L288
            }
          }
        }
      }
    }
  }
  for (int v184 = 0; v184 < 64; v184 += 1) {	// L295
    for (int v185 = 0; v185 < 32; v185 += 1) {	// L296
      for (int v186 = 0; v186 < 32; v186 += 1) {	// L297
        float v187 = v163[0][v184][v185][v186];	// L298
        bool v188 = v187 < v155;	// L299
        float v189 = v188 ? (float)v155 : (float)v187;	// L300
        v164[0][v184][v185][v186] = v189;	// L301
      }
    }
  }
  for (int v190 = 0; v190 < 64; v190 += 1) {	// L305
    for (int v191 = 0; v191 < 34; v191 += 1) {	// L306
      for (int v192 = 0; v192 < 34; v192 += 1) {	// L307
        v162[0][v190][v191][v192] = v155;	// L308
      }
    }
  }
  for (int v193 = 0; v193 < 64; v193 += 1) {	// L312
    for (int v194 = 0; v194 < 32; v194 += 1) {	// L313
      for (int v195 = 0; v195 < 32; v195 += 1) {	// L314
        float v196 = v164[0][v193][v194][v195];	// L315
        v162[0][v193][(v194 + 1)][(v195 + 1)] = v196;	// L316
      }
    }
  }
  for (int v197 = 0; v197 < 64; v197 += 1) {	// L320
    for (int v198 = 0; v198 < 32; v198 += 1) {	// L321
      for (int v199 = 0; v199 < 32; v199 += 1) {	// L322
        v161[0][v197][v198][v199] = v155;	// L323
        for (int v200 = 0; v200 < 64; v200 += 1) {	// L324
          for (int v201 = 0; v201 < 3; v201 += 1) {	// L325
            for (int v202 = 0; v202 < 3; v202 += 1) {	// L326
              float v203 = v162[0][v200][(v198 + v201)][(v199 + v202)];	// L327
              float v204 = v158[v197][v200][v201][v202];	// L328
              float v205 = v161[0][v197][v198][v199];	// L329
              float v206 = v203 * v204;	// L330
              float v207 = v205 + v206;	// L331
              v161[0][v197][v198][v199] = v207;	// L332
            }
          }
        }
      }
    }
  }
  for (int v208 = 0; v208 < 64; v208 += 1) {	// L339
    for (int v209 = 0; v209 < 32; v209 += 1) {	// L340
      for (int v210 = 0; v210 < 32; v210 += 1) {	// L341
        float v211 = v161[0][v208][v209][v210];	// L342
        bool v212 = v211 < v155;	// L343
        float v213 = v212 ? (float)v155 : (float)v211;	// L344
        v159[0][v208][v209][v210] = v213;	// L345
      }
    }
  }
  for (int v214 = 0; v214 < 1; v214 += 1) {	// L349
    for (int v215 = 0; v215 < 64; v215 += 1) {	// L350
      for (int v216 = 0; v216 < 32; v216 += 1) {	// L351
        for (int v217 = 0; v217 < 32; v217 += 1) {	// L352
          float v218 = v164[v214][v215][v216][v217];	// L353
          v160[v214][v215][v216][v217] = v218;	// L354
        }
      }
    }
  }
}

void dataflow4(
  float v219,
  float v220[1][256][8][8],
  float v221[256][256][3][3],
  float v222[1][128][16][16],
  float v223[256][128][1][1],
  float v224[256][256][3][3],
  float v225[1][256][8][8],
  float v226[1][256][8][8]
) {	// L361
  float v227[1][256][8][8];	// L362
  #pragma HLS resource variable=v227 core=ram_s2p_bram

  float v228[1][256][8][8];	// L363
  #pragma HLS resource variable=v228 core=ram_s2p_bram

  float v229[1][256][8][8];	// L364
  #pragma HLS resource variable=v229 core=ram_s2p_bram

  float v230[1][256][8][8];	// L365
  #pragma HLS resource variable=v230 core=ram_s2p_bram

  float v231[1][256][8][8];	// L366
  #pragma HLS resource variable=v231 core=ram_s2p_bram

  float v232[1][256][10][10];	// L367
  #pragma HLS resource variable=v232 core=ram_s2p_bram

  float v233[1][256][10][10];	// L368
  #pragma HLS resource variable=v233 core=ram_s2p_bram

  for (int v234 = 0; v234 < 256; v234 += 1) {	// L369
    for (int v235 = 0; v235 < 10; v235 += 1) {	// L370
      for (int v236 = 0; v236 < 10; v236 += 1) {	// L371
        v232[0][v234][v235][v236] = v219;	// L372
      }
    }
  }
  for (int v237 = 0; v237 < 256; v237 += 1) {	// L376
    for (int v238 = 0; v238 < 8; v238 += 1) {	// L377
      for (int v239 = 0; v239 < 8; v239 += 1) {	// L378
        float v240 = v220[0][v237][v238][v239];	// L379
        v232[0][v237][(v238 + 1)][(v239 + 1)] = v240;	// L380
      }
    }
  }
  for (int v241 = 0; v241 < 256; v241 += 1) {	// L384
    for (int v242 = 0; v242 < 8; v242 += 1) {	// L385
      for (int v243 = 0; v243 < 8; v243 += 1) {	// L386
        v227[0][v241][v242][v243] = v219;	// L387
        for (int v244 = 0; v244 < 256; v244 += 1) {	// L388
          for (int v245 = 0; v245 < 3; v245 += 1) {	// L389
            for (int v246 = 0; v246 < 3; v246 += 1) {	// L390
              float v247 = v232[0][v244][(v242 + v245)][(v243 + v246)];	// L391
              float v248 = v221[v241][v244][v245][v246];	// L392
              float v249 = v227[0][v241][v242][v243];	// L393
              float v250 = v247 * v248;	// L394
              float v251 = v249 + v250;	// L395
              v227[0][v241][v242][v243] = v251;	// L396
            }
          }
        }
      }
    }
  }
  for (int v252 = 0; v252 < 256; v252 += 1) {	// L403
    for (int v253 = 0; v253 < 8; v253 += 1) {	// L404
      for (int v254 = 0; v254 < 8; v254 += 1) {	// L405
        v229[0][v252][v253][v254] = v219;	// L406
        for (int v255 = 0; v255 < 128; v255 += 1) {	// L407
          float v256 = v222[0][v255][(v253 * 2)][(v254 * 2)];	// L408
          float v257 = v223[v252][v255][0][0];	// L409
          float v258 = v229[0][v252][v253][v254];	// L410
          float v259 = v256 * v257;	// L411
          float v260 = v258 + v259;	// L412
          v229[0][v252][v253][v254] = v260;	// L413
        }
      }
    }
  }
  for (int v261 = 0; v261 < 256; v261 += 1) {	// L418
    for (int v262 = 0; v262 < 8; v262 += 1) {	// L419
      for (int v263 = 0; v263 < 8; v263 += 1) {	// L420
        float v264 = v227[0][v261][v262][v263];	// L421
        float v265 = v229[0][v261][v262][v263];	// L422
        float v266 = v264 + v265;	// L423
        v230[0][v261][v262][v263] = v266;	// L424
      }
    }
  }
  for (int v267 = 0; v267 < 256; v267 += 1) {	// L428
    for (int v268 = 0; v268 < 8; v268 += 1) {	// L429
      for (int v269 = 0; v269 < 8; v269 += 1) {	// L430
        float v270 = v230[0][v267][v268][v269];	// L431
        bool v271 = v270 < v219;	// L432
        float v272 = v271 ? (float)v219 : (float)v270;	// L433
        v231[0][v267][v268][v269] = v272;	// L434
      }
    }
  }
  for (int v273 = 0; v273 < 256; v273 += 1) {	// L438
    for (int v274 = 0; v274 < 10; v274 += 1) {	// L439
      for (int v275 = 0; v275 < 10; v275 += 1) {	// L440
        v233[0][v273][v274][v275] = v219;	// L441
      }
    }
  }
  for (int v276 = 0; v276 < 256; v276 += 1) {	// L445
    for (int v277 = 0; v277 < 8; v277 += 1) {	// L446
      for (int v278 = 0; v278 < 8; v278 += 1) {	// L447
        float v279 = v231[0][v276][v277][v278];	// L448
        v233[0][v276][(v277 + 1)][(v278 + 1)] = v279;	// L449
      }
    }
  }
  for (int v280 = 0; v280 < 256; v280 += 1) {	// L453
    for (int v281 = 0; v281 < 8; v281 += 1) {	// L454
      for (int v282 = 0; v282 < 8; v282 += 1) {	// L455
        v228[0][v280][v281][v282] = v219;	// L456
        for (int v283 = 0; v283 < 256; v283 += 1) {	// L457
          for (int v284 = 0; v284 < 3; v284 += 1) {	// L458
            for (int v285 = 0; v285 < 3; v285 += 1) {	// L459
              float v286 = v233[0][v283][(v281 + v284)][(v282 + v285)];	// L460
              float v287 = v224[v280][v283][v284][v285];	// L461
              float v288 = v228[0][v280][v281][v282];	// L462
              float v289 = v286 * v287;	// L463
              float v290 = v288 + v289;	// L464
              v228[0][v280][v281][v282] = v290;	// L465
            }
          }
        }
      }
    }
  }
  for (int v291 = 0; v291 < 256; v291 += 1) {	// L472
    for (int v292 = 0; v292 < 8; v292 += 1) {	// L473
      for (int v293 = 0; v293 < 8; v293 += 1) {	// L474
        float v294 = v228[0][v291][v292][v293];	// L475
        bool v295 = v294 < v219;	// L476
        float v296 = v295 ? (float)v219 : (float)v294;	// L477
        v225[0][v291][v292][v293] = v296;	// L478
      }
    }
  }
  for (int v297 = 0; v297 < 1; v297 += 1) {	// L482
    for (int v298 = 0; v298 < 256; v298 += 1) {	// L483
      for (int v299 = 0; v299 < 8; v299 += 1) {	// L484
        for (int v300 = 0; v300 < 8; v300 += 1) {	// L485
          float v301 = v231[v297][v298][v299][v300];	// L486
          v226[v297][v298][v299][v300] = v301;	// L487
        }
      }
    }
  }
}

void dataflow6(
  float v302,
  float v303[1][128][16][16],
  float v304[128][128][3][3],
  float v305[1][64][32][32],
  float v306[128][64][1][1],
  float v307[128][128][3][3],
  float v308[1][128][16][16],
  float v309[1][128][16][16]
) {	// L494
  float v310[1][128][18][18];	// L495
  #pragma HLS resource variable=v310 core=ram_s2p_bram

  float v311[1][128][16][16];	// L496
  #pragma HLS resource variable=v311 core=ram_s2p_bram

  float v312[1][128][16][16];	// L497
  #pragma HLS resource variable=v312 core=ram_s2p_bram

  float v313[1][128][16][16];	// L498
  #pragma HLS resource variable=v313 core=ram_s2p_bram

  float v314[1][128][16][16];	// L499
  #pragma HLS resource variable=v314 core=ram_s2p_bram

  float v315[1][128][18][18];	// L500
  #pragma HLS resource variable=v315 core=ram_s2p_bram

  float v316[1][128][16][16];	// L501
  #pragma HLS resource variable=v316 core=ram_s2p_bram

  for (int v317 = 0; v317 < 128; v317 += 1) {	// L502
    for (int v318 = 0; v318 < 18; v318 += 1) {	// L503
      for (int v319 = 0; v319 < 18; v319 += 1) {	// L504
        v315[0][v317][v318][v319] = v302;	// L505
      }
    }
  }
  for (int v320 = 0; v320 < 128; v320 += 1) {	// L509
    for (int v321 = 0; v321 < 16; v321 += 1) {	// L510
      for (int v322 = 0; v322 < 16; v322 += 1) {	// L511
        float v323 = v303[0][v320][v321][v322];	// L512
        v315[0][v320][(v321 + 1)][(v322 + 1)] = v323;	// L513
      }
    }
  }
  for (int v324 = 0; v324 < 128; v324 += 1) {	// L517
    for (int v325 = 0; v325 < 16; v325 += 1) {	// L518
      for (int v326 = 0; v326 < 16; v326 += 1) {	// L519
        v311[0][v324][v325][v326] = v302;	// L520
        for (int v327 = 0; v327 < 128; v327 += 1) {	// L521
          for (int v328 = 0; v328 < 3; v328 += 1) {	// L522
            for (int v329 = 0; v329 < 3; v329 += 1) {	// L523
              float v330 = v315[0][v327][(v325 + v328)][(v326 + v329)];	// L524
              float v331 = v304[v324][v327][v328][v329];	// L525
              float v332 = v311[0][v324][v325][v326];	// L526
              float v333 = v330 * v331;	// L527
              float v334 = v332 + v333;	// L528
              v311[0][v324][v325][v326] = v334;	// L529
            }
          }
        }
      }
    }
  }
  for (int v335 = 0; v335 < 128; v335 += 1) {	// L536
    for (int v336 = 0; v336 < 16; v336 += 1) {	// L537
      for (int v337 = 0; v337 < 16; v337 += 1) {	// L538
        v313[0][v335][v336][v337] = v302;	// L539
        for (int v338 = 0; v338 < 64; v338 += 1) {	// L540
          float v339 = v305[0][v338][(v336 * 2)][(v337 * 2)];	// L541
          float v340 = v306[v335][v338][0][0];	// L542
          float v341 = v313[0][v335][v336][v337];	// L543
          float v342 = v339 * v340;	// L544
          float v343 = v341 + v342;	// L545
          v313[0][v335][v336][v337] = v343;	// L546
        }
      }
    }
  }
  for (int v344 = 0; v344 < 128; v344 += 1) {	// L551
    for (int v345 = 0; v345 < 16; v345 += 1) {	// L552
      for (int v346 = 0; v346 < 16; v346 += 1) {	// L553
        float v347 = v311[0][v344][v345][v346];	// L554
        float v348 = v313[0][v344][v345][v346];	// L555
        float v349 = v347 + v348;	// L556
        v316[0][v344][v345][v346] = v349;	// L557
      }
    }
  }
  for (int v350 = 0; v350 < 128; v350 += 1) {	// L561
    for (int v351 = 0; v351 < 16; v351 += 1) {	// L562
      for (int v352 = 0; v352 < 16; v352 += 1) {	// L563
        float v353 = v316[0][v350][v351][v352];	// L564
        bool v354 = v353 < v302;	// L565
        float v355 = v354 ? (float)v302 : (float)v353;	// L566
        v312[0][v350][v351][v352] = v355;	// L567
      }
    }
  }
  for (int v356 = 0; v356 < 128; v356 += 1) {	// L571
    for (int v357 = 0; v357 < 18; v357 += 1) {	// L572
      for (int v358 = 0; v358 < 18; v358 += 1) {	// L573
        v310[0][v356][v357][v358] = v302;	// L574
      }
    }
  }
  for (int v359 = 0; v359 < 128; v359 += 1) {	// L578
    for (int v360 = 0; v360 < 16; v360 += 1) {	// L579
      for (int v361 = 0; v361 < 16; v361 += 1) {	// L580
        float v362 = v312[0][v359][v360][v361];	// L581
        v310[0][v359][(v360 + 1)][(v361 + 1)] = v362;	// L582
      }
    }
  }
  for (int v363 = 0; v363 < 128; v363 += 1) {	// L586
    for (int v364 = 0; v364 < 16; v364 += 1) {	// L587
      for (int v365 = 0; v365 < 16; v365 += 1) {	// L588
        v314[0][v363][v364][v365] = v302;	// L589
        for (int v366 = 0; v366 < 128; v366 += 1) {	// L590
          for (int v367 = 0; v367 < 3; v367 += 1) {	// L591
            for (int v368 = 0; v368 < 3; v368 += 1) {	// L592
              float v369 = v310[0][v366][(v364 + v367)][(v365 + v368)];	// L593
              float v370 = v307[v363][v366][v367][v368];	// L594
              float v371 = v314[0][v363][v364][v365];	// L595
              float v372 = v369 * v370;	// L596
              float v373 = v371 + v372;	// L597
              v314[0][v363][v364][v365] = v373;	// L598
            }
          }
        }
      }
    }
  }
  for (int v374 = 0; v374 < 128; v374 += 1) {	// L605
    for (int v375 = 0; v375 < 16; v375 += 1) {	// L606
      for (int v376 = 0; v376 < 16; v376 += 1) {	// L607
        float v377 = v314[0][v374][v375][v376];	// L608
        bool v378 = v377 < v302;	// L609
        float v379 = v378 ? (float)v302 : (float)v377;	// L610
        v308[0][v374][v375][v376] = v379;	// L611
      }
    }
  }
  for (int v380 = 0; v380 < 1; v380 += 1) {	// L615
    for (int v381 = 0; v381 < 128; v381 += 1) {	// L616
      for (int v382 = 0; v382 < 16; v382 += 1) {	// L617
        for (int v383 = 0; v383 < 16; v383 += 1) {	// L618
          float v384 = v312[v380][v381][v382][v383];	// L619
          v309[v380][v381][v382][v383] = v384;	// L620
        }
      }
    }
  }
}

void dataflow1(
  float v385,
  float v386[1][512][4][4],
  float v387[512][512][3][3],
  float v388[1][512][4][4],
  float v389,
  float v390[10],
  float v391[10][512],
  float v392[1][10],
  float v393
) {	// L627
  float v394[1][512][6][6];	// L628
  #pragma HLS resource variable=v394 core=ram_s2p_bram

  float v395[1][512][4][4];	// L629
  #pragma HLS resource variable=v395 core=ram_s2p_bram

  float v396[1][512][4][4];	// L630
  #pragma HLS resource variable=v396 core=ram_s2p_bram

  float v397[1][512][1][1];	// L631
  #pragma HLS resource variable=v397 core=ram_s2p_bram

  float v398[1][512][4][4];	// L632
  #pragma HLS resource variable=v398 core=ram_s2p_bram

  float v399[1][512];	// L633
  #pragma HLS resource variable=v399 core=ram_s2p_bram

  for (int v400 = 0; v400 < 512; v400 += 1) {	// L634
    for (int v401 = 0; v401 < 6; v401 += 1) {	// L635
      for (int v402 = 0; v402 < 6; v402 += 1) {	// L636
        v394[0][v400][v401][v402] = v385;	// L637
      }
    }
  }
  for (int v403 = 0; v403 < 512; v403 += 1) {	// L641
    for (int v404 = 0; v404 < 4; v404 += 1) {	// L642
      for (int v405 = 0; v405 < 4; v405 += 1) {	// L643
        float v406 = v386[0][v403][v404][v405];	// L644
        v394[0][v403][(v404 + 1)][(v405 + 1)] = v406;	// L645
      }
    }
  }
  for (int v407 = 0; v407 < 512; v407 += 1) {	// L649
    for (int v408 = 0; v408 < 4; v408 += 1) {	// L650
      for (int v409 = 0; v409 < 4; v409 += 1) {	// L651
        v395[0][v407][v408][v409] = v385;	// L652
        for (int v410 = 0; v410 < 512; v410 += 1) {	// L653
          for (int v411 = 0; v411 < 3; v411 += 1) {	// L654
            for (int v412 = 0; v412 < 3; v412 += 1) {	// L655
              float v413 = v394[0][v410][(v408 + v411)][(v409 + v412)];	// L656
              float v414 = v387[v407][v410][v411][v412];	// L657
              float v415 = v395[0][v407][v408][v409];	// L658
              float v416 = v413 * v414;	// L659
              float v417 = v415 + v416;	// L660
              v395[0][v407][v408][v409] = v417;	// L661
            }
          }
        }
      }
    }
  }
  for (int v418 = 0; v418 < 512; v418 += 1) {	// L668
    for (int v419 = 0; v419 < 4; v419 += 1) {	// L669
      for (int v420 = 0; v420 < 4; v420 += 1) {	// L670
        float v421 = v395[0][v418][v419][v420];	// L671
        float v422 = v388[0][v418][v419][v420];	// L672
        float v423 = v421 + v422;	// L673
        v396[0][v418][v419][v420] = v423;	// L674
      }
    }
  }
  for (int v424 = 0; v424 < 512; v424 += 1) {	// L678
    for (int v425 = 0; v425 < 4; v425 += 1) {	// L679
      for (int v426 = 0; v426 < 4; v426 += 1) {	// L680
        float v427 = v396[0][v424][v425][v426];	// L681
        bool v428 = v427 < v385;	// L682
        float v429 = v428 ? (float)v385 : (float)v427;	// L683
        v398[0][v424][v425][v426] = v429;	// L684
      }
    }
  }
  for (int v430 = 0; v430 < 512; v430 += 1) {	// L688
    v397[0][v430][0][0] = v385;	// L689
  }
  for (int v431 = 0; v431 < 512; v431 += 1) {	// L691
    for (int v432 = 0; v432 < 4; v432 += 1) {	// L692
      for (int v433 = 0; v433 < 4; v433 += 1) {	// L693
        float v434 = v398[0][v431][v432][v433];	// L694
        float v435 = v397[0][v431][0][0];	// L695
        float v436 = v435 + v434;	// L696
        v397[0][v431][0][0] = v436;	// L697
      }
    }
  }
  for (int v437 = 0; v437 < 512; v437 += 1) {	// L701
    float v438 = v397[0][v437][0][0];	// L702
    float v439 = v438 / v389;	// L703
    v397[0][v437][0][0] = v439;	// L704
  }
  for (int v440 = 0; v440 < 512; v440 += 1) {	// L706
    float v441 = v397[0][v440][0][0];	// L707
    v399[0][v440] = v441;	// L708
  }
  for (int v442 = 0; v442 < 10; v442 += 1) {	// L710
    v392[0][v442] = v385;	// L711
    for (int v443 = 0; v443 < 512; v443 += 1) {	// L712
      float v444 = v399[0][v443];	// L713
      float v445 = v391[v442][v443];	// L714
      float v446 = v392[0][v442];	// L715
      float v447 = v444 * v445;	// L716
      float v448 = v446 + v447;	// L717
      v392[0][v442] = v448;	// L718
    }
    float v449 = v390[v442];	// L720
    float v450 = v393 * v449;	// L721
    float v451 = v393 + v450;	// L722
    float v452 = v392[0][v442];	// L723
    float v453 = v451 * v452;	// L724
    v392[0][v442] = v453;	// L725
  }
}

void dataflow8(
  float v454,
  float v455[1][64][32][32],
  float v456[64][64][3][3],
  float v457[1][64][32][32],
  float v458[64][64][3][3],
  float v459[1][64][32][32],
  float v460[1][64][32][32]
) {	// L729
  float v461[1][64][32][32];	// L730
  #pragma HLS resource variable=v461 core=ram_s2p_bram

  float v462[1][64][32][32];	// L731
  #pragma HLS resource variable=v462 core=ram_s2p_bram

  float v463[1][64][32][32];	// L732
  #pragma HLS resource variable=v463 core=ram_s2p_bram

  float v464[1][64][32][32];	// L733
  #pragma HLS resource variable=v464 core=ram_s2p_bram

  float v465[1][64][34][34];	// L734
  #pragma HLS resource variable=v465 core=ram_s2p_bram

  float v466[1][64][34][34];	// L735
  #pragma HLS resource variable=v466 core=ram_s2p_bram

  for (int v467 = 0; v467 < 64; v467 += 1) {	// L736
    for (int v468 = 0; v468 < 34; v468 += 1) {	// L737
      for (int v469 = 0; v469 < 34; v469 += 1) {	// L738
        v465[0][v467][v468][v469] = v454;	// L739
      }
    }
  }
  for (int v470 = 0; v470 < 64; v470 += 1) {	// L743
    for (int v471 = 0; v471 < 32; v471 += 1) {	// L744
      for (int v472 = 0; v472 < 32; v472 += 1) {	// L745
        float v473 = v455[0][v470][v471][v472];	// L746
        v465[0][v470][(v471 + 1)][(v472 + 1)] = v473;	// L747
      }
    }
  }
  for (int v474 = 0; v474 < 64; v474 += 1) {	// L751
    for (int v475 = 0; v475 < 32; v475 += 1) {	// L752
      for (int v476 = 0; v476 < 32; v476 += 1) {	// L753
        v462[0][v474][v475][v476] = v454;	// L754
        for (int v477 = 0; v477 < 64; v477 += 1) {	// L755
          for (int v478 = 0; v478 < 3; v478 += 1) {	// L756
            for (int v479 = 0; v479 < 3; v479 += 1) {	// L757
              float v480 = v465[0][v477][(v475 + v478)][(v476 + v479)];	// L758
              float v481 = v456[v474][v477][v478][v479];	// L759
              float v482 = v462[0][v474][v475][v476];	// L760
              float v483 = v480 * v481;	// L761
              float v484 = v482 + v483;	// L762
              v462[0][v474][v475][v476] = v484;	// L763
            }
          }
        }
      }
    }
  }
  for (int v485 = 0; v485 < 64; v485 += 1) {	// L770
    for (int v486 = 0; v486 < 32; v486 += 1) {	// L771
      for (int v487 = 0; v487 < 32; v487 += 1) {	// L772
        float v488 = v462[0][v485][v486][v487];	// L773
        float v489 = v457[0][v485][v486][v487];	// L774
        float v490 = v488 + v489;	// L775
        v463[0][v485][v486][v487] = v490;	// L776
      }
    }
  }
  for (int v491 = 0; v491 < 64; v491 += 1) {	// L780
    for (int v492 = 0; v492 < 32; v492 += 1) {	// L781
      for (int v493 = 0; v493 < 32; v493 += 1) {	// L782
        float v494 = v463[0][v491][v492][v493];	// L783
        bool v495 = v494 < v454;	// L784
        float v496 = v495 ? (float)v454 : (float)v494;	// L785
        v461[0][v491][v492][v493] = v496;	// L786
      }
    }
  }
  for (int v497 = 0; v497 < 64; v497 += 1) {	// L790
    for (int v498 = 0; v498 < 34; v498 += 1) {	// L791
      for (int v499 = 0; v499 < 34; v499 += 1) {	// L792
        v466[0][v497][v498][v499] = v454;	// L793
      }
    }
  }
  for (int v500 = 0; v500 < 64; v500 += 1) {	// L797
    for (int v501 = 0; v501 < 32; v501 += 1) {	// L798
      for (int v502 = 0; v502 < 32; v502 += 1) {	// L799
        float v503 = v461[0][v500][v501][v502];	// L800
        v466[0][v500][(v501 + 1)][(v502 + 1)] = v503;	// L801
      }
    }
  }
  for (int v504 = 0; v504 < 64; v504 += 1) {	// L805
    for (int v505 = 0; v505 < 32; v505 += 1) {	// L806
      for (int v506 = 0; v506 < 32; v506 += 1) {	// L807
        v464[0][v504][v505][v506] = v454;	// L808
        for (int v507 = 0; v507 < 64; v507 += 1) {	// L809
          for (int v508 = 0; v508 < 3; v508 += 1) {	// L810
            for (int v509 = 0; v509 < 3; v509 += 1) {	// L811
              float v510 = v466[0][v507][(v505 + v508)][(v506 + v509)];	// L812
              float v511 = v458[v504][v507][v508][v509];	// L813
              float v512 = v464[0][v504][v505][v506];	// L814
              float v513 = v510 * v511;	// L815
              float v514 = v512 + v513;	// L816
              v464[0][v504][v505][v506] = v514;	// L817
            }
          }
        }
      }
    }
  }
  for (int v515 = 0; v515 < 64; v515 += 1) {	// L824
    for (int v516 = 0; v516 < 32; v516 += 1) {	// L825
      for (int v517 = 0; v517 < 32; v517 += 1) {	// L826
        float v518 = v464[0][v515][v516][v517];	// L827
        bool v519 = v518 < v454;	// L828
        float v520 = v519 ? (float)v454 : (float)v518;	// L829
        v459[0][v515][v516][v517] = v520;	// L830
      }
    }
  }
  for (int v521 = 0; v521 < 1; v521 += 1) {	// L834
    for (int v522 = 0; v522 < 64; v522 += 1) {	// L835
      for (int v523 = 0; v523 < 32; v523 += 1) {	// L836
        for (int v524 = 0; v524 < 32; v524 += 1) {	// L837
          float v525 = v461[v521][v522][v523][v524];	// L838
          v460[v521][v522][v523][v524] = v525;	// L839
        }
      }
    }
  }
}

void dataflow3(
  float v526,
  float v527[1][256][8][8],
  float v528[256][256][3][3],
  float v529[1][256][8][8],
  float v530[512][256][3][3],
  float v531[1][512][4][4],
  float v532[1][256][8][8]
) {	// L846
  float v533[1][512][4][4];	// L847
  #pragma HLS resource variable=v533 core=ram_s2p_bram

  float v534[1][256][10][10];	// L848
  #pragma HLS resource variable=v534 core=ram_s2p_bram

  float v535[1][256][8][8];	// L849
  #pragma HLS resource variable=v535 core=ram_s2p_bram

  float v536[1][256][10][10];	// L850
  #pragma HLS resource variable=v536 core=ram_s2p_bram

  float v537[1][256][8][8];	// L851
  #pragma HLS resource variable=v537 core=ram_s2p_bram

  float v538[1][256][8][8];	// L852
  #pragma HLS resource variable=v538 core=ram_s2p_bram

  for (int v539 = 0; v539 < 256; v539 += 1) {	// L853
    for (int v540 = 0; v540 < 10; v540 += 1) {	// L854
      for (int v541 = 0; v541 < 10; v541 += 1) {	// L855
        v536[0][v539][v540][v541] = v526;	// L856
      }
    }
  }
  for (int v542 = 0; v542 < 256; v542 += 1) {	// L860
    for (int v543 = 0; v543 < 8; v543 += 1) {	// L861
      for (int v544 = 0; v544 < 8; v544 += 1) {	// L862
        float v545 = v527[0][v542][v543][v544];	// L863
        v536[0][v542][(v543 + 1)][(v544 + 1)] = v545;	// L864
      }
    }
  }
  for (int v546 = 0; v546 < 256; v546 += 1) {	// L868
    for (int v547 = 0; v547 < 8; v547 += 1) {	// L869
      for (int v548 = 0; v548 < 8; v548 += 1) {	// L870
        v535[0][v546][v547][v548] = v526;	// L871
        for (int v549 = 0; v549 < 256; v549 += 1) {	// L872
          for (int v550 = 0; v550 < 3; v550 += 1) {	// L873
            for (int v551 = 0; v551 < 3; v551 += 1) {	// L874
              float v552 = v536[0][v549][(v547 + v550)][(v548 + v551)];	// L875
              float v553 = v528[v546][v549][v550][v551];	// L876
              float v554 = v535[0][v546][v547][v548];	// L877
              float v555 = v552 * v553;	// L878
              float v556 = v554 + v555;	// L879
              v535[0][v546][v547][v548] = v556;	// L880
            }
          }
        }
      }
    }
  }
  for (int v557 = 0; v557 < 256; v557 += 1) {	// L887
    for (int v558 = 0; v558 < 8; v558 += 1) {	// L888
      for (int v559 = 0; v559 < 8; v559 += 1) {	// L889
        float v560 = v535[0][v557][v558][v559];	// L890
        float v561 = v529[0][v557][v558][v559];	// L891
        float v562 = v560 + v561;	// L892
        v538[0][v557][v558][v559] = v562;	// L893
      }
    }
  }
  for (int v563 = 0; v563 < 256; v563 += 1) {	// L897
    for (int v564 = 0; v564 < 8; v564 += 1) {	// L898
      for (int v565 = 0; v565 < 8; v565 += 1) {	// L899
        float v566 = v538[0][v563][v564][v565];	// L900
        bool v567 = v566 < v526;	// L901
        float v568 = v567 ? (float)v526 : (float)v566;	// L902
        v537[0][v563][v564][v565] = v568;	// L903
      }
    }
  }
  for (int v569 = 0; v569 < 256; v569 += 1) {	// L907
    for (int v570 = 0; v570 < 10; v570 += 1) {	// L908
      for (int v571 = 0; v571 < 10; v571 += 1) {	// L909
        v534[0][v569][v570][v571] = v526;	// L910
      }
    }
  }
  for (int v572 = 0; v572 < 256; v572 += 1) {	// L914
    for (int v573 = 0; v573 < 8; v573 += 1) {	// L915
      for (int v574 = 0; v574 < 8; v574 += 1) {	// L916
        float v575 = v537[0][v572][v573][v574];	// L917
        v534[0][v572][(v573 + 1)][(v574 + 1)] = v575;	// L918
      }
    }
  }
  for (int v576 = 0; v576 < 512; v576 += 1) {	// L922
    for (int v577 = 0; v577 < 4; v577 += 1) {	// L923
      for (int v578 = 0; v578 < 4; v578 += 1) {	// L924
        v533[0][v576][v577][v578] = v526;	// L925
        for (int v579 = 0; v579 < 256; v579 += 1) {	// L926
          for (int v580 = 0; v580 < 3; v580 += 1) {	// L927
            for (int v581 = 0; v581 < 3; v581 += 1) {	// L928
              float v582 = v534[0][v579][((v577 * 2) + v580)][((v578 * 2) + v581)];	// L929
              float v583 = v530[v576][v579][v580][v581];	// L930
              float v584 = v533[0][v576][v577][v578];	// L931
              float v585 = v582 * v583;	// L932
              float v586 = v584 + v585;	// L933
              v533[0][v576][v577][v578] = v586;	// L934
            }
          }
        }
      }
    }
  }
  for (int v587 = 0; v587 < 512; v587 += 1) {	// L941
    for (int v588 = 0; v588 < 4; v588 += 1) {	// L942
      for (int v589 = 0; v589 < 4; v589 += 1) {	// L943
        float v590 = v533[0][v587][v588][v589];	// L944
        bool v591 = v590 < v526;	// L945
        float v592 = v591 ? (float)v526 : (float)v590;	// L946
        v531[0][v587][v588][v589] = v592;	// L947
      }
    }
  }
  for (int v593 = 0; v593 < 1; v593 += 1) {	// L951
    for (int v594 = 0; v594 < 256; v594 += 1) {	// L952
      for (int v595 = 0; v595 < 8; v595 += 1) {	// L953
        for (int v596 = 0; v596 < 8; v596 += 1) {	// L954
          float v597 = v537[v593][v594][v595][v596];	// L955
          v532[v593][v594][v595][v596] = v597;	// L956
        }
      }
    }
  }
}

void dataflow5(
  float v598,
  float v599[1][128][16][16],
  float v600[128][128][3][3],
  float v601[1][128][16][16],
  float v602[256][128][3][3],
  float v603[1][256][8][8],
  float v604[1][128][16][16]
) {	// L963
  float v605[1][128][16][16];	// L964
  #pragma HLS resource variable=v605 core=ram_s2p_bram

  float v606[1][128][18][18];	// L965
  #pragma HLS resource variable=v606 core=ram_s2p_bram

  float v607[1][128][16][16];	// L966
  #pragma HLS resource variable=v607 core=ram_s2p_bram

  float v608[1][128][18][18];	// L967
  #pragma HLS resource variable=v608 core=ram_s2p_bram

  float v609[1][256][8][8];	// L968
  #pragma HLS resource variable=v609 core=ram_s2p_bram

  float v610[1][128][16][16];	// L969
  #pragma HLS resource variable=v610 core=ram_s2p_bram

  for (int v611 = 0; v611 < 128; v611 += 1) {	// L970
    for (int v612 = 0; v612 < 18; v612 += 1) {	// L971
      for (int v613 = 0; v613 < 18; v613 += 1) {	// L972
        v608[0][v611][v612][v613] = v598;	// L973
      }
    }
  }
  for (int v614 = 0; v614 < 128; v614 += 1) {	// L977
    for (int v615 = 0; v615 < 16; v615 += 1) {	// L978
      for (int v616 = 0; v616 < 16; v616 += 1) {	// L979
        float v617 = v599[0][v614][v615][v616];	// L980
        v608[0][v614][(v615 + 1)][(v616 + 1)] = v617;	// L981
      }
    }
  }
  for (int v618 = 0; v618 < 128; v618 += 1) {	// L985
    for (int v619 = 0; v619 < 16; v619 += 1) {	// L986
      for (int v620 = 0; v620 < 16; v620 += 1) {	// L987
        v607[0][v618][v619][v620] = v598;	// L988
        for (int v621 = 0; v621 < 128; v621 += 1) {	// L989
          for (int v622 = 0; v622 < 3; v622 += 1) {	// L990
            for (int v623 = 0; v623 < 3; v623 += 1) {	// L991
              float v624 = v608[0][v621][(v619 + v622)][(v620 + v623)];	// L992
              float v625 = v600[v618][v621][v622][v623];	// L993
              float v626 = v607[0][v618][v619][v620];	// L994
              float v627 = v624 * v625;	// L995
              float v628 = v626 + v627;	// L996
              v607[0][v618][v619][v620] = v628;	// L997
            }
          }
        }
      }
    }
  }
  for (int v629 = 0; v629 < 128; v629 += 1) {	// L1004
    for (int v630 = 0; v630 < 16; v630 += 1) {	// L1005
      for (int v631 = 0; v631 < 16; v631 += 1) {	// L1006
        float v632 = v607[0][v629][v630][v631];	// L1007
        float v633 = v601[0][v629][v630][v631];	// L1008
        float v634 = v632 + v633;	// L1009
        v605[0][v629][v630][v631] = v634;	// L1010
      }
    }
  }
  for (int v635 = 0; v635 < 128; v635 += 1) {	// L1014
    for (int v636 = 0; v636 < 16; v636 += 1) {	// L1015
      for (int v637 = 0; v637 < 16; v637 += 1) {	// L1016
        float v638 = v605[0][v635][v636][v637];	// L1017
        bool v639 = v638 < v598;	// L1018
        float v640 = v639 ? (float)v598 : (float)v638;	// L1019
        v610[0][v635][v636][v637] = v640;	// L1020
      }
    }
  }
  for (int v641 = 0; v641 < 128; v641 += 1) {	// L1024
    for (int v642 = 0; v642 < 18; v642 += 1) {	// L1025
      for (int v643 = 0; v643 < 18; v643 += 1) {	// L1026
        v606[0][v641][v642][v643] = v598;	// L1027
      }
    }
  }
  for (int v644 = 0; v644 < 128; v644 += 1) {	// L1031
    for (int v645 = 0; v645 < 16; v645 += 1) {	// L1032
      for (int v646 = 0; v646 < 16; v646 += 1) {	// L1033
        float v647 = v610[0][v644][v645][v646];	// L1034
        v606[0][v644][(v645 + 1)][(v646 + 1)] = v647;	// L1035
      }
    }
  }
  for (int v648 = 0; v648 < 256; v648 += 1) {	// L1039
    for (int v649 = 0; v649 < 8; v649 += 1) {	// L1040
      for (int v650 = 0; v650 < 8; v650 += 1) {	// L1041
        v609[0][v648][v649][v650] = v598;	// L1042
        for (int v651 = 0; v651 < 128; v651 += 1) {	// L1043
          for (int v652 = 0; v652 < 3; v652 += 1) {	// L1044
            for (int v653 = 0; v653 < 3; v653 += 1) {	// L1045
              float v654 = v606[0][v651][((v649 * 2) + v652)][((v650 * 2) + v653)];	// L1046
              float v655 = v602[v648][v651][v652][v653];	// L1047
              float v656 = v609[0][v648][v649][v650];	// L1048
              float v657 = v654 * v655;	// L1049
              float v658 = v656 + v657;	// L1050
              v609[0][v648][v649][v650] = v658;	// L1051
            }
          }
        }
      }
    }
  }
  for (int v659 = 0; v659 < 256; v659 += 1) {	// L1058
    for (int v660 = 0; v660 < 8; v660 += 1) {	// L1059
      for (int v661 = 0; v661 < 8; v661 += 1) {	// L1060
        float v662 = v609[0][v659][v660][v661];	// L1061
        bool v663 = v662 < v598;	// L1062
        float v664 = v663 ? (float)v598 : (float)v662;	// L1063
        v603[0][v659][v660][v661] = v664;	// L1064
      }
    }
  }
  for (int v665 = 0; v665 < 1; v665 += 1) {	// L1068
    for (int v666 = 0; v666 < 128; v666 += 1) {	// L1069
      for (int v667 = 0; v667 < 16; v667 += 1) {	// L1070
        for (int v668 = 0; v668 < 16; v668 += 1) {	// L1071
          float v669 = v610[v665][v666][v667][v668];	// L1072
          v604[v665][v666][v667][v668] = v669;	// L1073
        }
      }
    }
  }
}

/// This is top function.
void main_graph(
  float v670[1][3][32][32],
  float v671[64][3][3][3],
  float v672[64][64][3][3],
  float v673[64][64][3][3],
  float v674[64][64][3][3],
  float v675[64][64][3][3],
  float v676[128][64][3][3],
  float v677[128][128][3][3],
  float v678[128][64][1][1],
  float v679[128][128][3][3],
  float v680[128][128][3][3],
  float v681[256][128][3][3],
  float v682[256][256][3][3],
  float v683[256][128][1][1],
  float v684[256][256][3][3],
  float v685[256][256][3][3],
  float v686[512][256][3][3],
  float v687[512][512][3][3],
  float v688[512][256][1][1],
  float v689[512][512][3][3],
  float v690[512][512][3][3],
  float v691[10][512],
  float v692[1][10]
) {	// L1080
  #pragma HLS dataflow

  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v670
  #pragma HLS interface bram port=v671
  #pragma HLS interface bram port=v672
  #pragma HLS interface bram port=v673
  #pragma HLS interface bram port=v674
  #pragma HLS interface bram port=v675
  #pragma HLS interface bram port=v676
  #pragma HLS interface bram port=v677
  #pragma HLS interface bram port=v678
  #pragma HLS interface bram port=v679
  #pragma HLS interface bram port=v680
  #pragma HLS interface bram port=v681
  #pragma HLS interface bram port=v682
  #pragma HLS interface bram port=v683
  #pragma HLS interface bram port=v684
  #pragma HLS interface bram port=v685
  #pragma HLS interface bram port=v686
  #pragma HLS interface bram port=v687
  #pragma HLS interface bram port=v688
  #pragma HLS interface bram port=v689
  #pragma HLS interface bram port=v690
  #pragma HLS interface bram port=v691
  #pragma HLS interface bram port=v692

  #pragma HLS resource variable=v670 core=ram_s2p_bram

  #pragma HLS resource variable=v671 core=ram_s2p_bram

  #pragma HLS resource variable=v672 core=ram_s2p_bram

  #pragma HLS resource variable=v673 core=ram_s2p_bram

  #pragma HLS resource variable=v674 core=ram_s2p_bram

  #pragma HLS resource variable=v675 core=ram_s2p_bram

  #pragma HLS resource variable=v676 core=ram_s2p_bram

  #pragma HLS resource variable=v677 core=ram_s2p_bram

  #pragma HLS resource variable=v678 core=ram_s2p_bram

  #pragma HLS resource variable=v679 core=ram_s2p_bram

  #pragma HLS resource variable=v680 core=ram_s2p_bram

  #pragma HLS resource variable=v681 core=ram_s2p_bram

  #pragma HLS resource variable=v682 core=ram_s2p_bram

  #pragma HLS resource variable=v683 core=ram_s2p_bram

  #pragma HLS resource variable=v684 core=ram_s2p_bram

  #pragma HLS resource variable=v685 core=ram_s2p_bram

  #pragma HLS resource variable=v686 core=ram_s2p_bram

  #pragma HLS resource variable=v687 core=ram_s2p_bram

  #pragma HLS resource variable=v688 core=ram_s2p_bram

  #pragma HLS resource variable=v689 core=ram_s2p_bram

  #pragma HLS resource variable=v690 core=ram_s2p_bram

  #pragma HLS resource variable=v691 core=ram_s2p_bram

  #pragma HLS resource variable=v692 core=ram_s2p_bram

  float v693[10] = {-2.781226e-02, -4.107117e-02, -8.704335e-03, -3.831929e-02, -2.075570e-02, 4.087221e-02, 3.640073e-02, 4.095368e-02, 3.038846e-03, -4.327787e-02};	// L1084
  float v694[1][512][4][4];	// L1086
  #pragma HLS resource variable=v694 core=ram_s2p_bram

  float v695[1][512][4][4];	// L1087
  #pragma HLS resource variable=v695 core=ram_s2p_bram

  float v696[1][256][8][8];	// L1088
  #pragma HLS resource variable=v696 core=ram_s2p_bram

  float v697[1][256][8][8];	// L1089
  #pragma HLS resource variable=v697 core=ram_s2p_bram

  float v698[1][128][16][16];	// L1090
  #pragma HLS resource variable=v698 core=ram_s2p_bram

  float v699[1][128][16][16];	// L1091
  #pragma HLS resource variable=v699 core=ram_s2p_bram

  float v700[1][64][32][32];	// L1092
  #pragma HLS resource variable=v700 core=ram_s2p_bram

  float v701[1][64][32][32];	// L1093
  #pragma HLS resource variable=v701 core=ram_s2p_bram

  float v702[1][64][32][32];	// L1094
  #pragma HLS resource variable=v702 core=ram_s2p_bram

  dataflow9(0.000000, v670, v671, v672, v701, v702);	// L1095
  float v703[1][64][32][32];	// L1096
  #pragma HLS resource variable=v703 core=ram_s2p_bram

  dataflow8(0.000000, v701, v673, v702, v674, v700, v703);	// L1097
  float v704[1][64][32][32];	// L1098
  #pragma HLS resource variable=v704 core=ram_s2p_bram

  dataflow7(0.000000, v700, v675, v703, v676, v699, v704);	// L1099
  float v705[1][128][16][16];	// L1100
  #pragma HLS resource variable=v705 core=ram_s2p_bram

  dataflow6(0.000000, v699, v677, v704, v678, v679, v698, v705);	// L1101
  float v706[1][128][16][16];	// L1102
  #pragma HLS resource variable=v706 core=ram_s2p_bram

  dataflow5(0.000000, v698, v680, v705, v681, v697, v706);	// L1103
  float v707[1][256][8][8];	// L1104
  #pragma HLS resource variable=v707 core=ram_s2p_bram

  dataflow4(0.000000, v697, v682, v706, v683, v684, v696, v707);	// L1105
  float v708[1][256][8][8];	// L1106
  #pragma HLS resource variable=v708 core=ram_s2p_bram

  dataflow3(0.000000, v696, v685, v707, v686, v695, v708);	// L1107
  float v709[1][512][4][4];	// L1108
  #pragma HLS resource variable=v709 core=ram_s2p_bram

  dataflow2(0.000000, v695, v687, v708, v688, v689, v694, v709);	// L1109
  #pragma HLS resource variable=v693 core=ram_s2p_bram

  dataflow1(0.000000, v694, v690, v709, 16.000000, v693, v691, v692, 1.000000);	// L1111
}

