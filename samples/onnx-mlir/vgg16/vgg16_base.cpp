
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

/// This is top function.
void main_graph(
  int8_t v0[1][3][32][32],
  int8_t v1[64][3][3][3],
  int8_t v2[64][64][3][3],
  int8_t v3[128][64][3][3],
  int8_t v4[128][128][3][3],
  int8_t v5[256][128][3][3],
  int8_t v6[256][256][3][3],
  int8_t v7[256][256][3][3],
  int8_t v8[512][256][3][3],
  int8_t v9[512][512][3][3],
  int8_t v10[512][512][3][3],
  int8_t v11[512][512][3][3],
  int8_t v12[512][512][3][3],
  int8_t v13[512][512][3][3],
  int8_t v14[10][512],
  int8_t v15[1][10]
) {	// L2
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface bram port=v0
  #pragma HLS interface bram port=v1
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3
  #pragma HLS interface bram port=v4
  #pragma HLS interface bram port=v5
  #pragma HLS interface bram port=v6
  #pragma HLS interface bram port=v7
  #pragma HLS interface bram port=v8
  #pragma HLS interface bram port=v9
  #pragma HLS interface bram port=v10
  #pragma HLS interface bram port=v11
  #pragma HLS interface bram port=v12
  #pragma HLS interface bram port=v13
  #pragma HLS interface bram port=v14
  #pragma HLS interface bram port=v15

  #pragma HLS resource variable=v0 core=ram_s2p_bram

  #pragma HLS resource variable=v1 core=ram_s2p_bram

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS resource variable=v3 core=ram_s2p_bram

  #pragma HLS resource variable=v4 core=ram_s2p_bram

  #pragma HLS resource variable=v5 core=ram_s2p_bram

  #pragma HLS resource variable=v6 core=ram_s2p_bram

  #pragma HLS resource variable=v7 core=ram_s2p_bram

  #pragma HLS resource variable=v8 core=ram_s2p_bram

  #pragma HLS resource variable=v9 core=ram_s2p_bram

  #pragma HLS resource variable=v10 core=ram_s2p_bram

  #pragma HLS resource variable=v11 core=ram_s2p_bram

  #pragma HLS resource variable=v12 core=ram_s2p_bram

  #pragma HLS resource variable=v13 core=ram_s2p_bram

  #pragma HLS resource variable=v14 core=ram_s2p_bram

  #pragma HLS resource variable=v15 core=ram_s2p_bram

  int8_t v16[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};	// L5
  int8_t v17[1][512];	// L7
  #pragma HLS resource variable=v17 core=ram_s2p_bram

  int8_t v18[1][512][1][1];	// L8
  #pragma HLS resource variable=v18 core=ram_s2p_bram

  int8_t v19[1][512][1][1];	// L9
  #pragma HLS resource variable=v19 core=ram_s2p_bram

  int8_t v20[1][512][1][1];	// L10
  #pragma HLS resource variable=v20 core=ram_s2p_bram

  int8_t v21[1][512][4][4];	// L11
  #pragma HLS resource variable=v21 core=ram_s2p_bram

  int8_t v22[1][512][2][2];	// L12
  #pragma HLS resource variable=v22 core=ram_s2p_bram

  int8_t v23[1][512][2][2];	// L13
  #pragma HLS resource variable=v23 core=ram_s2p_bram

  int8_t v24[1][512][4][4];	// L14
  #pragma HLS resource variable=v24 core=ram_s2p_bram

  int8_t v25[1][512][2][2];	// L15
  #pragma HLS resource variable=v25 core=ram_s2p_bram

  int8_t v26[1][512][2][2];	// L16
  #pragma HLS resource variable=v26 core=ram_s2p_bram

  int8_t v27[1][512][4][4];	// L17
  #pragma HLS resource variable=v27 core=ram_s2p_bram

  int8_t v28[1][512][2][2];	// L18
  #pragma HLS resource variable=v28 core=ram_s2p_bram

  int8_t v29[1][512][2][2];	// L19
  #pragma HLS resource variable=v29 core=ram_s2p_bram

  int8_t v30[1][512][6][6];	// L20
  #pragma HLS resource variable=v30 core=ram_s2p_bram

  int8_t v31[1][512][4][4];	// L21
  #pragma HLS resource variable=v31 core=ram_s2p_bram

  int8_t v32[1][512][4][4];	// L22
  #pragma HLS resource variable=v32 core=ram_s2p_bram

  int8_t v33[1][512][6][6];	// L23
  #pragma HLS resource variable=v33 core=ram_s2p_bram

  int8_t v34[1][512][4][4];	// L24
  #pragma HLS resource variable=v34 core=ram_s2p_bram

  int8_t v35[1][512][4][4];	// L25
  #pragma HLS resource variable=v35 core=ram_s2p_bram

  int8_t v36[1][256][6][6];	// L26
  #pragma HLS resource variable=v36 core=ram_s2p_bram

  int8_t v37[1][256][4][4];	// L27
  #pragma HLS resource variable=v37 core=ram_s2p_bram

  int8_t v38[1][256][4][4];	// L28
  #pragma HLS resource variable=v38 core=ram_s2p_bram

  int8_t v39[1][256][10][10];	// L29
  #pragma HLS resource variable=v39 core=ram_s2p_bram

  int8_t v40[1][256][8][8];	// L30
  #pragma HLS resource variable=v40 core=ram_s2p_bram

  int8_t v41[1][256][8][8];	// L31
  #pragma HLS resource variable=v41 core=ram_s2p_bram

  int8_t v42[1][256][10][10];	// L32
  #pragma HLS resource variable=v42 core=ram_s2p_bram

  int8_t v43[1][256][8][8];	// L33
  #pragma HLS resource variable=v43 core=ram_s2p_bram

  int8_t v44[1][256][8][8];	// L34
  #pragma HLS resource variable=v44 core=ram_s2p_bram

  int8_t v45[1][128][10][10];	// L35
  #pragma HLS resource variable=v45 core=ram_s2p_bram

  int8_t v46[1][128][8][8];	// L36
  #pragma HLS resource variable=v46 core=ram_s2p_bram

  int8_t v47[1][128][8][8];	// L37
  #pragma HLS resource variable=v47 core=ram_s2p_bram

  int8_t v48[1][128][18][18];	// L38
  #pragma HLS resource variable=v48 core=ram_s2p_bram

  int8_t v49[1][128][16][16];	// L39
  #pragma HLS resource variable=v49 core=ram_s2p_bram

  int8_t v50[1][128][16][16];	// L40
  #pragma HLS resource variable=v50 core=ram_s2p_bram

  int8_t v51[1][64][18][18];	// L41
  #pragma HLS resource variable=v51 core=ram_s2p_bram

  int8_t v52[1][64][16][16];	// L42
  #pragma HLS resource variable=v52 core=ram_s2p_bram

  int8_t v53[1][64][16][16];	// L43
  #pragma HLS resource variable=v53 core=ram_s2p_bram

  int8_t v54[1][64][34][34];	// L44
  #pragma HLS resource variable=v54 core=ram_s2p_bram

  int8_t v55[1][64][32][32];	// L45
  #pragma HLS resource variable=v55 core=ram_s2p_bram

  int8_t v56[1][64][32][32];	// L46
  #pragma HLS resource variable=v56 core=ram_s2p_bram

  int8_t v57[1][3][34][34];	// L47
  #pragma HLS resource variable=v57 core=ram_s2p_bram

  for (int v58 = 0; v58 < 3; v58 += 1) {	// L48
    for (int v59 = 0; v59 < 34; v59 += 1) {	// L49
      for (int v60 = 0; v60 < 34; v60 += 1) {	// L50
        v57[0][v58][v59][v60] = 0;	// L51
      }
    }
  }
  for (int v61 = 0; v61 < 3; v61 += 1) {	// L55
    for (int v62 = 0; v62 < 32; v62 += 1) {	// L56
      for (int v63 = 0; v63 < 32; v63 += 1) {	// L57
        int8_t v64 = v0[0][v61][v62][v63];	// L58
        v57[0][v61][(v62 + 1)][(v63 + 1)] = v64;	// L59
      }
    }
  }
  for (int v65 = 0; v65 < 64; v65 += 1) {	// L63
    for (int v66 = 0; v66 < 32; v66 += 1) {	// L64
      for (int v67 = 0; v67 < 32; v67 += 1) {	// L65
        v56[0][v65][v66][v67] = 0;	// L66
        for (int v68 = 0; v68 < 3; v68 += 1) {	// L67
          for (int v69 = 0; v69 < 3; v69 += 1) {	// L68
            for (int v70 = 0; v70 < 3; v70 += 1) {	// L69
              int8_t v71 = v57[0][v68][(v66 + v69)][(v67 + v70)];	// L70
              int8_t v72 = v1[v65][v68][v69][v70];	// L71
              int8_t v73 = v56[0][v65][v66][v67];	// L72
              int16_t v74 = v71;	// L73
              int16_t v75 = v72;	// L74
              int32_t v76 = v74 * v75;	// L75
              int32_t v77 = v73;	// L76
              int32_t v78 = v77 + v76;	// L77
              int8_t v79 = v78;	// L78
              v56[0][v65][v66][v67] = v79;	// L79
            }
          }
        }
      }
    }
  }
  for (int v80 = 0; v80 < 64; v80 += 1) {	// L86
    for (int v81 = 0; v81 < 32; v81 += 1) {	// L87
      for (int v82 = 0; v82 < 32; v82 += 1) {	// L88
        int8_t v83 = v56[0][v80][v81][v82];	// L89
        bool v84 = v83 < 0;	// L90
        int8_t v85 = v84 ? (int8_t)0 : (int8_t)v83;	// L91
        v55[0][v80][v81][v82] = v85;	// L92
      }
    }
  }
  for (int v86 = 0; v86 < 64; v86 += 1) {	// L96
    for (int v87 = 0; v87 < 34; v87 += 1) {	// L97
      for (int v88 = 0; v88 < 34; v88 += 1) {	// L98
        v54[0][v86][v87][v88] = 0;	// L99
      }
    }
  }
  for (int v89 = 0; v89 < 64; v89 += 1) {	// L103
    for (int v90 = 0; v90 < 32; v90 += 1) {	// L104
      for (int v91 = 0; v91 < 32; v91 += 1) {	// L105
        int8_t v92 = v55[0][v89][v90][v91];	// L106
        v54[0][v89][(v90 + 1)][(v91 + 1)] = v92;	// L107
      }
    }
  }
  for (int v93 = 0; v93 < 64; v93 += 1) {	// L111
    for (int v94 = 0; v94 < 16; v94 += 1) {	// L112
      for (int v95 = 0; v95 < 16; v95 += 1) {	// L113
        v53[0][v93][v94][v95] = 0;	// L114
        for (int v96 = 0; v96 < 64; v96 += 1) {	// L115
          for (int v97 = 0; v97 < 3; v97 += 1) {	// L116
            for (int v98 = 0; v98 < 3; v98 += 1) {	// L117
              int8_t v99 = v54[0][v96][((v94 * 2) + v97)][((v95 * 2) + v98)];	// L118
              int8_t v100 = v2[v93][v96][v97][v98];	// L119
              int8_t v101 = v53[0][v93][v94][v95];	// L120
              int16_t v102 = v99;	// L121
              int16_t v103 = v100;	// L122
              int32_t v104 = v102 * v103;	// L123
              int32_t v105 = v101;	// L124
              int32_t v106 = v105 + v104;	// L125
              int8_t v107 = v106;	// L126
              v53[0][v93][v94][v95] = v107;	// L127
            }
          }
        }
      }
    }
  }
  for (int v108 = 0; v108 < 64; v108 += 1) {	// L134
    for (int v109 = 0; v109 < 16; v109 += 1) {	// L135
      for (int v110 = 0; v110 < 16; v110 += 1) {	// L136
        int8_t v111 = v53[0][v108][v109][v110];	// L137
        bool v112 = v111 < 0;	// L138
        int8_t v113 = v112 ? (int8_t)0 : (int8_t)v111;	// L139
        v52[0][v108][v109][v110] = v113;	// L140
      }
    }
  }
  for (int v114 = 0; v114 < 64; v114 += 1) {	// L144
    for (int v115 = 0; v115 < 18; v115 += 1) {	// L145
      for (int v116 = 0; v116 < 18; v116 += 1) {	// L146
        v51[0][v114][v115][v116] = 0;	// L147
      }
    }
  }
  for (int v117 = 0; v117 < 64; v117 += 1) {	// L151
    for (int v118 = 0; v118 < 16; v118 += 1) {	// L152
      for (int v119 = 0; v119 < 16; v119 += 1) {	// L153
        int8_t v120 = v52[0][v117][v118][v119];	// L154
        v51[0][v117][(v118 + 1)][(v119 + 1)] = v120;	// L155
      }
    }
  }
  for (int v121 = 0; v121 < 128; v121 += 1) {	// L159
    for (int v122 = 0; v122 < 16; v122 += 1) {	// L160
      for (int v123 = 0; v123 < 16; v123 += 1) {	// L161
        v50[0][v121][v122][v123] = 0;	// L162
        for (int v124 = 0; v124 < 64; v124 += 1) {	// L163
          for (int v125 = 0; v125 < 3; v125 += 1) {	// L164
            for (int v126 = 0; v126 < 3; v126 += 1) {	// L165
              int8_t v127 = v51[0][v124][(v122 + v125)][(v123 + v126)];	// L166
              int8_t v128 = v3[v121][v124][v125][v126];	// L167
              int8_t v129 = v50[0][v121][v122][v123];	// L168
              int16_t v130 = v127;	// L169
              int16_t v131 = v128;	// L170
              int32_t v132 = v130 * v131;	// L171
              int32_t v133 = v129;	// L172
              int32_t v134 = v133 + v132;	// L173
              int8_t v135 = v134;	// L174
              v50[0][v121][v122][v123] = v135;	// L175
            }
          }
        }
      }
    }
  }
  for (int v136 = 0; v136 < 128; v136 += 1) {	// L182
    for (int v137 = 0; v137 < 16; v137 += 1) {	// L183
      for (int v138 = 0; v138 < 16; v138 += 1) {	// L184
        int8_t v139 = v50[0][v136][v137][v138];	// L185
        bool v140 = v139 < 0;	// L186
        int8_t v141 = v140 ? (int8_t)0 : (int8_t)v139;	// L187
        v49[0][v136][v137][v138] = v141;	// L188
      }
    }
  }
  for (int v142 = 0; v142 < 128; v142 += 1) {	// L192
    for (int v143 = 0; v143 < 18; v143 += 1) {	// L193
      for (int v144 = 0; v144 < 18; v144 += 1) {	// L194
        v48[0][v142][v143][v144] = 0;	// L195
      }
    }
  }
  for (int v145 = 0; v145 < 128; v145 += 1) {	// L199
    for (int v146 = 0; v146 < 16; v146 += 1) {	// L200
      for (int v147 = 0; v147 < 16; v147 += 1) {	// L201
        int8_t v148 = v49[0][v145][v146][v147];	// L202
        v48[0][v145][(v146 + 1)][(v147 + 1)] = v148;	// L203
      }
    }
  }
  for (int v149 = 0; v149 < 128; v149 += 1) {	// L207
    for (int v150 = 0; v150 < 8; v150 += 1) {	// L208
      for (int v151 = 0; v151 < 8; v151 += 1) {	// L209
        v47[0][v149][v150][v151] = 0;	// L210
        for (int v152 = 0; v152 < 128; v152 += 1) {	// L211
          for (int v153 = 0; v153 < 3; v153 += 1) {	// L212
            for (int v154 = 0; v154 < 3; v154 += 1) {	// L213
              int8_t v155 = v48[0][v152][((v150 * 2) + v153)][((v151 * 2) + v154)];	// L214
              int8_t v156 = v4[v149][v152][v153][v154];	// L215
              int8_t v157 = v47[0][v149][v150][v151];	// L216
              int16_t v158 = v155;	// L217
              int16_t v159 = v156;	// L218
              int32_t v160 = v158 * v159;	// L219
              int32_t v161 = v157;	// L220
              int32_t v162 = v161 + v160;	// L221
              int8_t v163 = v162;	// L222
              v47[0][v149][v150][v151] = v163;	// L223
            }
          }
        }
      }
    }
  }
  for (int v164 = 0; v164 < 128; v164 += 1) {	// L230
    for (int v165 = 0; v165 < 8; v165 += 1) {	// L231
      for (int v166 = 0; v166 < 8; v166 += 1) {	// L232
        int8_t v167 = v47[0][v164][v165][v166];	// L233
        bool v168 = v167 < 0;	// L234
        int8_t v169 = v168 ? (int8_t)0 : (int8_t)v167;	// L235
        v46[0][v164][v165][v166] = v169;	// L236
      }
    }
  }
  for (int v170 = 0; v170 < 128; v170 += 1) {	// L240
    for (int v171 = 0; v171 < 10; v171 += 1) {	// L241
      for (int v172 = 0; v172 < 10; v172 += 1) {	// L242
        v45[0][v170][v171][v172] = 0;	// L243
      }
    }
  }
  for (int v173 = 0; v173 < 128; v173 += 1) {	// L247
    for (int v174 = 0; v174 < 8; v174 += 1) {	// L248
      for (int v175 = 0; v175 < 8; v175 += 1) {	// L249
        int8_t v176 = v46[0][v173][v174][v175];	// L250
        v45[0][v173][(v174 + 1)][(v175 + 1)] = v176;	// L251
      }
    }
  }
  for (int v177 = 0; v177 < 256; v177 += 1) {	// L255
    for (int v178 = 0; v178 < 8; v178 += 1) {	// L256
      for (int v179 = 0; v179 < 8; v179 += 1) {	// L257
        v44[0][v177][v178][v179] = 0;	// L258
        for (int v180 = 0; v180 < 128; v180 += 1) {	// L259
          for (int v181 = 0; v181 < 3; v181 += 1) {	// L260
            for (int v182 = 0; v182 < 3; v182 += 1) {	// L261
              int8_t v183 = v45[0][v180][(v178 + v181)][(v179 + v182)];	// L262
              int8_t v184 = v5[v177][v180][v181][v182];	// L263
              int8_t v185 = v44[0][v177][v178][v179];	// L264
              int16_t v186 = v183;	// L265
              int16_t v187 = v184;	// L266
              int32_t v188 = v186 * v187;	// L267
              int32_t v189 = v185;	// L268
              int32_t v190 = v189 + v188;	// L269
              int8_t v191 = v190;	// L270
              v44[0][v177][v178][v179] = v191;	// L271
            }
          }
        }
      }
    }
  }
  for (int v192 = 0; v192 < 256; v192 += 1) {	// L278
    for (int v193 = 0; v193 < 8; v193 += 1) {	// L279
      for (int v194 = 0; v194 < 8; v194 += 1) {	// L280
        int8_t v195 = v44[0][v192][v193][v194];	// L281
        bool v196 = v195 < 0;	// L282
        int8_t v197 = v196 ? (int8_t)0 : (int8_t)v195;	// L283
        v43[0][v192][v193][v194] = v197;	// L284
      }
    }
  }
  for (int v198 = 0; v198 < 256; v198 += 1) {	// L288
    for (int v199 = 0; v199 < 10; v199 += 1) {	// L289
      for (int v200 = 0; v200 < 10; v200 += 1) {	// L290
        v42[0][v198][v199][v200] = 0;	// L291
      }
    }
  }
  for (int v201 = 0; v201 < 256; v201 += 1) {	// L295
    for (int v202 = 0; v202 < 8; v202 += 1) {	// L296
      for (int v203 = 0; v203 < 8; v203 += 1) {	// L297
        int8_t v204 = v43[0][v201][v202][v203];	// L298
        v42[0][v201][(v202 + 1)][(v203 + 1)] = v204;	// L299
      }
    }
  }
  for (int v205 = 0; v205 < 256; v205 += 1) {	// L303
    for (int v206 = 0; v206 < 8; v206 += 1) {	// L304
      for (int v207 = 0; v207 < 8; v207 += 1) {	// L305
        v41[0][v205][v206][v207] = 0;	// L306
        for (int v208 = 0; v208 < 256; v208 += 1) {	// L307
          for (int v209 = 0; v209 < 3; v209 += 1) {	// L308
            for (int v210 = 0; v210 < 3; v210 += 1) {	// L309
              int8_t v211 = v42[0][v208][(v206 + v209)][(v207 + v210)];	// L310
              int8_t v212 = v6[v205][v208][v209][v210];	// L311
              int8_t v213 = v41[0][v205][v206][v207];	// L312
              int16_t v214 = v211;	// L313
              int16_t v215 = v212;	// L314
              int32_t v216 = v214 * v215;	// L315
              int32_t v217 = v213;	// L316
              int32_t v218 = v217 + v216;	// L317
              int8_t v219 = v218;	// L318
              v41[0][v205][v206][v207] = v219;	// L319
            }
          }
        }
      }
    }
  }
  for (int v220 = 0; v220 < 256; v220 += 1) {	// L326
    for (int v221 = 0; v221 < 8; v221 += 1) {	// L327
      for (int v222 = 0; v222 < 8; v222 += 1) {	// L328
        int8_t v223 = v41[0][v220][v221][v222];	// L329
        bool v224 = v223 < 0;	// L330
        int8_t v225 = v224 ? (int8_t)0 : (int8_t)v223;	// L331
        v40[0][v220][v221][v222] = v225;	// L332
      }
    }
  }
  for (int v226 = 0; v226 < 256; v226 += 1) {	// L336
    for (int v227 = 0; v227 < 10; v227 += 1) {	// L337
      for (int v228 = 0; v228 < 10; v228 += 1) {	// L338
        v39[0][v226][v227][v228] = 0;	// L339
      }
    }
  }
  for (int v229 = 0; v229 < 256; v229 += 1) {	// L343
    for (int v230 = 0; v230 < 8; v230 += 1) {	// L344
      for (int v231 = 0; v231 < 8; v231 += 1) {	// L345
        int8_t v232 = v40[0][v229][v230][v231];	// L346
        v39[0][v229][(v230 + 1)][(v231 + 1)] = v232;	// L347
      }
    }
  }
  for (int v233 = 0; v233 < 256; v233 += 1) {	// L351
    for (int v234 = 0; v234 < 4; v234 += 1) {	// L352
      for (int v235 = 0; v235 < 4; v235 += 1) {	// L353
        v38[0][v233][v234][v235] = 0;	// L354
        for (int v236 = 0; v236 < 256; v236 += 1) {	// L355
          for (int v237 = 0; v237 < 3; v237 += 1) {	// L356
            for (int v238 = 0; v238 < 3; v238 += 1) {	// L357
              int8_t v239 = v39[0][v236][((v234 * 2) + v237)][((v235 * 2) + v238)];	// L358
              int8_t v240 = v7[v233][v236][v237][v238];	// L359
              int8_t v241 = v38[0][v233][v234][v235];	// L360
              int16_t v242 = v239;	// L361
              int16_t v243 = v240;	// L362
              int32_t v244 = v242 * v243;	// L363
              int32_t v245 = v241;	// L364
              int32_t v246 = v245 + v244;	// L365
              int8_t v247 = v246;	// L366
              v38[0][v233][v234][v235] = v247;	// L367
            }
          }
        }
      }
    }
  }
  for (int v248 = 0; v248 < 256; v248 += 1) {	// L374
    for (int v249 = 0; v249 < 4; v249 += 1) {	// L375
      for (int v250 = 0; v250 < 4; v250 += 1) {	// L376
        int8_t v251 = v38[0][v248][v249][v250];	// L377
        bool v252 = v251 < 0;	// L378
        int8_t v253 = v252 ? (int8_t)0 : (int8_t)v251;	// L379
        v37[0][v248][v249][v250] = v253;	// L380
      }
    }
  }
  for (int v254 = 0; v254 < 256; v254 += 1) {	// L384
    for (int v255 = 0; v255 < 6; v255 += 1) {	// L385
      for (int v256 = 0; v256 < 6; v256 += 1) {	// L386
        v36[0][v254][v255][v256] = 0;	// L387
      }
    }
  }
  for (int v257 = 0; v257 < 256; v257 += 1) {	// L391
    for (int v258 = 0; v258 < 4; v258 += 1) {	// L392
      for (int v259 = 0; v259 < 4; v259 += 1) {	// L393
        int8_t v260 = v37[0][v257][v258][v259];	// L394
        v36[0][v257][(v258 + 1)][(v259 + 1)] = v260;	// L395
      }
    }
  }
  for (int v261 = 0; v261 < 512; v261 += 1) {	// L399
    for (int v262 = 0; v262 < 4; v262 += 1) {	// L400
      for (int v263 = 0; v263 < 4; v263 += 1) {	// L401
        v35[0][v261][v262][v263] = 0;	// L402
        for (int v264 = 0; v264 < 256; v264 += 1) {	// L403
          for (int v265 = 0; v265 < 3; v265 += 1) {	// L404
            for (int v266 = 0; v266 < 3; v266 += 1) {	// L405
              int8_t v267 = v36[0][v264][(v262 + v265)][(v263 + v266)];	// L406
              int8_t v268 = v8[v261][v264][v265][v266];	// L407
              int8_t v269 = v35[0][v261][v262][v263];	// L408
              int16_t v270 = v267;	// L409
              int16_t v271 = v268;	// L410
              int32_t v272 = v270 * v271;	// L411
              int32_t v273 = v269;	// L412
              int32_t v274 = v273 + v272;	// L413
              int8_t v275 = v274;	// L414
              v35[0][v261][v262][v263] = v275;	// L415
            }
          }
        }
      }
    }
  }
  for (int v276 = 0; v276 < 512; v276 += 1) {	// L422
    for (int v277 = 0; v277 < 4; v277 += 1) {	// L423
      for (int v278 = 0; v278 < 4; v278 += 1) {	// L424
        int8_t v279 = v35[0][v276][v277][v278];	// L425
        bool v280 = v279 < 0;	// L426
        int8_t v281 = v280 ? (int8_t)0 : (int8_t)v279;	// L427
        v34[0][v276][v277][v278] = v281;	// L428
      }
    }
  }
  for (int v282 = 0; v282 < 512; v282 += 1) {	// L432
    for (int v283 = 0; v283 < 6; v283 += 1) {	// L433
      for (int v284 = 0; v284 < 6; v284 += 1) {	// L434
        v33[0][v282][v283][v284] = 0;	// L435
      }
    }
  }
  for (int v285 = 0; v285 < 512; v285 += 1) {	// L439
    for (int v286 = 0; v286 < 4; v286 += 1) {	// L440
      for (int v287 = 0; v287 < 4; v287 += 1) {	// L441
        int8_t v288 = v34[0][v285][v286][v287];	// L442
        v33[0][v285][(v286 + 1)][(v287 + 1)] = v288;	// L443
      }
    }
  }
  for (int v289 = 0; v289 < 512; v289 += 1) {	// L447
    for (int v290 = 0; v290 < 4; v290 += 1) {	// L448
      for (int v291 = 0; v291 < 4; v291 += 1) {	// L449
        v32[0][v289][v290][v291] = 0;	// L450
        for (int v292 = 0; v292 < 512; v292 += 1) {	// L451
          for (int v293 = 0; v293 < 3; v293 += 1) {	// L452
            for (int v294 = 0; v294 < 3; v294 += 1) {	// L453
              int8_t v295 = v33[0][v292][(v290 + v293)][(v291 + v294)];	// L454
              int8_t v296 = v9[v289][v292][v293][v294];	// L455
              int8_t v297 = v32[0][v289][v290][v291];	// L456
              int16_t v298 = v295;	// L457
              int16_t v299 = v296;	// L458
              int32_t v300 = v298 * v299;	// L459
              int32_t v301 = v297;	// L460
              int32_t v302 = v301 + v300;	// L461
              int8_t v303 = v302;	// L462
              v32[0][v289][v290][v291] = v303;	// L463
            }
          }
        }
      }
    }
  }
  for (int v304 = 0; v304 < 512; v304 += 1) {	// L470
    for (int v305 = 0; v305 < 4; v305 += 1) {	// L471
      for (int v306 = 0; v306 < 4; v306 += 1) {	// L472
        int8_t v307 = v32[0][v304][v305][v306];	// L473
        bool v308 = v307 < 0;	// L474
        int8_t v309 = v308 ? (int8_t)0 : (int8_t)v307;	// L475
        v31[0][v304][v305][v306] = v309;	// L476
      }
    }
  }
  for (int v310 = 0; v310 < 512; v310 += 1) {	// L480
    for (int v311 = 0; v311 < 6; v311 += 1) {	// L481
      for (int v312 = 0; v312 < 6; v312 += 1) {	// L482
        v30[0][v310][v311][v312] = 0;	// L483
      }
    }
  }
  for (int v313 = 0; v313 < 512; v313 += 1) {	// L487
    for (int v314 = 0; v314 < 4; v314 += 1) {	// L488
      for (int v315 = 0; v315 < 4; v315 += 1) {	// L489
        int8_t v316 = v31[0][v313][v314][v315];	// L490
        v30[0][v313][(v314 + 1)][(v315 + 1)] = v316;	// L491
      }
    }
  }
  for (int v317 = 0; v317 < 512; v317 += 1) {	// L495
    for (int v318 = 0; v318 < 2; v318 += 1) {	// L496
      for (int v319 = 0; v319 < 2; v319 += 1) {	// L497
        v29[0][v317][v318][v319] = 0;	// L498
        for (int v320 = 0; v320 < 512; v320 += 1) {	// L499
          for (int v321 = 0; v321 < 3; v321 += 1) {	// L500
            for (int v322 = 0; v322 < 3; v322 += 1) {	// L501
              int8_t v323 = v30[0][v320][((v318 * 2) + v321)][((v319 * 2) + v322)];	// L502
              int8_t v324 = v10[v317][v320][v321][v322];	// L503
              int8_t v325 = v29[0][v317][v318][v319];	// L504
              int16_t v326 = v323;	// L505
              int16_t v327 = v324;	// L506
              int32_t v328 = v326 * v327;	// L507
              int32_t v329 = v325;	// L508
              int32_t v330 = v329 + v328;	// L509
              int8_t v331 = v330;	// L510
              v29[0][v317][v318][v319] = v331;	// L511
            }
          }
        }
      }
    }
  }
  for (int v332 = 0; v332 < 512; v332 += 1) {	// L518
    for (int v333 = 0; v333 < 2; v333 += 1) {	// L519
      for (int v334 = 0; v334 < 2; v334 += 1) {	// L520
        int8_t v335 = v29[0][v332][v333][v334];	// L521
        bool v336 = v335 < 0;	// L522
        int8_t v337 = v336 ? (int8_t)0 : (int8_t)v335;	// L523
        v28[0][v332][v333][v334] = v337;	// L524
      }
    }
  }
  for (int v338 = 0; v338 < 512; v338 += 1) {	// L528
    for (int v339 = 0; v339 < 4; v339 += 1) {	// L529
      for (int v340 = 0; v340 < 4; v340 += 1) {	// L530
        v27[0][v338][v339][v340] = 0;	// L531
      }
    }
  }
  for (int v341 = 0; v341 < 512; v341 += 1) {	// L535
    for (int v342 = 0; v342 < 2; v342 += 1) {	// L536
      for (int v343 = 0; v343 < 2; v343 += 1) {	// L537
        int8_t v344 = v28[0][v341][v342][v343];	// L538
        v27[0][v341][(v342 + 1)][(v343 + 1)] = v344;	// L539
      }
    }
  }
  for (int v345 = 0; v345 < 512; v345 += 1) {	// L543
    for (int v346 = 0; v346 < 2; v346 += 1) {	// L544
      for (int v347 = 0; v347 < 2; v347 += 1) {	// L545
        v26[0][v345][v346][v347] = 0;	// L546
        for (int v348 = 0; v348 < 512; v348 += 1) {	// L547
          for (int v349 = 0; v349 < 3; v349 += 1) {	// L548
            for (int v350 = 0; v350 < 3; v350 += 1) {	// L549
              int8_t v351 = v27[0][v348][(v346 + v349)][(v347 + v350)];	// L550
              int8_t v352 = v11[v345][v348][v349][v350];	// L551
              int8_t v353 = v26[0][v345][v346][v347];	// L552
              int16_t v354 = v351;	// L553
              int16_t v355 = v352;	// L554
              int32_t v356 = v354 * v355;	// L555
              int32_t v357 = v353;	// L556
              int32_t v358 = v357 + v356;	// L557
              int8_t v359 = v358;	// L558
              v26[0][v345][v346][v347] = v359;	// L559
            }
          }
        }
      }
    }
  }
  for (int v360 = 0; v360 < 512; v360 += 1) {	// L566
    for (int v361 = 0; v361 < 2; v361 += 1) {	// L567
      for (int v362 = 0; v362 < 2; v362 += 1) {	// L568
        int8_t v363 = v26[0][v360][v361][v362];	// L569
        bool v364 = v363 < 0;	// L570
        int8_t v365 = v364 ? (int8_t)0 : (int8_t)v363;	// L571
        v25[0][v360][v361][v362] = v365;	// L572
      }
    }
  }
  for (int v366 = 0; v366 < 512; v366 += 1) {	// L576
    for (int v367 = 0; v367 < 4; v367 += 1) {	// L577
      for (int v368 = 0; v368 < 4; v368 += 1) {	// L578
        v24[0][v366][v367][v368] = 0;	// L579
      }
    }
  }
  for (int v369 = 0; v369 < 512; v369 += 1) {	// L583
    for (int v370 = 0; v370 < 2; v370 += 1) {	// L584
      for (int v371 = 0; v371 < 2; v371 += 1) {	// L585
        int8_t v372 = v25[0][v369][v370][v371];	// L586
        v24[0][v369][(v370 + 1)][(v371 + 1)] = v372;	// L587
      }
    }
  }
  for (int v373 = 0; v373 < 512; v373 += 1) {	// L591
    for (int v374 = 0; v374 < 2; v374 += 1) {	// L592
      for (int v375 = 0; v375 < 2; v375 += 1) {	// L593
        v23[0][v373][v374][v375] = 0;	// L594
        for (int v376 = 0; v376 < 512; v376 += 1) {	// L595
          for (int v377 = 0; v377 < 3; v377 += 1) {	// L596
            for (int v378 = 0; v378 < 3; v378 += 1) {	// L597
              int8_t v379 = v24[0][v376][(v374 + v377)][(v375 + v378)];	// L598
              int8_t v380 = v12[v373][v376][v377][v378];	// L599
              int8_t v381 = v23[0][v373][v374][v375];	// L600
              int16_t v382 = v379;	// L601
              int16_t v383 = v380;	// L602
              int32_t v384 = v382 * v383;	// L603
              int32_t v385 = v381;	// L604
              int32_t v386 = v385 + v384;	// L605
              int8_t v387 = v386;	// L606
              v23[0][v373][v374][v375] = v387;	// L607
            }
          }
        }
      }
    }
  }
  for (int v388 = 0; v388 < 512; v388 += 1) {	// L614
    for (int v389 = 0; v389 < 2; v389 += 1) {	// L615
      for (int v390 = 0; v390 < 2; v390 += 1) {	// L616
        int8_t v391 = v23[0][v388][v389][v390];	// L617
        bool v392 = v391 < 0;	// L618
        int8_t v393 = v392 ? (int8_t)0 : (int8_t)v391;	// L619
        v22[0][v388][v389][v390] = v393;	// L620
      }
    }
  }
  for (int v394 = 0; v394 < 512; v394 += 1) {	// L624
    for (int v395 = 0; v395 < 4; v395 += 1) {	// L625
      for (int v396 = 0; v396 < 4; v396 += 1) {	// L626
        v21[0][v394][v395][v396] = 0;	// L627
      }
    }
  }
  for (int v397 = 0; v397 < 512; v397 += 1) {	// L631
    for (int v398 = 0; v398 < 2; v398 += 1) {	// L632
      for (int v399 = 0; v399 < 2; v399 += 1) {	// L633
        int8_t v400 = v22[0][v397][v398][v399];	// L634
        v21[0][v397][(v398 + 1)][(v399 + 1)] = v400;	// L635
      }
    }
  }
  for (int v401 = 0; v401 < 512; v401 += 1) {	// L639
    v20[0][v401][0][0] = 0;	// L640
    for (int v402 = 0; v402 < 512; v402 += 1) {	// L641
      for (int v403 = 0; v403 < 3; v403 += 1) {	// L642
        for (int v404 = 0; v404 < 3; v404 += 1) {	// L643
          int8_t v405 = v21[0][v402][v403][v404];	// L644
          int8_t v406 = v13[v401][v402][v403][v404];	// L645
          int8_t v407 = v20[0][v401][0][0];	// L646
          int16_t v408 = v405;	// L647
          int16_t v409 = v406;	// L648
          int32_t v410 = v408 * v409;	// L649
          int32_t v411 = v407;	// L650
          int32_t v412 = v411 + v410;	// L651
          int8_t v413 = v412;	// L652
          v20[0][v401][0][0] = v413;	// L653
        }
      }
    }
  }
  for (int v414 = 0; v414 < 512; v414 += 1) {	// L658
    int8_t v415 = v20[0][v414][0][0];	// L659
    bool v416 = v415 < 0;	// L660
    int8_t v417 = v416 ? (int8_t)0 : (int8_t)v415;	// L661
    v19[0][v414][0][0] = v417;	// L662
  }
  for (int v418 = 0; v418 < 512; v418 += 1) {	// L664
    v18[0][v418][0][0] = 0;	// L665
  }
  for (int v419 = 0; v419 < 512; v419 += 1) {	// L667
    int8_t v420 = v19[0][v419][0][0];	// L668
    int8_t v421 = v18[0][v419][0][0];	// L669
    int32_t v422 = v421;	// L670
    int32_t v423 = v420;	// L671
    int32_t v424 = v422 + v423;	// L672
    int8_t v425 = v424;	// L673
    v18[0][v419][0][0] = v425;	// L674
  }
  for (int v426 = 0; v426 < 512; v426 += 1) {	// L676
    int8_t v427 = v18[0][v426][0][0];	// L677
    v18[0][v426][0][0] = v427;	// L678
  }
  for (int v428 = 0; v428 < 512; v428 += 1) {	// L680
    int8_t v429 = v18[0][v428][0][0];	// L681
    v17[0][v428] = v429;	// L682
  }
  #pragma HLS resource variable=v16 core=ram_s2p_bram

  for (int v431 = 0; v431 < 10; v431 += 1) {	// L685
    v15[0][v431] = 0;	// L686
    for (int v432 = 0; v432 < 512; v432 += 1) {	// L687
      int8_t v433 = v17[0][v432];	// L688
      int8_t v434 = v14[v431][v432];	// L689
      int8_t v435 = v15[0][v431];	// L690
      int16_t v436 = v433;	// L691
      int16_t v437 = v434;	// L692
      int32_t v438 = v436 * v437;	// L693
      int32_t v439 = v435;	// L694
      int32_t v440 = v439 + v438;	// L695
      int8_t v441 = v440;	// L696
      v15[0][v431] = v441;	// L697
    }
    int8_t v442 = v15[0][v431];	// L699
    int16_t v443 = 1;	// L700
    int16_t v444 = v442;	// L701
    int32_t v445 = v443 * v444;	// L702
    int8_t v446 = v16[v431];	// L703
    int16_t v447 = 1;	// L704
    int16_t v448 = v446;	// L705
    int32_t v449 = v447 * v448;	// L706
    int32_t v450 = v445 + v449;	// L707
    int8_t v451 = v450;	// L708
    v15[0][v431] = v451;	// L709
  }
}

