
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
  float v1[1][256][8][8],
  float v2[256][256][3][3],
  float v3[1][256][8][8],
  float v4[1][256][8][8]
) {	// L5
  float v5[1][256][8][8];	// L6
  #pragma HLS resource variable=v5 core=ram_s2p_bram

  float v6[1][256][10][10];	// L7
  #pragma HLS resource variable=v6 core=ram_s2p_bram

  for (int v7 = 0; v7 < 256; v7 += 1) {	// L8
    for (int v8 = 0; v8 < 10; v8 += 1) {	// L9
      for (int v9 = 0; v9 < 10; v9 += 1) {	// L10
        #pragma HLS pipeline II=1
        v6[0][v7][v8][v9] = v0;	// L11
      }
    }
  }
  for (int v10 = 0; v10 < 256; v10 += 1) {	// L15
    for (int v11 = 0; v11 < 8; v11 += 1) {	// L16
      for (int v12 = 0; v12 < 8; v12 += 1) {	// L17
        #pragma HLS pipeline II=1
        float v13 = v1[0][v10][v11][v12];	// L18
        v6[0][v10][(v11 + 1)][(v12 + 1)] = v13;	// L19
      }
    }
  }
  for (int v14 = 0; v14 < 256; v14 += 1) {	// L23
    for (int v15 = 0; v15 < 3; v15 += 1) {	// L24
      for (int v16 = 0; v16 < 3; v16 += 1) {	// L25
        for (int v17 = 0; v17 < 256; v17 += 1) {	// L26
          for (int v18 = 0; v18 < 8; v18 += 1) {	// L27
            for (int v19 = 0; v19 < 8; v19 += 1) {	// L28
              #pragma HLS pipeline II=1
              float v20 = v6[0][v14][(v18 + v15)][(v19 + v16)];	// L29
              float v21 = v2[v17][v14][v15][v16];	// L30
              float v22 = v5[0][v17][v18][v19];	// L31
              float v23;
              if (v14 == 0 && v15 == 0 && v16 == 0) {	// L32
                v23 = v0;	// L33
              } else {
                v23 = v22;	// L35
              }
              float v24 = v20 * v21;	// L37
              float v25 = v23 + v24;	// L38
              v5[0][v17][v18][v19] = v25;	// L39
            }
          }
        }
      }
    }
  }
  for (int v26 = 0; v26 < 256; v26 += 1) {	// L46
    for (int v27 = 0; v27 < 8; v27 += 1) {	// L47
      for (int v28 = 0; v28 < 8; v28 += 1) {	// L48
        #pragma HLS pipeline II=1
        float v29 = v5[0][v26][v27][v28];	// L49
        float v30 = v3[0][v26][v27][v28];	// L50
        float v31 = v29 + v30;	// L51
        v4[0][v26][v27][v28] = v31;	// L52
      }
    }
  }
}

void dataflow14(
  float v32,
  float v33[1][128][16][16],
  float v34[128][128][3][3],
  float v35[1][64][32][32],
  float v36[128][64][1][1],
  float v37[1][128][16][16]
) {	// L58
  float v38[1][128][16][16];	// L59
  #pragma HLS resource variable=v38 core=ram_s2p_bram

  float v39[1][128][16][16];	// L60
  #pragma HLS resource variable=v39 core=ram_s2p_bram

  float v40[1][128][18][18];	// L61
  #pragma HLS resource variable=v40 core=ram_s2p_bram

  for (int v41 = 0; v41 < 128; v41 += 1) {	// L62
    for (int v42 = 0; v42 < 18; v42 += 1) {	// L63
      for (int v43 = 0; v43 < 18; v43 += 1) {	// L64
        #pragma HLS pipeline II=1
        v40[0][v41][v42][v43] = v32;	// L65
      }
    }
  }
  for (int v44 = 0; v44 < 128; v44 += 1) {	// L69
    for (int v45 = 0; v45 < 16; v45 += 1) {	// L70
      for (int v46 = 0; v46 < 16; v46 += 1) {	// L71
        #pragma HLS pipeline II=1
        float v47 = v33[0][v44][v45][v46];	// L72
        v40[0][v44][(v45 + 1)][(v46 + 1)] = v47;	// L73
      }
    }
  }
  for (int v48 = 0; v48 < 128; v48 += 1) {	// L77
    for (int v49 = 0; v49 < 3; v49 += 1) {	// L78
      for (int v50 = 0; v50 < 3; v50 += 1) {	// L79
        for (int v51 = 0; v51 < 128; v51 += 1) {	// L80
          for (int v52 = 0; v52 < 16; v52 += 1) {	// L81
            for (int v53 = 0; v53 < 16; v53 += 1) {	// L82
              #pragma HLS pipeline II=1
              float v54 = v40[0][v48][(v52 + v49)][(v53 + v50)];	// L83
              float v55 = v34[v51][v48][v49][v50];	// L84
              float v56 = v39[0][v51][v52][v53];	// L85
              float v57;
              if (v48 == 0 && v49 == 0 && v50 == 0) {	// L86
                v57 = v32;	// L87
              } else {
                v57 = v56;	// L89
              }
              float v58 = v54 * v55;	// L91
              float v59 = v57 + v58;	// L92
              v39[0][v51][v52][v53] = v59;	// L93
            }
          }
        }
      }
    }
  }
  for (int v60 = 0; v60 < 64; v60 += 1) {	// L100
    for (int v61 = 0; v61 < 128; v61 += 1) {	// L101
      for (int v62 = 0; v62 < 16; v62 += 1) {	// L102
        for (int v63 = 0; v63 < 16; v63 += 1) {	// L103
          #pragma HLS pipeline II=1
          float v64 = v35[0][v60][(v62 * 2)][(v63 * 2)];	// L104
          float v65 = v36[v61][v60][0][0];	// L105
          float v66 = v38[0][v61][v62][v63];	// L106
          float v67;
          if (v60 == 0) {	// L107
            v67 = v32;	// L108
          } else {
            v67 = v66;	// L110
          }
          float v68 = v64 * v65;	// L112
          float v69 = v67 + v68;	// L113
          v38[0][v61][v62][v63] = v69;	// L114
        }
      }
    }
  }
  for (int v70 = 0; v70 < 128; v70 += 1) {	// L119
    for (int v71 = 0; v71 < 16; v71 += 1) {	// L120
      for (int v72 = 0; v72 < 16; v72 += 1) {	// L121
        #pragma HLS pipeline II=1
        float v73 = v39[0][v70][v71][v72];	// L122
        float v74 = v38[0][v70][v71][v72];	// L123
        float v75 = v73 + v74;	// L124
        v37[0][v70][v71][v72] = v75;	// L125
      }
    }
  }
}

void dataflow21(
  float v76,
  float v77[1][3][32][32],
  float v78[1][64][32][32],
  float v79[64][3][3][3]
) {	// L131
  float v80[1][3][34][34];	// L132
  #pragma HLS resource variable=v80 core=ram_s2p_bram

  for (int v81 = 0; v81 < 3; v81 += 1) {	// L133
    for (int v82 = 0; v82 < 34; v82 += 1) {	// L134
      for (int v83 = 0; v83 < 34; v83 += 1) {	// L135
        #pragma HLS pipeline II=1
        v80[0][v81][v82][v83] = v76;	// L136
      }
    }
  }
  for (int v84 = 0; v84 < 3; v84 += 1) {	// L140
    for (int v85 = 0; v85 < 32; v85 += 1) {	// L141
      for (int v86 = 0; v86 < 32; v86 += 1) {	// L142
        #pragma HLS pipeline II=1
        float v87 = v77[0][v84][v85][v86];	// L143
        v80[0][v84][(v85 + 1)][(v86 + 1)] = v87;	// L144
      }
    }
  }
  for (int v88 = 0; v88 < 3; v88 += 1) {	// L148
    for (int v89 = 0; v89 < 3; v89 += 1) {	// L149
      for (int v90 = 0; v90 < 3; v90 += 1) {	// L150
        for (int v91 = 0; v91 < 64; v91 += 1) {	// L151
          for (int v92 = 0; v92 < 32; v92 += 1) {	// L152
            for (int v93 = 0; v93 < 32; v93 += 1) {	// L153
              #pragma HLS pipeline II=1
              float v94 = v80[0][v88][(v92 + v89)][(v93 + v90)];	// L154
              float v95 = v79[v91][v88][v89][v90];	// L155
              float v96 = v78[0][v91][v92][v93];	// L156
              float v97;
              if (v88 == 0 && v89 == 0 && v90 == 0) {	// L157
                v97 = v76;	// L158
              } else {
                v97 = v96;	// L160
              }
              float v98 = v94 * v95;	// L162
              float v99 = v97 + v98;	// L163
              v78[0][v91][v92][v93] = v99;	// L164
            }
          }
        }
      }
    }
  }
}

