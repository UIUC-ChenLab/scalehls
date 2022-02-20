
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
  int8_t v3[64][64][3][3],
  int8_t v4[64][64][3][3],
  int8_t v5[64][64][3][3],
  int8_t v6[128][64][3][3],
  int8_t v7[128][128][3][3],
  int8_t v8[128][64][1][1],
  int8_t v9[128][128][3][3],
  int8_t v10[128][128][3][3],
  int8_t v11[256][128][3][3],
  int8_t v12[256][256][3][3],
  int8_t v13[256][128][1][1],
  int8_t v14[256][256][3][3],
  int8_t v15[256][256][3][3],
  int8_t v16[512][256][3][3],
  int8_t v17[512][512][3][3],
  int8_t v18[512][256][1][1],
  int8_t v19[512][512][3][3],
  int8_t v20[512][512][3][3],
  int8_t v21[10][512],
  int8_t v22[1][10]
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
  #pragma HLS interface bram port=v16
  #pragma HLS interface bram port=v17
  #pragma HLS interface bram port=v18
  #pragma HLS interface bram port=v19
  #pragma HLS interface bram port=v20
  #pragma HLS interface bram port=v21
  #pragma HLS interface bram port=v22

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

  #pragma HLS resource variable=v16 core=ram_s2p_bram

  #pragma HLS resource variable=v17 core=ram_s2p_bram

  #pragma HLS resource variable=v18 core=ram_s2p_bram

  #pragma HLS resource variable=v19 core=ram_s2p_bram

  #pragma HLS resource variable=v20 core=ram_s2p_bram

  #pragma HLS resource variable=v21 core=ram_s2p_bram

  #pragma HLS resource variable=v22 core=ram_s2p_bram

  int8_t v23[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};	// L6
  int8_t v24[1][512];	// L8
  #pragma HLS resource variable=v24 core=ram_s2p_bram

  int8_t v25[1][512][1][1];	// L9
  #pragma HLS resource variable=v25 core=ram_s2p_bram

  int8_t v26[1][512][4][4];	// L10
  #pragma HLS resource variable=v26 core=ram_s2p_bram

  int8_t v27[1][512][4][4];	// L11
  #pragma HLS resource variable=v27 core=ram_s2p_bram

  int8_t v28[1][512][4][4];	// L12
  #pragma HLS resource variable=v28 core=ram_s2p_bram

  int8_t v29[1][512][6][6];	// L13
  #pragma HLS resource variable=v29 core=ram_s2p_bram

  int8_t v30[1][512][4][4];	// L14
  #pragma HLS resource variable=v30 core=ram_s2p_bram

  int8_t v31[1][512][4][4];	// L15
  #pragma HLS resource variable=v31 core=ram_s2p_bram

  int8_t v32[1][512][6][6];	// L16
  #pragma HLS resource variable=v32 core=ram_s2p_bram

  int8_t v33[1][512][4][4];	// L17
  #pragma HLS resource variable=v33 core=ram_s2p_bram

  int8_t v34[1][512][4][4];	// L18
  #pragma HLS resource variable=v34 core=ram_s2p_bram

  int8_t v35[1][512][4][4];	// L19
  #pragma HLS resource variable=v35 core=ram_s2p_bram

  int8_t v36[1][512][4][4];	// L20
  #pragma HLS resource variable=v36 core=ram_s2p_bram

  int8_t v37[1][512][6][6];	// L21
  #pragma HLS resource variable=v37 core=ram_s2p_bram

  int8_t v38[1][512][4][4];	// L22
  #pragma HLS resource variable=v38 core=ram_s2p_bram

  int8_t v39[1][512][4][4];	// L23
  #pragma HLS resource variable=v39 core=ram_s2p_bram

  int8_t v40[1][256][10][10];	// L24
  #pragma HLS resource variable=v40 core=ram_s2p_bram

  int8_t v41[1][256][8][8];	// L25
  #pragma HLS resource variable=v41 core=ram_s2p_bram

  int8_t v42[1][256][8][8];	// L26
  #pragma HLS resource variable=v42 core=ram_s2p_bram

  int8_t v43[1][256][8][8];	// L27
  #pragma HLS resource variable=v43 core=ram_s2p_bram

  int8_t v44[1][256][10][10];	// L28
  #pragma HLS resource variable=v44 core=ram_s2p_bram

  int8_t v45[1][256][8][8];	// L29
  #pragma HLS resource variable=v45 core=ram_s2p_bram

  int8_t v46[1][256][8][8];	// L30
  #pragma HLS resource variable=v46 core=ram_s2p_bram

  int8_t v47[1][256][10][10];	// L31
  #pragma HLS resource variable=v47 core=ram_s2p_bram

  int8_t v48[1][256][8][8];	// L32
  #pragma HLS resource variable=v48 core=ram_s2p_bram

  int8_t v49[1][256][8][8];	// L33
  #pragma HLS resource variable=v49 core=ram_s2p_bram

  int8_t v50[1][256][8][8];	// L34
  #pragma HLS resource variable=v50 core=ram_s2p_bram

  int8_t v51[1][256][8][8];	// L35
  #pragma HLS resource variable=v51 core=ram_s2p_bram

  int8_t v52[1][256][10][10];	// L36
  #pragma HLS resource variable=v52 core=ram_s2p_bram

  int8_t v53[1][256][8][8];	// L37
  #pragma HLS resource variable=v53 core=ram_s2p_bram

  int8_t v54[1][256][8][8];	// L38
  #pragma HLS resource variable=v54 core=ram_s2p_bram

  int8_t v55[1][128][18][18];	// L39
  #pragma HLS resource variable=v55 core=ram_s2p_bram

  int8_t v56[1][128][16][16];	// L40
  #pragma HLS resource variable=v56 core=ram_s2p_bram

  int8_t v57[1][128][16][16];	// L41
  #pragma HLS resource variable=v57 core=ram_s2p_bram

  int8_t v58[1][128][16][16];	// L42
  #pragma HLS resource variable=v58 core=ram_s2p_bram

  int8_t v59[1][128][18][18];	// L43
  #pragma HLS resource variable=v59 core=ram_s2p_bram

  int8_t v60[1][128][16][16];	// L44
  #pragma HLS resource variable=v60 core=ram_s2p_bram

  int8_t v61[1][128][16][16];	// L45
  #pragma HLS resource variable=v61 core=ram_s2p_bram

  int8_t v62[1][128][18][18];	// L46
  #pragma HLS resource variable=v62 core=ram_s2p_bram

  int8_t v63[1][128][16][16];	// L47
  #pragma HLS resource variable=v63 core=ram_s2p_bram

  int8_t v64[1][128][16][16];	// L48
  #pragma HLS resource variable=v64 core=ram_s2p_bram

  int8_t v65[1][128][16][16];	// L49
  #pragma HLS resource variable=v65 core=ram_s2p_bram

  int8_t v66[1][128][16][16];	// L50
  #pragma HLS resource variable=v66 core=ram_s2p_bram

  int8_t v67[1][128][18][18];	// L51
  #pragma HLS resource variable=v67 core=ram_s2p_bram

  int8_t v68[1][128][16][16];	// L52
  #pragma HLS resource variable=v68 core=ram_s2p_bram

  int8_t v69[1][128][16][16];	// L53
  #pragma HLS resource variable=v69 core=ram_s2p_bram

  int8_t v70[1][64][34][34];	// L54
  #pragma HLS resource variable=v70 core=ram_s2p_bram

  int8_t v71[1][64][32][32];	// L55
  #pragma HLS resource variable=v71 core=ram_s2p_bram

  int8_t v72[1][64][32][32];	// L56
  #pragma HLS resource variable=v72 core=ram_s2p_bram

  int8_t v73[1][64][32][32];	// L57
  #pragma HLS resource variable=v73 core=ram_s2p_bram

  int8_t v74[1][64][34][34];	// L58
  #pragma HLS resource variable=v74 core=ram_s2p_bram

  int8_t v75[1][64][32][32];	// L59
  #pragma HLS resource variable=v75 core=ram_s2p_bram

  int8_t v76[1][64][32][32];	// L60
  #pragma HLS resource variable=v76 core=ram_s2p_bram

  int8_t v77[1][64][34][34];	// L61
  #pragma HLS resource variable=v77 core=ram_s2p_bram

  int8_t v78[1][64][32][32];	// L62
  #pragma HLS resource variable=v78 core=ram_s2p_bram

  int8_t v79[1][64][32][32];	// L63
  #pragma HLS resource variable=v79 core=ram_s2p_bram

  int8_t v80[1][64][32][32];	// L64
  #pragma HLS resource variable=v80 core=ram_s2p_bram

  int8_t v81[1][64][34][34];	// L65
  #pragma HLS resource variable=v81 core=ram_s2p_bram

  int8_t v82[1][64][32][32];	// L66
  #pragma HLS resource variable=v82 core=ram_s2p_bram

  int8_t v83[1][64][32][32];	// L67
  #pragma HLS resource variable=v83 core=ram_s2p_bram

  int8_t v84[1][64][34][34];	// L68
  #pragma HLS resource variable=v84 core=ram_s2p_bram

  int8_t v85[1][64][32][32];	// L69
  #pragma HLS resource variable=v85 core=ram_s2p_bram

  int8_t v86[1][64][32][32];	// L70
  #pragma HLS resource variable=v86 core=ram_s2p_bram

  int8_t v87[1][3][34][34];	// L71
  #pragma HLS resource variable=v87 core=ram_s2p_bram

  for (int v88 = 0; v88 < 3; v88 += 1) {	// L72
    for (int v89 = 0; v89 < 34; v89 += 1) {	// L73
      for (int v90 = 0; v90 < 34; v90 += 1) {	// L74
        v87[0][v88][v89][v90] = 0;	// L75
      }
    }
  }
  for (int v91 = 0; v91 < 3; v91 += 1) {	// L79
    for (int v92 = 0; v92 < 32; v92 += 1) {	// L80
      for (int v93 = 0; v93 < 32; v93 += 1) {	// L81
        int8_t v94 = v0[0][v91][v92][v93];	// L82
        v87[0][v91][(v92 + 1)][(v93 + 1)] = v94;	// L83
      }
    }
  }
  for (int v95 = 0; v95 < 64; v95 += 1) {	// L87
    for (int v96 = 0; v96 < 32; v96 += 1) {	// L88
      for (int v97 = 0; v97 < 32; v97 += 1) {	// L89
        v86[0][v95][v96][v97] = 0;	// L90
        for (int v98 = 0; v98 < 3; v98 += 1) {	// L91
          for (int v99 = 0; v99 < 3; v99 += 1) {	// L92
            for (int v100 = 0; v100 < 3; v100 += 1) {	// L93
              int8_t v101 = v87[0][v98][(v96 + v99)][(v97 + v100)];	// L94
              int8_t v102 = v1[v95][v98][v99][v100];	// L95
              int8_t v103 = v86[0][v95][v96][v97];	// L96
              int16_t v104 = v101;	// L97
              int16_t v105 = v102;	// L98
              int32_t v106 = v104 * v105;	// L99
              int32_t v107 = v103;	// L100
              int32_t v108 = v107 + v106;	// L101
              int8_t v109 = v108;	// L102
              v86[0][v95][v96][v97] = v109;	// L103
            }
          }
        }
      }
    }
  }
  for (int v110 = 0; v110 < 64; v110 += 1) {	// L110
    for (int v111 = 0; v111 < 32; v111 += 1) {	// L111
      for (int v112 = 0; v112 < 32; v112 += 1) {	// L112
        int8_t v113 = v86[0][v110][v111][v112];	// L113
        bool v114 = v113 < 0;	// L114
        int8_t v115 = v114 ? (int8_t)0 : (int8_t)v113;	// L115
        v85[0][v110][v111][v112] = v115;	// L116
      }
    }
  }
  for (int v116 = 0; v116 < 64; v116 += 1) {	// L120
    for (int v117 = 0; v117 < 34; v117 += 1) {	// L121
      for (int v118 = 0; v118 < 34; v118 += 1) {	// L122
        v84[0][v116][v117][v118] = 0;	// L123
      }
    }
  }
  for (int v119 = 0; v119 < 64; v119 += 1) {	// L127
    for (int v120 = 0; v120 < 32; v120 += 1) {	// L128
      for (int v121 = 0; v121 < 32; v121 += 1) {	// L129
        int8_t v122 = v85[0][v119][v120][v121];	// L130
        v84[0][v119][(v120 + 1)][(v121 + 1)] = v122;	// L131
      }
    }
  }
  for (int v123 = 0; v123 < 64; v123 += 1) {	// L135
    for (int v124 = 0; v124 < 32; v124 += 1) {	// L136
      for (int v125 = 0; v125 < 32; v125 += 1) {	// L137
        v83[0][v123][v124][v125] = 0;	// L138
        for (int v126 = 0; v126 < 64; v126 += 1) {	// L139
          for (int v127 = 0; v127 < 3; v127 += 1) {	// L140
            for (int v128 = 0; v128 < 3; v128 += 1) {	// L141
              int8_t v129 = v84[0][v126][(v124 + v127)][(v125 + v128)];	// L142
              int8_t v130 = v2[v123][v126][v127][v128];	// L143
              int8_t v131 = v83[0][v123][v124][v125];	// L144
              int16_t v132 = v129;	// L145
              int16_t v133 = v130;	// L146
              int32_t v134 = v132 * v133;	// L147
              int32_t v135 = v131;	// L148
              int32_t v136 = v135 + v134;	// L149
              int8_t v137 = v136;	// L150
              v83[0][v123][v124][v125] = v137;	// L151
            }
          }
        }
      }
    }
  }
  for (int v138 = 0; v138 < 64; v138 += 1) {	// L158
    for (int v139 = 0; v139 < 32; v139 += 1) {	// L159
      for (int v140 = 0; v140 < 32; v140 += 1) {	// L160
        int8_t v141 = v83[0][v138][v139][v140];	// L161
        bool v142 = v141 < 0;	// L162
        int8_t v143 = v142 ? (int8_t)0 : (int8_t)v141;	// L163
        v82[0][v138][v139][v140] = v143;	// L164
      }
    }
  }
  for (int v144 = 0; v144 < 64; v144 += 1) {	// L168
    for (int v145 = 0; v145 < 34; v145 += 1) {	// L169
      for (int v146 = 0; v146 < 34; v146 += 1) {	// L170
        v81[0][v144][v145][v146] = 0;	// L171
      }
    }
  }
  for (int v147 = 0; v147 < 64; v147 += 1) {	// L175
    for (int v148 = 0; v148 < 32; v148 += 1) {	// L176
      for (int v149 = 0; v149 < 32; v149 += 1) {	// L177
        int8_t v150 = v82[0][v147][v148][v149];	// L178
        v81[0][v147][(v148 + 1)][(v149 + 1)] = v150;	// L179
      }
    }
  }
  for (int v151 = 0; v151 < 64; v151 += 1) {	// L183
    for (int v152 = 0; v152 < 32; v152 += 1) {	// L184
      for (int v153 = 0; v153 < 32; v153 += 1) {	// L185
        v80[0][v151][v152][v153] = 0;	// L186
        for (int v154 = 0; v154 < 64; v154 += 1) {	// L187
          for (int v155 = 0; v155 < 3; v155 += 1) {	// L188
            for (int v156 = 0; v156 < 3; v156 += 1) {	// L189
              int8_t v157 = v81[0][v154][(v152 + v155)][(v153 + v156)];	// L190
              int8_t v158 = v3[v151][v154][v155][v156];	// L191
              int8_t v159 = v80[0][v151][v152][v153];	// L192
              int16_t v160 = v157;	// L193
              int16_t v161 = v158;	// L194
              int32_t v162 = v160 * v161;	// L195
              int32_t v163 = v159;	// L196
              int32_t v164 = v163 + v162;	// L197
              int8_t v165 = v164;	// L198
              v80[0][v151][v152][v153] = v165;	// L199
            }
          }
        }
      }
    }
  }
  for (int v166 = 0; v166 < 64; v166 += 1) {	// L206
    for (int v167 = 0; v167 < 32; v167 += 1) {	// L207
      for (int v168 = 0; v168 < 32; v168 += 1) {	// L208
        int8_t v169 = v80[0][v166][v167][v168];	// L209
        int8_t v170 = v85[0][v166][v167][v168];	// L210
        int32_t v171 = v169;	// L211
        int32_t v172 = v170;	// L212
        int32_t v173 = v171 + v172;	// L213
        int8_t v174 = v173;	// L214
        v79[0][v166][v167][v168] = v174;	// L215
      }
    }
  }
  for (int v175 = 0; v175 < 64; v175 += 1) {	// L219
    for (int v176 = 0; v176 < 32; v176 += 1) {	// L220
      for (int v177 = 0; v177 < 32; v177 += 1) {	// L221
        int8_t v178 = v79[0][v175][v176][v177];	// L222
        bool v179 = v178 < 0;	// L223
        int8_t v180 = v179 ? (int8_t)0 : (int8_t)v178;	// L224
        v78[0][v175][v176][v177] = v180;	// L225
      }
    }
  }
  for (int v181 = 0; v181 < 64; v181 += 1) {	// L229
    for (int v182 = 0; v182 < 34; v182 += 1) {	// L230
      for (int v183 = 0; v183 < 34; v183 += 1) {	// L231
        v77[0][v181][v182][v183] = 0;	// L232
      }
    }
  }
  for (int v184 = 0; v184 < 64; v184 += 1) {	// L236
    for (int v185 = 0; v185 < 32; v185 += 1) {	// L237
      for (int v186 = 0; v186 < 32; v186 += 1) {	// L238
        int8_t v187 = v78[0][v184][v185][v186];	// L239
        v77[0][v184][(v185 + 1)][(v186 + 1)] = v187;	// L240
      }
    }
  }
  for (int v188 = 0; v188 < 64; v188 += 1) {	// L244
    for (int v189 = 0; v189 < 32; v189 += 1) {	// L245
      for (int v190 = 0; v190 < 32; v190 += 1) {	// L246
        v76[0][v188][v189][v190] = 0;	// L247
        for (int v191 = 0; v191 < 64; v191 += 1) {	// L248
          for (int v192 = 0; v192 < 3; v192 += 1) {	// L249
            for (int v193 = 0; v193 < 3; v193 += 1) {	// L250
              int8_t v194 = v77[0][v191][(v189 + v192)][(v190 + v193)];	// L251
              int8_t v195 = v4[v188][v191][v192][v193];	// L252
              int8_t v196 = v76[0][v188][v189][v190];	// L253
              int16_t v197 = v194;	// L254
              int16_t v198 = v195;	// L255
              int32_t v199 = v197 * v198;	// L256
              int32_t v200 = v196;	// L257
              int32_t v201 = v200 + v199;	// L258
              int8_t v202 = v201;	// L259
              v76[0][v188][v189][v190] = v202;	// L260
            }
          }
        }
      }
    }
  }
  for (int v203 = 0; v203 < 64; v203 += 1) {	// L267
    for (int v204 = 0; v204 < 32; v204 += 1) {	// L268
      for (int v205 = 0; v205 < 32; v205 += 1) {	// L269
        int8_t v206 = v76[0][v203][v204][v205];	// L270
        bool v207 = v206 < 0;	// L271
        int8_t v208 = v207 ? (int8_t)0 : (int8_t)v206;	// L272
        v75[0][v203][v204][v205] = v208;	// L273
      }
    }
  }
  for (int v209 = 0; v209 < 64; v209 += 1) {	// L277
    for (int v210 = 0; v210 < 34; v210 += 1) {	// L278
      for (int v211 = 0; v211 < 34; v211 += 1) {	// L279
        v74[0][v209][v210][v211] = 0;	// L280
      }
    }
  }
  for (int v212 = 0; v212 < 64; v212 += 1) {	// L284
    for (int v213 = 0; v213 < 32; v213 += 1) {	// L285
      for (int v214 = 0; v214 < 32; v214 += 1) {	// L286
        int8_t v215 = v75[0][v212][v213][v214];	// L287
        v74[0][v212][(v213 + 1)][(v214 + 1)] = v215;	// L288
      }
    }
  }
  for (int v216 = 0; v216 < 64; v216 += 1) {	// L292
    for (int v217 = 0; v217 < 32; v217 += 1) {	// L293
      for (int v218 = 0; v218 < 32; v218 += 1) {	// L294
        v73[0][v216][v217][v218] = 0;	// L295
        for (int v219 = 0; v219 < 64; v219 += 1) {	// L296
          for (int v220 = 0; v220 < 3; v220 += 1) {	// L297
            for (int v221 = 0; v221 < 3; v221 += 1) {	// L298
              int8_t v222 = v74[0][v219][(v217 + v220)][(v218 + v221)];	// L299
              int8_t v223 = v5[v216][v219][v220][v221];	// L300
              int8_t v224 = v73[0][v216][v217][v218];	// L301
              int16_t v225 = v222;	// L302
              int16_t v226 = v223;	// L303
              int32_t v227 = v225 * v226;	// L304
              int32_t v228 = v224;	// L305
              int32_t v229 = v228 + v227;	// L306
              int8_t v230 = v229;	// L307
              v73[0][v216][v217][v218] = v230;	// L308
            }
          }
        }
      }
    }
  }
  for (int v231 = 0; v231 < 64; v231 += 1) {	// L315
    for (int v232 = 0; v232 < 32; v232 += 1) {	// L316
      for (int v233 = 0; v233 < 32; v233 += 1) {	// L317
        int8_t v234 = v73[0][v231][v232][v233];	// L318
        int8_t v235 = v78[0][v231][v232][v233];	// L319
        int32_t v236 = v234;	// L320
        int32_t v237 = v235;	// L321
        int32_t v238 = v236 + v237;	// L322
        int8_t v239 = v238;	// L323
        v72[0][v231][v232][v233] = v239;	// L324
      }
    }
  }
  for (int v240 = 0; v240 < 64; v240 += 1) {	// L328
    for (int v241 = 0; v241 < 32; v241 += 1) {	// L329
      for (int v242 = 0; v242 < 32; v242 += 1) {	// L330
        int8_t v243 = v72[0][v240][v241][v242];	// L331
        bool v244 = v243 < 0;	// L332
        int8_t v245 = v244 ? (int8_t)0 : (int8_t)v243;	// L333
        v71[0][v240][v241][v242] = v245;	// L334
      }
    }
  }
  for (int v246 = 0; v246 < 64; v246 += 1) {	// L338
    for (int v247 = 0; v247 < 34; v247 += 1) {	// L339
      for (int v248 = 0; v248 < 34; v248 += 1) {	// L340
        v70[0][v246][v247][v248] = 0;	// L341
      }
    }
  }
  for (int v249 = 0; v249 < 64; v249 += 1) {	// L345
    for (int v250 = 0; v250 < 32; v250 += 1) {	// L346
      for (int v251 = 0; v251 < 32; v251 += 1) {	// L347
        int8_t v252 = v71[0][v249][v250][v251];	// L348
        v70[0][v249][(v250 + 1)][(v251 + 1)] = v252;	// L349
      }
    }
  }
  for (int v253 = 0; v253 < 128; v253 += 1) {	// L353
    for (int v254 = 0; v254 < 16; v254 += 1) {	// L354
      for (int v255 = 0; v255 < 16; v255 += 1) {	// L355
        v69[0][v253][v254][v255] = 0;	// L356
        for (int v256 = 0; v256 < 64; v256 += 1) {	// L357
          for (int v257 = 0; v257 < 3; v257 += 1) {	// L358
            for (int v258 = 0; v258 < 3; v258 += 1) {	// L359
              int8_t v259 = v70[0][v256][((v254 * 2) + v257)][((v255 * 2) + v258)];	// L360
              int8_t v260 = v6[v253][v256][v257][v258];	// L361
              int8_t v261 = v69[0][v253][v254][v255];	// L362
              int16_t v262 = v259;	// L363
              int16_t v263 = v260;	// L364
              int32_t v264 = v262 * v263;	// L365
              int32_t v265 = v261;	// L366
              int32_t v266 = v265 + v264;	// L367
              int8_t v267 = v266;	// L368
              v69[0][v253][v254][v255] = v267;	// L369
            }
          }
        }
      }
    }
  }
  for (int v268 = 0; v268 < 128; v268 += 1) {	// L376
    for (int v269 = 0; v269 < 16; v269 += 1) {	// L377
      for (int v270 = 0; v270 < 16; v270 += 1) {	// L378
        int8_t v271 = v69[0][v268][v269][v270];	// L379
        bool v272 = v271 < 0;	// L380
        int8_t v273 = v272 ? (int8_t)0 : (int8_t)v271;	// L381
        v68[0][v268][v269][v270] = v273;	// L382
      }
    }
  }
  for (int v274 = 0; v274 < 128; v274 += 1) {	// L386
    for (int v275 = 0; v275 < 18; v275 += 1) {	// L387
      for (int v276 = 0; v276 < 18; v276 += 1) {	// L388
        v67[0][v274][v275][v276] = 0;	// L389
      }
    }
  }
  for (int v277 = 0; v277 < 128; v277 += 1) {	// L393
    for (int v278 = 0; v278 < 16; v278 += 1) {	// L394
      for (int v279 = 0; v279 < 16; v279 += 1) {	// L395
        int8_t v280 = v68[0][v277][v278][v279];	// L396
        v67[0][v277][(v278 + 1)][(v279 + 1)] = v280;	// L397
      }
    }
  }
  for (int v281 = 0; v281 < 128; v281 += 1) {	// L401
    for (int v282 = 0; v282 < 16; v282 += 1) {	// L402
      for (int v283 = 0; v283 < 16; v283 += 1) {	// L403
        v66[0][v281][v282][v283] = 0;	// L404
        for (int v284 = 0; v284 < 128; v284 += 1) {	// L405
          for (int v285 = 0; v285 < 3; v285 += 1) {	// L406
            for (int v286 = 0; v286 < 3; v286 += 1) {	// L407
              int8_t v287 = v67[0][v284][(v282 + v285)][(v283 + v286)];	// L408
              int8_t v288 = v7[v281][v284][v285][v286];	// L409
              int8_t v289 = v66[0][v281][v282][v283];	// L410
              int16_t v290 = v287;	// L411
              int16_t v291 = v288;	// L412
              int32_t v292 = v290 * v291;	// L413
              int32_t v293 = v289;	// L414
              int32_t v294 = v293 + v292;	// L415
              int8_t v295 = v294;	// L416
              v66[0][v281][v282][v283] = v295;	// L417
            }
          }
        }
      }
    }
  }
  for (int v296 = 0; v296 < 128; v296 += 1) {	// L424
    for (int v297 = 0; v297 < 16; v297 += 1) {	// L425
      for (int v298 = 0; v298 < 16; v298 += 1) {	// L426
        v65[0][v296][v297][v298] = 0;	// L427
        for (int v299 = 0; v299 < 64; v299 += 1) {	// L428
          int8_t v300 = v71[0][v299][(v297 * 2)][(v298 * 2)];	// L429
          int8_t v301 = v8[v296][v299][0][0];	// L430
          int8_t v302 = v65[0][v296][v297][v298];	// L431
          int16_t v303 = v300;	// L432
          int16_t v304 = v301;	// L433
          int32_t v305 = v303 * v304;	// L434
          int32_t v306 = v302;	// L435
          int32_t v307 = v306 + v305;	// L436
          int8_t v308 = v307;	// L437
          v65[0][v296][v297][v298] = v308;	// L438
        }
      }
    }
  }
  for (int v309 = 0; v309 < 128; v309 += 1) {	// L443
    for (int v310 = 0; v310 < 16; v310 += 1) {	// L444
      for (int v311 = 0; v311 < 16; v311 += 1) {	// L445
        int8_t v312 = v66[0][v309][v310][v311];	// L446
        int8_t v313 = v65[0][v309][v310][v311];	// L447
        int32_t v314 = v312;	// L448
        int32_t v315 = v313;	// L449
        int32_t v316 = v314 + v315;	// L450
        int8_t v317 = v316;	// L451
        v64[0][v309][v310][v311] = v317;	// L452
      }
    }
  }
  for (int v318 = 0; v318 < 128; v318 += 1) {	// L456
    for (int v319 = 0; v319 < 16; v319 += 1) {	// L457
      for (int v320 = 0; v320 < 16; v320 += 1) {	// L458
        int8_t v321 = v64[0][v318][v319][v320];	// L459
        bool v322 = v321 < 0;	// L460
        int8_t v323 = v322 ? (int8_t)0 : (int8_t)v321;	// L461
        v63[0][v318][v319][v320] = v323;	// L462
      }
    }
  }
  for (int v324 = 0; v324 < 128; v324 += 1) {	// L466
    for (int v325 = 0; v325 < 18; v325 += 1) {	// L467
      for (int v326 = 0; v326 < 18; v326 += 1) {	// L468
        v62[0][v324][v325][v326] = 0;	// L469
      }
    }
  }
  for (int v327 = 0; v327 < 128; v327 += 1) {	// L473
    for (int v328 = 0; v328 < 16; v328 += 1) {	// L474
      for (int v329 = 0; v329 < 16; v329 += 1) {	// L475
        int8_t v330 = v63[0][v327][v328][v329];	// L476
        v62[0][v327][(v328 + 1)][(v329 + 1)] = v330;	// L477
      }
    }
  }
  for (int v331 = 0; v331 < 128; v331 += 1) {	// L481
    for (int v332 = 0; v332 < 16; v332 += 1) {	// L482
      for (int v333 = 0; v333 < 16; v333 += 1) {	// L483
        v61[0][v331][v332][v333] = 0;	// L484
        for (int v334 = 0; v334 < 128; v334 += 1) {	// L485
          for (int v335 = 0; v335 < 3; v335 += 1) {	// L486
            for (int v336 = 0; v336 < 3; v336 += 1) {	// L487
              int8_t v337 = v62[0][v334][(v332 + v335)][(v333 + v336)];	// L488
              int8_t v338 = v9[v331][v334][v335][v336];	// L489
              int8_t v339 = v61[0][v331][v332][v333];	// L490
              int16_t v340 = v337;	// L491
              int16_t v341 = v338;	// L492
              int32_t v342 = v340 * v341;	// L493
              int32_t v343 = v339;	// L494
              int32_t v344 = v343 + v342;	// L495
              int8_t v345 = v344;	// L496
              v61[0][v331][v332][v333] = v345;	// L497
            }
          }
        }
      }
    }
  }
  for (int v346 = 0; v346 < 128; v346 += 1) {	// L504
    for (int v347 = 0; v347 < 16; v347 += 1) {	// L505
      for (int v348 = 0; v348 < 16; v348 += 1) {	// L506
        int8_t v349 = v61[0][v346][v347][v348];	// L507
        bool v350 = v349 < 0;	// L508
        int8_t v351 = v350 ? (int8_t)0 : (int8_t)v349;	// L509
        v60[0][v346][v347][v348] = v351;	// L510
      }
    }
  }
  for (int v352 = 0; v352 < 128; v352 += 1) {	// L514
    for (int v353 = 0; v353 < 18; v353 += 1) {	// L515
      for (int v354 = 0; v354 < 18; v354 += 1) {	// L516
        v59[0][v352][v353][v354] = 0;	// L517
      }
    }
  }
  for (int v355 = 0; v355 < 128; v355 += 1) {	// L521
    for (int v356 = 0; v356 < 16; v356 += 1) {	// L522
      for (int v357 = 0; v357 < 16; v357 += 1) {	// L523
        int8_t v358 = v60[0][v355][v356][v357];	// L524
        v59[0][v355][(v356 + 1)][(v357 + 1)] = v358;	// L525
      }
    }
  }
  for (int v359 = 0; v359 < 128; v359 += 1) {	// L529
    for (int v360 = 0; v360 < 16; v360 += 1) {	// L530
      for (int v361 = 0; v361 < 16; v361 += 1) {	// L531
        v58[0][v359][v360][v361] = 0;	// L532
        for (int v362 = 0; v362 < 128; v362 += 1) {	// L533
          for (int v363 = 0; v363 < 3; v363 += 1) {	// L534
            for (int v364 = 0; v364 < 3; v364 += 1) {	// L535
              int8_t v365 = v59[0][v362][(v360 + v363)][(v361 + v364)];	// L536
              int8_t v366 = v10[v359][v362][v363][v364];	// L537
              int8_t v367 = v58[0][v359][v360][v361];	// L538
              int16_t v368 = v365;	// L539
              int16_t v369 = v366;	// L540
              int32_t v370 = v368 * v369;	// L541
              int32_t v371 = v367;	// L542
              int32_t v372 = v371 + v370;	// L543
              int8_t v373 = v372;	// L544
              v58[0][v359][v360][v361] = v373;	// L545
            }
          }
        }
      }
    }
  }
  for (int v374 = 0; v374 < 128; v374 += 1) {	// L552
    for (int v375 = 0; v375 < 16; v375 += 1) {	// L553
      for (int v376 = 0; v376 < 16; v376 += 1) {	// L554
        int8_t v377 = v58[0][v374][v375][v376];	// L555
        int8_t v378 = v63[0][v374][v375][v376];	// L556
        int32_t v379 = v377;	// L557
        int32_t v380 = v378;	// L558
        int32_t v381 = v379 + v380;	// L559
        int8_t v382 = v381;	// L560
        v57[0][v374][v375][v376] = v382;	// L561
      }
    }
  }
  for (int v383 = 0; v383 < 128; v383 += 1) {	// L565
    for (int v384 = 0; v384 < 16; v384 += 1) {	// L566
      for (int v385 = 0; v385 < 16; v385 += 1) {	// L567
        int8_t v386 = v57[0][v383][v384][v385];	// L568
        bool v387 = v386 < 0;	// L569
        int8_t v388 = v387 ? (int8_t)0 : (int8_t)v386;	// L570
        v56[0][v383][v384][v385] = v388;	// L571
      }
    }
  }
  for (int v389 = 0; v389 < 128; v389 += 1) {	// L575
    for (int v390 = 0; v390 < 18; v390 += 1) {	// L576
      for (int v391 = 0; v391 < 18; v391 += 1) {	// L577
        v55[0][v389][v390][v391] = 0;	// L578
      }
    }
  }
  for (int v392 = 0; v392 < 128; v392 += 1) {	// L582
    for (int v393 = 0; v393 < 16; v393 += 1) {	// L583
      for (int v394 = 0; v394 < 16; v394 += 1) {	// L584
        int8_t v395 = v56[0][v392][v393][v394];	// L585
        v55[0][v392][(v393 + 1)][(v394 + 1)] = v395;	// L586
      }
    }
  }
  for (int v396 = 0; v396 < 256; v396 += 1) {	// L590
    for (int v397 = 0; v397 < 8; v397 += 1) {	// L591
      for (int v398 = 0; v398 < 8; v398 += 1) {	// L592
        v54[0][v396][v397][v398] = 0;	// L593
        for (int v399 = 0; v399 < 128; v399 += 1) {	// L594
          for (int v400 = 0; v400 < 3; v400 += 1) {	// L595
            for (int v401 = 0; v401 < 3; v401 += 1) {	// L596
              int8_t v402 = v55[0][v399][((v397 * 2) + v400)][((v398 * 2) + v401)];	// L597
              int8_t v403 = v11[v396][v399][v400][v401];	// L598
              int8_t v404 = v54[0][v396][v397][v398];	// L599
              int16_t v405 = v402;	// L600
              int16_t v406 = v403;	// L601
              int32_t v407 = v405 * v406;	// L602
              int32_t v408 = v404;	// L603
              int32_t v409 = v408 + v407;	// L604
              int8_t v410 = v409;	// L605
              v54[0][v396][v397][v398] = v410;	// L606
            }
          }
        }
      }
    }
  }
  for (int v411 = 0; v411 < 256; v411 += 1) {	// L613
    for (int v412 = 0; v412 < 8; v412 += 1) {	// L614
      for (int v413 = 0; v413 < 8; v413 += 1) {	// L615
        int8_t v414 = v54[0][v411][v412][v413];	// L616
        bool v415 = v414 < 0;	// L617
        int8_t v416 = v415 ? (int8_t)0 : (int8_t)v414;	// L618
        v53[0][v411][v412][v413] = v416;	// L619
      }
    }
  }
  for (int v417 = 0; v417 < 256; v417 += 1) {	// L623
    for (int v418 = 0; v418 < 10; v418 += 1) {	// L624
      for (int v419 = 0; v419 < 10; v419 += 1) {	// L625
        v52[0][v417][v418][v419] = 0;	// L626
      }
    }
  }
  for (int v420 = 0; v420 < 256; v420 += 1) {	// L630
    for (int v421 = 0; v421 < 8; v421 += 1) {	// L631
      for (int v422 = 0; v422 < 8; v422 += 1) {	// L632
        int8_t v423 = v53[0][v420][v421][v422];	// L633
        v52[0][v420][(v421 + 1)][(v422 + 1)] = v423;	// L634
      }
    }
  }
  for (int v424 = 0; v424 < 256; v424 += 1) {	// L638
    for (int v425 = 0; v425 < 8; v425 += 1) {	// L639
      for (int v426 = 0; v426 < 8; v426 += 1) {	// L640
        v51[0][v424][v425][v426] = 0;	// L641
        for (int v427 = 0; v427 < 256; v427 += 1) {	// L642
          for (int v428 = 0; v428 < 3; v428 += 1) {	// L643
            for (int v429 = 0; v429 < 3; v429 += 1) {	// L644
              int8_t v430 = v52[0][v427][(v425 + v428)][(v426 + v429)];	// L645
              int8_t v431 = v12[v424][v427][v428][v429];	// L646
              int8_t v432 = v51[0][v424][v425][v426];	// L647
              int16_t v433 = v430;	// L648
              int16_t v434 = v431;	// L649
              int32_t v435 = v433 * v434;	// L650
              int32_t v436 = v432;	// L651
              int32_t v437 = v436 + v435;	// L652
              int8_t v438 = v437;	// L653
              v51[0][v424][v425][v426] = v438;	// L654
            }
          }
        }
      }
    }
  }
  for (int v439 = 0; v439 < 256; v439 += 1) {	// L661
    for (int v440 = 0; v440 < 8; v440 += 1) {	// L662
      for (int v441 = 0; v441 < 8; v441 += 1) {	// L663
        v50[0][v439][v440][v441] = 0;	// L664
        for (int v442 = 0; v442 < 128; v442 += 1) {	// L665
          int8_t v443 = v56[0][v442][(v440 * 2)][(v441 * 2)];	// L666
          int8_t v444 = v13[v439][v442][0][0];	// L667
          int8_t v445 = v50[0][v439][v440][v441];	// L668
          int16_t v446 = v443;	// L669
          int16_t v447 = v444;	// L670
          int32_t v448 = v446 * v447;	// L671
          int32_t v449 = v445;	// L672
          int32_t v450 = v449 + v448;	// L673
          int8_t v451 = v450;	// L674
          v50[0][v439][v440][v441] = v451;	// L675
        }
      }
    }
  }
  for (int v452 = 0; v452 < 256; v452 += 1) {	// L680
    for (int v453 = 0; v453 < 8; v453 += 1) {	// L681
      for (int v454 = 0; v454 < 8; v454 += 1) {	// L682
        int8_t v455 = v51[0][v452][v453][v454];	// L683
        int8_t v456 = v50[0][v452][v453][v454];	// L684
        int32_t v457 = v455;	// L685
        int32_t v458 = v456;	// L686
        int32_t v459 = v457 + v458;	// L687
        int8_t v460 = v459;	// L688
        v49[0][v452][v453][v454] = v460;	// L689
      }
    }
  }
  for (int v461 = 0; v461 < 256; v461 += 1) {	// L693
    for (int v462 = 0; v462 < 8; v462 += 1) {	// L694
      for (int v463 = 0; v463 < 8; v463 += 1) {	// L695
        int8_t v464 = v49[0][v461][v462][v463];	// L696
        bool v465 = v464 < 0;	// L697
        int8_t v466 = v465 ? (int8_t)0 : (int8_t)v464;	// L698
        v48[0][v461][v462][v463] = v466;	// L699
      }
    }
  }
  for (int v467 = 0; v467 < 256; v467 += 1) {	// L703
    for (int v468 = 0; v468 < 10; v468 += 1) {	// L704
      for (int v469 = 0; v469 < 10; v469 += 1) {	// L705
        v47[0][v467][v468][v469] = 0;	// L706
      }
    }
  }
  for (int v470 = 0; v470 < 256; v470 += 1) {	// L710
    for (int v471 = 0; v471 < 8; v471 += 1) {	// L711
      for (int v472 = 0; v472 < 8; v472 += 1) {	// L712
        int8_t v473 = v48[0][v470][v471][v472];	// L713
        v47[0][v470][(v471 + 1)][(v472 + 1)] = v473;	// L714
      }
    }
  }
  for (int v474 = 0; v474 < 256; v474 += 1) {	// L718
    for (int v475 = 0; v475 < 8; v475 += 1) {	// L719
      for (int v476 = 0; v476 < 8; v476 += 1) {	// L720
        v46[0][v474][v475][v476] = 0;	// L721
        for (int v477 = 0; v477 < 256; v477 += 1) {	// L722
          for (int v478 = 0; v478 < 3; v478 += 1) {	// L723
            for (int v479 = 0; v479 < 3; v479 += 1) {	// L724
              int8_t v480 = v47[0][v477][(v475 + v478)][(v476 + v479)];	// L725
              int8_t v481 = v14[v474][v477][v478][v479];	// L726
              int8_t v482 = v46[0][v474][v475][v476];	// L727
              int16_t v483 = v480;	// L728
              int16_t v484 = v481;	// L729
              int32_t v485 = v483 * v484;	// L730
              int32_t v486 = v482;	// L731
              int32_t v487 = v486 + v485;	// L732
              int8_t v488 = v487;	// L733
              v46[0][v474][v475][v476] = v488;	// L734
            }
          }
        }
      }
    }
  }
  for (int v489 = 0; v489 < 256; v489 += 1) {	// L741
    for (int v490 = 0; v490 < 8; v490 += 1) {	// L742
      for (int v491 = 0; v491 < 8; v491 += 1) {	// L743
        int8_t v492 = v46[0][v489][v490][v491];	// L744
        bool v493 = v492 < 0;	// L745
        int8_t v494 = v493 ? (int8_t)0 : (int8_t)v492;	// L746
        v45[0][v489][v490][v491] = v494;	// L747
      }
    }
  }
  for (int v495 = 0; v495 < 256; v495 += 1) {	// L751
    for (int v496 = 0; v496 < 10; v496 += 1) {	// L752
      for (int v497 = 0; v497 < 10; v497 += 1) {	// L753
        v44[0][v495][v496][v497] = 0;	// L754
      }
    }
  }
  for (int v498 = 0; v498 < 256; v498 += 1) {	// L758
    for (int v499 = 0; v499 < 8; v499 += 1) {	// L759
      for (int v500 = 0; v500 < 8; v500 += 1) {	// L760
        int8_t v501 = v45[0][v498][v499][v500];	// L761
        v44[0][v498][(v499 + 1)][(v500 + 1)] = v501;	// L762
      }
    }
  }
  for (int v502 = 0; v502 < 256; v502 += 1) {	// L766
    for (int v503 = 0; v503 < 8; v503 += 1) {	// L767
      for (int v504 = 0; v504 < 8; v504 += 1) {	// L768
        v43[0][v502][v503][v504] = 0;	// L769
        for (int v505 = 0; v505 < 256; v505 += 1) {	// L770
          for (int v506 = 0; v506 < 3; v506 += 1) {	// L771
            for (int v507 = 0; v507 < 3; v507 += 1) {	// L772
              int8_t v508 = v44[0][v505][(v503 + v506)][(v504 + v507)];	// L773
              int8_t v509 = v15[v502][v505][v506][v507];	// L774
              int8_t v510 = v43[0][v502][v503][v504];	// L775
              int16_t v511 = v508;	// L776
              int16_t v512 = v509;	// L777
              int32_t v513 = v511 * v512;	// L778
              int32_t v514 = v510;	// L779
              int32_t v515 = v514 + v513;	// L780
              int8_t v516 = v515;	// L781
              v43[0][v502][v503][v504] = v516;	// L782
            }
          }
        }
      }
    }
  }
  for (int v517 = 0; v517 < 256; v517 += 1) {	// L789
    for (int v518 = 0; v518 < 8; v518 += 1) {	// L790
      for (int v519 = 0; v519 < 8; v519 += 1) {	// L791
        int8_t v520 = v43[0][v517][v518][v519];	// L792
        int8_t v521 = v48[0][v517][v518][v519];	// L793
        int32_t v522 = v520;	// L794
        int32_t v523 = v521;	// L795
        int32_t v524 = v522 + v523;	// L796
        int8_t v525 = v524;	// L797
        v42[0][v517][v518][v519] = v525;	// L798
      }
    }
  }
  for (int v526 = 0; v526 < 256; v526 += 1) {	// L802
    for (int v527 = 0; v527 < 8; v527 += 1) {	// L803
      for (int v528 = 0; v528 < 8; v528 += 1) {	// L804
        int8_t v529 = v42[0][v526][v527][v528];	// L805
        bool v530 = v529 < 0;	// L806
        int8_t v531 = v530 ? (int8_t)0 : (int8_t)v529;	// L807
        v41[0][v526][v527][v528] = v531;	// L808
      }
    }
  }
  for (int v532 = 0; v532 < 256; v532 += 1) {	// L812
    for (int v533 = 0; v533 < 10; v533 += 1) {	// L813
      for (int v534 = 0; v534 < 10; v534 += 1) {	// L814
        v40[0][v532][v533][v534] = 0;	// L815
      }
    }
  }
  for (int v535 = 0; v535 < 256; v535 += 1) {	// L819
    for (int v536 = 0; v536 < 8; v536 += 1) {	// L820
      for (int v537 = 0; v537 < 8; v537 += 1) {	// L821
        int8_t v538 = v41[0][v535][v536][v537];	// L822
        v40[0][v535][(v536 + 1)][(v537 + 1)] = v538;	// L823
      }
    }
  }
  for (int v539 = 0; v539 < 512; v539 += 1) {	// L827
    for (int v540 = 0; v540 < 4; v540 += 1) {	// L828
      for (int v541 = 0; v541 < 4; v541 += 1) {	// L829
        v39[0][v539][v540][v541] = 0;	// L830
        for (int v542 = 0; v542 < 256; v542 += 1) {	// L831
          for (int v543 = 0; v543 < 3; v543 += 1) {	// L832
            for (int v544 = 0; v544 < 3; v544 += 1) {	// L833
              int8_t v545 = v40[0][v542][((v540 * 2) + v543)][((v541 * 2) + v544)];	// L834
              int8_t v546 = v16[v539][v542][v543][v544];	// L835
              int8_t v547 = v39[0][v539][v540][v541];	// L836
              int16_t v548 = v545;	// L837
              int16_t v549 = v546;	// L838
              int32_t v550 = v548 * v549;	// L839
              int32_t v551 = v547;	// L840
              int32_t v552 = v551 + v550;	// L841
              int8_t v553 = v552;	// L842
              v39[0][v539][v540][v541] = v553;	// L843
            }
          }
        }
      }
    }
  }
  for (int v554 = 0; v554 < 512; v554 += 1) {	// L850
    for (int v555 = 0; v555 < 4; v555 += 1) {	// L851
      for (int v556 = 0; v556 < 4; v556 += 1) {	// L852
        int8_t v557 = v39[0][v554][v555][v556];	// L853
        bool v558 = v557 < 0;	// L854
        int8_t v559 = v558 ? (int8_t)0 : (int8_t)v557;	// L855
        v38[0][v554][v555][v556] = v559;	// L856
      }
    }
  }
  for (int v560 = 0; v560 < 512; v560 += 1) {	// L860
    for (int v561 = 0; v561 < 6; v561 += 1) {	// L861
      for (int v562 = 0; v562 < 6; v562 += 1) {	// L862
        v37[0][v560][v561][v562] = 0;	// L863
      }
    }
  }
  for (int v563 = 0; v563 < 512; v563 += 1) {	// L867
    for (int v564 = 0; v564 < 4; v564 += 1) {	// L868
      for (int v565 = 0; v565 < 4; v565 += 1) {	// L869
        int8_t v566 = v38[0][v563][v564][v565];	// L870
        v37[0][v563][(v564 + 1)][(v565 + 1)] = v566;	// L871
      }
    }
  }
  for (int v567 = 0; v567 < 512; v567 += 1) {	// L875
    for (int v568 = 0; v568 < 4; v568 += 1) {	// L876
      for (int v569 = 0; v569 < 4; v569 += 1) {	// L877
        v36[0][v567][v568][v569] = 0;	// L878
        for (int v570 = 0; v570 < 512; v570 += 1) {	// L879
          for (int v571 = 0; v571 < 3; v571 += 1) {	// L880
            for (int v572 = 0; v572 < 3; v572 += 1) {	// L881
              int8_t v573 = v37[0][v570][(v568 + v571)][(v569 + v572)];	// L882
              int8_t v574 = v17[v567][v570][v571][v572];	// L883
              int8_t v575 = v36[0][v567][v568][v569];	// L884
              int16_t v576 = v573;	// L885
              int16_t v577 = v574;	// L886
              int32_t v578 = v576 * v577;	// L887
              int32_t v579 = v575;	// L888
              int32_t v580 = v579 + v578;	// L889
              int8_t v581 = v580;	// L890
              v36[0][v567][v568][v569] = v581;	// L891
            }
          }
        }
      }
    }
  }
  for (int v582 = 0; v582 < 512; v582 += 1) {	// L898
    for (int v583 = 0; v583 < 4; v583 += 1) {	// L899
      for (int v584 = 0; v584 < 4; v584 += 1) {	// L900
        v35[0][v582][v583][v584] = 0;	// L901
        for (int v585 = 0; v585 < 256; v585 += 1) {	// L902
          int8_t v586 = v41[0][v585][(v583 * 2)][(v584 * 2)];	// L903
          int8_t v587 = v18[v582][v585][0][0];	// L904
          int8_t v588 = v35[0][v582][v583][v584];	// L905
          int16_t v589 = v586;	// L906
          int16_t v590 = v587;	// L907
          int32_t v591 = v589 * v590;	// L908
          int32_t v592 = v588;	// L909
          int32_t v593 = v592 + v591;	// L910
          int8_t v594 = v593;	// L911
          v35[0][v582][v583][v584] = v594;	// L912
        }
      }
    }
  }
  for (int v595 = 0; v595 < 512; v595 += 1) {	// L917
    for (int v596 = 0; v596 < 4; v596 += 1) {	// L918
      for (int v597 = 0; v597 < 4; v597 += 1) {	// L919
        int8_t v598 = v36[0][v595][v596][v597];	// L920
        int8_t v599 = v35[0][v595][v596][v597];	// L921
        int32_t v600 = v598;	// L922
        int32_t v601 = v599;	// L923
        int32_t v602 = v600 + v601;	// L924
        int8_t v603 = v602;	// L925
        v34[0][v595][v596][v597] = v603;	// L926
      }
    }
  }
  for (int v604 = 0; v604 < 512; v604 += 1) {	// L930
    for (int v605 = 0; v605 < 4; v605 += 1) {	// L931
      for (int v606 = 0; v606 < 4; v606 += 1) {	// L932
        int8_t v607 = v34[0][v604][v605][v606];	// L933
        bool v608 = v607 < 0;	// L934
        int8_t v609 = v608 ? (int8_t)0 : (int8_t)v607;	// L935
        v33[0][v604][v605][v606] = v609;	// L936
      }
    }
  }
  for (int v610 = 0; v610 < 512; v610 += 1) {	// L940
    for (int v611 = 0; v611 < 6; v611 += 1) {	// L941
      for (int v612 = 0; v612 < 6; v612 += 1) {	// L942
        v32[0][v610][v611][v612] = 0;	// L943
      }
    }
  }
  for (int v613 = 0; v613 < 512; v613 += 1) {	// L947
    for (int v614 = 0; v614 < 4; v614 += 1) {	// L948
      for (int v615 = 0; v615 < 4; v615 += 1) {	// L949
        int8_t v616 = v33[0][v613][v614][v615];	// L950
        v32[0][v613][(v614 + 1)][(v615 + 1)] = v616;	// L951
      }
    }
  }
  for (int v617 = 0; v617 < 512; v617 += 1) {	// L955
    for (int v618 = 0; v618 < 4; v618 += 1) {	// L956
      for (int v619 = 0; v619 < 4; v619 += 1) {	// L957
        v31[0][v617][v618][v619] = 0;	// L958
        for (int v620 = 0; v620 < 512; v620 += 1) {	// L959
          for (int v621 = 0; v621 < 3; v621 += 1) {	// L960
            for (int v622 = 0; v622 < 3; v622 += 1) {	// L961
              int8_t v623 = v32[0][v620][(v618 + v621)][(v619 + v622)];	// L962
              int8_t v624 = v19[v617][v620][v621][v622];	// L963
              int8_t v625 = v31[0][v617][v618][v619];	// L964
              int16_t v626 = v623;	// L965
              int16_t v627 = v624;	// L966
              int32_t v628 = v626 * v627;	// L967
              int32_t v629 = v625;	// L968
              int32_t v630 = v629 + v628;	// L969
              int8_t v631 = v630;	// L970
              v31[0][v617][v618][v619] = v631;	// L971
            }
          }
        }
      }
    }
  }
  for (int v632 = 0; v632 < 512; v632 += 1) {	// L978
    for (int v633 = 0; v633 < 4; v633 += 1) {	// L979
      for (int v634 = 0; v634 < 4; v634 += 1) {	// L980
        int8_t v635 = v31[0][v632][v633][v634];	// L981
        bool v636 = v635 < 0;	// L982
        int8_t v637 = v636 ? (int8_t)0 : (int8_t)v635;	// L983
        v30[0][v632][v633][v634] = v637;	// L984
      }
    }
  }
  for (int v638 = 0; v638 < 512; v638 += 1) {	// L988
    for (int v639 = 0; v639 < 6; v639 += 1) {	// L989
      for (int v640 = 0; v640 < 6; v640 += 1) {	// L990
        v29[0][v638][v639][v640] = 0;	// L991
      }
    }
  }
  for (int v641 = 0; v641 < 512; v641 += 1) {	// L995
    for (int v642 = 0; v642 < 4; v642 += 1) {	// L996
      for (int v643 = 0; v643 < 4; v643 += 1) {	// L997
        int8_t v644 = v30[0][v641][v642][v643];	// L998
        v29[0][v641][(v642 + 1)][(v643 + 1)] = v644;	// L999
      }
    }
  }
  for (int v645 = 0; v645 < 512; v645 += 1) {	// L1003
    for (int v646 = 0; v646 < 4; v646 += 1) {	// L1004
      for (int v647 = 0; v647 < 4; v647 += 1) {	// L1005
        v28[0][v645][v646][v647] = 0;	// L1006
        for (int v648 = 0; v648 < 512; v648 += 1) {	// L1007
          for (int v649 = 0; v649 < 3; v649 += 1) {	// L1008
            for (int v650 = 0; v650 < 3; v650 += 1) {	// L1009
              int8_t v651 = v29[0][v648][(v646 + v649)][(v647 + v650)];	// L1010
              int8_t v652 = v20[v645][v648][v649][v650];	// L1011
              int8_t v653 = v28[0][v645][v646][v647];	// L1012
              int16_t v654 = v651;	// L1013
              int16_t v655 = v652;	// L1014
              int32_t v656 = v654 * v655;	// L1015
              int32_t v657 = v653;	// L1016
              int32_t v658 = v657 + v656;	// L1017
              int8_t v659 = v658;	// L1018
              v28[0][v645][v646][v647] = v659;	// L1019
            }
          }
        }
      }
    }
  }
  for (int v660 = 0; v660 < 512; v660 += 1) {	// L1026
    for (int v661 = 0; v661 < 4; v661 += 1) {	// L1027
      for (int v662 = 0; v662 < 4; v662 += 1) {	// L1028
        int8_t v663 = v28[0][v660][v661][v662];	// L1029
        int8_t v664 = v33[0][v660][v661][v662];	// L1030
        int32_t v665 = v663;	// L1031
        int32_t v666 = v664;	// L1032
        int32_t v667 = v665 + v666;	// L1033
        int8_t v668 = v667;	// L1034
        v27[0][v660][v661][v662] = v668;	// L1035
      }
    }
  }
  for (int v669 = 0; v669 < 512; v669 += 1) {	// L1039
    for (int v670 = 0; v670 < 4; v670 += 1) {	// L1040
      for (int v671 = 0; v671 < 4; v671 += 1) {	// L1041
        int8_t v672 = v27[0][v669][v670][v671];	// L1042
        bool v673 = v672 < 0;	// L1043
        int8_t v674 = v673 ? (int8_t)0 : (int8_t)v672;	// L1044
        v26[0][v669][v670][v671] = v674;	// L1045
      }
    }
  }
  for (int v675 = 0; v675 < 512; v675 += 1) {	// L1049
    v25[0][v675][0][0] = 0;	// L1050
  }
  for (int v676 = 0; v676 < 512; v676 += 1) {	// L1052
    for (int v677 = 0; v677 < 4; v677 += 1) {	// L1053
      for (int v678 = 0; v678 < 4; v678 += 1) {	// L1054
        int8_t v679 = v26[0][v676][v677][v678];	// L1055
        int8_t v680 = v25[0][v676][0][0];	// L1056
        int32_t v681 = v680;	// L1057
        int32_t v682 = v679;	// L1058
        int32_t v683 = v681 + v682;	// L1059
        int8_t v684 = v683;	// L1060
        v25[0][v676][0][0] = v684;	// L1061
      }
    }
  }
  for (int v685 = 0; v685 < 512; v685 += 1) {	// L1065
    int8_t v686 = v25[0][v685][0][0];	// L1066
    int8_t v687 = v686 / 16;	// L1067
    v25[0][v685][0][0] = v687;	// L1068
  }
  for (int v688 = 0; v688 < 512; v688 += 1) {	// L1070
    int8_t v689 = v25[0][v688][0][0];	// L1071
    v24[0][v688] = v689;	// L1072
  }
  #pragma HLS resource variable=v23 core=ram_s2p_bram

  for (int v691 = 0; v691 < 10; v691 += 1) {	// L1075
    v22[0][v691] = 0;	// L1076
    for (int v692 = 0; v692 < 512; v692 += 1) {	// L1077
      int8_t v693 = v24[0][v692];	// L1078
      int8_t v694 = v21[v691][v692];	// L1079
      int8_t v695 = v22[0][v691];	// L1080
      int16_t v696 = v693;	// L1081
      int16_t v697 = v694;	// L1082
      int32_t v698 = v696 * v697;	// L1083
      int32_t v699 = v695;	// L1084
      int32_t v700 = v699 + v698;	// L1085
      int8_t v701 = v700;	// L1086
      v22[0][v691] = v701;	// L1087
    }
    int8_t v702 = v22[0][v691];	// L1089
    int16_t v703 = 1;	// L1090
    int16_t v704 = v702;	// L1091
    int32_t v705 = v703 * v704;	// L1092
    int8_t v706 = v23[v691];	// L1093
    int16_t v707 = 1;	// L1094
    int16_t v708 = v706;	// L1095
    int32_t v709 = v707 * v708;	// L1096
    int32_t v710 = v705 + v709;	// L1097
    int8_t v711 = v710;	// L1098
    v22[0][v691] = v711;	// L1099
  }
}

