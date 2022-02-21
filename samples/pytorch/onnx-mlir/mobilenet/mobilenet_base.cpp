
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
  int8_t v1[32][3][3][3],
  int8_t v2[32][1][3][3],
  int8_t v3[64][32][1][1],
  int8_t v4[64][1][3][3],
  int8_t v5[128][64][1][1],
  int8_t v6[128][1][3][3],
  int8_t v7[128][128][1][1],
  int8_t v8[128][1][3][3],
  int8_t v9[256][128][1][1],
  int8_t v10[256][1][3][3],
  int8_t v11[256][256][1][1],
  int8_t v12[256][1][3][3],
  int8_t v13[512][256][1][1],
  int8_t v14[512][1][3][3],
  int8_t v15[512][512][1][1],
  int8_t v16[512][1][3][3],
  int8_t v17[512][512][1][1],
  int8_t v18[512][1][3][3],
  int8_t v19[512][512][1][1],
  int8_t v20[512][1][3][3],
  int8_t v21[512][512][1][1],
  int8_t v22[512][1][3][3],
  int8_t v23[512][512][1][1],
  int8_t v24[512][1][3][3],
  int8_t v25[1024][512][1][1],
  int8_t v26[1024][1][3][3],
  int8_t v27[1024][1024][1][1],
  int8_t v28[10][1024],
  int8_t v29[1][10]
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
  #pragma HLS interface bram port=v23
  #pragma HLS interface bram port=v24
  #pragma HLS interface bram port=v25
  #pragma HLS interface bram port=v26
  #pragma HLS interface bram port=v27
  #pragma HLS interface bram port=v28
  #pragma HLS interface bram port=v29

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

  #pragma HLS resource variable=v23 core=ram_s2p_bram

  #pragma HLS resource variable=v24 core=ram_s2p_bram

  #pragma HLS resource variable=v25 core=ram_s2p_bram

  #pragma HLS resource variable=v26 core=ram_s2p_bram

  #pragma HLS resource variable=v27 core=ram_s2p_bram

  #pragma HLS resource variable=v28 core=ram_s2p_bram

  #pragma HLS resource variable=v29 core=ram_s2p_bram

  int8_t v30[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};	// L6
  int8_t v31[1][1024];	// L8
  #pragma HLS resource variable=v31 core=ram_s2p_bram

  int8_t v32[1][1024][1][1];	// L9
  #pragma HLS resource variable=v32 core=ram_s2p_bram

  int8_t v33[1][1024][2][2];	// L10
  #pragma HLS resource variable=v33 core=ram_s2p_bram

  int8_t v34[1][1024][2][2];	// L11
  #pragma HLS resource variable=v34 core=ram_s2p_bram

  int8_t v35[1][1024][2][2];	// L12
  #pragma HLS resource variable=v35 core=ram_s2p_bram

  int8_t v36[1][1024][2][2];	// L13
  #pragma HLS resource variable=v36 core=ram_s2p_bram

  int8_t v37[1][1024][4][4];	// L14
  #pragma HLS resource variable=v37 core=ram_s2p_bram

  int8_t v38[1][1024][2][2];	// L15
  #pragma HLS resource variable=v38 core=ram_s2p_bram

  int8_t v39[1][1024][2][2];	// L16
  #pragma HLS resource variable=v39 core=ram_s2p_bram

  int8_t v40[1][512][2][2];	// L17
  #pragma HLS resource variable=v40 core=ram_s2p_bram

  int8_t v41[1][512][2][2];	// L18
  #pragma HLS resource variable=v41 core=ram_s2p_bram

  int8_t v42[1][512][6][6];	// L19
  #pragma HLS resource variable=v42 core=ram_s2p_bram

  int8_t v43[1][512][4][4];	// L20
  #pragma HLS resource variable=v43 core=ram_s2p_bram

  int8_t v44[1][512][4][4];	// L21
  #pragma HLS resource variable=v44 core=ram_s2p_bram

  int8_t v45[1][512][4][4];	// L22
  #pragma HLS resource variable=v45 core=ram_s2p_bram

  int8_t v46[1][512][4][4];	// L23
  #pragma HLS resource variable=v46 core=ram_s2p_bram

  int8_t v47[1][512][6][6];	// L24
  #pragma HLS resource variable=v47 core=ram_s2p_bram

  int8_t v48[1][512][4][4];	// L25
  #pragma HLS resource variable=v48 core=ram_s2p_bram

  int8_t v49[1][512][4][4];	// L26
  #pragma HLS resource variable=v49 core=ram_s2p_bram

  int8_t v50[1][512][4][4];	// L27
  #pragma HLS resource variable=v50 core=ram_s2p_bram

  int8_t v51[1][512][4][4];	// L28
  #pragma HLS resource variable=v51 core=ram_s2p_bram

  int8_t v52[1][512][6][6];	// L29
  #pragma HLS resource variable=v52 core=ram_s2p_bram

  int8_t v53[1][512][4][4];	// L30
  #pragma HLS resource variable=v53 core=ram_s2p_bram

  int8_t v54[1][512][4][4];	// L31
  #pragma HLS resource variable=v54 core=ram_s2p_bram

  int8_t v55[1][512][4][4];	// L32
  #pragma HLS resource variable=v55 core=ram_s2p_bram

  int8_t v56[1][512][4][4];	// L33
  #pragma HLS resource variable=v56 core=ram_s2p_bram

  int8_t v57[1][512][6][6];	// L34
  #pragma HLS resource variable=v57 core=ram_s2p_bram

  int8_t v58[1][512][4][4];	// L35
  #pragma HLS resource variable=v58 core=ram_s2p_bram

  int8_t v59[1][512][4][4];	// L36
  #pragma HLS resource variable=v59 core=ram_s2p_bram

  int8_t v60[1][512][4][4];	// L37
  #pragma HLS resource variable=v60 core=ram_s2p_bram

  int8_t v61[1][512][4][4];	// L38
  #pragma HLS resource variable=v61 core=ram_s2p_bram

  int8_t v62[1][512][6][6];	// L39
  #pragma HLS resource variable=v62 core=ram_s2p_bram

  int8_t v63[1][512][4][4];	// L40
  #pragma HLS resource variable=v63 core=ram_s2p_bram

  int8_t v64[1][512][4][4];	// L41
  #pragma HLS resource variable=v64 core=ram_s2p_bram

  int8_t v65[1][512][4][4];	// L42
  #pragma HLS resource variable=v65 core=ram_s2p_bram

  int8_t v66[1][512][4][4];	// L43
  #pragma HLS resource variable=v66 core=ram_s2p_bram

  int8_t v67[1][512][6][6];	// L44
  #pragma HLS resource variable=v67 core=ram_s2p_bram

  int8_t v68[1][512][4][4];	// L45
  #pragma HLS resource variable=v68 core=ram_s2p_bram

  int8_t v69[1][512][4][4];	// L46
  #pragma HLS resource variable=v69 core=ram_s2p_bram

  int8_t v70[1][256][4][4];	// L47
  #pragma HLS resource variable=v70 core=ram_s2p_bram

  int8_t v71[1][256][4][4];	// L48
  #pragma HLS resource variable=v71 core=ram_s2p_bram

  int8_t v72[1][256][10][10];	// L49
  #pragma HLS resource variable=v72 core=ram_s2p_bram

  int8_t v73[1][256][8][8];	// L50
  #pragma HLS resource variable=v73 core=ram_s2p_bram

  int8_t v74[1][256][8][8];	// L51
  #pragma HLS resource variable=v74 core=ram_s2p_bram

  int8_t v75[1][256][8][8];	// L52
  #pragma HLS resource variable=v75 core=ram_s2p_bram

  int8_t v76[1][256][8][8];	// L53
  #pragma HLS resource variable=v76 core=ram_s2p_bram

  int8_t v77[1][256][10][10];	// L54
  #pragma HLS resource variable=v77 core=ram_s2p_bram

  int8_t v78[1][256][8][8];	// L55
  #pragma HLS resource variable=v78 core=ram_s2p_bram

  int8_t v79[1][256][8][8];	// L56
  #pragma HLS resource variable=v79 core=ram_s2p_bram

  int8_t v80[1][128][8][8];	// L57
  #pragma HLS resource variable=v80 core=ram_s2p_bram

  int8_t v81[1][128][8][8];	// L58
  #pragma HLS resource variable=v81 core=ram_s2p_bram

  int8_t v82[1][128][18][18];	// L59
  #pragma HLS resource variable=v82 core=ram_s2p_bram

  int8_t v83[1][128][16][16];	// L60
  #pragma HLS resource variable=v83 core=ram_s2p_bram

  int8_t v84[1][128][16][16];	// L61
  #pragma HLS resource variable=v84 core=ram_s2p_bram

  int8_t v85[1][128][16][16];	// L62
  #pragma HLS resource variable=v85 core=ram_s2p_bram

  int8_t v86[1][128][16][16];	// L63
  #pragma HLS resource variable=v86 core=ram_s2p_bram

  int8_t v87[1][128][18][18];	// L64
  #pragma HLS resource variable=v87 core=ram_s2p_bram

  int8_t v88[1][128][16][16];	// L65
  #pragma HLS resource variable=v88 core=ram_s2p_bram

  int8_t v89[1][128][16][16];	// L66
  #pragma HLS resource variable=v89 core=ram_s2p_bram

  int8_t v90[1][64][16][16];	// L67
  #pragma HLS resource variable=v90 core=ram_s2p_bram

  int8_t v91[1][64][16][16];	// L68
  #pragma HLS resource variable=v91 core=ram_s2p_bram

  int8_t v92[1][64][34][34];	// L69
  #pragma HLS resource variable=v92 core=ram_s2p_bram

  int8_t v93[1][64][32][32];	// L70
  #pragma HLS resource variable=v93 core=ram_s2p_bram

  int8_t v94[1][64][32][32];	// L71
  #pragma HLS resource variable=v94 core=ram_s2p_bram

  int8_t v95[1][32][32][32];	// L72
  #pragma HLS resource variable=v95 core=ram_s2p_bram

  int8_t v96[1][32][32][32];	// L73
  #pragma HLS resource variable=v96 core=ram_s2p_bram

  int8_t v97[1][32][34][34];	// L74
  #pragma HLS resource variable=v97 core=ram_s2p_bram

  int8_t v98[1][32][32][32];	// L75
  #pragma HLS resource variable=v98 core=ram_s2p_bram

  int8_t v99[1][32][32][32];	// L76
  #pragma HLS resource variable=v99 core=ram_s2p_bram

  int8_t v100[1][3][34][34];	// L77
  #pragma HLS resource variable=v100 core=ram_s2p_bram

  for (int v101 = 0; v101 < 3; v101 += 1) {	// L78
    for (int v102 = 0; v102 < 34; v102 += 1) {	// L79
      for (int v103 = 0; v103 < 34; v103 += 1) {	// L80
        v100[0][v101][v102][v103] = 0;	// L81
      }
    }
  }
  for (int v104 = 0; v104 < 3; v104 += 1) {	// L85
    for (int v105 = 0; v105 < 32; v105 += 1) {	// L86
      for (int v106 = 0; v106 < 32; v106 += 1) {	// L87
        int8_t v107 = v0[0][v104][v105][v106];	// L88
        v100[0][v104][(v105 + 1)][(v106 + 1)] = v107;	// L89
      }
    }
  }
  for (int v108 = 0; v108 < 32; v108 += 1) {	// L93
    for (int v109 = 0; v109 < 32; v109 += 1) {	// L94
      for (int v110 = 0; v110 < 32; v110 += 1) {	// L95
        v99[0][v108][v109][v110] = 0;	// L96
        for (int v111 = 0; v111 < 3; v111 += 1) {	// L97
          for (int v112 = 0; v112 < 3; v112 += 1) {	// L98
            for (int v113 = 0; v113 < 3; v113 += 1) {	// L99
              int8_t v114 = v100[0][v111][(v109 + v112)][(v110 + v113)];	// L100
              int8_t v115 = v1[v108][v111][v112][v113];	// L101
              int8_t v116 = v99[0][v108][v109][v110];	// L102
              int16_t v117 = v114;	// L103
              int16_t v118 = v115;	// L104
              int32_t v119 = v117 * v118;	// L105
              int32_t v120 = v116;	// L106
              int32_t v121 = v120 + v119;	// L107
              int8_t v122 = v121;	// L108
              v99[0][v108][v109][v110] = v122;	// L109
            }
          }
        }
      }
    }
  }
  for (int v123 = 0; v123 < 32; v123 += 1) {	// L116
    for (int v124 = 0; v124 < 32; v124 += 1) {	// L117
      for (int v125 = 0; v125 < 32; v125 += 1) {	// L118
        int8_t v126 = v99[0][v123][v124][v125];	// L119
        bool v127 = v126 < 0;	// L120
        int8_t v128 = v127 ? (int8_t)0 : (int8_t)v126;	// L121
        v98[0][v123][v124][v125] = v128;	// L122
      }
    }
  }
  for (int v129 = 0; v129 < 32; v129 += 1) {	// L126
    for (int v130 = 0; v130 < 34; v130 += 1) {	// L127
      for (int v131 = 0; v131 < 34; v131 += 1) {	// L128
        v97[0][v129][v130][v131] = 0;	// L129
      }
    }
  }
  for (int v132 = 0; v132 < 32; v132 += 1) {	// L133
    for (int v133 = 0; v133 < 32; v133 += 1) {	// L134
      for (int v134 = 0; v134 < 32; v134 += 1) {	// L135
        int8_t v135 = v98[0][v132][v133][v134];	// L136
        v97[0][v132][(v133 + 1)][(v134 + 1)] = v135;	// L137
      }
    }
  }
  for (int v136 = 0; v136 < 32; v136 += 1) {	// L141
    for (int v137 = 0; v137 < 32; v137 += 1) {	// L142
      for (int v138 = 0; v138 < 32; v138 += 1) {	// L143
        v96[0][v136][v137][v138] = 0;	// L144
        for (int v139 = 0; v139 < 3; v139 += 1) {	// L145
          for (int v140 = 0; v140 < 3; v140 += 1) {	// L146
            int8_t v141 = v97[0][v136][(v137 + v139)][(v138 + v140)];	// L147
            int8_t v142 = v2[v136][0][v139][v140];	// L148
            int8_t v143 = v96[0][v136][v137][v138];	// L149
            int16_t v144 = v141;	// L150
            int16_t v145 = v142;	// L151
            int32_t v146 = v144 * v145;	// L152
            int32_t v147 = v143;	// L153
            int32_t v148 = v147 + v146;	// L154
            int8_t v149 = v148;	// L155
            v96[0][v136][v137][v138] = v149;	// L156
          }
        }
      }
    }
  }
  for (int v150 = 0; v150 < 32; v150 += 1) {	// L162
    for (int v151 = 0; v151 < 32; v151 += 1) {	// L163
      for (int v152 = 0; v152 < 32; v152 += 1) {	// L164
        int8_t v153 = v96[0][v150][v151][v152];	// L165
        bool v154 = v153 < 0;	// L166
        int8_t v155 = v154 ? (int8_t)0 : (int8_t)v153;	// L167
        v95[0][v150][v151][v152] = v155;	// L168
      }
    }
  }
  for (int v156 = 0; v156 < 64; v156 += 1) {	// L172
    for (int v157 = 0; v157 < 32; v157 += 1) {	// L173
      for (int v158 = 0; v158 < 32; v158 += 1) {	// L174
        v94[0][v156][v157][v158] = 0;	// L175
        for (int v159 = 0; v159 < 32; v159 += 1) {	// L176
          int8_t v160 = v95[0][v159][v157][v158];	// L177
          int8_t v161 = v3[v156][v159][0][0];	// L178
          int8_t v162 = v94[0][v156][v157][v158];	// L179
          int16_t v163 = v160;	// L180
          int16_t v164 = v161;	// L181
          int32_t v165 = v163 * v164;	// L182
          int32_t v166 = v162;	// L183
          int32_t v167 = v166 + v165;	// L184
          int8_t v168 = v167;	// L185
          v94[0][v156][v157][v158] = v168;	// L186
        }
      }
    }
  }
  for (int v169 = 0; v169 < 64; v169 += 1) {	// L191
    for (int v170 = 0; v170 < 32; v170 += 1) {	// L192
      for (int v171 = 0; v171 < 32; v171 += 1) {	// L193
        int8_t v172 = v94[0][v169][v170][v171];	// L194
        bool v173 = v172 < 0;	// L195
        int8_t v174 = v173 ? (int8_t)0 : (int8_t)v172;	// L196
        v93[0][v169][v170][v171] = v174;	// L197
      }
    }
  }
  for (int v175 = 0; v175 < 64; v175 += 1) {	// L201
    for (int v176 = 0; v176 < 34; v176 += 1) {	// L202
      for (int v177 = 0; v177 < 34; v177 += 1) {	// L203
        v92[0][v175][v176][v177] = 0;	// L204
      }
    }
  }
  for (int v178 = 0; v178 < 64; v178 += 1) {	// L208
    for (int v179 = 0; v179 < 32; v179 += 1) {	// L209
      for (int v180 = 0; v180 < 32; v180 += 1) {	// L210
        int8_t v181 = v93[0][v178][v179][v180];	// L211
        v92[0][v178][(v179 + 1)][(v180 + 1)] = v181;	// L212
      }
    }
  }
  for (int v182 = 0; v182 < 64; v182 += 1) {	// L216
    for (int v183 = 0; v183 < 16; v183 += 1) {	// L217
      for (int v184 = 0; v184 < 16; v184 += 1) {	// L218
        v91[0][v182][v183][v184] = 0;	// L219
        for (int v185 = 0; v185 < 3; v185 += 1) {	// L220
          for (int v186 = 0; v186 < 3; v186 += 1) {	// L221
            int8_t v187 = v92[0][v182][((v183 * 2) + v185)][((v184 * 2) + v186)];	// L222
            int8_t v188 = v4[v182][0][v185][v186];	// L223
            int8_t v189 = v91[0][v182][v183][v184];	// L224
            int16_t v190 = v187;	// L225
            int16_t v191 = v188;	// L226
            int32_t v192 = v190 * v191;	// L227
            int32_t v193 = v189;	// L228
            int32_t v194 = v193 + v192;	// L229
            int8_t v195 = v194;	// L230
            v91[0][v182][v183][v184] = v195;	// L231
          }
        }
      }
    }
  }
  for (int v196 = 0; v196 < 64; v196 += 1) {	// L237
    for (int v197 = 0; v197 < 16; v197 += 1) {	// L238
      for (int v198 = 0; v198 < 16; v198 += 1) {	// L239
        int8_t v199 = v91[0][v196][v197][v198];	// L240
        bool v200 = v199 < 0;	// L241
        int8_t v201 = v200 ? (int8_t)0 : (int8_t)v199;	// L242
        v90[0][v196][v197][v198] = v201;	// L243
      }
    }
  }
  for (int v202 = 0; v202 < 128; v202 += 1) {	// L247
    for (int v203 = 0; v203 < 16; v203 += 1) {	// L248
      for (int v204 = 0; v204 < 16; v204 += 1) {	// L249
        v89[0][v202][v203][v204] = 0;	// L250
        for (int v205 = 0; v205 < 64; v205 += 1) {	// L251
          int8_t v206 = v90[0][v205][v203][v204];	// L252
          int8_t v207 = v5[v202][v205][0][0];	// L253
          int8_t v208 = v89[0][v202][v203][v204];	// L254
          int16_t v209 = v206;	// L255
          int16_t v210 = v207;	// L256
          int32_t v211 = v209 * v210;	// L257
          int32_t v212 = v208;	// L258
          int32_t v213 = v212 + v211;	// L259
          int8_t v214 = v213;	// L260
          v89[0][v202][v203][v204] = v214;	// L261
        }
      }
    }
  }
  for (int v215 = 0; v215 < 128; v215 += 1) {	// L266
    for (int v216 = 0; v216 < 16; v216 += 1) {	// L267
      for (int v217 = 0; v217 < 16; v217 += 1) {	// L268
        int8_t v218 = v89[0][v215][v216][v217];	// L269
        bool v219 = v218 < 0;	// L270
        int8_t v220 = v219 ? (int8_t)0 : (int8_t)v218;	// L271
        v88[0][v215][v216][v217] = v220;	// L272
      }
    }
  }
  for (int v221 = 0; v221 < 128; v221 += 1) {	// L276
    for (int v222 = 0; v222 < 18; v222 += 1) {	// L277
      for (int v223 = 0; v223 < 18; v223 += 1) {	// L278
        v87[0][v221][v222][v223] = 0;	// L279
      }
    }
  }
  for (int v224 = 0; v224 < 128; v224 += 1) {	// L283
    for (int v225 = 0; v225 < 16; v225 += 1) {	// L284
      for (int v226 = 0; v226 < 16; v226 += 1) {	// L285
        int8_t v227 = v88[0][v224][v225][v226];	// L286
        v87[0][v224][(v225 + 1)][(v226 + 1)] = v227;	// L287
      }
    }
  }
  for (int v228 = 0; v228 < 128; v228 += 1) {	// L291
    for (int v229 = 0; v229 < 16; v229 += 1) {	// L292
      for (int v230 = 0; v230 < 16; v230 += 1) {	// L293
        v86[0][v228][v229][v230] = 0;	// L294
        for (int v231 = 0; v231 < 3; v231 += 1) {	// L295
          for (int v232 = 0; v232 < 3; v232 += 1) {	// L296
            int8_t v233 = v87[0][v228][(v229 + v231)][(v230 + v232)];	// L297
            int8_t v234 = v6[v228][0][v231][v232];	// L298
            int8_t v235 = v86[0][v228][v229][v230];	// L299
            int16_t v236 = v233;	// L300
            int16_t v237 = v234;	// L301
            int32_t v238 = v236 * v237;	// L302
            int32_t v239 = v235;	// L303
            int32_t v240 = v239 + v238;	// L304
            int8_t v241 = v240;	// L305
            v86[0][v228][v229][v230] = v241;	// L306
          }
        }
      }
    }
  }
  for (int v242 = 0; v242 < 128; v242 += 1) {	// L312
    for (int v243 = 0; v243 < 16; v243 += 1) {	// L313
      for (int v244 = 0; v244 < 16; v244 += 1) {	// L314
        int8_t v245 = v86[0][v242][v243][v244];	// L315
        bool v246 = v245 < 0;	// L316
        int8_t v247 = v246 ? (int8_t)0 : (int8_t)v245;	// L317
        v85[0][v242][v243][v244] = v247;	// L318
      }
    }
  }
  for (int v248 = 0; v248 < 128; v248 += 1) {	// L322
    for (int v249 = 0; v249 < 16; v249 += 1) {	// L323
      for (int v250 = 0; v250 < 16; v250 += 1) {	// L324
        v84[0][v248][v249][v250] = 0;	// L325
        for (int v251 = 0; v251 < 128; v251 += 1) {	// L326
          int8_t v252 = v85[0][v251][v249][v250];	// L327
          int8_t v253 = v7[v248][v251][0][0];	// L328
          int8_t v254 = v84[0][v248][v249][v250];	// L329
          int16_t v255 = v252;	// L330
          int16_t v256 = v253;	// L331
          int32_t v257 = v255 * v256;	// L332
          int32_t v258 = v254;	// L333
          int32_t v259 = v258 + v257;	// L334
          int8_t v260 = v259;	// L335
          v84[0][v248][v249][v250] = v260;	// L336
        }
      }
    }
  }
  for (int v261 = 0; v261 < 128; v261 += 1) {	// L341
    for (int v262 = 0; v262 < 16; v262 += 1) {	// L342
      for (int v263 = 0; v263 < 16; v263 += 1) {	// L343
        int8_t v264 = v84[0][v261][v262][v263];	// L344
        bool v265 = v264 < 0;	// L345
        int8_t v266 = v265 ? (int8_t)0 : (int8_t)v264;	// L346
        v83[0][v261][v262][v263] = v266;	// L347
      }
    }
  }
  for (int v267 = 0; v267 < 128; v267 += 1) {	// L351
    for (int v268 = 0; v268 < 18; v268 += 1) {	// L352
      for (int v269 = 0; v269 < 18; v269 += 1) {	// L353
        v82[0][v267][v268][v269] = 0;	// L354
      }
    }
  }
  for (int v270 = 0; v270 < 128; v270 += 1) {	// L358
    for (int v271 = 0; v271 < 16; v271 += 1) {	// L359
      for (int v272 = 0; v272 < 16; v272 += 1) {	// L360
        int8_t v273 = v83[0][v270][v271][v272];	// L361
        v82[0][v270][(v271 + 1)][(v272 + 1)] = v273;	// L362
      }
    }
  }
  for (int v274 = 0; v274 < 128; v274 += 1) {	// L366
    for (int v275 = 0; v275 < 8; v275 += 1) {	// L367
      for (int v276 = 0; v276 < 8; v276 += 1) {	// L368
        v81[0][v274][v275][v276] = 0;	// L369
        for (int v277 = 0; v277 < 3; v277 += 1) {	// L370
          for (int v278 = 0; v278 < 3; v278 += 1) {	// L371
            int8_t v279 = v82[0][v274][((v275 * 2) + v277)][((v276 * 2) + v278)];	// L372
            int8_t v280 = v8[v274][0][v277][v278];	// L373
            int8_t v281 = v81[0][v274][v275][v276];	// L374
            int16_t v282 = v279;	// L375
            int16_t v283 = v280;	// L376
            int32_t v284 = v282 * v283;	// L377
            int32_t v285 = v281;	// L378
            int32_t v286 = v285 + v284;	// L379
            int8_t v287 = v286;	// L380
            v81[0][v274][v275][v276] = v287;	// L381
          }
        }
      }
    }
  }
  for (int v288 = 0; v288 < 128; v288 += 1) {	// L387
    for (int v289 = 0; v289 < 8; v289 += 1) {	// L388
      for (int v290 = 0; v290 < 8; v290 += 1) {	// L389
        int8_t v291 = v81[0][v288][v289][v290];	// L390
        bool v292 = v291 < 0;	// L391
        int8_t v293 = v292 ? (int8_t)0 : (int8_t)v291;	// L392
        v80[0][v288][v289][v290] = v293;	// L393
      }
    }
  }
  for (int v294 = 0; v294 < 256; v294 += 1) {	// L397
    for (int v295 = 0; v295 < 8; v295 += 1) {	// L398
      for (int v296 = 0; v296 < 8; v296 += 1) {	// L399
        v79[0][v294][v295][v296] = 0;	// L400
        for (int v297 = 0; v297 < 128; v297 += 1) {	// L401
          int8_t v298 = v80[0][v297][v295][v296];	// L402
          int8_t v299 = v9[v294][v297][0][0];	// L403
          int8_t v300 = v79[0][v294][v295][v296];	// L404
          int16_t v301 = v298;	// L405
          int16_t v302 = v299;	// L406
          int32_t v303 = v301 * v302;	// L407
          int32_t v304 = v300;	// L408
          int32_t v305 = v304 + v303;	// L409
          int8_t v306 = v305;	// L410
          v79[0][v294][v295][v296] = v306;	// L411
        }
      }
    }
  }
  for (int v307 = 0; v307 < 256; v307 += 1) {	// L416
    for (int v308 = 0; v308 < 8; v308 += 1) {	// L417
      for (int v309 = 0; v309 < 8; v309 += 1) {	// L418
        int8_t v310 = v79[0][v307][v308][v309];	// L419
        bool v311 = v310 < 0;	// L420
        int8_t v312 = v311 ? (int8_t)0 : (int8_t)v310;	// L421
        v78[0][v307][v308][v309] = v312;	// L422
      }
    }
  }
  for (int v313 = 0; v313 < 256; v313 += 1) {	// L426
    for (int v314 = 0; v314 < 10; v314 += 1) {	// L427
      for (int v315 = 0; v315 < 10; v315 += 1) {	// L428
        v77[0][v313][v314][v315] = 0;	// L429
      }
    }
  }
  for (int v316 = 0; v316 < 256; v316 += 1) {	// L433
    for (int v317 = 0; v317 < 8; v317 += 1) {	// L434
      for (int v318 = 0; v318 < 8; v318 += 1) {	// L435
        int8_t v319 = v78[0][v316][v317][v318];	// L436
        v77[0][v316][(v317 + 1)][(v318 + 1)] = v319;	// L437
      }
    }
  }
  for (int v320 = 0; v320 < 256; v320 += 1) {	// L441
    for (int v321 = 0; v321 < 8; v321 += 1) {	// L442
      for (int v322 = 0; v322 < 8; v322 += 1) {	// L443
        v76[0][v320][v321][v322] = 0;	// L444
        for (int v323 = 0; v323 < 3; v323 += 1) {	// L445
          for (int v324 = 0; v324 < 3; v324 += 1) {	// L446
            int8_t v325 = v77[0][v320][(v321 + v323)][(v322 + v324)];	// L447
            int8_t v326 = v10[v320][0][v323][v324];	// L448
            int8_t v327 = v76[0][v320][v321][v322];	// L449
            int16_t v328 = v325;	// L450
            int16_t v329 = v326;	// L451
            int32_t v330 = v328 * v329;	// L452
            int32_t v331 = v327;	// L453
            int32_t v332 = v331 + v330;	// L454
            int8_t v333 = v332;	// L455
            v76[0][v320][v321][v322] = v333;	// L456
          }
        }
      }
    }
  }
  for (int v334 = 0; v334 < 256; v334 += 1) {	// L462
    for (int v335 = 0; v335 < 8; v335 += 1) {	// L463
      for (int v336 = 0; v336 < 8; v336 += 1) {	// L464
        int8_t v337 = v76[0][v334][v335][v336];	// L465
        bool v338 = v337 < 0;	// L466
        int8_t v339 = v338 ? (int8_t)0 : (int8_t)v337;	// L467
        v75[0][v334][v335][v336] = v339;	// L468
      }
    }
  }
  for (int v340 = 0; v340 < 256; v340 += 1) {	// L472
    for (int v341 = 0; v341 < 8; v341 += 1) {	// L473
      for (int v342 = 0; v342 < 8; v342 += 1) {	// L474
        v74[0][v340][v341][v342] = 0;	// L475
        for (int v343 = 0; v343 < 256; v343 += 1) {	// L476
          int8_t v344 = v75[0][v343][v341][v342];	// L477
          int8_t v345 = v11[v340][v343][0][0];	// L478
          int8_t v346 = v74[0][v340][v341][v342];	// L479
          int16_t v347 = v344;	// L480
          int16_t v348 = v345;	// L481
          int32_t v349 = v347 * v348;	// L482
          int32_t v350 = v346;	// L483
          int32_t v351 = v350 + v349;	// L484
          int8_t v352 = v351;	// L485
          v74[0][v340][v341][v342] = v352;	// L486
        }
      }
    }
  }
  for (int v353 = 0; v353 < 256; v353 += 1) {	// L491
    for (int v354 = 0; v354 < 8; v354 += 1) {	// L492
      for (int v355 = 0; v355 < 8; v355 += 1) {	// L493
        int8_t v356 = v74[0][v353][v354][v355];	// L494
        bool v357 = v356 < 0;	// L495
        int8_t v358 = v357 ? (int8_t)0 : (int8_t)v356;	// L496
        v73[0][v353][v354][v355] = v358;	// L497
      }
    }
  }
  for (int v359 = 0; v359 < 256; v359 += 1) {	// L501
    for (int v360 = 0; v360 < 10; v360 += 1) {	// L502
      for (int v361 = 0; v361 < 10; v361 += 1) {	// L503
        v72[0][v359][v360][v361] = 0;	// L504
      }
    }
  }
  for (int v362 = 0; v362 < 256; v362 += 1) {	// L508
    for (int v363 = 0; v363 < 8; v363 += 1) {	// L509
      for (int v364 = 0; v364 < 8; v364 += 1) {	// L510
        int8_t v365 = v73[0][v362][v363][v364];	// L511
        v72[0][v362][(v363 + 1)][(v364 + 1)] = v365;	// L512
      }
    }
  }
  for (int v366 = 0; v366 < 256; v366 += 1) {	// L516
    for (int v367 = 0; v367 < 4; v367 += 1) {	// L517
      for (int v368 = 0; v368 < 4; v368 += 1) {	// L518
        v71[0][v366][v367][v368] = 0;	// L519
        for (int v369 = 0; v369 < 3; v369 += 1) {	// L520
          for (int v370 = 0; v370 < 3; v370 += 1) {	// L521
            int8_t v371 = v72[0][v366][((v367 * 2) + v369)][((v368 * 2) + v370)];	// L522
            int8_t v372 = v12[v366][0][v369][v370];	// L523
            int8_t v373 = v71[0][v366][v367][v368];	// L524
            int16_t v374 = v371;	// L525
            int16_t v375 = v372;	// L526
            int32_t v376 = v374 * v375;	// L527
            int32_t v377 = v373;	// L528
            int32_t v378 = v377 + v376;	// L529
            int8_t v379 = v378;	// L530
            v71[0][v366][v367][v368] = v379;	// L531
          }
        }
      }
    }
  }
  for (int v380 = 0; v380 < 256; v380 += 1) {	// L537
    for (int v381 = 0; v381 < 4; v381 += 1) {	// L538
      for (int v382 = 0; v382 < 4; v382 += 1) {	// L539
        int8_t v383 = v71[0][v380][v381][v382];	// L540
        bool v384 = v383 < 0;	// L541
        int8_t v385 = v384 ? (int8_t)0 : (int8_t)v383;	// L542
        v70[0][v380][v381][v382] = v385;	// L543
      }
    }
  }
  for (int v386 = 0; v386 < 512; v386 += 1) {	// L547
    for (int v387 = 0; v387 < 4; v387 += 1) {	// L548
      for (int v388 = 0; v388 < 4; v388 += 1) {	// L549
        v69[0][v386][v387][v388] = 0;	// L550
        for (int v389 = 0; v389 < 256; v389 += 1) {	// L551
          int8_t v390 = v70[0][v389][v387][v388];	// L552
          int8_t v391 = v13[v386][v389][0][0];	// L553
          int8_t v392 = v69[0][v386][v387][v388];	// L554
          int16_t v393 = v390;	// L555
          int16_t v394 = v391;	// L556
          int32_t v395 = v393 * v394;	// L557
          int32_t v396 = v392;	// L558
          int32_t v397 = v396 + v395;	// L559
          int8_t v398 = v397;	// L560
          v69[0][v386][v387][v388] = v398;	// L561
        }
      }
    }
  }
  for (int v399 = 0; v399 < 512; v399 += 1) {	// L566
    for (int v400 = 0; v400 < 4; v400 += 1) {	// L567
      for (int v401 = 0; v401 < 4; v401 += 1) {	// L568
        int8_t v402 = v69[0][v399][v400][v401];	// L569
        bool v403 = v402 < 0;	// L570
        int8_t v404 = v403 ? (int8_t)0 : (int8_t)v402;	// L571
        v68[0][v399][v400][v401] = v404;	// L572
      }
    }
  }
  for (int v405 = 0; v405 < 512; v405 += 1) {	// L576
    for (int v406 = 0; v406 < 6; v406 += 1) {	// L577
      for (int v407 = 0; v407 < 6; v407 += 1) {	// L578
        v67[0][v405][v406][v407] = 0;	// L579
      }
    }
  }
  for (int v408 = 0; v408 < 512; v408 += 1) {	// L583
    for (int v409 = 0; v409 < 4; v409 += 1) {	// L584
      for (int v410 = 0; v410 < 4; v410 += 1) {	// L585
        int8_t v411 = v68[0][v408][v409][v410];	// L586
        v67[0][v408][(v409 + 1)][(v410 + 1)] = v411;	// L587
      }
    }
  }
  for (int v412 = 0; v412 < 512; v412 += 1) {	// L591
    for (int v413 = 0; v413 < 4; v413 += 1) {	// L592
      for (int v414 = 0; v414 < 4; v414 += 1) {	// L593
        v66[0][v412][v413][v414] = 0;	// L594
        for (int v415 = 0; v415 < 3; v415 += 1) {	// L595
          for (int v416 = 0; v416 < 3; v416 += 1) {	// L596
            int8_t v417 = v67[0][v412][(v413 + v415)][(v414 + v416)];	// L597
            int8_t v418 = v14[v412][0][v415][v416];	// L598
            int8_t v419 = v66[0][v412][v413][v414];	// L599
            int16_t v420 = v417;	// L600
            int16_t v421 = v418;	// L601
            int32_t v422 = v420 * v421;	// L602
            int32_t v423 = v419;	// L603
            int32_t v424 = v423 + v422;	// L604
            int8_t v425 = v424;	// L605
            v66[0][v412][v413][v414] = v425;	// L606
          }
        }
      }
    }
  }
  for (int v426 = 0; v426 < 512; v426 += 1) {	// L612
    for (int v427 = 0; v427 < 4; v427 += 1) {	// L613
      for (int v428 = 0; v428 < 4; v428 += 1) {	// L614
        int8_t v429 = v66[0][v426][v427][v428];	// L615
        bool v430 = v429 < 0;	// L616
        int8_t v431 = v430 ? (int8_t)0 : (int8_t)v429;	// L617
        v65[0][v426][v427][v428] = v431;	// L618
      }
    }
  }
  for (int v432 = 0; v432 < 512; v432 += 1) {	// L622
    for (int v433 = 0; v433 < 4; v433 += 1) {	// L623
      for (int v434 = 0; v434 < 4; v434 += 1) {	// L624
        v64[0][v432][v433][v434] = 0;	// L625
        for (int v435 = 0; v435 < 512; v435 += 1) {	// L626
          int8_t v436 = v65[0][v435][v433][v434];	// L627
          int8_t v437 = v15[v432][v435][0][0];	// L628
          int8_t v438 = v64[0][v432][v433][v434];	// L629
          int16_t v439 = v436;	// L630
          int16_t v440 = v437;	// L631
          int32_t v441 = v439 * v440;	// L632
          int32_t v442 = v438;	// L633
          int32_t v443 = v442 + v441;	// L634
          int8_t v444 = v443;	// L635
          v64[0][v432][v433][v434] = v444;	// L636
        }
      }
    }
  }
  for (int v445 = 0; v445 < 512; v445 += 1) {	// L641
    for (int v446 = 0; v446 < 4; v446 += 1) {	// L642
      for (int v447 = 0; v447 < 4; v447 += 1) {	// L643
        int8_t v448 = v64[0][v445][v446][v447];	// L644
        bool v449 = v448 < 0;	// L645
        int8_t v450 = v449 ? (int8_t)0 : (int8_t)v448;	// L646
        v63[0][v445][v446][v447] = v450;	// L647
      }
    }
  }
  for (int v451 = 0; v451 < 512; v451 += 1) {	// L651
    for (int v452 = 0; v452 < 6; v452 += 1) {	// L652
      for (int v453 = 0; v453 < 6; v453 += 1) {	// L653
        v62[0][v451][v452][v453] = 0;	// L654
      }
    }
  }
  for (int v454 = 0; v454 < 512; v454 += 1) {	// L658
    for (int v455 = 0; v455 < 4; v455 += 1) {	// L659
      for (int v456 = 0; v456 < 4; v456 += 1) {	// L660
        int8_t v457 = v63[0][v454][v455][v456];	// L661
        v62[0][v454][(v455 + 1)][(v456 + 1)] = v457;	// L662
      }
    }
  }
  for (int v458 = 0; v458 < 512; v458 += 1) {	// L666
    for (int v459 = 0; v459 < 4; v459 += 1) {	// L667
      for (int v460 = 0; v460 < 4; v460 += 1) {	// L668
        v61[0][v458][v459][v460] = 0;	// L669
        for (int v461 = 0; v461 < 3; v461 += 1) {	// L670
          for (int v462 = 0; v462 < 3; v462 += 1) {	// L671
            int8_t v463 = v62[0][v458][(v459 + v461)][(v460 + v462)];	// L672
            int8_t v464 = v16[v458][0][v461][v462];	// L673
            int8_t v465 = v61[0][v458][v459][v460];	// L674
            int16_t v466 = v463;	// L675
            int16_t v467 = v464;	// L676
            int32_t v468 = v466 * v467;	// L677
            int32_t v469 = v465;	// L678
            int32_t v470 = v469 + v468;	// L679
            int8_t v471 = v470;	// L680
            v61[0][v458][v459][v460] = v471;	// L681
          }
        }
      }
    }
  }
  for (int v472 = 0; v472 < 512; v472 += 1) {	// L687
    for (int v473 = 0; v473 < 4; v473 += 1) {	// L688
      for (int v474 = 0; v474 < 4; v474 += 1) {	// L689
        int8_t v475 = v61[0][v472][v473][v474];	// L690
        bool v476 = v475 < 0;	// L691
        int8_t v477 = v476 ? (int8_t)0 : (int8_t)v475;	// L692
        v60[0][v472][v473][v474] = v477;	// L693
      }
    }
  }
  for (int v478 = 0; v478 < 512; v478 += 1) {	// L697
    for (int v479 = 0; v479 < 4; v479 += 1) {	// L698
      for (int v480 = 0; v480 < 4; v480 += 1) {	// L699
        v59[0][v478][v479][v480] = 0;	// L700
        for (int v481 = 0; v481 < 512; v481 += 1) {	// L701
          int8_t v482 = v60[0][v481][v479][v480];	// L702
          int8_t v483 = v17[v478][v481][0][0];	// L703
          int8_t v484 = v59[0][v478][v479][v480];	// L704
          int16_t v485 = v482;	// L705
          int16_t v486 = v483;	// L706
          int32_t v487 = v485 * v486;	// L707
          int32_t v488 = v484;	// L708
          int32_t v489 = v488 + v487;	// L709
          int8_t v490 = v489;	// L710
          v59[0][v478][v479][v480] = v490;	// L711
        }
      }
    }
  }
  for (int v491 = 0; v491 < 512; v491 += 1) {	// L716
    for (int v492 = 0; v492 < 4; v492 += 1) {	// L717
      for (int v493 = 0; v493 < 4; v493 += 1) {	// L718
        int8_t v494 = v59[0][v491][v492][v493];	// L719
        bool v495 = v494 < 0;	// L720
        int8_t v496 = v495 ? (int8_t)0 : (int8_t)v494;	// L721
        v58[0][v491][v492][v493] = v496;	// L722
      }
    }
  }
  for (int v497 = 0; v497 < 512; v497 += 1) {	// L726
    for (int v498 = 0; v498 < 6; v498 += 1) {	// L727
      for (int v499 = 0; v499 < 6; v499 += 1) {	// L728
        v57[0][v497][v498][v499] = 0;	// L729
      }
    }
  }
  for (int v500 = 0; v500 < 512; v500 += 1) {	// L733
    for (int v501 = 0; v501 < 4; v501 += 1) {	// L734
      for (int v502 = 0; v502 < 4; v502 += 1) {	// L735
        int8_t v503 = v58[0][v500][v501][v502];	// L736
        v57[0][v500][(v501 + 1)][(v502 + 1)] = v503;	// L737
      }
    }
  }
  for (int v504 = 0; v504 < 512; v504 += 1) {	// L741
    for (int v505 = 0; v505 < 4; v505 += 1) {	// L742
      for (int v506 = 0; v506 < 4; v506 += 1) {	// L743
        v56[0][v504][v505][v506] = 0;	// L744
        for (int v507 = 0; v507 < 3; v507 += 1) {	// L745
          for (int v508 = 0; v508 < 3; v508 += 1) {	// L746
            int8_t v509 = v57[0][v504][(v505 + v507)][(v506 + v508)];	// L747
            int8_t v510 = v18[v504][0][v507][v508];	// L748
            int8_t v511 = v56[0][v504][v505][v506];	// L749
            int16_t v512 = v509;	// L750
            int16_t v513 = v510;	// L751
            int32_t v514 = v512 * v513;	// L752
            int32_t v515 = v511;	// L753
            int32_t v516 = v515 + v514;	// L754
            int8_t v517 = v516;	// L755
            v56[0][v504][v505][v506] = v517;	// L756
          }
        }
      }
    }
  }
  for (int v518 = 0; v518 < 512; v518 += 1) {	// L762
    for (int v519 = 0; v519 < 4; v519 += 1) {	// L763
      for (int v520 = 0; v520 < 4; v520 += 1) {	// L764
        int8_t v521 = v56[0][v518][v519][v520];	// L765
        bool v522 = v521 < 0;	// L766
        int8_t v523 = v522 ? (int8_t)0 : (int8_t)v521;	// L767
        v55[0][v518][v519][v520] = v523;	// L768
      }
    }
  }
  for (int v524 = 0; v524 < 512; v524 += 1) {	// L772
    for (int v525 = 0; v525 < 4; v525 += 1) {	// L773
      for (int v526 = 0; v526 < 4; v526 += 1) {	// L774
        v54[0][v524][v525][v526] = 0;	// L775
        for (int v527 = 0; v527 < 512; v527 += 1) {	// L776
          int8_t v528 = v55[0][v527][v525][v526];	// L777
          int8_t v529 = v19[v524][v527][0][0];	// L778
          int8_t v530 = v54[0][v524][v525][v526];	// L779
          int16_t v531 = v528;	// L780
          int16_t v532 = v529;	// L781
          int32_t v533 = v531 * v532;	// L782
          int32_t v534 = v530;	// L783
          int32_t v535 = v534 + v533;	// L784
          int8_t v536 = v535;	// L785
          v54[0][v524][v525][v526] = v536;	// L786
        }
      }
    }
  }
  for (int v537 = 0; v537 < 512; v537 += 1) {	// L791
    for (int v538 = 0; v538 < 4; v538 += 1) {	// L792
      for (int v539 = 0; v539 < 4; v539 += 1) {	// L793
        int8_t v540 = v54[0][v537][v538][v539];	// L794
        bool v541 = v540 < 0;	// L795
        int8_t v542 = v541 ? (int8_t)0 : (int8_t)v540;	// L796
        v53[0][v537][v538][v539] = v542;	// L797
      }
    }
  }
  for (int v543 = 0; v543 < 512; v543 += 1) {	// L801
    for (int v544 = 0; v544 < 6; v544 += 1) {	// L802
      for (int v545 = 0; v545 < 6; v545 += 1) {	// L803
        v52[0][v543][v544][v545] = 0;	// L804
      }
    }
  }
  for (int v546 = 0; v546 < 512; v546 += 1) {	// L808
    for (int v547 = 0; v547 < 4; v547 += 1) {	// L809
      for (int v548 = 0; v548 < 4; v548 += 1) {	// L810
        int8_t v549 = v53[0][v546][v547][v548];	// L811
        v52[0][v546][(v547 + 1)][(v548 + 1)] = v549;	// L812
      }
    }
  }
  for (int v550 = 0; v550 < 512; v550 += 1) {	// L816
    for (int v551 = 0; v551 < 4; v551 += 1) {	// L817
      for (int v552 = 0; v552 < 4; v552 += 1) {	// L818
        v51[0][v550][v551][v552] = 0;	// L819
        for (int v553 = 0; v553 < 3; v553 += 1) {	// L820
          for (int v554 = 0; v554 < 3; v554 += 1) {	// L821
            int8_t v555 = v52[0][v550][(v551 + v553)][(v552 + v554)];	// L822
            int8_t v556 = v20[v550][0][v553][v554];	// L823
            int8_t v557 = v51[0][v550][v551][v552];	// L824
            int16_t v558 = v555;	// L825
            int16_t v559 = v556;	// L826
            int32_t v560 = v558 * v559;	// L827
            int32_t v561 = v557;	// L828
            int32_t v562 = v561 + v560;	// L829
            int8_t v563 = v562;	// L830
            v51[0][v550][v551][v552] = v563;	// L831
          }
        }
      }
    }
  }
  for (int v564 = 0; v564 < 512; v564 += 1) {	// L837
    for (int v565 = 0; v565 < 4; v565 += 1) {	// L838
      for (int v566 = 0; v566 < 4; v566 += 1) {	// L839
        int8_t v567 = v51[0][v564][v565][v566];	// L840
        bool v568 = v567 < 0;	// L841
        int8_t v569 = v568 ? (int8_t)0 : (int8_t)v567;	// L842
        v50[0][v564][v565][v566] = v569;	// L843
      }
    }
  }
  for (int v570 = 0; v570 < 512; v570 += 1) {	// L847
    for (int v571 = 0; v571 < 4; v571 += 1) {	// L848
      for (int v572 = 0; v572 < 4; v572 += 1) {	// L849
        v49[0][v570][v571][v572] = 0;	// L850
        for (int v573 = 0; v573 < 512; v573 += 1) {	// L851
          int8_t v574 = v50[0][v573][v571][v572];	// L852
          int8_t v575 = v21[v570][v573][0][0];	// L853
          int8_t v576 = v49[0][v570][v571][v572];	// L854
          int16_t v577 = v574;	// L855
          int16_t v578 = v575;	// L856
          int32_t v579 = v577 * v578;	// L857
          int32_t v580 = v576;	// L858
          int32_t v581 = v580 + v579;	// L859
          int8_t v582 = v581;	// L860
          v49[0][v570][v571][v572] = v582;	// L861
        }
      }
    }
  }
  for (int v583 = 0; v583 < 512; v583 += 1) {	// L866
    for (int v584 = 0; v584 < 4; v584 += 1) {	// L867
      for (int v585 = 0; v585 < 4; v585 += 1) {	// L868
        int8_t v586 = v49[0][v583][v584][v585];	// L869
        bool v587 = v586 < 0;	// L870
        int8_t v588 = v587 ? (int8_t)0 : (int8_t)v586;	// L871
        v48[0][v583][v584][v585] = v588;	// L872
      }
    }
  }
  for (int v589 = 0; v589 < 512; v589 += 1) {	// L876
    for (int v590 = 0; v590 < 6; v590 += 1) {	// L877
      for (int v591 = 0; v591 < 6; v591 += 1) {	// L878
        v47[0][v589][v590][v591] = 0;	// L879
      }
    }
  }
  for (int v592 = 0; v592 < 512; v592 += 1) {	// L883
    for (int v593 = 0; v593 < 4; v593 += 1) {	// L884
      for (int v594 = 0; v594 < 4; v594 += 1) {	// L885
        int8_t v595 = v48[0][v592][v593][v594];	// L886
        v47[0][v592][(v593 + 1)][(v594 + 1)] = v595;	// L887
      }
    }
  }
  for (int v596 = 0; v596 < 512; v596 += 1) {	// L891
    for (int v597 = 0; v597 < 4; v597 += 1) {	// L892
      for (int v598 = 0; v598 < 4; v598 += 1) {	// L893
        v46[0][v596][v597][v598] = 0;	// L894
        for (int v599 = 0; v599 < 3; v599 += 1) {	// L895
          for (int v600 = 0; v600 < 3; v600 += 1) {	// L896
            int8_t v601 = v47[0][v596][(v597 + v599)][(v598 + v600)];	// L897
            int8_t v602 = v22[v596][0][v599][v600];	// L898
            int8_t v603 = v46[0][v596][v597][v598];	// L899
            int16_t v604 = v601;	// L900
            int16_t v605 = v602;	// L901
            int32_t v606 = v604 * v605;	// L902
            int32_t v607 = v603;	// L903
            int32_t v608 = v607 + v606;	// L904
            int8_t v609 = v608;	// L905
            v46[0][v596][v597][v598] = v609;	// L906
          }
        }
      }
    }
  }
  for (int v610 = 0; v610 < 512; v610 += 1) {	// L912
    for (int v611 = 0; v611 < 4; v611 += 1) {	// L913
      for (int v612 = 0; v612 < 4; v612 += 1) {	// L914
        int8_t v613 = v46[0][v610][v611][v612];	// L915
        bool v614 = v613 < 0;	// L916
        int8_t v615 = v614 ? (int8_t)0 : (int8_t)v613;	// L917
        v45[0][v610][v611][v612] = v615;	// L918
      }
    }
  }
  for (int v616 = 0; v616 < 512; v616 += 1) {	// L922
    for (int v617 = 0; v617 < 4; v617 += 1) {	// L923
      for (int v618 = 0; v618 < 4; v618 += 1) {	// L924
        v44[0][v616][v617][v618] = 0;	// L925
        for (int v619 = 0; v619 < 512; v619 += 1) {	// L926
          int8_t v620 = v45[0][v619][v617][v618];	// L927
          int8_t v621 = v23[v616][v619][0][0];	// L928
          int8_t v622 = v44[0][v616][v617][v618];	// L929
          int16_t v623 = v620;	// L930
          int16_t v624 = v621;	// L931
          int32_t v625 = v623 * v624;	// L932
          int32_t v626 = v622;	// L933
          int32_t v627 = v626 + v625;	// L934
          int8_t v628 = v627;	// L935
          v44[0][v616][v617][v618] = v628;	// L936
        }
      }
    }
  }
  for (int v629 = 0; v629 < 512; v629 += 1) {	// L941
    for (int v630 = 0; v630 < 4; v630 += 1) {	// L942
      for (int v631 = 0; v631 < 4; v631 += 1) {	// L943
        int8_t v632 = v44[0][v629][v630][v631];	// L944
        bool v633 = v632 < 0;	// L945
        int8_t v634 = v633 ? (int8_t)0 : (int8_t)v632;	// L946
        v43[0][v629][v630][v631] = v634;	// L947
      }
    }
  }
  for (int v635 = 0; v635 < 512; v635 += 1) {	// L951
    for (int v636 = 0; v636 < 6; v636 += 1) {	// L952
      for (int v637 = 0; v637 < 6; v637 += 1) {	// L953
        v42[0][v635][v636][v637] = 0;	// L954
      }
    }
  }
  for (int v638 = 0; v638 < 512; v638 += 1) {	// L958
    for (int v639 = 0; v639 < 4; v639 += 1) {	// L959
      for (int v640 = 0; v640 < 4; v640 += 1) {	// L960
        int8_t v641 = v43[0][v638][v639][v640];	// L961
        v42[0][v638][(v639 + 1)][(v640 + 1)] = v641;	// L962
      }
    }
  }
  for (int v642 = 0; v642 < 512; v642 += 1) {	// L966
    for (int v643 = 0; v643 < 2; v643 += 1) {	// L967
      for (int v644 = 0; v644 < 2; v644 += 1) {	// L968
        v41[0][v642][v643][v644] = 0;	// L969
        for (int v645 = 0; v645 < 3; v645 += 1) {	// L970
          for (int v646 = 0; v646 < 3; v646 += 1) {	// L971
            int8_t v647 = v42[0][v642][((v643 * 2) + v645)][((v644 * 2) + v646)];	// L972
            int8_t v648 = v24[v642][0][v645][v646];	// L973
            int8_t v649 = v41[0][v642][v643][v644];	// L974
            int16_t v650 = v647;	// L975
            int16_t v651 = v648;	// L976
            int32_t v652 = v650 * v651;	// L977
            int32_t v653 = v649;	// L978
            int32_t v654 = v653 + v652;	// L979
            int8_t v655 = v654;	// L980
            v41[0][v642][v643][v644] = v655;	// L981
          }
        }
      }
    }
  }
  for (int v656 = 0; v656 < 512; v656 += 1) {	// L987
    for (int v657 = 0; v657 < 2; v657 += 1) {	// L988
      for (int v658 = 0; v658 < 2; v658 += 1) {	// L989
        int8_t v659 = v41[0][v656][v657][v658];	// L990
        bool v660 = v659 < 0;	// L991
        int8_t v661 = v660 ? (int8_t)0 : (int8_t)v659;	// L992
        v40[0][v656][v657][v658] = v661;	// L993
      }
    }
  }
  for (int v662 = 0; v662 < 1024; v662 += 1) {	// L997
    for (int v663 = 0; v663 < 2; v663 += 1) {	// L998
      for (int v664 = 0; v664 < 2; v664 += 1) {	// L999
        v39[0][v662][v663][v664] = 0;	// L1000
        for (int v665 = 0; v665 < 512; v665 += 1) {	// L1001
          int8_t v666 = v40[0][v665][v663][v664];	// L1002
          int8_t v667 = v25[v662][v665][0][0];	// L1003
          int8_t v668 = v39[0][v662][v663][v664];	// L1004
          int16_t v669 = v666;	// L1005
          int16_t v670 = v667;	// L1006
          int32_t v671 = v669 * v670;	// L1007
          int32_t v672 = v668;	// L1008
          int32_t v673 = v672 + v671;	// L1009
          int8_t v674 = v673;	// L1010
          v39[0][v662][v663][v664] = v674;	// L1011
        }
      }
    }
  }
  for (int v675 = 0; v675 < 1024; v675 += 1) {	// L1016
    for (int v676 = 0; v676 < 2; v676 += 1) {	// L1017
      for (int v677 = 0; v677 < 2; v677 += 1) {	// L1018
        int8_t v678 = v39[0][v675][v676][v677];	// L1019
        bool v679 = v678 < 0;	// L1020
        int8_t v680 = v679 ? (int8_t)0 : (int8_t)v678;	// L1021
        v38[0][v675][v676][v677] = v680;	// L1022
      }
    }
  }
  for (int v681 = 0; v681 < 1024; v681 += 1) {	// L1026
    for (int v682 = 0; v682 < 4; v682 += 1) {	// L1027
      for (int v683 = 0; v683 < 4; v683 += 1) {	// L1028
        v37[0][v681][v682][v683] = 0;	// L1029
      }
    }
  }
  for (int v684 = 0; v684 < 1024; v684 += 1) {	// L1033
    for (int v685 = 0; v685 < 2; v685 += 1) {	// L1034
      for (int v686 = 0; v686 < 2; v686 += 1) {	// L1035
        int8_t v687 = v38[0][v684][v685][v686];	// L1036
        v37[0][v684][(v685 + 1)][(v686 + 1)] = v687;	// L1037
      }
    }
  }
  for (int v688 = 0; v688 < 1024; v688 += 1) {	// L1041
    for (int v689 = 0; v689 < 2; v689 += 1) {	// L1042
      for (int v690 = 0; v690 < 2; v690 += 1) {	// L1043
        v36[0][v688][v689][v690] = 0;	// L1044
        for (int v691 = 0; v691 < 3; v691 += 1) {	// L1045
          for (int v692 = 0; v692 < 3; v692 += 1) {	// L1046
            int8_t v693 = v37[0][v688][(v689 + v691)][(v690 + v692)];	// L1047
            int8_t v694 = v26[v688][0][v691][v692];	// L1048
            int8_t v695 = v36[0][v688][v689][v690];	// L1049
            int16_t v696 = v693;	// L1050
            int16_t v697 = v694;	// L1051
            int32_t v698 = v696 * v697;	// L1052
            int32_t v699 = v695;	// L1053
            int32_t v700 = v699 + v698;	// L1054
            int8_t v701 = v700;	// L1055
            v36[0][v688][v689][v690] = v701;	// L1056
          }
        }
      }
    }
  }
  for (int v702 = 0; v702 < 1024; v702 += 1) {	// L1062
    for (int v703 = 0; v703 < 2; v703 += 1) {	// L1063
      for (int v704 = 0; v704 < 2; v704 += 1) {	// L1064
        int8_t v705 = v36[0][v702][v703][v704];	// L1065
        bool v706 = v705 < 0;	// L1066
        int8_t v707 = v706 ? (int8_t)0 : (int8_t)v705;	// L1067
        v35[0][v702][v703][v704] = v707;	// L1068
      }
    }
  }
  for (int v708 = 0; v708 < 1024; v708 += 1) {	// L1072
    for (int v709 = 0; v709 < 2; v709 += 1) {	// L1073
      for (int v710 = 0; v710 < 2; v710 += 1) {	// L1074
        v34[0][v708][v709][v710] = 0;	// L1075
        for (int v711 = 0; v711 < 1024; v711 += 1) {	// L1076
          int8_t v712 = v35[0][v711][v709][v710];	// L1077
          int8_t v713 = v27[v708][v711][0][0];	// L1078
          int8_t v714 = v34[0][v708][v709][v710];	// L1079
          int16_t v715 = v712;	// L1080
          int16_t v716 = v713;	// L1081
          int32_t v717 = v715 * v716;	// L1082
          int32_t v718 = v714;	// L1083
          int32_t v719 = v718 + v717;	// L1084
          int8_t v720 = v719;	// L1085
          v34[0][v708][v709][v710] = v720;	// L1086
        }
      }
    }
  }
  for (int v721 = 0; v721 < 1024; v721 += 1) {	// L1091
    for (int v722 = 0; v722 < 2; v722 += 1) {	// L1092
      for (int v723 = 0; v723 < 2; v723 += 1) {	// L1093
        int8_t v724 = v34[0][v721][v722][v723];	// L1094
        bool v725 = v724 < 0;	// L1095
        int8_t v726 = v725 ? (int8_t)0 : (int8_t)v724;	// L1096
        v33[0][v721][v722][v723] = v726;	// L1097
      }
    }
  }
  for (int v727 = 0; v727 < 1024; v727 += 1) {	// L1101
    v32[0][v727][0][0] = 0;	// L1102
  }
  for (int v728 = 0; v728 < 1024; v728 += 1) {	// L1104
    for (int v729 = 0; v729 < 2; v729 += 1) {	// L1105
      for (int v730 = 0; v730 < 2; v730 += 1) {	// L1106
        int8_t v731 = v33[0][v728][v729][v730];	// L1107
        int8_t v732 = v32[0][v728][0][0];	// L1108
        int32_t v733 = v732;	// L1109
        int32_t v734 = v731;	// L1110
        int32_t v735 = v733 + v734;	// L1111
        int8_t v736 = v735;	// L1112
        v32[0][v728][0][0] = v736;	// L1113
      }
    }
  }
  for (int v737 = 0; v737 < 1024; v737 += 1) {	// L1117
    int8_t v738 = v32[0][v737][0][0];	// L1118
    int8_t v739 = v738 / 4;	// L1119
    v32[0][v737][0][0] = v739;	// L1120
  }
  for (int v740 = 0; v740 < 1024; v740 += 1) {	// L1122
    int8_t v741 = v32[0][v740][0][0];	// L1123
    v31[0][v740] = v741;	// L1124
  }
  #pragma HLS resource variable=v30 core=ram_s2p_bram

  for (int v743 = 0; v743 < 10; v743 += 1) {	// L1127
    v29[0][v743] = 0;	// L1128
    for (int v744 = 0; v744 < 1024; v744 += 1) {	// L1129
      int8_t v745 = v31[0][v744];	// L1130
      int8_t v746 = v28[v743][v744];	// L1131
      int8_t v747 = v29[0][v743];	// L1132
      int16_t v748 = v745;	// L1133
      int16_t v749 = v746;	// L1134
      int32_t v750 = v748 * v749;	// L1135
      int32_t v751 = v747;	// L1136
      int32_t v752 = v751 + v750;	// L1137
      int8_t v753 = v752;	// L1138
      v29[0][v743] = v753;	// L1139
    }
    int8_t v754 = v29[0][v743];	// L1141
    int16_t v755 = 1;	// L1142
    int16_t v756 = v754;	// L1143
    int32_t v757 = v755 * v756;	// L1144
    int8_t v758 = v30[v743];	// L1145
    int16_t v759 = 1;	// L1146
    int16_t v760 = v758;	// L1147
    int32_t v761 = v759 * v760;	// L1148
    int32_t v762 = v757 + v761;	// L1149
    int8_t v763 = v762;	// L1150
    v29[0][v743] = v763;	// L1151
  }
}