void dataflow2(
  float v100,
  float v101[1][512][6][6],
  float v102[512][512][3][3],
  float v103[1][512][4][4],
  float v104[1][512][4][4]
) {	// L173
  float v105[1][512][4][4];	// L174
  #pragma HLS resource variable=v105 core=ram_s2p_bram

  float v106[1][512][4][4];	// L175
  #pragma HLS resource variable=v106 core=ram_s2p_bram

  for (int v107 = 0; v107 < 512; v107 += 1) {	// L176
    for (int v108 = 0; v108 < 3; v108 += 1) {	// L177
      for (int v109 = 0; v109 < 3; v109 += 1) {	// L178
        for (int v110 = 0; v110 < 512; v110 += 1) {	// L179
          for (int v111 = 0; v111 < 4; v111 += 1) {	// L180
            for (int v112 = 0; v112 < 4; v112 += 1) {	// L181
              #pragma HLS pipeline II=1
              float v113 = v101[0][v107][(v111 + v108)][(v112 + v109)];	// L182
              float v114 = v102[v110][v107][v108][v109];	// L183
              float v115 = v106[0][v110][v111][v112];	// L184
              float v116;
              if (v107 == 0 && v108 == 0 && v109 == 0) {	// L185
                v116 = v100;	// L186
              } else {
                v116 = v115;	// L188
              }
              float v117 = v113 * v114;	// L190
              float v118 = v116 + v117;	// L191
              v106[0][v110][v111][v112] = v118;	// L192
            }
          }
        }
      }
    }
  }
  for (int v119 = 0; v119 < 512; v119 += 1) {	// L199
    for (int v120 = 0; v120 < 4; v120 += 1) {	// L200
      for (int v121 = 0; v121 < 4; v121 += 1) {	// L201
        #pragma HLS pipeline II=1
        float v122 = v106[0][v119][v120][v121];	// L202
        float v123 = v103[0][v119][v120][v121];	// L203
        float v124 = v122 + v123;	// L204
        v105[0][v119][v120][v121] = v124;	// L205
      }
    }
  }
  for (int v125 = 0; v125 < 512; v125 += 1) {	// L209
    for (int v126 = 0; v126 < 4; v126 += 1) {	// L210
      for (int v127 = 0; v127 < 4; v127 += 1) {	// L211
        #pragma HLS pipeline II=1
        float v128 = v105[0][v125][v126][v127];	// L212
        bool v129 = v128 < v100;	// L213
        float v130 = v129 ? (float)v100 : (float)v128;	// L214
        v104[0][v125][v126][v127] = v130;	// L215
      }
    }
  }
}

void dataflow9(
  float v131,
  float v132[1][256][10][10],
  float v133[256][256][3][3],
  float v134[1][128][16][16],
  float v135[256][128][1][1],
  float v136[1][256][8][8]
) {	// L221
  float v137[1][256][8][8];	// L222
  #pragma HLS resource variable=v137 core=ram_s2p_bram

  float v138[1][256][8][8];	// L223
  #pragma HLS resource variable=v138 core=ram_s2p_bram

  float v139[1][256][8][8];	// L224
  #pragma HLS resource variable=v139 core=ram_s2p_bram

  for (int v140 = 0; v140 < 256; v140 += 1) {	// L225
    for (int v141 = 0; v141 < 3; v141 += 1) {	// L226
      for (int v142 = 0; v142 < 3; v142 += 1) {	// L227
        for (int v143 = 0; v143 < 256; v143 += 1) {	// L228
          for (int v144 = 0; v144 < 8; v144 += 1) {	// L229
            for (int v145 = 0; v145 < 8; v145 += 1) {	// L230
              #pragma HLS pipeline II=1
              float v146 = v132[0][v140][(v144 + v141)][(v145 + v142)];	// L231
              float v147 = v133[v143][v140][v141][v142];	// L232
              float v148 = v139[0][v143][v144][v145];	// L233
              float v149;
              if (v140 == 0 && v141 == 0 && v142 == 0) {	// L234
                v149 = v131;	// L235
              } else {
                v149 = v148;	// L237
              }
              float v150 = v146 * v147;	// L239
              float v151 = v149 + v150;	// L240
              v139[0][v143][v144][v145] = v151;	// L241
            }
          }
        }
      }
    }
  }
  for (int v152 = 0; v152 < 128; v152 += 1) {	// L248
    for (int v153 = 0; v153 < 256; v153 += 1) {	// L249
      for (int v154 = 0; v154 < 8; v154 += 1) {	// L250
        for (int v155 = 0; v155 < 8; v155 += 1) {	// L251
          #pragma HLS pipeline II=1
          float v156 = v134[0][v152][(v154 * 2)][(v155 * 2)];	// L252
          float v157 = v135[v153][v152][0][0];	// L253
          float v158 = v138[0][v153][v154][v155];	// L254
          float v159;
          if (v152 == 0) {	// L255
            v159 = v131;	// L256
          } else {
            v159 = v158;	// L258
          }
          float v160 = v156 * v157;	// L260
          float v161 = v159 + v160;	// L261
          v138[0][v153][v154][v155] = v161;	// L262
        }
      }
    }
  }
  for (int v162 = 0; v162 < 256; v162 += 1) {	// L267
    for (int v163 = 0; v163 < 8; v163 += 1) {	// L268
      for (int v164 = 0; v164 < 8; v164 += 1) {	// L269
        #pragma HLS pipeline II=1
        float v165 = v139[0][v162][v163][v164];	// L270
        float v166 = v138[0][v162][v163][v164];	// L271
        float v167 = v165 + v166;	// L272
        v137[0][v162][v163][v164] = v167;	// L273
      }
    }
  }
  for (int v168 = 0; v168 < 256; v168 += 1) {	// L277
    for (int v169 = 0; v169 < 8; v169 += 1) {	// L278
      for (int v170 = 0; v170 < 8; v170 += 1) {	// L279
        #pragma HLS pipeline II=1
        float v171 = v137[0][v168][v169][v170];	// L280
        bool v172 = v171 < v131;	// L281
        float v173 = v172 ? (float)v131 : (float)v171;	// L282
        v136[0][v168][v169][v170] = v173;	// L283
      }
    }
  }
}

void dataflow16(
  float v174,
  float v175[1][64][34][34],
  float v176[64][64][3][3],
  float v177[1][64][32][32],
  float v178[1][64][32][32]
) {	// L289
  float v179[1][64][32][32];	// L290
  #pragma HLS resource variable=v179 core=ram_s2p_bram

  float v180[1][64][32][32];	// L291
  #pragma HLS resource variable=v180 core=ram_s2p_bram

  for (int v181 = 0; v181 < 64; v181 += 1) {	// L292
    for (int v182 = 0; v182 < 3; v182 += 1) {	// L293
      for (int v183 = 0; v183 < 3; v183 += 1) {	// L294
        for (int v184 = 0; v184 < 64; v184 += 1) {	// L295
          for (int v185 = 0; v185 < 32; v185 += 1) {	// L296
            for (int v186 = 0; v186 < 32; v186 += 1) {	// L297
              #pragma HLS pipeline II=1
              float v187 = v175[0][v181][(v185 + v182)][(v186 + v183)];	// L298
              float v188 = v176[v184][v181][v182][v183];	// L299
              float v189 = v180[0][v184][v185][v186];	// L300
              float v190;
              if (v181 == 0 && v182 == 0 && v183 == 0) {	// L301
                v190 = v174;	// L302
              } else {
                v190 = v189;	// L304
              }
              float v191 = v187 * v188;	// L306
              float v192 = v190 + v191;	// L307
              v180[0][v184][v185][v186] = v192;	// L308
            }
          }
        }
      }
    }
  }
  for (int v193 = 0; v193 < 64; v193 += 1) {	// L315
    for (int v194 = 0; v194 < 32; v194 += 1) {	// L316
      for (int v195 = 0; v195 < 32; v195 += 1) {	// L317
        #pragma HLS pipeline II=1
        float v196 = v180[0][v193][v194][v195];	// L318
        float v197 = v177[0][v193][v194][v195];	// L319
        float v198 = v196 + v197;	// L320
        v179[0][v193][v194][v195] = v198;	// L321
      }
    }
  }
  for (int v199 = 0; v199 < 64; v199 += 1) {	// L325
    for (int v200 = 0; v200 < 32; v200 += 1) {	// L326
      for (int v201 = 0; v201 < 32; v201 += 1) {	// L327
        #pragma HLS pipeline II=1
        float v202 = v179[0][v199][v200][v201];	// L328
        bool v203 = v202 < v174;	// L329
        float v204 = v203 ? (float)v174 : (float)v202;	// L330
        v178[0][v199][v200][v201] = v204;	// L331
      }
    }
  }
}

