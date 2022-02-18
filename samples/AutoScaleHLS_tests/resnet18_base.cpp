
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
  float v0[1][3][32][32],
  float v1[64][3][3][3],
  float v2[64][64][3][3],
  float v3[64][64][3][3],
  float v4[64][64][3][3],
  float v5[64][64][3][3],
  float v6[128][64][3][3],
  float v7[128][128][3][3],
  float v8[128][64][1][1],
  float v9[128][128][3][3],
  float v10[128][128][3][3],
  float v11[256][128][3][3],
  float v12[256][256][3][3],
  float v13[256][128][1][1],
  float v14[256][256][3][3],
  float v15[256][256][3][3],
  float v16[512][256][3][3],
  float v17[512][512][3][3],
  float v18[512][256][1][1],
  float v19[512][512][3][3],
  float v20[512][512][3][3],
  float v21[10][512],
  float v22[1][10]
) {	// L4
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

  float v23[10] = {-2.781226e-02, -4.107117e-02, -8.704335e-03, -3.831929e-02, -2.075570e-02, 4.087221e-02, 3.640073e-02, 4.095368e-02, 3.038846e-03, -4.327787e-02};	// L5
  float v24[1][512];	// L10
  #pragma HLS resource variable=v24 core=ram_s2p_bram

  float v25[1][512][1][1];	// L11
  #pragma HLS resource variable=v25 core=ram_s2p_bram

  float v26[1][512][4][4];	// L12
  #pragma HLS resource variable=v26 core=ram_s2p_bram

  float v27[1][512][4][4];	// L13
  #pragma HLS resource variable=v27 core=ram_s2p_bram

  float v28[1][512][4][4];	// L14
  #pragma HLS resource variable=v28 core=ram_s2p_bram

  float v29[1][512][6][6];	// L15
  #pragma HLS resource variable=v29 core=ram_s2p_bram

  float v30[1][512][4][4];	// L16
  #pragma HLS resource variable=v30 core=ram_s2p_bram

  float v31[1][512][4][4];	// L17
  #pragma HLS resource variable=v31 core=ram_s2p_bram

  float v32[1][512][6][6];	// L18
  #pragma HLS resource variable=v32 core=ram_s2p_bram

  float v33[1][512][4][4];	// L19
  #pragma HLS resource variable=v33 core=ram_s2p_bram

  float v34[1][512][4][4];	// L20
  #pragma HLS resource variable=v34 core=ram_s2p_bram

  float v35[1][512][4][4];	// L21
  #pragma HLS resource variable=v35 core=ram_s2p_bram

  float v36[1][512][4][4];	// L22
  #pragma HLS resource variable=v36 core=ram_s2p_bram

  float v37[1][512][6][6];	// L23
  #pragma HLS resource variable=v37 core=ram_s2p_bram

  float v38[1][512][4][4];	// L24
  #pragma HLS resource variable=v38 core=ram_s2p_bram

  float v39[1][512][4][4];	// L25
  #pragma HLS resource variable=v39 core=ram_s2p_bram

  float v40[1][256][10][10];	// L26
  #pragma HLS resource variable=v40 core=ram_s2p_bram

  float v41[1][256][8][8];	// L27
  #pragma HLS resource variable=v41 core=ram_s2p_bram

  float v42[1][256][8][8];	// L28
  #pragma HLS resource variable=v42 core=ram_s2p_bram

  float v43[1][256][8][8];	// L29
  #pragma HLS resource variable=v43 core=ram_s2p_bram

  float v44[1][256][10][10];	// L30
  #pragma HLS resource variable=v44 core=ram_s2p_bram

  float v45[1][256][8][8];	// L31
  #pragma HLS resource variable=v45 core=ram_s2p_bram

  float v46[1][256][8][8];	// L32
  #pragma HLS resource variable=v46 core=ram_s2p_bram

  float v47[1][256][10][10];	// L33
  #pragma HLS resource variable=v47 core=ram_s2p_bram

  float v48[1][256][8][8];	// L34
  #pragma HLS resource variable=v48 core=ram_s2p_bram

  float v49[1][256][8][8];	// L35
  #pragma HLS resource variable=v49 core=ram_s2p_bram

  float v50[1][256][8][8];	// L36
  #pragma HLS resource variable=v50 core=ram_s2p_bram

  float v51[1][256][8][8];	// L37
  #pragma HLS resource variable=v51 core=ram_s2p_bram

  float v52[1][256][10][10];	// L38
  #pragma HLS resource variable=v52 core=ram_s2p_bram

  float v53[1][256][8][8];	// L39
  #pragma HLS resource variable=v53 core=ram_s2p_bram

  float v54[1][256][8][8];	// L40
  #pragma HLS resource variable=v54 core=ram_s2p_bram

  float v55[1][128][18][18];	// L41
  #pragma HLS resource variable=v55 core=ram_s2p_bram

  float v56[1][128][16][16];	// L42
  #pragma HLS resource variable=v56 core=ram_s2p_bram

  float v57[1][128][16][16];	// L43
  #pragma HLS resource variable=v57 core=ram_s2p_bram

  float v58[1][128][16][16];	// L44
  #pragma HLS resource variable=v58 core=ram_s2p_bram

  float v59[1][128][18][18];	// L45
  #pragma HLS resource variable=v59 core=ram_s2p_bram

  float v60[1][128][16][16];	// L46
  #pragma HLS resource variable=v60 core=ram_s2p_bram

  float v61[1][128][16][16];	// L47
  #pragma HLS resource variable=v61 core=ram_s2p_bram

  float v62[1][128][18][18];	// L48
  #pragma HLS resource variable=v62 core=ram_s2p_bram

  float v63[1][128][16][16];	// L49
  #pragma HLS resource variable=v63 core=ram_s2p_bram

  float v64[1][128][16][16];	// L50
  #pragma HLS resource variable=v64 core=ram_s2p_bram

  float v65[1][128][16][16];	// L51
  #pragma HLS resource variable=v65 core=ram_s2p_bram

  float v66[1][128][16][16];	// L52
  #pragma HLS resource variable=v66 core=ram_s2p_bram

  float v67[1][128][18][18];	// L53
  #pragma HLS resource variable=v67 core=ram_s2p_bram

  float v68[1][128][16][16];	// L54
  #pragma HLS resource variable=v68 core=ram_s2p_bram

  float v69[1][128][16][16];	// L55
  #pragma HLS resource variable=v69 core=ram_s2p_bram

  float v70[1][64][34][34];	// L56
  #pragma HLS resource variable=v70 core=ram_s2p_bram

  float v71[1][64][32][32];	// L57
  #pragma HLS resource variable=v71 core=ram_s2p_bram

  float v72[1][64][32][32];	// L58
  #pragma HLS resource variable=v72 core=ram_s2p_bram

  float v73[1][64][32][32];	// L59
  #pragma HLS resource variable=v73 core=ram_s2p_bram

  float v74[1][64][34][34];	// L60
  #pragma HLS resource variable=v74 core=ram_s2p_bram

  float v75[1][64][32][32];	// L61
  #pragma HLS resource variable=v75 core=ram_s2p_bram

  float v76[1][64][32][32];	// L62
  #pragma HLS resource variable=v76 core=ram_s2p_bram

  float v77[1][64][34][34];	// L63
  #pragma HLS resource variable=v77 core=ram_s2p_bram

  float v78[1][64][32][32];	// L64
  #pragma HLS resource variable=v78 core=ram_s2p_bram

  float v79[1][64][32][32];	// L65
  #pragma HLS resource variable=v79 core=ram_s2p_bram

  float v80[1][64][32][32];	// L66
  #pragma HLS resource variable=v80 core=ram_s2p_bram

  float v81[1][64][34][34];	// L67
  #pragma HLS resource variable=v81 core=ram_s2p_bram

  float v82[1][64][32][32];	// L68
  #pragma HLS resource variable=v82 core=ram_s2p_bram

  float v83[1][64][32][32];	// L69
  #pragma HLS resource variable=v83 core=ram_s2p_bram

  float v84[1][64][34][34];	// L70
  #pragma HLS resource variable=v84 core=ram_s2p_bram

  float v85[1][64][32][32];	// L71
  #pragma HLS resource variable=v85 core=ram_s2p_bram

  float v86[1][64][32][32];	// L72
  #pragma HLS resource variable=v86 core=ram_s2p_bram

  float v87[1][3][34][34];	// L73
  #pragma HLS resource variable=v87 core=ram_s2p_bram

  for (int v88 = 0; v88 < 3; v88 += 1) {	// L74
    for (int v89 = 0; v89 < 34; v89 += 1) {	// L75
      for (int v90 = 0; v90 < 34; v90 += 1) {	// L76
        v87[0][v88][v89][v90] = 0.000000;	// L77
      }
    }
  }
  for (int v91 = 0; v91 < 3; v91 += 1) {	// L81
    for (int v92 = 0; v92 < 32; v92 += 1) {	// L82
      for (int v93 = 0; v93 < 32; v93 += 1) {	// L83
        float v94 = v0[0][v91][v92][v93];	// L84
        v87[0][v91][(v92 + 1)][(v93 + 1)] = v94;	// L85
      }
    }
  }
  for (int v95 = 0; v95 < 64; v95 += 1) {	// L89
    for (int v96 = 0; v96 < 32; v96 += 1) {	// L90
      for (int v97 = 0; v97 < 32; v97 += 1) {	// L91
        v86[0][v95][v96][v97] = 0.000000;	// L92
        for (int v98 = 0; v98 < 3; v98 += 1) {	// L93
          for (int v99 = 0; v99 < 3; v99 += 1) {	// L94
            for (int v100 = 0; v100 < 3; v100 += 1) {	// L95
              float v101 = v87[0][v98][(v96 + v99)][(v97 + v100)];	// L96
              float v102 = v1[v95][v98][v99][v100];	// L97
              float v103 = v86[0][v95][v96][v97];	// L98
              float v104 = v101 * v102;	// L99
              float v105 = v103 + v104;	// L100
              v86[0][v95][v96][v97] = v105;	// L101
            }
          }
        }
      }
    }
  }
  for (int v106 = 0; v106 < 64; v106 += 1) {	// L108
    for (int v107 = 0; v107 < 32; v107 += 1) {	// L109
      for (int v108 = 0; v108 < 32; v108 += 1) {	// L110
        float v109 = v86[0][v106][v107][v108];	// L111
        bool v110 = v109 < 0.000000;	// L112
        float v111 = v110 ? (float)0.000000 : (float)v109;	// L113
        v85[0][v106][v107][v108] = v111;	// L114
      }
    }
  }
  for (int v112 = 0; v112 < 64; v112 += 1) {	// L118
    for (int v113 = 0; v113 < 34; v113 += 1) {	// L119
      for (int v114 = 0; v114 < 34; v114 += 1) {	// L120
        v84[0][v112][v113][v114] = 0.000000;	// L121
      }
    }
  }
  for (int v115 = 0; v115 < 64; v115 += 1) {	// L125
    for (int v116 = 0; v116 < 32; v116 += 1) {	// L126
      for (int v117 = 0; v117 < 32; v117 += 1) {	// L127
        float v118 = v85[0][v115][v116][v117];	// L128
        v84[0][v115][(v116 + 1)][(v117 + 1)] = v118;	// L129
      }
    }
  }
  for (int v119 = 0; v119 < 64; v119 += 1) {	// L133
    for (int v120 = 0; v120 < 32; v120 += 1) {	// L134
      for (int v121 = 0; v121 < 32; v121 += 1) {	// L135
        v83[0][v119][v120][v121] = 0.000000;	// L136
        for (int v122 = 0; v122 < 64; v122 += 1) {	// L137
          for (int v123 = 0; v123 < 3; v123 += 1) {	// L138
            for (int v124 = 0; v124 < 3; v124 += 1) {	// L139
              float v125 = v84[0][v122][(v120 + v123)][(v121 + v124)];	// L140
              float v126 = v2[v119][v122][v123][v124];	// L141
              float v127 = v83[0][v119][v120][v121];	// L142
              float v128 = v125 * v126;	// L143
              float v129 = v127 + v128;	// L144
              v83[0][v119][v120][v121] = v129;	// L145
            }
          }
        }
      }
    }
  }
  for (int v130 = 0; v130 < 64; v130 += 1) {	// L152
    for (int v131 = 0; v131 < 32; v131 += 1) {	// L153
      for (int v132 = 0; v132 < 32; v132 += 1) {	// L154
        float v133 = v83[0][v130][v131][v132];	// L155
        bool v134 = v133 < 0.000000;	// L156
        float v135 = v134 ? (float)0.000000 : (float)v133;	// L157
        v82[0][v130][v131][v132] = v135;	// L158
      }
    }
  }
  for (int v136 = 0; v136 < 64; v136 += 1) {	// L162
    for (int v137 = 0; v137 < 34; v137 += 1) {	// L163
      for (int v138 = 0; v138 < 34; v138 += 1) {	// L164
        v81[0][v136][v137][v138] = 0.000000;	// L165
      }
    }
  }
  for (int v139 = 0; v139 < 64; v139 += 1) {	// L169
    for (int v140 = 0; v140 < 32; v140 += 1) {	// L170
      for (int v141 = 0; v141 < 32; v141 += 1) {	// L171
        float v142 = v82[0][v139][v140][v141];	// L172
        v81[0][v139][(v140 + 1)][(v141 + 1)] = v142;	// L173
      }
    }
  }
  for (int v143 = 0; v143 < 64; v143 += 1) {	// L177
    for (int v144 = 0; v144 < 32; v144 += 1) {	// L178
      for (int v145 = 0; v145 < 32; v145 += 1) {	// L179
        v80[0][v143][v144][v145] = 0.000000;	// L180
        for (int v146 = 0; v146 < 64; v146 += 1) {	// L181
          for (int v147 = 0; v147 < 3; v147 += 1) {	// L182
            for (int v148 = 0; v148 < 3; v148 += 1) {	// L183
              float v149 = v81[0][v146][(v144 + v147)][(v145 + v148)];	// L184
              float v150 = v3[v143][v146][v147][v148];	// L185
              float v151 = v80[0][v143][v144][v145];	// L186
              float v152 = v149 * v150;	// L187
              float v153 = v151 + v152;	// L188
              v80[0][v143][v144][v145] = v153;	// L189
            }
          }
        }
      }
    }
  }
  for (int v154 = 0; v154 < 64; v154 += 1) {	// L196
    for (int v155 = 0; v155 < 32; v155 += 1) {	// L197
      for (int v156 = 0; v156 < 32; v156 += 1) {	// L198
        float v157 = v80[0][v154][v155][v156];	// L199
        float v158 = v85[0][v154][v155][v156];	// L200
        float v159 = v157 + v158;	// L201
        v79[0][v154][v155][v156] = v159;	// L202
      }
    }
  }
  for (int v160 = 0; v160 < 64; v160 += 1) {	// L206
    for (int v161 = 0; v161 < 32; v161 += 1) {	// L207
      for (int v162 = 0; v162 < 32; v162 += 1) {	// L208
        float v163 = v79[0][v160][v161][v162];	// L209
        bool v164 = v163 < 0.000000;	// L210
        float v165 = v164 ? (float)0.000000 : (float)v163;	// L211
        v78[0][v160][v161][v162] = v165;	// L212
      }
    }
  }
  for (int v166 = 0; v166 < 64; v166 += 1) {	// L216
    for (int v167 = 0; v167 < 34; v167 += 1) {	// L217
      for (int v168 = 0; v168 < 34; v168 += 1) {	// L218
        v77[0][v166][v167][v168] = 0.000000;	// L219
      }
    }
  }
  for (int v169 = 0; v169 < 64; v169 += 1) {	// L223
    for (int v170 = 0; v170 < 32; v170 += 1) {	// L224
      for (int v171 = 0; v171 < 32; v171 += 1) {	// L225
        float v172 = v78[0][v169][v170][v171];	// L226
        v77[0][v169][(v170 + 1)][(v171 + 1)] = v172;	// L227
      }
    }
  }
  for (int v173 = 0; v173 < 64; v173 += 1) {	// L231
    for (int v174 = 0; v174 < 32; v174 += 1) {	// L232
      for (int v175 = 0; v175 < 32; v175 += 1) {	// L233
        v76[0][v173][v174][v175] = 0.000000;	// L234
        for (int v176 = 0; v176 < 64; v176 += 1) {	// L235
          for (int v177 = 0; v177 < 3; v177 += 1) {	// L236
            for (int v178 = 0; v178 < 3; v178 += 1) {	// L237
              float v179 = v77[0][v176][(v174 + v177)][(v175 + v178)];	// L238
              float v180 = v4[v173][v176][v177][v178];	// L239
              float v181 = v76[0][v173][v174][v175];	// L240
              float v182 = v179 * v180;	// L241
              float v183 = v181 + v182;	// L242
              v76[0][v173][v174][v175] = v183;	// L243
            }
          }
        }
      }
    }
  }
  for (int v184 = 0; v184 < 64; v184 += 1) {	// L250
    for (int v185 = 0; v185 < 32; v185 += 1) {	// L251
      for (int v186 = 0; v186 < 32; v186 += 1) {	// L252
        float v187 = v76[0][v184][v185][v186];	// L253
        bool v188 = v187 < 0.000000;	// L254
        float v189 = v188 ? (float)0.000000 : (float)v187;	// L255
        v75[0][v184][v185][v186] = v189;	// L256
      }
    }
  }
  for (int v190 = 0; v190 < 64; v190 += 1) {	// L260
    for (int v191 = 0; v191 < 34; v191 += 1) {	// L261
      for (int v192 = 0; v192 < 34; v192 += 1) {	// L262
        v74[0][v190][v191][v192] = 0.000000;	// L263
      }
    }
  }
  for (int v193 = 0; v193 < 64; v193 += 1) {	// L267
    for (int v194 = 0; v194 < 32; v194 += 1) {	// L268
      for (int v195 = 0; v195 < 32; v195 += 1) {	// L269
        float v196 = v75[0][v193][v194][v195];	// L270
        v74[0][v193][(v194 + 1)][(v195 + 1)] = v196;	// L271
      }
    }
  }
  for (int v197 = 0; v197 < 64; v197 += 1) {	// L275
    for (int v198 = 0; v198 < 32; v198 += 1) {	// L276
      for (int v199 = 0; v199 < 32; v199 += 1) {	// L277
        v73[0][v197][v198][v199] = 0.000000;	// L278
        for (int v200 = 0; v200 < 64; v200 += 1) {	// L279
          for (int v201 = 0; v201 < 3; v201 += 1) {	// L280
            for (int v202 = 0; v202 < 3; v202 += 1) {	// L281
              float v203 = v74[0][v200][(v198 + v201)][(v199 + v202)];	// L282
              float v204 = v5[v197][v200][v201][v202];	// L283
              float v205 = v73[0][v197][v198][v199];	// L284
              float v206 = v203 * v204;	// L285
              float v207 = v205 + v206;	// L286
              v73[0][v197][v198][v199] = v207;	// L287
            }
          }
        }
      }
    }
  }
  for (int v208 = 0; v208 < 64; v208 += 1) {	// L294
    for (int v209 = 0; v209 < 32; v209 += 1) {	// L295
      for (int v210 = 0; v210 < 32; v210 += 1) {	// L296
        float v211 = v73[0][v208][v209][v210];	// L297
        float v212 = v78[0][v208][v209][v210];	// L298
        float v213 = v211 + v212;	// L299
        v72[0][v208][v209][v210] = v213;	// L300
      }
    }
  }
  for (int v214 = 0; v214 < 64; v214 += 1) {	// L304
    for (int v215 = 0; v215 < 32; v215 += 1) {	// L305
      for (int v216 = 0; v216 < 32; v216 += 1) {	// L306
        float v217 = v72[0][v214][v215][v216];	// L307
        bool v218 = v217 < 0.000000;	// L308
        float v219 = v218 ? (float)0.000000 : (float)v217;	// L309
        v71[0][v214][v215][v216] = v219;	// L310
      }
    }
  }
  for (int v220 = 0; v220 < 64; v220 += 1) {	// L314
    for (int v221 = 0; v221 < 34; v221 += 1) {	// L315
      for (int v222 = 0; v222 < 34; v222 += 1) {	// L316
        v70[0][v220][v221][v222] = 0.000000;	// L317
      }
    }
  }
  for (int v223 = 0; v223 < 64; v223 += 1) {	// L321
    for (int v224 = 0; v224 < 32; v224 += 1) {	// L322
      for (int v225 = 0; v225 < 32; v225 += 1) {	// L323
        float v226 = v71[0][v223][v224][v225];	// L324
        v70[0][v223][(v224 + 1)][(v225 + 1)] = v226;	// L325
      }
    }
  }
  for (int v227 = 0; v227 < 128; v227 += 1) {	// L329
    for (int v228 = 0; v228 < 16; v228 += 1) {	// L330
      for (int v229 = 0; v229 < 16; v229 += 1) {	// L331
        v69[0][v227][v228][v229] = 0.000000;	// L332
        for (int v230 = 0; v230 < 64; v230 += 1) {	// L333
          for (int v231 = 0; v231 < 3; v231 += 1) {	// L334
            for (int v232 = 0; v232 < 3; v232 += 1) {	// L335
              float v233 = v70[0][v230][((v228 * 2) + v231)][((v229 * 2) + v232)];	// L336
              float v234 = v6[v227][v230][v231][v232];	// L337
              float v235 = v69[0][v227][v228][v229];	// L338
              float v236 = v233 * v234;	// L339
              float v237 = v235 + v236;	// L340
              v69[0][v227][v228][v229] = v237;	// L341
            }
          }
        }
      }
    }
  }
  for (int v238 = 0; v238 < 128; v238 += 1) {	// L348
    for (int v239 = 0; v239 < 16; v239 += 1) {	// L349
      for (int v240 = 0; v240 < 16; v240 += 1) {	// L350
        float v241 = v69[0][v238][v239][v240];	// L351
        bool v242 = v241 < 0.000000;	// L352
        float v243 = v242 ? (float)0.000000 : (float)v241;	// L353
        v68[0][v238][v239][v240] = v243;	// L354
      }
    }
  }
  for (int v244 = 0; v244 < 128; v244 += 1) {	// L358
    for (int v245 = 0; v245 < 18; v245 += 1) {	// L359
      for (int v246 = 0; v246 < 18; v246 += 1) {	// L360
        v67[0][v244][v245][v246] = 0.000000;	// L361
      }
    }
  }
  for (int v247 = 0; v247 < 128; v247 += 1) {	// L365
    for (int v248 = 0; v248 < 16; v248 += 1) {	// L366
      for (int v249 = 0; v249 < 16; v249 += 1) {	// L367
        float v250 = v68[0][v247][v248][v249];	// L368
        v67[0][v247][(v248 + 1)][(v249 + 1)] = v250;	// L369
      }
    }
  }
  for (int v251 = 0; v251 < 128; v251 += 1) {	// L373
    for (int v252 = 0; v252 < 16; v252 += 1) {	// L374
      for (int v253 = 0; v253 < 16; v253 += 1) {	// L375
        v66[0][v251][v252][v253] = 0.000000;	// L376
        for (int v254 = 0; v254 < 128; v254 += 1) {	// L377
          for (int v255 = 0; v255 < 3; v255 += 1) {	// L378
            for (int v256 = 0; v256 < 3; v256 += 1) {	// L379
              float v257 = v67[0][v254][(v252 + v255)][(v253 + v256)];	// L380
              float v258 = v7[v251][v254][v255][v256];	// L381
              float v259 = v66[0][v251][v252][v253];	// L382
              float v260 = v257 * v258;	// L383
              float v261 = v259 + v260;	// L384
              v66[0][v251][v252][v253] = v261;	// L385
            }
          }
        }
      }
    }
  }
  for (int v262 = 0; v262 < 128; v262 += 1) {	// L392
    for (int v263 = 0; v263 < 16; v263 += 1) {	// L393
      for (int v264 = 0; v264 < 16; v264 += 1) {	// L394
        v65[0][v262][v263][v264] = 0.000000;	// L395
        for (int v265 = 0; v265 < 64; v265 += 1) {	// L396
          float v266 = v71[0][v265][(v263 * 2)][(v264 * 2)];	// L397
          float v267 = v8[v262][v265][0][0];	// L398
          float v268 = v65[0][v262][v263][v264];	// L399
          float v269 = v266 * v267;	// L400
          float v270 = v268 + v269;	// L401
          v65[0][v262][v263][v264] = v270;	// L402
        }
      }
    }
  }
  for (int v271 = 0; v271 < 128; v271 += 1) {	// L407
    for (int v272 = 0; v272 < 16; v272 += 1) {	// L408
      for (int v273 = 0; v273 < 16; v273 += 1) {	// L409
        float v274 = v66[0][v271][v272][v273];	// L410
        float v275 = v65[0][v271][v272][v273];	// L411
        float v276 = v274 + v275;	// L412
        v64[0][v271][v272][v273] = v276;	// L413
      }
    }
  }
  for (int v277 = 0; v277 < 128; v277 += 1) {	// L417
    for (int v278 = 0; v278 < 16; v278 += 1) {	// L418
      for (int v279 = 0; v279 < 16; v279 += 1) {	// L419
        float v280 = v64[0][v277][v278][v279];	// L420
        bool v281 = v280 < 0.000000;	// L421
        float v282 = v281 ? (float)0.000000 : (float)v280;	// L422
        v63[0][v277][v278][v279] = v282;	// L423
      }
    }
  }
  for (int v283 = 0; v283 < 128; v283 += 1) {	// L427
    for (int v284 = 0; v284 < 18; v284 += 1) {	// L428
      for (int v285 = 0; v285 < 18; v285 += 1) {	// L429
        v62[0][v283][v284][v285] = 0.000000;	// L430
      }
    }
  }
  for (int v286 = 0; v286 < 128; v286 += 1) {	// L434
    for (int v287 = 0; v287 < 16; v287 += 1) {	// L435
      for (int v288 = 0; v288 < 16; v288 += 1) {	// L436
        float v289 = v63[0][v286][v287][v288];	// L437
        v62[0][v286][(v287 + 1)][(v288 + 1)] = v289;	// L438
      }
    }
  }
  for (int v290 = 0; v290 < 128; v290 += 1) {	// L442
    for (int v291 = 0; v291 < 16; v291 += 1) {	// L443
      for (int v292 = 0; v292 < 16; v292 += 1) {	// L444
        v61[0][v290][v291][v292] = 0.000000;	// L445
        for (int v293 = 0; v293 < 128; v293 += 1) {	// L446
          for (int v294 = 0; v294 < 3; v294 += 1) {	// L447
            for (int v295 = 0; v295 < 3; v295 += 1) {	// L448
              float v296 = v62[0][v293][(v291 + v294)][(v292 + v295)];	// L449
              float v297 = v9[v290][v293][v294][v295];	// L450
              float v298 = v61[0][v290][v291][v292];	// L451
              float v299 = v296 * v297;	// L452
              float v300 = v298 + v299;	// L453
              v61[0][v290][v291][v292] = v300;	// L454
            }
          }
        }
      }
    }
  }
  for (int v301 = 0; v301 < 128; v301 += 1) {	// L461
    for (int v302 = 0; v302 < 16; v302 += 1) {	// L462
      for (int v303 = 0; v303 < 16; v303 += 1) {	// L463
        float v304 = v61[0][v301][v302][v303];	// L464
        bool v305 = v304 < 0.000000;	// L465
        float v306 = v305 ? (float)0.000000 : (float)v304;	// L466
        v60[0][v301][v302][v303] = v306;	// L467
      }
    }
  }
  for (int v307 = 0; v307 < 128; v307 += 1) {	// L471
    for (int v308 = 0; v308 < 18; v308 += 1) {	// L472
      for (int v309 = 0; v309 < 18; v309 += 1) {	// L473
        v59[0][v307][v308][v309] = 0.000000;	// L474
      }
    }
  }
  for (int v310 = 0; v310 < 128; v310 += 1) {	// L478
    for (int v311 = 0; v311 < 16; v311 += 1) {	// L479
      for (int v312 = 0; v312 < 16; v312 += 1) {	// L480
        float v313 = v60[0][v310][v311][v312];	// L481
        v59[0][v310][(v311 + 1)][(v312 + 1)] = v313;	// L482
      }
    }
  }
  for (int v314 = 0; v314 < 128; v314 += 1) {	// L486
    for (int v315 = 0; v315 < 16; v315 += 1) {	// L487
      for (int v316 = 0; v316 < 16; v316 += 1) {	// L488
        v58[0][v314][v315][v316] = 0.000000;	// L489
        for (int v317 = 0; v317 < 128; v317 += 1) {	// L490
          for (int v318 = 0; v318 < 3; v318 += 1) {	// L491
            for (int v319 = 0; v319 < 3; v319 += 1) {	// L492
              float v320 = v59[0][v317][(v315 + v318)][(v316 + v319)];	// L493
              float v321 = v10[v314][v317][v318][v319];	// L494
              float v322 = v58[0][v314][v315][v316];	// L495
              float v323 = v320 * v321;	// L496
              float v324 = v322 + v323;	// L497
              v58[0][v314][v315][v316] = v324;	// L498
            }
          }
        }
      }
    }
  }
  for (int v325 = 0; v325 < 128; v325 += 1) {	// L505
    for (int v326 = 0; v326 < 16; v326 += 1) {	// L506
      for (int v327 = 0; v327 < 16; v327 += 1) {	// L507
        float v328 = v58[0][v325][v326][v327];	// L508
        float v329 = v63[0][v325][v326][v327];	// L509
        float v330 = v328 + v329;	// L510
        v57[0][v325][v326][v327] = v330;	// L511
      }
    }
  }
  for (int v331 = 0; v331 < 128; v331 += 1) {	// L515
    for (int v332 = 0; v332 < 16; v332 += 1) {	// L516
      for (int v333 = 0; v333 < 16; v333 += 1) {	// L517
        float v334 = v57[0][v331][v332][v333];	// L518
        bool v335 = v334 < 0.000000;	// L519
        float v336 = v335 ? (float)0.000000 : (float)v334;	// L520
        v56[0][v331][v332][v333] = v336;	// L521
      }
    }
  }
  for (int v337 = 0; v337 < 128; v337 += 1) {	// L525
    for (int v338 = 0; v338 < 18; v338 += 1) {	// L526
      for (int v339 = 0; v339 < 18; v339 += 1) {	// L527
        v55[0][v337][v338][v339] = 0.000000;	// L528
      }
    }
  }
  for (int v340 = 0; v340 < 128; v340 += 1) {	// L532
    for (int v341 = 0; v341 < 16; v341 += 1) {	// L533
      for (int v342 = 0; v342 < 16; v342 += 1) {	// L534
        float v343 = v56[0][v340][v341][v342];	// L535
        v55[0][v340][(v341 + 1)][(v342 + 1)] = v343;	// L536
      }
    }
  }
  for (int v344 = 0; v344 < 256; v344 += 1) {	// L540
    for (int v345 = 0; v345 < 8; v345 += 1) {	// L541
      for (int v346 = 0; v346 < 8; v346 += 1) {	// L542
        v54[0][v344][v345][v346] = 0.000000;	// L543
        for (int v347 = 0; v347 < 128; v347 += 1) {	// L544
          for (int v348 = 0; v348 < 3; v348 += 1) {	// L545
            for (int v349 = 0; v349 < 3; v349 += 1) {	// L546
              float v350 = v55[0][v347][((v345 * 2) + v348)][((v346 * 2) + v349)];	// L547
              float v351 = v11[v344][v347][v348][v349];	// L548
              float v352 = v54[0][v344][v345][v346];	// L549
              float v353 = v350 * v351;	// L550
              float v354 = v352 + v353;	// L551
              v54[0][v344][v345][v346] = v354;	// L552
            }
          }
        }
      }
    }
  }
  for (int v355 = 0; v355 < 256; v355 += 1) {	// L559
    for (int v356 = 0; v356 < 8; v356 += 1) {	// L560
      for (int v357 = 0; v357 < 8; v357 += 1) {	// L561
        float v358 = v54[0][v355][v356][v357];	// L562
        bool v359 = v358 < 0.000000;	// L563
        float v360 = v359 ? (float)0.000000 : (float)v358;	// L564
        v53[0][v355][v356][v357] = v360;	// L565
      }
    }
  }
  for (int v361 = 0; v361 < 256; v361 += 1) {	// L569
    for (int v362 = 0; v362 < 10; v362 += 1) {	// L570
      for (int v363 = 0; v363 < 10; v363 += 1) {	// L571
        v52[0][v361][v362][v363] = 0.000000;	// L572
      }
    }
  }
  for (int v364 = 0; v364 < 256; v364 += 1) {	// L576
    for (int v365 = 0; v365 < 8; v365 += 1) {	// L577
      for (int v366 = 0; v366 < 8; v366 += 1) {	// L578
        float v367 = v53[0][v364][v365][v366];	// L579
        v52[0][v364][(v365 + 1)][(v366 + 1)] = v367;	// L580
      }
    }
  }
  for (int v368 = 0; v368 < 256; v368 += 1) {	// L584
    for (int v369 = 0; v369 < 8; v369 += 1) {	// L585
      for (int v370 = 0; v370 < 8; v370 += 1) {	// L586
        v51[0][v368][v369][v370] = 0.000000;	// L587
        for (int v371 = 0; v371 < 256; v371 += 1) {	// L588
          for (int v372 = 0; v372 < 3; v372 += 1) {	// L589
            for (int v373 = 0; v373 < 3; v373 += 1) {	// L590
              float v374 = v52[0][v371][(v369 + v372)][(v370 + v373)];	// L591
              float v375 = v12[v368][v371][v372][v373];	// L592
              float v376 = v51[0][v368][v369][v370];	// L593
              float v377 = v374 * v375;	// L594
              float v378 = v376 + v377;	// L595
              v51[0][v368][v369][v370] = v378;	// L596
            }
          }
        }
      }
    }
  }
  for (int v379 = 0; v379 < 256; v379 += 1) {	// L603
    for (int v380 = 0; v380 < 8; v380 += 1) {	// L604
      for (int v381 = 0; v381 < 8; v381 += 1) {	// L605
        v50[0][v379][v380][v381] = 0.000000;	// L606
        for (int v382 = 0; v382 < 128; v382 += 1) {	// L607
          float v383 = v56[0][v382][(v380 * 2)][(v381 * 2)];	// L608
          float v384 = v13[v379][v382][0][0];	// L609
          float v385 = v50[0][v379][v380][v381];	// L610
          float v386 = v383 * v384;	// L611
          float v387 = v385 + v386;	// L612
          v50[0][v379][v380][v381] = v387;	// L613
        }
      }
    }
  }
  for (int v388 = 0; v388 < 256; v388 += 1) {	// L618
    for (int v389 = 0; v389 < 8; v389 += 1) {	// L619
      for (int v390 = 0; v390 < 8; v390 += 1) {	// L620
        float v391 = v51[0][v388][v389][v390];	// L621
        float v392 = v50[0][v388][v389][v390];	// L622
        float v393 = v391 + v392;	// L623
        v49[0][v388][v389][v390] = v393;	// L624
      }
    }
  }
  for (int v394 = 0; v394 < 256; v394 += 1) {	// L628
    for (int v395 = 0; v395 < 8; v395 += 1) {	// L629
      for (int v396 = 0; v396 < 8; v396 += 1) {	// L630
        float v397 = v49[0][v394][v395][v396];	// L631
        bool v398 = v397 < 0.000000;	// L632
        float v399 = v398 ? (float)0.000000 : (float)v397;	// L633
        v48[0][v394][v395][v396] = v399;	// L634
      }
    }
  }
  for (int v400 = 0; v400 < 256; v400 += 1) {	// L638
    for (int v401 = 0; v401 < 10; v401 += 1) {	// L639
      for (int v402 = 0; v402 < 10; v402 += 1) {	// L640
        v47[0][v400][v401][v402] = 0.000000;	// L641
      }
    }
  }
  for (int v403 = 0; v403 < 256; v403 += 1) {	// L645
    for (int v404 = 0; v404 < 8; v404 += 1) {	// L646
      for (int v405 = 0; v405 < 8; v405 += 1) {	// L647
        float v406 = v48[0][v403][v404][v405];	// L648
        v47[0][v403][(v404 + 1)][(v405 + 1)] = v406;	// L649
      }
    }
  }
  for (int v407 = 0; v407 < 256; v407 += 1) {	// L653
    for (int v408 = 0; v408 < 8; v408 += 1) {	// L654
      for (int v409 = 0; v409 < 8; v409 += 1) {	// L655
        v46[0][v407][v408][v409] = 0.000000;	// L656
        for (int v410 = 0; v410 < 256; v410 += 1) {	// L657
          for (int v411 = 0; v411 < 3; v411 += 1) {	// L658
            for (int v412 = 0; v412 < 3; v412 += 1) {	// L659
              float v413 = v47[0][v410][(v408 + v411)][(v409 + v412)];	// L660
              float v414 = v14[v407][v410][v411][v412];	// L661
              float v415 = v46[0][v407][v408][v409];	// L662
              float v416 = v413 * v414;	// L663
              float v417 = v415 + v416;	// L664
              v46[0][v407][v408][v409] = v417;	// L665
            }
          }
        }
      }
    }
  }
  for (int v418 = 0; v418 < 256; v418 += 1) {	// L672
    for (int v419 = 0; v419 < 8; v419 += 1) {	// L673
      for (int v420 = 0; v420 < 8; v420 += 1) {	// L674
        float v421 = v46[0][v418][v419][v420];	// L675
        bool v422 = v421 < 0.000000;	// L676
        float v423 = v422 ? (float)0.000000 : (float)v421;	// L677
        v45[0][v418][v419][v420] = v423;	// L678
      }
    }
  }
  for (int v424 = 0; v424 < 256; v424 += 1) {	// L682
    for (int v425 = 0; v425 < 10; v425 += 1) {	// L683
      for (int v426 = 0; v426 < 10; v426 += 1) {	// L684
        v44[0][v424][v425][v426] = 0.000000;	// L685
      }
    }
  }
  for (int v427 = 0; v427 < 256; v427 += 1) {	// L689
    for (int v428 = 0; v428 < 8; v428 += 1) {	// L690
      for (int v429 = 0; v429 < 8; v429 += 1) {	// L691
        float v430 = v45[0][v427][v428][v429];	// L692
        v44[0][v427][(v428 + 1)][(v429 + 1)] = v430;	// L693
      }
    }
  }
  for (int v431 = 0; v431 < 256; v431 += 1) {	// L697
    for (int v432 = 0; v432 < 8; v432 += 1) {	// L698
      for (int v433 = 0; v433 < 8; v433 += 1) {	// L699
        v43[0][v431][v432][v433] = 0.000000;	// L700
        for (int v434 = 0; v434 < 256; v434 += 1) {	// L701
          for (int v435 = 0; v435 < 3; v435 += 1) {	// L702
            for (int v436 = 0; v436 < 3; v436 += 1) {	// L703
              float v437 = v44[0][v434][(v432 + v435)][(v433 + v436)];	// L704
              float v438 = v15[v431][v434][v435][v436];	// L705
              float v439 = v43[0][v431][v432][v433];	// L706
              float v440 = v437 * v438;	// L707
              float v441 = v439 + v440;	// L708
              v43[0][v431][v432][v433] = v441;	// L709
            }
          }
        }
      }
    }
  }
  for (int v442 = 0; v442 < 256; v442 += 1) {	// L716
    for (int v443 = 0; v443 < 8; v443 += 1) {	// L717
      for (int v444 = 0; v444 < 8; v444 += 1) {	// L718
        float v445 = v43[0][v442][v443][v444];	// L719
        float v446 = v48[0][v442][v443][v444];	// L720
        float v447 = v445 + v446;	// L721
        v42[0][v442][v443][v444] = v447;	// L722
      }
    }
  }
  for (int v448 = 0; v448 < 256; v448 += 1) {	// L726
    for (int v449 = 0; v449 < 8; v449 += 1) {	// L727
      for (int v450 = 0; v450 < 8; v450 += 1) {	// L728
        float v451 = v42[0][v448][v449][v450];	// L729
        bool v452 = v451 < 0.000000;	// L730
        float v453 = v452 ? (float)0.000000 : (float)v451;	// L731
        v41[0][v448][v449][v450] = v453;	// L732
      }
    }
  }
  for (int v454 = 0; v454 < 256; v454 += 1) {	// L736
    for (int v455 = 0; v455 < 10; v455 += 1) {	// L737
      for (int v456 = 0; v456 < 10; v456 += 1) {	// L738
        v40[0][v454][v455][v456] = 0.000000;	// L739
      }
    }
  }
  for (int v457 = 0; v457 < 256; v457 += 1) {	// L743
    for (int v458 = 0; v458 < 8; v458 += 1) {	// L744
      for (int v459 = 0; v459 < 8; v459 += 1) {	// L745
        float v460 = v41[0][v457][v458][v459];	// L746
        v40[0][v457][(v458 + 1)][(v459 + 1)] = v460;	// L747
      }
    }
  }
  for (int v461 = 0; v461 < 512; v461 += 1) {	// L751
    for (int v462 = 0; v462 < 4; v462 += 1) {	// L752
      for (int v463 = 0; v463 < 4; v463 += 1) {	// L753
        v39[0][v461][v462][v463] = 0.000000;	// L754
        for (int v464 = 0; v464 < 256; v464 += 1) {	// L755
          for (int v465 = 0; v465 < 3; v465 += 1) {	// L756
            for (int v466 = 0; v466 < 3; v466 += 1) {	// L757
              float v467 = v40[0][v464][((v462 * 2) + v465)][((v463 * 2) + v466)];	// L758
              float v468 = v16[v461][v464][v465][v466];	// L759
              float v469 = v39[0][v461][v462][v463];	// L760
              float v470 = v467 * v468;	// L761
              float v471 = v469 + v470;	// L762
              v39[0][v461][v462][v463] = v471;	// L763
            }
          }
        }
      }
    }
  }
  for (int v472 = 0; v472 < 512; v472 += 1) {	// L770
    for (int v473 = 0; v473 < 4; v473 += 1) {	// L771
      for (int v474 = 0; v474 < 4; v474 += 1) {	// L772
        float v475 = v39[0][v472][v473][v474];	// L773
        bool v476 = v475 < 0.000000;	// L774
        float v477 = v476 ? (float)0.000000 : (float)v475;	// L775
        v38[0][v472][v473][v474] = v477;	// L776
      }
    }
  }
  for (int v478 = 0; v478 < 512; v478 += 1) {	// L780
    for (int v479 = 0; v479 < 6; v479 += 1) {	// L781
      for (int v480 = 0; v480 < 6; v480 += 1) {	// L782
        v37[0][v478][v479][v480] = 0.000000;	// L783
      }
    }
  }
  for (int v481 = 0; v481 < 512; v481 += 1) {	// L787
    for (int v482 = 0; v482 < 4; v482 += 1) {	// L788
      for (int v483 = 0; v483 < 4; v483 += 1) {	// L789
        float v484 = v38[0][v481][v482][v483];	// L790
        v37[0][v481][(v482 + 1)][(v483 + 1)] = v484;	// L791
      }
    }
  }
  for (int v485 = 0; v485 < 512; v485 += 1) {	// L795
    for (int v486 = 0; v486 < 4; v486 += 1) {	// L796
      for (int v487 = 0; v487 < 4; v487 += 1) {	// L797
        v36[0][v485][v486][v487] = 0.000000;	// L798
        for (int v488 = 0; v488 < 512; v488 += 1) {	// L799
          for (int v489 = 0; v489 < 3; v489 += 1) {	// L800
            for (int v490 = 0; v490 < 3; v490 += 1) {	// L801
              float v491 = v37[0][v488][(v486 + v489)][(v487 + v490)];	// L802
              float v492 = v17[v485][v488][v489][v490];	// L803
              float v493 = v36[0][v485][v486][v487];	// L804
              float v494 = v491 * v492;	// L805
              float v495 = v493 + v494;	// L806
              v36[0][v485][v486][v487] = v495;	// L807
            }
          }
        }
      }
    }
  }
  for (int v496 = 0; v496 < 512; v496 += 1) {	// L814
    for (int v497 = 0; v497 < 4; v497 += 1) {	// L815
      for (int v498 = 0; v498 < 4; v498 += 1) {	// L816
        v35[0][v496][v497][v498] = 0.000000;	// L817
        for (int v499 = 0; v499 < 256; v499 += 1) {	// L818
          float v500 = v41[0][v499][(v497 * 2)][(v498 * 2)];	// L819
          float v501 = v18[v496][v499][0][0];	// L820
          float v502 = v35[0][v496][v497][v498];	// L821
          float v503 = v500 * v501;	// L822
          float v504 = v502 + v503;	// L823
          v35[0][v496][v497][v498] = v504;	// L824
        }
      }
    }
  }
  for (int v505 = 0; v505 < 512; v505 += 1) {	// L829
    for (int v506 = 0; v506 < 4; v506 += 1) {	// L830
      for (int v507 = 0; v507 < 4; v507 += 1) {	// L831
        float v508 = v36[0][v505][v506][v507];	// L832
        float v509 = v35[0][v505][v506][v507];	// L833
        float v510 = v508 + v509;	// L834
        v34[0][v505][v506][v507] = v510;	// L835
      }
    }
  }
  for (int v511 = 0; v511 < 512; v511 += 1) {	// L839
    for (int v512 = 0; v512 < 4; v512 += 1) {	// L840
      for (int v513 = 0; v513 < 4; v513 += 1) {	// L841
        float v514 = v34[0][v511][v512][v513];	// L842
        bool v515 = v514 < 0.000000;	// L843
        float v516 = v515 ? (float)0.000000 : (float)v514;	// L844
        v33[0][v511][v512][v513] = v516;	// L845
      }
    }
  }
  for (int v517 = 0; v517 < 512; v517 += 1) {	// L849
    for (int v518 = 0; v518 < 6; v518 += 1) {	// L850
      for (int v519 = 0; v519 < 6; v519 += 1) {	// L851
        v32[0][v517][v518][v519] = 0.000000;	// L852
      }
    }
  }
  for (int v520 = 0; v520 < 512; v520 += 1) {	// L856
    for (int v521 = 0; v521 < 4; v521 += 1) {	// L857
      for (int v522 = 0; v522 < 4; v522 += 1) {	// L858
        float v523 = v33[0][v520][v521][v522];	// L859
        v32[0][v520][(v521 + 1)][(v522 + 1)] = v523;	// L860
      }
    }
  }
  for (int v524 = 0; v524 < 512; v524 += 1) {	// L864
    for (int v525 = 0; v525 < 4; v525 += 1) {	// L865
      for (int v526 = 0; v526 < 4; v526 += 1) {	// L866
        v31[0][v524][v525][v526] = 0.000000;	// L867
        for (int v527 = 0; v527 < 512; v527 += 1) {	// L868
          for (int v528 = 0; v528 < 3; v528 += 1) {	// L869
            for (int v529 = 0; v529 < 3; v529 += 1) {	// L870
              float v530 = v32[0][v527][(v525 + v528)][(v526 + v529)];	// L871
              float v531 = v19[v524][v527][v528][v529];	// L872
              float v532 = v31[0][v524][v525][v526];	// L873
              float v533 = v530 * v531;	// L874
              float v534 = v532 + v533;	// L875
              v31[0][v524][v525][v526] = v534;	// L876
            }
          }
        }
      }
    }
  }
  for (int v535 = 0; v535 < 512; v535 += 1) {	// L883
    for (int v536 = 0; v536 < 4; v536 += 1) {	// L884
      for (int v537 = 0; v537 < 4; v537 += 1) {	// L885
        float v538 = v31[0][v535][v536][v537];	// L886
        bool v539 = v538 < 0.000000;	// L887
        float v540 = v539 ? (float)0.000000 : (float)v538;	// L888
        v30[0][v535][v536][v537] = v540;	// L889
      }
    }
  }
  for (int v541 = 0; v541 < 512; v541 += 1) {	// L893
    for (int v542 = 0; v542 < 6; v542 += 1) {	// L894
      for (int v543 = 0; v543 < 6; v543 += 1) {	// L895
        v29[0][v541][v542][v543] = 0.000000;	// L896
      }
    }
  }
  for (int v544 = 0; v544 < 512; v544 += 1) {	// L900
    for (int v545 = 0; v545 < 4; v545 += 1) {	// L901
      for (int v546 = 0; v546 < 4; v546 += 1) {	// L902
        float v547 = v30[0][v544][v545][v546];	// L903
        v29[0][v544][(v545 + 1)][(v546 + 1)] = v547;	// L904
      }
    }
  }
  for (int v548 = 0; v548 < 512; v548 += 1) {	// L908
    for (int v549 = 0; v549 < 4; v549 += 1) {	// L909
      for (int v550 = 0; v550 < 4; v550 += 1) {	// L910
        v28[0][v548][v549][v550] = 0.000000;	// L911
        for (int v551 = 0; v551 < 512; v551 += 1) {	// L912
          for (int v552 = 0; v552 < 3; v552 += 1) {	// L913
            for (int v553 = 0; v553 < 3; v553 += 1) {	// L914
              float v554 = v29[0][v551][(v549 + v552)][(v550 + v553)];	// L915
              float v555 = v20[v548][v551][v552][v553];	// L916
              float v556 = v28[0][v548][v549][v550];	// L917
              float v557 = v554 * v555;	// L918
              float v558 = v556 + v557;	// L919
              v28[0][v548][v549][v550] = v558;	// L920
            }
          }
        }
      }
    }
  }
  for (int v559 = 0; v559 < 512; v559 += 1) {	// L927
    for (int v560 = 0; v560 < 4; v560 += 1) {	// L928
      for (int v561 = 0; v561 < 4; v561 += 1) {	// L929
        float v562 = v28[0][v559][v560][v561];	// L930
        float v563 = v33[0][v559][v560][v561];	// L931
        float v564 = v562 + v563;	// L932
        v27[0][v559][v560][v561] = v564;	// L933
      }
    }
  }
  for (int v565 = 0; v565 < 512; v565 += 1) {	// L937
    for (int v566 = 0; v566 < 4; v566 += 1) {	// L938
      for (int v567 = 0; v567 < 4; v567 += 1) {	// L939
        float v568 = v27[0][v565][v566][v567];	// L940
        bool v569 = v568 < 0.000000;	// L941
        float v570 = v569 ? (float)0.000000 : (float)v568;	// L942
        v26[0][v565][v566][v567] = v570;	// L943
      }
    }
  }
  for (int v571 = 0; v571 < 512; v571 += 1) {	// L947
    v25[0][v571][0][0] = 0.000000;	// L948
  }
  for (int v572 = 0; v572 < 512; v572 += 1) {	// L950
    for (int v573 = 0; v573 < 4; v573 += 1) {	// L951
      for (int v574 = 0; v574 < 4; v574 += 1) {	// L952
        float v575 = v26[0][v572][v573][v574];	// L953
        float v576 = v25[0][v572][0][0];	// L954
        float v577 = v576 + v575;	// L955
        v25[0][v572][0][0] = v577;	// L956
      }
    }
  }
  for (int v578 = 0; v578 < 512; v578 += 1) {	// L960
    float v579 = v25[0][v578][0][0];	// L961
    float v580 = v579 / 16.000000;	// L962
    v25[0][v578][0][0] = v580;	// L963
  }
  for (int v581 = 0; v581 < 512; v581 += 1) {	// L965
    float v582 = v25[0][v581][0][0];	// L966
    v24[0][v581] = v582;	// L967
  }
  #pragma HLS resource variable=v23 core=ram_s2p_bram

  for (int v584 = 0; v584 < 10; v584 += 1) {	// L970
    v22[0][v584] = 0.000000;	// L971
    for (int v585 = 0; v585 < 512; v585 += 1) {	// L972
      float v586 = v24[0][v585];	// L973
      float v587 = v21[v584][v585];	// L974
      float v588 = v22[0][v584];	// L975
      float v589 = v586 * v587;	// L976
      float v590 = v588 + v589;	// L977
      v22[0][v584] = v590;	// L978
    }
    float v591 = v23[v584];	// L980
    float v592 = 1.000000 * v591;	// L981
    float v593 = 1.000000 + v592;	// L982
    float v594 = v22[0][v584];	// L983
    float v595 = v593 * v594;	// L984
    v22[0][v584] = v595;	// L985
  }
}