void dataflow4(
  float v205[1][512][4][4],
  float v206[1][512][4][4],
  float v207,
  float v208[1][512][6][6],
  float v209[1][512][4][4]
) {	// L337
  float v210[1][512][4][4];	// L338
  #pragma HLS resource variable=v210 core=ram_s2p_bram

  float v211[1][512][4][4];	// L339
  #pragma HLS resource variable=v211 core=ram_s2p_bram

  for (int v212 = 0; v212 < 512; v212 += 1) {	// L340
    for (int v213 = 0; v213 < 4; v213 += 1) {	// L341
      for (int v214 = 0; v214 < 4; v214 += 1) {	// L342
        #pragma HLS pipeline II=1
        float v215 = v205[0][v212][v213][v214];	// L343
        float v216 = v206[0][v212][v213][v214];	// L344
        float v217 = v215 + v216;	// L345
        v211[0][v212][v213][v214] = v217;	// L346
      }
    }
  }
  for (int v218 = 0; v218 < 512; v218 += 1) {	// L350
    for (int v219 = 0; v219 < 4; v219 += 1) {	// L351
      for (int v220 = 0; v220 < 4; v220 += 1) {	// L352
        #pragma HLS pipeline II=1
        float v221 = v211[0][v218][v219][v220];	// L353
        bool v222 = v221 < v207;	// L354
        float v223 = v222 ? (float)v207 : (float)v221;	// L355
        v210[0][v218][v219][v220] = v223;	// L356
      }
    }
  }
  for (int v224 = 0; v224 < 512; v224 += 1) {	// L360
    for (int v225 = 0; v225 < 6; v225 += 1) {	// L361
      for (int v226 = 0; v226 < 6; v226 += 1) {	// L362
        #pragma HLS pipeline II=1
        v208[0][v224][v225][v226] = v207;	// L363
      }
    }
  }
  for (int v227 = 0; v227 < 512; v227 += 1) {	// L367
    for (int v228 = 0; v228 < 4; v228 += 1) {	// L368
      for (int v229 = 0; v229 < 4; v229 += 1) {	// L369
        #pragma HLS pipeline II=1
        float v230 = v210[0][v227][v228][v229];	// L370
        v208[0][v227][(v228 + 1)][(v229 + 1)] = v230;	// L371
      }
    }
  }
  for (int v231 = 0; v231 < 1; v231 += 1) {	// L375
    for (int v232 = 0; v232 < 512; v232 += 1) {	// L376
      for (int v233 = 0; v233 < 4; v233 += 1) {	// L377
        for (int v234 = 0; v234 < 4; v234 += 1) {	// L378
          #pragma HLS pipeline II=1
          float v235 = v210[v231][v232][v233][v234];	// L379
          v209[v231][v232][v233][v234] = v235;	// L380
        }
      }
    }
  }
}

void dataflow11(
  float v236[1][128][16][16],
  float v237[1][128][16][16],
  float v238,
  float v239[1][128][18][18],
  float v240[1][128][16][16]
) {	// L387
  float v241[1][128][16][16];	// L388
  #pragma HLS resource variable=v241 core=ram_s2p_bram

  float v242[1][128][16][16];	// L389
  #pragma HLS resource variable=v242 core=ram_s2p_bram

  for (int v243 = 0; v243 < 128; v243 += 1) {	// L390
    for (int v244 = 0; v244 < 16; v244 += 1) {	// L391
      for (int v245 = 0; v245 < 16; v245 += 1) {	// L392
        #pragma HLS pipeline II=1
        float v246 = v236[0][v243][v244][v245];	// L393
        float v247 = v237[0][v243][v244][v245];	// L394
        float v248 = v246 + v247;	// L395
        v242[0][v243][v244][v245] = v248;	// L396
      }
    }
  }
  for (int v249 = 0; v249 < 128; v249 += 1) {	// L400
    for (int v250 = 0; v250 < 16; v250 += 1) {	// L401
      for (int v251 = 0; v251 < 16; v251 += 1) {	// L402
        #pragma HLS pipeline II=1
        float v252 = v242[0][v249][v250][v251];	// L403
        bool v253 = v252 < v238;	// L404
        float v254 = v253 ? (float)v238 : (float)v252;	// L405
        v241[0][v249][v250][v251] = v254;	// L406
      }
    }
  }
  for (int v255 = 0; v255 < 128; v255 += 1) {	// L410
    for (int v256 = 0; v256 < 18; v256 += 1) {	// L411
      for (int v257 = 0; v257 < 18; v257 += 1) {	// L412
        #pragma HLS pipeline II=1
        v239[0][v255][v256][v257] = v238;	// L413
      }
    }
  }
  for (int v258 = 0; v258 < 128; v258 += 1) {	// L417
    for (int v259 = 0; v259 < 16; v259 += 1) {	// L418
      for (int v260 = 0; v260 < 16; v260 += 1) {	// L419
        #pragma HLS pipeline II=1
        float v261 = v241[0][v258][v259][v260];	// L420
        v239[0][v258][(v259 + 1)][(v260 + 1)] = v261;	// L421
      }
    }
  }
  for (int v262 = 0; v262 < 1; v262 += 1) {	// L425
    for (int v263 = 0; v263 < 128; v263 += 1) {	// L426
      for (int v264 = 0; v264 < 16; v264 += 1) {	// L427
        for (int v265 = 0; v265 < 16; v265 += 1) {	// L428
          #pragma HLS pipeline II=1
          float v266 = v241[v262][v263][v264][v265];	// L429
          v240[v262][v263][v264][v265] = v266;	// L430
        }
      }
    }
  }
}

void dataflow18(
  float v267[1][64][32][32],
  float v268[1][64][32][32],
  float v269,
  float v270[1][64][34][34],
  float v271[1][64][32][32]
) {	// L437
  float v272[1][64][32][32];	// L438
  #pragma HLS resource variable=v272 core=ram_s2p_bram

  float v273[1][64][32][32];	// L439
  #pragma HLS resource variable=v273 core=ram_s2p_bram

  for (int v274 = 0; v274 < 64; v274 += 1) {	// L440
    for (int v275 = 0; v275 < 32; v275 += 1) {	// L441
      for (int v276 = 0; v276 < 32; v276 += 1) {	// L442
        #pragma HLS pipeline II=1
        float v277 = v267[0][v274][v275][v276];	// L443
        float v278 = v268[0][v274][v275][v276];	// L444
        float v279 = v277 + v278;	// L445
        v273[0][v274][v275][v276] = v279;	// L446
      }
    }
  }
  for (int v280 = 0; v280 < 64; v280 += 1) {	// L450
    for (int v281 = 0; v281 < 32; v281 += 1) {	// L451
      for (int v282 = 0; v282 < 32; v282 += 1) {	// L452
        #pragma HLS pipeline II=1
        float v283 = v273[0][v280][v281][v282];	// L453
        bool v284 = v283 < v269;	// L454
        float v285 = v284 ? (float)v269 : (float)v283;	// L455
        v272[0][v280][v281][v282] = v285;	// L456
      }
    }
  }
  for (int v286 = 0; v286 < 64; v286 += 1) {	// L460
    for (int v287 = 0; v287 < 34; v287 += 1) {	// L461
      for (int v288 = 0; v288 < 34; v288 += 1) {	// L462
        #pragma HLS pipeline II=1
        v270[0][v286][v287][v288] = v269;	// L463
      }
    }
  }
  for (int v289 = 0; v289 < 64; v289 += 1) {	// L467
    for (int v290 = 0; v290 < 32; v290 += 1) {	// L468
      for (int v291 = 0; v291 < 32; v291 += 1) {	// L469
        #pragma HLS pipeline II=1
        float v292 = v272[0][v289][v290][v291];	// L470
        v270[0][v289][(v290 + 1)][(v291 + 1)] = v292;	// L471
      }
    }
  }
  for (int v293 = 0; v293 < 1; v293 += 1) {	// L475
    for (int v294 = 0; v294 < 64; v294 += 1) {	// L476
      for (int v295 = 0; v295 < 32; v295 += 1) {	// L477
        for (int v296 = 0; v296 < 32; v296 += 1) {	// L478
          #pragma HLS pipeline II=1
          float v297 = v272[v293][v294][v295][v296];	// L479
          v271[v293][v294][v295][v296] = v297;	// L480
        }
      }
    }
  }
}

void dataflow6(
  float v298[1][256][8][8],
  float v299,
  float v300[1][512][4][4],
  float v301[512][256][3][3],
  float v302[1][256][8][8]
) {	// L487
  float v303[1][256][8][8];	// L488
  #pragma HLS resource variable=v303 core=ram_s2p_bram

  float v304[1][256][10][10];	// L489
  #pragma HLS resource variable=v304 core=ram_s2p_bram

  for (int v305 = 0; v305 < 256; v305 += 1) {	// L490
    for (int v306 = 0; v306 < 8; v306 += 1) {	// L491
      for (int v307 = 0; v307 < 8; v307 += 1) {	// L492
        #pragma HLS pipeline II=1
        float v308 = v298[0][v305][v306][v307];	// L493
        bool v309 = v308 < v299;	// L494
        float v310 = v309 ? (float)v299 : (float)v308;	// L495
        v303[0][v305][v306][v307] = v310;	// L496
      }
    }
  }
  for (int v311 = 0; v311 < 256; v311 += 1) {	// L500
    for (int v312 = 0; v312 < 10; v312 += 1) {	// L501
      for (int v313 = 0; v313 < 10; v313 += 1) {	// L502
        #pragma HLS pipeline II=1
        v304[0][v311][v312][v313] = v299;	// L503
      }
    }
  }
  for (int v314 = 0; v314 < 256; v314 += 1) {	// L507
    for (int v315 = 0; v315 < 8; v315 += 1) {	// L508
      for (int v316 = 0; v316 < 8; v316 += 1) {	// L509
        #pragma HLS pipeline II=1
        float v317 = v303[0][v314][v315][v316];	// L510
        v304[0][v314][(v315 + 1)][(v316 + 1)] = v317;	// L511
      }
    }
  }
  for (int v318 = 0; v318 < 256; v318 += 1) {	// L515
    for (int v319 = 0; v319 < 3; v319 += 1) {	// L516
      for (int v320 = 0; v320 < 3; v320 += 1) {	// L517
        for (int v321 = 0; v321 < 512; v321 += 1) {	// L518
          for (int v322 = 0; v322 < 4; v322 += 1) {	// L519
            for (int v323 = 0; v323 < 4; v323 += 1) {	// L520
              #pragma HLS pipeline II=1
              float v324 = v304[0][v318][((v322 * 2) + v319)][((v323 * 2) + v320)];	// L521
              float v325 = v301[v321][v318][v319][v320];	// L522
              float v326 = v300[0][v321][v322][v323];	// L523
              float v327;
              if (v318 == 0 && v319 == 0 && v320 == 0) {	// L524
                v327 = v299;	// L525
              } else {
                v327 = v326;	// L527
              }
              float v328 = v324 * v325;	// L529
              float v329 = v327 + v328;	// L530
              v300[0][v321][v322][v323] = v329;	// L531
            }
          }
        }
      }
    }
  }
  for (int v330 = 0; v330 < 1; v330 += 1) {	// L538
    for (int v331 = 0; v331 < 256; v331 += 1) {	// L539
      for (int v332 = 0; v332 < 8; v332 += 1) {	// L540
        for (int v333 = 0; v333 < 8; v333 += 1) {	// L541
          #pragma HLS pipeline II=1
          float v334 = v303[v330][v331][v332][v333];	// L542
          v302[v330][v331][v332][v333] = v334;	// L543
        }
      }
    }
  }
}

void dataflow13(
  float v335[1][128][16][16],
  float v336,
  float v337[1][128][16][16],
  float v338[128][128][3][3],
  float v339[1][128][16][16]
) {	// L550
  float v340[1][128][16][16];	// L551
  #pragma HLS resource variable=v340 core=ram_s2p_bram

  float v341[1][128][18][18];	// L552
  #pragma HLS resource variable=v341 core=ram_s2p_bram

  for (int v342 = 0; v342 < 128; v342 += 1) {	// L553
    for (int v343 = 0; v343 < 16; v343 += 1) {	// L554
      for (int v344 = 0; v344 < 16; v344 += 1) {	// L555
        #pragma HLS pipeline II=1
        float v345 = v335[0][v342][v343][v344];	// L556
        bool v346 = v345 < v336;	// L557
        float v347 = v346 ? (float)v336 : (float)v345;	// L558
        v340[0][v342][v343][v344] = v347;	// L559
      }
    }
  }
  for (int v348 = 0; v348 < 128; v348 += 1) {	// L563
    for (int v349 = 0; v349 < 18; v349 += 1) {	// L564
      for (int v350 = 0; v350 < 18; v350 += 1) {	// L565
        #pragma HLS pipeline II=1
        v341[0][v348][v349][v350] = v336;	// L566
      }
    }
  }
  for (int v351 = 0; v351 < 128; v351 += 1) {	// L570
    for (int v352 = 0; v352 < 16; v352 += 1) {	// L571
      for (int v353 = 0; v353 < 16; v353 += 1) {	// L572
        #pragma HLS pipeline II=1
        float v354 = v340[0][v351][v352][v353];	// L573
        v341[0][v351][(v352 + 1)][(v353 + 1)] = v354;	// L574
      }
    }
  }
  for (int v355 = 0; v355 < 128; v355 += 1) {	// L578
    for (int v356 = 0; v356 < 3; v356 += 1) {	// L579
      for (int v357 = 0; v357 < 3; v357 += 1) {	// L580
        for (int v358 = 0; v358 < 128; v358 += 1) {	// L581
          for (int v359 = 0; v359 < 16; v359 += 1) {	// L582
            for (int v360 = 0; v360 < 16; v360 += 1) {	// L583
              #pragma HLS pipeline II=1
              float v361 = v341[0][v355][(v359 + v356)][(v360 + v357)];	// L584
              float v362 = v338[v358][v355][v356][v357];	// L585
              float v363 = v337[0][v358][v359][v360];	// L586
              float v364;
              if (v355 == 0 && v356 == 0 && v357 == 0) {	// L587
                v364 = v336;	// L588
              } else {
                v364 = v363;	// L590
              }
              float v365 = v361 * v362;	// L592
              float v366 = v364 + v365;	// L593
              v337[0][v358][v359][v360] = v366;	// L594
            }
          }
        }
      }
    }
  }
  for (int v367 = 0; v367 < 1; v367 += 1) {	// L601
    for (int v368 = 0; v368 < 128; v368 += 1) {	// L602
      for (int v369 = 0; v369 < 16; v369 += 1) {	// L603
        for (int v370 = 0; v370 < 16; v370 += 1) {	// L604
          #pragma HLS pipeline II=1
          float v371 = v340[v367][v368][v369][v370];	// L605
          v339[v367][v368][v369][v370] = v371;	// L606
        }
      }
    }
  }
}

void dataflow20(
  float v372[1][64][32][32],
  float v373,
  float v374[1][64][32][32],
  float v375[64][64][3][3],
  float v376[1][64][32][32]
) {	// L613
  float v377[1][64][32][32];	// L614
  #pragma HLS resource variable=v377 core=ram_s2p_bram

  float v378[1][64][34][34];	// L615
  #pragma HLS resource variable=v378 core=ram_s2p_bram

  for (int v379 = 0; v379 < 64; v379 += 1) {	// L616
    for (int v380 = 0; v380 < 32; v380 += 1) {	// L617
      for (int v381 = 0; v381 < 32; v381 += 1) {	// L618
        #pragma HLS pipeline II=1
        float v382 = v372[0][v379][v380][v381];	// L619
        bool v383 = v382 < v373;	// L620
        float v384 = v383 ? (float)v373 : (float)v382;	// L621
        v377[0][v379][v380][v381] = v384;	// L622
      }
    }
  }
  for (int v385 = 0; v385 < 64; v385 += 1) {	// L626
    for (int v386 = 0; v386 < 34; v386 += 1) {	// L627
      for (int v387 = 0; v387 < 34; v387 += 1) {	// L628
        #pragma HLS pipeline II=1
        v378[0][v385][v386][v387] = v373;	// L629
      }
    }
  }
  for (int v388 = 0; v388 < 64; v388 += 1) {	// L633
    for (int v389 = 0; v389 < 32; v389 += 1) {	// L634
      for (int v390 = 0; v390 < 32; v390 += 1) {	// L635
        #pragma HLS pipeline II=1
        float v391 = v377[0][v388][v389][v390];	// L636
        v378[0][v388][(v389 + 1)][(v390 + 1)] = v391;	// L637
      }
    }
  }
  for (int v392 = 0; v392 < 64; v392 += 1) {	// L641
    for (int v393 = 0; v393 < 3; v393 += 1) {	// L642
      for (int v394 = 0; v394 < 3; v394 += 1) {	// L643
        for (int v395 = 0; v395 < 64; v395 += 1) {	// L644
          for (int v396 = 0; v396 < 32; v396 += 1) {	// L645
            for (int v397 = 0; v397 < 32; v397 += 1) {	// L646
              #pragma HLS pipeline II=1
              float v398 = v378[0][v392][(v396 + v393)][(v397 + v394)];	// L647
              float v399 = v375[v395][v392][v393][v394];	// L648
              float v400 = v374[0][v395][v396][v397];	// L649
              float v401;
              if (v392 == 0 && v393 == 0 && v394 == 0) {	// L650
                v401 = v373;	// L651
              } else {
                v401 = v400;	// L653
              }
              float v402 = v398 * v399;	// L655
              float v403 = v401 + v402;	// L656
              v374[0][v395][v396][v397] = v403;	// L657
            }
          }
        }
      }
    }
  }
  for (int v404 = 0; v404 < 1; v404 += 1) {	// L664
    for (int v405 = 0; v405 < 64; v405 += 1) {	// L665
      for (int v406 = 0; v406 < 32; v406 += 1) {	// L666
        for (int v407 = 0; v407 < 32; v407 += 1) {	// L667
          #pragma HLS pipeline II=1
          float v408 = v377[v404][v405][v406][v407];	// L668
          v376[v404][v405][v406][v407] = v408;	// L669
        }
      }
    }
  }
}

void dataflow1(
  float v409,
  float v410[1][512][4][4],
  float v411,
  float v412[1][10],
  float v413,
  float v414[10],
  float v415[10][512]
) {	// L676
  float v416[1][512];	// L677
  #pragma HLS resource variable=v416 core=ram_s2p_bram

  float v417[1][512][1][1];	// L678
  #pragma HLS resource variable=v417 core=ram_s2p_bram

  for (int v418 = 0; v418 < 512; v418 += 1) {	// L679
    #pragma HLS pipeline II=1
    v417[0][v418][0][0] = v409;	// L680
  }
  for (int v419 = 0; v419 < 4; v419 += 1) {	// L682
    for (int v420 = 0; v420 < 4; v420 += 1) {	// L683
      for (int v421 = 0; v421 < 512; v421 += 1) {	// L684
        #pragma HLS pipeline II=1
        float v422 = v410[0][v421][v419][v420];	// L685
        float v423 = v417[0][v421][0][0];	// L686
        float v424 = v423 + v422;	// L687
        v417[0][v421][0][0] = v424;	// L688
      }
    }
  }
  for (int v425 = 0; v425 < 512; v425 += 1) {	// L692
    #pragma HLS pipeline II=1
    float v426 = v417[0][v425][0][0];	// L693
    float v427 = v426 / v411;	// L694
    v417[0][v425][0][0] = v427;	// L695
  }
  for (int v428 = 0; v428 < 512; v428 += 1) {	// L697
    #pragma HLS pipeline II=1
    float v429 = v417[0][v428][0][0];	// L698
    v416[0][v428] = v429;	// L699
  }
  for (int v430 = 0; v430 < 512; v430 += 1) {	// L701
    for (int v431 = 0; v431 < 10; v431 += 1) {	// L702
      #pragma HLS pipeline II=1
      float v432 = v416[0][v430];	// L703
      float v433 = v415[v431][v430];	// L704
      float v434 = v412[0][v431];	// L705
      float v435;
      if (v430 == 0) {	// L706
        v435 = v409;	// L707
      } else {
        v435 = v434;	// L709
      }
      float v436 = v432 * v433;	// L711
      float v437 = v435 + v436;	// L712
      v412[0][v431] = v437;	// L713
      float v438 = v413 * v437;	// L714
      float v439 = v414[v431];	// L715
      float v440 = v413 * v439;	// L716
      float v441 = v438 + v440;	// L717
      if (((-v430) + 511) == 0) {	// L718
        v412[0][v431] = v441;	// L719
      }
    }
  }
}

void dataflow8(
  float v442,
  float v443[1][256][8][8],
  float v444[256][256][3][3],
  float v445[1][256][8][8],
  float v446[1][256][8][8]
) {	// L725
  float v447[1][256][8][8];	// L726
  #pragma HLS resource variable=v447 core=ram_s2p_bram

  float v448[1][256][10][10];	// L727
  #pragma HLS resource variable=v448 core=ram_s2p_bram

  for (int v449 = 0; v449 < 256; v449 += 1) {	// L728
    for (int v450 = 0; v450 < 10; v450 += 1) {	// L729
      for (int v451 = 0; v451 < 10; v451 += 1) {	// L730
        #pragma HLS pipeline II=1
        v448[0][v449][v450][v451] = v442;	// L731
      }
    }
  }
  for (int v452 = 0; v452 < 256; v452 += 1) {	// L735
    for (int v453 = 0; v453 < 8; v453 += 1) {	// L736
      for (int v454 = 0; v454 < 8; v454 += 1) {	// L737
        #pragma HLS pipeline II=1
        float v455 = v443[0][v452][v453][v454];	// L738
        v448[0][v452][(v453 + 1)][(v454 + 1)] = v455;	// L739
      }
    }
  }
  for (int v456 = 0; v456 < 256; v456 += 1) {	// L743
    for (int v457 = 0; v457 < 3; v457 += 1) {	// L744
      for (int v458 = 0; v458 < 3; v458 += 1) {	// L745
        for (int v459 = 0; v459 < 256; v459 += 1) {	// L746
          for (int v460 = 0; v460 < 8; v460 += 1) {	// L747
            for (int v461 = 0; v461 < 8; v461 += 1) {	// L748
              #pragma HLS pipeline II=1
              float v462 = v448[0][v456][(v460 + v457)][(v461 + v458)];	// L749
              float v463 = v444[v459][v456][v457][v458];	// L750
              float v464 = v447[0][v459][v460][v461];	// L751
              float v465;
              if (v456 == 0 && v457 == 0 && v458 == 0) {	// L752
                v465 = v442;	// L753
              } else {
                v465 = v464;	// L755
              }
              float v466 = v462 * v463;	// L757
              float v467 = v465 + v466;	// L758
              v447[0][v459][v460][v461] = v467;	// L759
            }
          }
        }
      }
    }
  }
  for (int v468 = 0; v468 < 256; v468 += 1) {	// L766
    for (int v469 = 0; v469 < 8; v469 += 1) {	// L767
      for (int v470 = 0; v470 < 8; v470 += 1) {	// L768
        #pragma HLS pipeline II=1
        float v471 = v447[0][v468][v469][v470];	// L769
        bool v472 = v471 < v442;	// L770
        float v473 = v472 ? (float)v442 : (float)v471;	// L771
        v445[0][v468][v469][v470] = v473;	// L772
      }
    }
  }
  for (int v474 = 0; v474 < 1; v474 += 1) {	// L776
    for (int v475 = 0; v475 < 256; v475 += 1) {	// L777
      for (int v476 = 0; v476 < 8; v476 += 1) {	// L778
        for (int v477 = 0; v477 < 8; v477 += 1) {	// L779
          #pragma HLS pipeline II=1
          float v478 = v443[v474][v475][v476][v477];	// L780
          v446[v474][v475][v476][v477] = v478;	// L781
        }
      }
    }
  }
}

void dataflow15(
  float v479,
  float v480[1][64][32][32],
  float v481[128][64][3][3],
  float v482[1][128][16][16],
  float v483[1][64][32][32]
) {	// L788
  float v484[1][128][16][16];	// L789
  #pragma HLS resource variable=v484 core=ram_s2p_bram

  float v485[1][64][34][34];	// L790
  #pragma HLS resource variable=v485 core=ram_s2p_bram

  for (int v486 = 0; v486 < 64; v486 += 1) {	// L791
    for (int v487 = 0; v487 < 34; v487 += 1) {	// L792
      for (int v488 = 0; v488 < 34; v488 += 1) {	// L793
        #pragma HLS pipeline II=1
        v485[0][v486][v487][v488] = v479;	// L794
      }
    }
  }
  for (int v489 = 0; v489 < 64; v489 += 1) {	// L798
    for (int v490 = 0; v490 < 32; v490 += 1) {	// L799
      for (int v491 = 0; v491 < 32; v491 += 1) {	// L800
        #pragma HLS pipeline II=1
        float v492 = v480[0][v489][v490][v491];	// L801
        v485[0][v489][(v490 + 1)][(v491 + 1)] = v492;	// L802
      }
    }
  }
  for (int v493 = 0; v493 < 64; v493 += 1) {	// L806
    for (int v494 = 0; v494 < 3; v494 += 1) {	// L807
      for (int v495 = 0; v495 < 3; v495 += 1) {	// L808
        for (int v496 = 0; v496 < 128; v496 += 1) {	// L809
          for (int v497 = 0; v497 < 16; v497 += 1) {	// L810
            for (int v498 = 0; v498 < 16; v498 += 1) {	// L811
              #pragma HLS pipeline II=1
              float v499 = v485[0][v493][((v497 * 2) + v494)][((v498 * 2) + v495)];	// L812
              float v500 = v481[v496][v493][v494][v495];	// L813
              float v501 = v484[0][v496][v497][v498];	// L814
              float v502;
              if (v493 == 0 && v494 == 0 && v495 == 0) {	// L815
                v502 = v479;	// L816
              } else {
                v502 = v501;	// L818
              }
              float v503 = v499 * v500;	// L820
              float v504 = v502 + v503;	// L821
              v484[0][v496][v497][v498] = v504;	// L822
            }
          }
        }
      }
    }
  }
  for (int v505 = 0; v505 < 128; v505 += 1) {	// L829
    for (int v506 = 0; v506 < 16; v506 += 1) {	// L830
      for (int v507 = 0; v507 < 16; v507 += 1) {	// L831
        #pragma HLS pipeline II=1
        float v508 = v484[0][v505][v506][v507];	// L832
        bool v509 = v508 < v479;	// L833
        float v510 = v509 ? (float)v479 : (float)v508;	// L834
        v482[0][v505][v506][v507] = v510;	// L835
      }
    }
  }
  for (int v511 = 0; v511 < 1; v511 += 1) {	// L839
    for (int v512 = 0; v512 < 64; v512 += 1) {	// L840
      for (int v513 = 0; v513 < 32; v513 += 1) {	// L841
        for (int v514 = 0; v514 < 32; v514 += 1) {	// L842
          #pragma HLS pipeline II=1
          float v515 = v480[v511][v512][v513][v514];	// L843
          v483[v511][v512][v513][v514] = v515;	// L844
        }
      }
    }
  }
}

void dataflow3(
  float v516,
  float v517[1][512][6][6],
  float v518[512][512][3][3],
  float v519[1][512][6][6],
  float v520[1][512][4][4],
  float v521[1][512][4][4]
) {	// L851
  float v522[1][512][4][4];	// L852
  #pragma HLS resource variable=v522 core=ram_s2p_bram

  float v523[1][512][4][4];	// L853
  #pragma HLS resource variable=v523 core=ram_s2p_bram

  for (int v524 = 0; v524 < 512; v524 += 1) {	// L854
    for (int v525 = 0; v525 < 3; v525 += 1) {	// L855
      for (int v526 = 0; v526 < 3; v526 += 1) {	// L856
        for (int v527 = 0; v527 < 512; v527 += 1) {	// L857
          for (int v528 = 0; v528 < 4; v528 += 1) {	// L858
            for (int v529 = 0; v529 < 4; v529 += 1) {	// L859
              #pragma HLS pipeline II=1
              float v530 = v517[0][v524][(v528 + v525)][(v529 + v526)];	// L860
              float v531 = v518[v527][v524][v525][v526];	// L861
              float v532 = v523[0][v527][v528][v529];	// L862
              float v533;
              if (v524 == 0 && v525 == 0 && v526 == 0) {	// L863
                v533 = v516;	// L864
              } else {
                v533 = v532;	// L866
              }
              float v534 = v530 * v531;	// L868
              float v535 = v533 + v534;	// L869
              v523[0][v527][v528][v529] = v535;	// L870
            }
          }
        }
      }
    }
  }
  for (int v536 = 0; v536 < 512; v536 += 1) {	// L877
    for (int v537 = 0; v537 < 4; v537 += 1) {	// L878
      for (int v538 = 0; v538 < 4; v538 += 1) {	// L879
        #pragma HLS pipeline II=1
        float v539 = v523[0][v536][v537][v538];	// L880
        bool v540 = v539 < v516;	// L881
        float v541 = v540 ? (float)v516 : (float)v539;	// L882
        v522[0][v536][v537][v538] = v541;	// L883
      }
    }
  }
  for (int v542 = 0; v542 < 512; v542 += 1) {	// L887
    for (int v543 = 0; v543 < 6; v543 += 1) {	// L888
      for (int v544 = 0; v544 < 6; v544 += 1) {	// L889
        #pragma HLS pipeline II=1
        v519[0][v542][v543][v544] = v516;	// L890
      }
    }
  }
  for (int v545 = 0; v545 < 512; v545 += 1) {	// L894
    for (int v546 = 0; v546 < 4; v546 += 1) {	// L895
      for (int v547 = 0; v547 < 4; v547 += 1) {	// L896
        #pragma HLS pipeline II=1
        float v548 = v522[0][v545][v546][v547];	// L897
        v519[0][v545][(v546 + 1)][(v547 + 1)] = v548;	// L898
      }
    }
  }
  for (int v549 = 0; v549 < 1; v549 += 1) {	// L902
    for (int v550 = 0; v550 < 512; v550 += 1) {	// L903
      for (int v551 = 0; v551 < 4; v551 += 1) {	// L904
        for (int v552 = 0; v552 < 4; v552 += 1) {	// L905
          #pragma HLS pipeline II=1
          float v553 = v520[v549][v550][v551][v552];	// L906
          v521[v549][v550][v551][v552] = v553;	// L907
        }
      }
    }
  }
}

void dataflow10(
  float v554,
  float v555[1][128][18][18],
  float v556[256][128][3][3],
  float v557[1][256][10][10],
  float v558[1][128][16][16],
  float v559[1][128][16][16]
) {	// L914
  float v560[1][256][8][8];	// L915
  #pragma HLS resource variable=v560 core=ram_s2p_bram

  float v561[1][256][8][8];	// L916
  #pragma HLS resource variable=v561 core=ram_s2p_bram

  for (int v562 = 0; v562 < 128; v562 += 1) {	// L917
    for (int v563 = 0; v563 < 3; v563 += 1) {	// L918
      for (int v564 = 0; v564 < 3; v564 += 1) {	// L919
        for (int v565 = 0; v565 < 256; v565 += 1) {	// L920
          for (int v566 = 0; v566 < 8; v566 += 1) {	// L921
            for (int v567 = 0; v567 < 8; v567 += 1) {	// L922
              #pragma HLS pipeline II=1
              float v568 = v555[0][v562][((v566 * 2) + v563)][((v567 * 2) + v564)];	// L923
              float v569 = v556[v565][v562][v563][v564];	// L924
              float v570 = v561[0][v565][v566][v567];	// L925
              float v571;
              if (v562 == 0 && v563 == 0 && v564 == 0) {	// L926
                v571 = v554;	// L927
              } else {
                v571 = v570;	// L929
              }
              float v572 = v568 * v569;	// L931
              float v573 = v571 + v572;	// L932
              v561[0][v565][v566][v567] = v573;	// L933
            }
          }
        }
      }
    }
  }
  for (int v574 = 0; v574 < 256; v574 += 1) {	// L940
    for (int v575 = 0; v575 < 8; v575 += 1) {	// L941
      for (int v576 = 0; v576 < 8; v576 += 1) {	// L942
        #pragma HLS pipeline II=1
        float v577 = v561[0][v574][v575][v576];	// L943
        bool v578 = v577 < v554;	// L944
        float v579 = v578 ? (float)v554 : (float)v577;	// L945
        v560[0][v574][v575][v576] = v579;	// L946
      }
    }
  }
  for (int v580 = 0; v580 < 256; v580 += 1) {	// L950
    for (int v581 = 0; v581 < 10; v581 += 1) {	// L951
      for (int v582 = 0; v582 < 10; v582 += 1) {	// L952
        #pragma HLS pipeline II=1
        v557[0][v580][v581][v582] = v554;	// L953
      }
    }
  }
  for (int v583 = 0; v583 < 256; v583 += 1) {	// L957
    for (int v584 = 0; v584 < 8; v584 += 1) {	// L958
      for (int v585 = 0; v585 < 8; v585 += 1) {	// L959
        #pragma HLS pipeline II=1
        float v586 = v560[0][v583][v584][v585];	// L960
        v557[0][v583][(v584 + 1)][(v585 + 1)] = v586;	// L961
      }
    }
  }
  for (int v587 = 0; v587 < 1; v587 += 1) {	// L965
    for (int v588 = 0; v588 < 128; v588 += 1) {	// L966
      for (int v589 = 0; v589 < 16; v589 += 1) {	// L967
        for (int v590 = 0; v590 < 16; v590 += 1) {	// L968
          #pragma HLS pipeline II=1
          float v591 = v558[v587][v588][v589][v590];	// L969
          v559[v587][v588][v589][v590] = v591;	// L970
        }
      }
    }
  }
}

void dataflow17(
  float v592,
  float v593[1][64][34][34],
  float v594[64][64][3][3],
  float v595[1][64][34][34],
  float v596[1][64][32][32],
  float v597[1][64][32][32]
) {	// L977
  float v598[1][64][32][32];	// L978
  #pragma HLS resource variable=v598 core=ram_s2p_bram

  float v599[1][64][32][32];	// L979
  #pragma HLS resource variable=v599 core=ram_s2p_bram

  for (int v600 = 0; v600 < 64; v600 += 1) {	// L980
    for (int v601 = 0; v601 < 3; v601 += 1) {	// L981
      for (int v602 = 0; v602 < 3; v602 += 1) {	// L982
        for (int v603 = 0; v603 < 64; v603 += 1) {	// L983
          for (int v604 = 0; v604 < 32; v604 += 1) {	// L984
            for (int v605 = 0; v605 < 32; v605 += 1) {	// L985
              #pragma HLS pipeline II=1
              float v606 = v593[0][v600][(v604 + v601)][(v605 + v602)];	// L986
              float v607 = v594[v603][v600][v601][v602];	// L987
              float v608 = v599[0][v603][v604][v605];	// L988
              float v609;
              if (v600 == 0 && v601 == 0 && v602 == 0) {	// L989
                v609 = v592;	// L990
              } else {
                v609 = v608;	// L992
              }
              float v610 = v606 * v607;	// L994
              float v611 = v609 + v610;	// L995
              v599[0][v603][v604][v605] = v611;	// L996
            }
          }
        }
      }
    }
  }
  for (int v612 = 0; v612 < 64; v612 += 1) {	// L1003
    for (int v613 = 0; v613 < 32; v613 += 1) {	// L1004
      for (int v614 = 0; v614 < 32; v614 += 1) {	// L1005
        #pragma HLS pipeline II=1
        float v615 = v599[0][v612][v613][v614];	// L1006
        bool v616 = v615 < v592;	// L1007
        float v617 = v616 ? (float)v592 : (float)v615;	// L1008
        v598[0][v612][v613][v614] = v617;	// L1009
      }
    }
  }
  for (int v618 = 0; v618 < 64; v618 += 1) {	// L1013
    for (int v619 = 0; v619 < 34; v619 += 1) {	// L1014
      for (int v620 = 0; v620 < 34; v620 += 1) {	// L1015
        #pragma HLS pipeline II=1
        v595[0][v618][v619][v620] = v592;	// L1016
      }
    }
  }
  for (int v621 = 0; v621 < 64; v621 += 1) {	// L1020
    for (int v622 = 0; v622 < 32; v622 += 1) {	// L1021
      for (int v623 = 0; v623 < 32; v623 += 1) {	// L1022
        #pragma HLS pipeline II=1
        float v624 = v598[0][v621][v622][v623];	// L1023
        v595[0][v621][(v622 + 1)][(v623 + 1)] = v624;	// L1024
      }
    }
  }
  for (int v625 = 0; v625 < 1; v625 += 1) {	// L1028
    for (int v626 = 0; v626 < 64; v626 += 1) {	// L1029
      for (int v627 = 0; v627 < 32; v627 += 1) {	// L1030
        for (int v628 = 0; v628 < 32; v628 += 1) {	// L1031
          #pragma HLS pipeline II=1
          float v629 = v596[v625][v626][v627][v628];	// L1032
          v597[v625][v626][v627][v628] = v629;	// L1033
        }
      }
    }
  }
}

void dataflow5(
  float v630[1][512][4][4],
  float v631,
  float v632[1][512][4][4],
  float v633[512][512][3][3],
  float v634[1][256][8][8],
  float v635[1][512][4][4],
  float v636[512][256][1][1]
) {	// L1040
  float v637[1][512][6][6];	// L1041
  #pragma HLS resource variable=v637 core=ram_s2p_bram

  float v638[1][512][4][4];	// L1042
  #pragma HLS resource variable=v638 core=ram_s2p_bram

  for (int v639 = 0; v639 < 512; v639 += 1) {	// L1043
    for (int v640 = 0; v640 < 4; v640 += 1) {	// L1044
      for (int v641 = 0; v641 < 4; v641 += 1) {	// L1045
        #pragma HLS pipeline II=1
        float v642 = v630[0][v639][v640][v641];	// L1046
        bool v643 = v642 < v631;	// L1047
        float v644 = v643 ? (float)v631 : (float)v642;	// L1048
        v638[0][v639][v640][v641] = v644;	// L1049
      }
    }
  }
  for (int v645 = 0; v645 < 512; v645 += 1) {	// L1053
    for (int v646 = 0; v646 < 6; v646 += 1) {	// L1054
      for (int v647 = 0; v647 < 6; v647 += 1) {	// L1055
        #pragma HLS pipeline II=1
        v637[0][v645][v646][v647] = v631;	// L1056
      }
    }
  }
  for (int v648 = 0; v648 < 512; v648 += 1) {	// L1060
    for (int v649 = 0; v649 < 4; v649 += 1) {	// L1061
      for (int v650 = 0; v650 < 4; v650 += 1) {	// L1062
        #pragma HLS pipeline II=1
        float v651 = v638[0][v648][v649][v650];	// L1063
        v637[0][v648][(v649 + 1)][(v650 + 1)] = v651;	// L1064
      }
    }
  }
  for (int v652 = 0; v652 < 512; v652 += 1) {	// L1068
    for (int v653 = 0; v653 < 3; v653 += 1) {	// L1069
      for (int v654 = 0; v654 < 3; v654 += 1) {	// L1070
        for (int v655 = 0; v655 < 512; v655 += 1) {	// L1071
          for (int v656 = 0; v656 < 4; v656 += 1) {	// L1072
            for (int v657 = 0; v657 < 4; v657 += 1) {	// L1073
              #pragma HLS pipeline II=1
              float v658 = v637[0][v652][(v656 + v653)][(v657 + v654)];	// L1074
              float v659 = v633[v655][v652][v653][v654];	// L1075
              float v660 = v632[0][v655][v656][v657];	// L1076
              float v661;
              if (v652 == 0 && v653 == 0 && v654 == 0) {	// L1077
                v661 = v631;	// L1078
              } else {
                v661 = v660;	// L1080
              }
              float v662 = v658 * v659;	// L1082
              float v663 = v661 + v662;	// L1083
              v632[0][v655][v656][v657] = v663;	// L1084
            }
          }
        }
      }
    }
  }
  for (int v664 = 0; v664 < 256; v664 += 1) {	// L1091
    for (int v665 = 0; v665 < 512; v665 += 1) {	// L1092
      for (int v666 = 0; v666 < 4; v666 += 1) {	// L1093
        for (int v667 = 0; v667 < 4; v667 += 1) {	// L1094
          #pragma HLS pipeline II=1
          float v668 = v634[0][v664][(v666 * 2)][(v667 * 2)];	// L1095
          float v669 = v636[v665][v664][0][0];	// L1096
          float v670 = v635[0][v665][v666][v667];	// L1097
          float v671;
          if (v664 == 0) {	// L1098
            v671 = v631;	// L1099
          } else {
            v671 = v670;	// L1101
          }
          float v672 = v668 * v669;	// L1103
          float v673 = v671 + v672;	// L1104
          v635[0][v665][v666][v667] = v673;	// L1105
        }
      }
    }
  }
}

void dataflow12(
  float v674[1][128][16][16],
  float v675,
  float v676[1][128][16][16],
  float v677[128][128][3][3],
  float v678[1][128][16][16],
  float v679[1][128][16][16]
) {	// L1112
  float v680[1][128][18][18];	// L1113
  #pragma HLS resource variable=v680 core=ram_s2p_bram

  float v681[1][128][16][16];	// L1114
  #pragma HLS resource variable=v681 core=ram_s2p_bram

  for (int v682 = 0; v682 < 128; v682 += 1) {	// L1115
    for (int v683 = 0; v683 < 16; v683 += 1) {	// L1116
      for (int v684 = 0; v684 < 16; v684 += 1) {	// L1117
        #pragma HLS pipeline II=1
        float v685 = v674[0][v682][v683][v684];	// L1118
        bool v686 = v685 < v675;	// L1119
        float v687 = v686 ? (float)v675 : (float)v685;	// L1120
        v681[0][v682][v683][v684] = v687;	// L1121
      }
    }
  }
  for (int v688 = 0; v688 < 128; v688 += 1) {	// L1125
    for (int v689 = 0; v689 < 18; v689 += 1) {	// L1126
      for (int v690 = 0; v690 < 18; v690 += 1) {	// L1127
        #pragma HLS pipeline II=1
        v680[0][v688][v689][v690] = v675;	// L1128
      }
    }
  }
  for (int v691 = 0; v691 < 128; v691 += 1) {	// L1132
    for (int v692 = 0; v692 < 16; v692 += 1) {	// L1133
      for (int v693 = 0; v693 < 16; v693 += 1) {	// L1134
        #pragma HLS pipeline II=1
        float v694 = v681[0][v691][v692][v693];	// L1135
        v680[0][v691][(v692 + 1)][(v693 + 1)] = v694;	// L1136
      }
    }
  }
  for (int v695 = 0; v695 < 128; v695 += 1) {	// L1140
    for (int v696 = 0; v696 < 3; v696 += 1) {	// L1141
      for (int v697 = 0; v697 < 3; v697 += 1) {	// L1142
        for (int v698 = 0; v698 < 128; v698 += 1) {	// L1143
          for (int v699 = 0; v699 < 16; v699 += 1) {	// L1144
            for (int v700 = 0; v700 < 16; v700 += 1) {	// L1145
              #pragma HLS pipeline II=1
              float v701 = v680[0][v695][(v699 + v696)][(v700 + v697)];	// L1146
              float v702 = v677[v698][v695][v696][v697];	// L1147
              float v703 = v676[0][v698][v699][v700];	// L1148
              float v704;
              if (v695 == 0 && v696 == 0 && v697 == 0) {	// L1149
                v704 = v675;	// L1150
              } else {
                v704 = v703;	// L1152
              }
              float v705 = v701 * v702;	// L1154
              float v706 = v704 + v705;	// L1155
              v676[0][v698][v699][v700] = v706;	// L1156
            }
          }
        }
      }
    }
  }
  for (int v707 = 0; v707 < 1; v707 += 1) {	// L1163
    for (int v708 = 0; v708 < 128; v708 += 1) {	// L1164
      for (int v709 = 0; v709 < 16; v709 += 1) {	// L1165
        for (int v710 = 0; v710 < 16; v710 += 1) {	// L1166
          #pragma HLS pipeline II=1
          float v711 = v678[v707][v708][v709][v710];	// L1167
          v679[v707][v708][v709][v710] = v711;	// L1168
        }
      }
    }
  }
}

void dataflow19(
  float v712[1][64][32][32],
  float v713,
  float v714[1][64][32][32],
  float v715[64][64][3][3],
  float v716[1][64][32][32],
  float v717[1][64][32][32]
) {	// L1175
  float v718[1][64][34][34];	// L1176
  #pragma HLS resource variable=v718 core=ram_s2p_bram

  float v719[1][64][32][32];	// L1177
  #pragma HLS resource variable=v719 core=ram_s2p_bram

  for (int v720 = 0; v720 < 64; v720 += 1) {	// L1178
    for (int v721 = 0; v721 < 32; v721 += 1) {	// L1179
      for (int v722 = 0; v722 < 32; v722 += 1) {	// L1180
        #pragma HLS pipeline II=1
        float v723 = v712[0][v720][v721][v722];	// L1181
        bool v724 = v723 < v713;	// L1182
        float v725 = v724 ? (float)v713 : (float)v723;	// L1183
        v719[0][v720][v721][v722] = v725;	// L1184
      }
    }
  }
  for (int v726 = 0; v726 < 64; v726 += 1) {	// L1188
    for (int v727 = 0; v727 < 34; v727 += 1) {	// L1189
      for (int v728 = 0; v728 < 34; v728 += 1) {	// L1190
        #pragma HLS pipeline II=1
        v718[0][v726][v727][v728] = v713;	// L1191
      }
    }
  }
  for (int v729 = 0; v729 < 64; v729 += 1) {	// L1195
    for (int v730 = 0; v730 < 32; v730 += 1) {	// L1196
      for (int v731 = 0; v731 < 32; v731 += 1) {	// L1197
        #pragma HLS pipeline II=1
        float v732 = v719[0][v729][v730][v731];	// L1198
        v718[0][v729][(v730 + 1)][(v731 + 1)] = v732;	// L1199
      }
    }
  }
  for (int v733 = 0; v733 < 64; v733 += 1) {	// L1203
    for (int v734 = 0; v734 < 3; v734 += 1) {	// L1204
      for (int v735 = 0; v735 < 3; v735 += 1) {	// L1205
        for (int v736 = 0; v736 < 64; v736 += 1) {	// L1206
          for (int v737 = 0; v737 < 32; v737 += 1) {	// L1207
            for (int v738 = 0; v738 < 32; v738 += 1) {	// L1208
              #pragma HLS pipeline II=1
              float v739 = v718[0][v733][(v737 + v734)][(v738 + v735)];	// L1209
              float v740 = v715[v736][v733][v734][v735];	// L1210
              float v741 = v714[0][v736][v737][v738];	// L1211
              float v742;
              if (v733 == 0 && v734 == 0 && v735 == 0) {	// L1212
                v742 = v713;	// L1213
              } else {
                v742 = v741;	// L1215
              }
              float v743 = v739 * v740;	// L1217
              float v744 = v742 + v743;	// L1218
              v714[0][v736][v737][v738] = v744;	// L1219
            }
          }
        }
      }
    }
  }
  for (int v745 = 0; v745 < 1; v745 += 1) {	// L1226
    for (int v746 = 0; v746 < 64; v746 += 1) {	// L1227
      for (int v747 = 0; v747 < 32; v747 += 1) {	// L1228
        for (int v748 = 0; v748 < 32; v748 += 1) {	// L1229
          #pragma HLS pipeline II=1
          float v749 = v716[v745][v746][v747][v748];	// L1230
          v717[v745][v746][v747][v748] = v749;	// L1231
        }
      }
    }
  }
}

void main_graph(
  float v750[1][3][32][32],
  float v751[64][3][3][3],
  float v752[64][64][3][3],
  float v753[64][64][3][3],
  float v754[64][64][3][3],
  float v755[64][64][3][3],
  float v756[128][64][3][3],
  float v757[128][128][3][3],
  float v758[128][64][1][1],
  float v759[128][128][3][3],
  float v760[128][128][3][3],
  float v761[256][128][3][3],
  float v762[256][256][3][3],
  float v763[256][128][1][1],
  float v764[256][256][3][3],
  float v765[256][256][3][3],
  float v766[512][256][3][3],
  float v767[512][512][3][3],
  float v768[512][256][1][1],
  float v769[512][512][3][3],
  float v770[512][512][3][3],
  float v771[10][512],
  float v772[1][10]
) {	// L1238
  #pragma HLS dataflow

  float v773[10] = {-2.781226e-02, -4.107117e-02, -8.704335e-03, -3.831929e-02, -2.075570e-02, 4.087221e-02, 3.640073e-02, 4.095368e-02, 3.038846e-03, -4.327787e-02};	// L1242
  float v774[1][512][4][4];	// L1244
  #pragma HLS resource variable=v774 core=ram_s2p_bram

  float v775[1][512][6][6];	// L1245
  #pragma HLS resource variable=v775 core=ram_s2p_bram

  float v776[1][512][6][6];	// L1246
  #pragma HLS resource variable=v776 core=ram_s2p_bram

  float v777[1][512][4][4];	// L1247
  #pragma HLS resource variable=v777 core=ram_s2p_bram

  float v778[1][512][4][4];	// L1248
  #pragma HLS resource variable=v778 core=ram_s2p_bram

  float v779[1][512][4][4];	// L1249
  #pragma HLS resource variable=v779 core=ram_s2p_bram

  float v780[1][256][8][8];	// L1250
  #pragma HLS resource variable=v780 core=ram_s2p_bram

  float v781[1][256][8][8];	// L1251
  #pragma HLS resource variable=v781 core=ram_s2p_bram

  float v782[1][256][8][8];	// L1252
  #pragma HLS resource variable=v782 core=ram_s2p_bram

  float v783[1][256][10][10];	// L1253
  #pragma HLS resource variable=v783 core=ram_s2p_bram

  float v784[1][128][18][18];	// L1254
  #pragma HLS resource variable=v784 core=ram_s2p_bram

  float v785[1][128][16][16];	// L1255
  #pragma HLS resource variable=v785 core=ram_s2p_bram

  float v786[1][128][16][16];	// L1256
  #pragma HLS resource variable=v786 core=ram_s2p_bram

  float v787[1][128][16][16];	// L1257
  #pragma HLS resource variable=v787 core=ram_s2p_bram

  float v788[1][128][16][16];	// L1258
  #pragma HLS resource variable=v788 core=ram_s2p_bram

  float v789[1][64][32][32];	// L1259
  #pragma HLS resource variable=v789 core=ram_s2p_bram

  float v790[1][64][34][34];	// L1260
  #pragma HLS resource variable=v790 core=ram_s2p_bram

  float v791[1][64][34][34];	// L1261
  #pragma HLS resource variable=v791 core=ram_s2p_bram

  float v792[1][64][32][32];	// L1262
  #pragma HLS resource variable=v792 core=ram_s2p_bram

  float v793[1][64][32][32];	// L1263
  #pragma HLS resource variable=v793 core=ram_s2p_bram

  float v794[1][64][32][32];	// L1264
  #pragma HLS resource variable=v794 core=ram_s2p_bram

  dataflow21(0.000000, v750, v794, v751);	// L1265
  float v795[1][64][32][32];	// L1266
  #pragma HLS resource variable=v795 core=ram_s2p_bram

  dataflow20(v794, 0.000000, v793, v752, v795);	// L1267
  float v796[1][64][32][32];	// L1268
  #pragma HLS resource variable=v796 core=ram_s2p_bram

  dataflow19(v793, 0.000000, v792, v753, v795, v796);	// L1269
  float v797[1][64][32][32];	// L1270
  #pragma HLS resource variable=v797 core=ram_s2p_bram

  dataflow18(v792, v796, 0.000000, v791, v797);	// L1271
  float v798[1][64][32][32];	// L1272
  #pragma HLS resource variable=v798 core=ram_s2p_bram

  dataflow17(0.000000, v791, v754, v790, v797, v798);	// L1273
  dataflow16(0.000000, v790, v755, v798, v789);	// L1274
  float v799[1][64][32][32];	// L1275
  #pragma HLS resource variable=v799 core=ram_s2p_bram

  dataflow15(0.000000, v789, v756, v788, v799);	// L1276
  dataflow14(0.000000, v788, v757, v799, v758, v787);	// L1277
  float v800[1][128][16][16];	// L1278
  #pragma HLS resource variable=v800 core=ram_s2p_bram

  dataflow13(v787, 0.000000, v786, v759, v800);	// L1279
  float v801[1][128][16][16];	// L1280
  #pragma HLS resource variable=v801 core=ram_s2p_bram

  dataflow12(v786, 0.000000, v785, v760, v800, v801);	// L1281
  float v802[1][128][16][16];	// L1282
  #pragma HLS resource variable=v802 core=ram_s2p_bram

  dataflow11(v785, v801, 0.000000, v784, v802);	// L1283
  float v803[1][128][16][16];	// L1284
  #pragma HLS resource variable=v803 core=ram_s2p_bram

  dataflow10(0.000000, v784, v761, v783, v802, v803);	// L1285
  dataflow9(0.000000, v783, v762, v803, v763, v782);	// L1286
  float v804[1][256][8][8];	// L1287
  #pragma HLS resource variable=v804 core=ram_s2p_bram

  dataflow8(0.000000, v782, v764, v781, v804);	// L1288
  dataflow7(0.000000, v781, v765, v804, v780);	// L1289
  float v805[1][256][8][8];	// L1290
  #pragma HLS resource variable=v805 core=ram_s2p_bram

  dataflow6(v780, 0.000000, v779, v766, v805);	// L1291
  dataflow5(v779, 0.000000, v778, v767, v805, v777, v768);	// L1292
  float v806[1][512][4][4];	// L1293
  #pragma HLS resource variable=v806 core=ram_s2p_bram

  dataflow4(v778, v777, 0.000000, v776, v806);	// L1294
  float v807[1][512][4][4];	// L1295
  #pragma HLS resource variable=v807 core=ram_s2p_bram

  dataflow3(0.000000, v776, v769, v775, v806, v807);	// L1296
  dataflow2(0.000000, v775, v770, v807, v774);	// L1297
  float v808 = 16;	// L1298
  #pragma HLS resource variable=v773 core=ram_s2p_bram

  dataflow1(0.000000, v774, v808, v772, 1.000000, v773, v771);	// L1300
}

