
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

void kernel_correlation_node0(
  hls::stream<bool> &v0,
  float v1[260][240],
  float v2[240][240]
) {	// L27
  #pragma HLS inline
  #pragma HLS array_partition variable=v1 cyclic factor=20 dim=1

  v0.read();	// L30
  for (int v3 = 0; v3 < 260; v3 += 20) {	// L31
    for (int v4 = 0; v4 < 239; v4 += 1) {	// L32
      for (int v5 = 0; v5 < 239; v5 += 1) {	// L33
        #pragma HLS pipeline II=1
        if ((((-v4) - v5) + 238) >= 0) {	// L34
          if (v5 == 0 && v3 == 0) {	// L35
            v2[v4][v4] = (float)1.000000;	// L36
          }
          float v6 = v2[v4][((v4 + v5) + 1)];	// L38
          float v7 = (v3 == 0) ? (float)0.000000 : v6;	// L39
          float v8 = v1[v3][v4];	// L40
          float v9 = v1[v3][((v4 + v5) + 1)];	// L41
          float v10 = v8 * v9;	// L42
          float v11 = v7 + v10;	// L43
          v2[v4][((v4 + v5) + 1)] = v11;	// L44
        }
        int v12 = (v3 + 1);	// L46
        if ((((-v4) - v5) + 238) >= 0) {	// L47
          float v13 = v2[v4][((v4 + v5) + 1)];	// L48
          float v14 = (v12 == 0) ? (float)0.000000 : v13;	// L49
          float v15 = v1[(v3 + 1)][v4];	// L50
          float v16 = v1[(v3 + 1)][((v4 + v5) + 1)];	// L51
          float v17 = v15 * v16;	// L52
          float v18 = v14 + v17;	// L53
          v2[v4][((v4 + v5) + 1)] = v18;	// L54
        }
        int v19 = (v3 + 2);	// L56
        if ((((-v4) - v5) + 238) >= 0) {	// L57
          float v20 = v2[v4][((v4 + v5) + 1)];	// L58
          float v21 = (v19 == 0) ? (float)0.000000 : v20;	// L59
          float v22 = v1[(v3 + 2)][v4];	// L60
          float v23 = v1[(v3 + 2)][((v4 + v5) + 1)];	// L61
          float v24 = v22 * v23;	// L62
          float v25 = v21 + v24;	// L63
          v2[v4][((v4 + v5) + 1)] = v25;	// L64
        }
        int v26 = (v3 + 3);	// L66
        if ((((-v4) - v5) + 238) >= 0) {	// L67
          float v27 = v2[v4][((v4 + v5) + 1)];	// L68
          float v28 = (v26 == 0) ? (float)0.000000 : v27;	// L69
          float v29 = v1[(v3 + 3)][v4];	// L70
          float v30 = v1[(v3 + 3)][((v4 + v5) + 1)];	// L71
          float v31 = v29 * v30;	// L72
          float v32 = v28 + v31;	// L73
          v2[v4][((v4 + v5) + 1)] = v32;	// L74
        }
        int v33 = (v3 + 4);	// L76
        if ((((-v4) - v5) + 238) >= 0) {	// L77
          float v34 = v2[v4][((v4 + v5) + 1)];	// L78
          float v35 = (v33 == 0) ? (float)0.000000 : v34;	// L79
          float v36 = v1[(v3 + 4)][v4];	// L80
          float v37 = v1[(v3 + 4)][((v4 + v5) + 1)];	// L81
          float v38 = v36 * v37;	// L82
          float v39 = v35 + v38;	// L83
          v2[v4][((v4 + v5) + 1)] = v39;	// L84
        }
        int v40 = (v3 + 5);	// L86
        if ((((-v4) - v5) + 238) >= 0) {	// L87
          float v41 = v2[v4][((v4 + v5) + 1)];	// L88
          float v42 = (v40 == 0) ? (float)0.000000 : v41;	// L89
          float v43 = v1[(v3 + 5)][v4];	// L90
          float v44 = v1[(v3 + 5)][((v4 + v5) + 1)];	// L91
          float v45 = v43 * v44;	// L92
          float v46 = v42 + v45;	// L93
          v2[v4][((v4 + v5) + 1)] = v46;	// L94
        }
        int v47 = (v3 + 6);	// L96
        if ((((-v4) - v5) + 238) >= 0) {	// L97
          float v48 = v2[v4][((v4 + v5) + 1)];	// L98
          float v49 = (v47 == 0) ? (float)0.000000 : v48;	// L99
          float v50 = v1[(v3 + 6)][v4];	// L100
          float v51 = v1[(v3 + 6)][((v4 + v5) + 1)];	// L101
          float v52 = v50 * v51;	// L102
          float v53 = v49 + v52;	// L103
          v2[v4][((v4 + v5) + 1)] = v53;	// L104
        }
        int v54 = (v3 + 7);	// L106
        if ((((-v4) - v5) + 238) >= 0) {	// L107
          float v55 = v2[v4][((v4 + v5) + 1)];	// L108
          float v56 = (v54 == 0) ? (float)0.000000 : v55;	// L109
          float v57 = v1[(v3 + 7)][v4];	// L110
          float v58 = v1[(v3 + 7)][((v4 + v5) + 1)];	// L111
          float v59 = v57 * v58;	// L112
          float v60 = v56 + v59;	// L113
          v2[v4][((v4 + v5) + 1)] = v60;	// L114
        }
        int v61 = (v3 + 8);	// L116
        if ((((-v4) - v5) + 238) >= 0) {	// L117
          float v62 = v2[v4][((v4 + v5) + 1)];	// L118
          float v63 = (v61 == 0) ? (float)0.000000 : v62;	// L119
          float v64 = v1[(v3 + 8)][v4];	// L120
          float v65 = v1[(v3 + 8)][((v4 + v5) + 1)];	// L121
          float v66 = v64 * v65;	// L122
          float v67 = v63 + v66;	// L123
          v2[v4][((v4 + v5) + 1)] = v67;	// L124
        }
        int v68 = (v3 + 9);	// L126
        if ((((-v4) - v5) + 238) >= 0) {	// L127
          float v69 = v2[v4][((v4 + v5) + 1)];	// L128
          float v70 = (v68 == 0) ? (float)0.000000 : v69;	// L129
          float v71 = v1[(v3 + 9)][v4];	// L130
          float v72 = v1[(v3 + 9)][((v4 + v5) + 1)];	// L131
          float v73 = v71 * v72;	// L132
          float v74 = v70 + v73;	// L133
          v2[v4][((v4 + v5) + 1)] = v74;	// L134
        }
        int v75 = (v3 + 10);	// L136
        if ((((-v4) - v5) + 238) >= 0) {	// L137
          float v76 = v2[v4][((v4 + v5) + 1)];	// L138
          float v77 = (v75 == 0) ? (float)0.000000 : v76;	// L139
          float v78 = v1[(v3 + 10)][v4];	// L140
          float v79 = v1[(v3 + 10)][((v4 + v5) + 1)];	// L141
          float v80 = v78 * v79;	// L142
          float v81 = v77 + v80;	// L143
          v2[v4][((v4 + v5) + 1)] = v81;	// L144
        }
        int v82 = (v3 + 11);	// L146
        if ((((-v4) - v5) + 238) >= 0) {	// L147
          float v83 = v2[v4][((v4 + v5) + 1)];	// L148
          float v84 = (v82 == 0) ? (float)0.000000 : v83;	// L149
          float v85 = v1[(v3 + 11)][v4];	// L150
          float v86 = v1[(v3 + 11)][((v4 + v5) + 1)];	// L151
          float v87 = v85 * v86;	// L152
          float v88 = v84 + v87;	// L153
          v2[v4][((v4 + v5) + 1)] = v88;	// L154
        }
        int v89 = (v3 + 12);	// L156
        if ((((-v4) - v5) + 238) >= 0) {	// L157
          float v90 = v2[v4][((v4 + v5) + 1)];	// L158
          float v91 = (v89 == 0) ? (float)0.000000 : v90;	// L159
          float v92 = v1[(v3 + 12)][v4];	// L160
          float v93 = v1[(v3 + 12)][((v4 + v5) + 1)];	// L161
          float v94 = v92 * v93;	// L162
          float v95 = v91 + v94;	// L163
          v2[v4][((v4 + v5) + 1)] = v95;	// L164
        }
        int v96 = (v3 + 13);	// L166
        if ((((-v4) - v5) + 238) >= 0) {	// L167
          float v97 = v2[v4][((v4 + v5) + 1)];	// L168
          float v98 = (v96 == 0) ? (float)0.000000 : v97;	// L169
          float v99 = v1[(v3 + 13)][v4];	// L170
          float v100 = v1[(v3 + 13)][((v4 + v5) + 1)];	// L171
          float v101 = v99 * v100;	// L172
          float v102 = v98 + v101;	// L173
          v2[v4][((v4 + v5) + 1)] = v102;	// L174
        }
        int v103 = (v3 + 14);	// L176
        if ((((-v4) - v5) + 238) >= 0) {	// L177
          float v104 = v2[v4][((v4 + v5) + 1)];	// L178
          float v105 = (v103 == 0) ? (float)0.000000 : v104;	// L179
          float v106 = v1[(v3 + 14)][v4];	// L180
          float v107 = v1[(v3 + 14)][((v4 + v5) + 1)];	// L181
          float v108 = v106 * v107;	// L182
          float v109 = v105 + v108;	// L183
          v2[v4][((v4 + v5) + 1)] = v109;	// L184
        }
        int v110 = (v3 + 15);	// L186
        if ((((-v4) - v5) + 238) >= 0) {	// L187
          float v111 = v2[v4][((v4 + v5) + 1)];	// L188
          float v112 = (v110 == 0) ? (float)0.000000 : v111;	// L189
          float v113 = v1[(v3 + 15)][v4];	// L190
          float v114 = v1[(v3 + 15)][((v4 + v5) + 1)];	// L191
          float v115 = v113 * v114;	// L192
          float v116 = v112 + v115;	// L193
          v2[v4][((v4 + v5) + 1)] = v116;	// L194
        }
        int v117 = (v3 + 16);	// L196
        if ((((-v4) - v5) + 238) >= 0) {	// L197
          float v118 = v2[v4][((v4 + v5) + 1)];	// L198
          float v119 = (v117 == 0) ? (float)0.000000 : v118;	// L199
          float v120 = v1[(v3 + 16)][v4];	// L200
          float v121 = v1[(v3 + 16)][((v4 + v5) + 1)];	// L201
          float v122 = v120 * v121;	// L202
          float v123 = v119 + v122;	// L203
          v2[v4][((v4 + v5) + 1)] = v123;	// L204
        }
        int v124 = (v3 + 17);	// L206
        if ((((-v4) - v5) + 238) >= 0) {	// L207
          float v125 = v2[v4][((v4 + v5) + 1)];	// L208
          float v126 = (v124 == 0) ? (float)0.000000 : v125;	// L209
          float v127 = v1[(v3 + 17)][v4];	// L210
          float v128 = v1[(v3 + 17)][((v4 + v5) + 1)];	// L211
          float v129 = v127 * v128;	// L212
          float v130 = v126 + v129;	// L213
          v2[v4][((v4 + v5) + 1)] = v130;	// L214
        }
        int v131 = (v3 + 18);	// L216
        if ((((-v4) - v5) + 238) >= 0) {	// L217
          float v132 = v2[v4][((v4 + v5) + 1)];	// L218
          float v133 = (v131 == 0) ? (float)0.000000 : v132;	// L219
          float v134 = v1[(v3 + 18)][v4];	// L220
          float v135 = v1[(v3 + 18)][((v4 + v5) + 1)];	// L221
          float v136 = v134 * v135;	// L222
          float v137 = v133 + v136;	// L223
          v2[v4][((v4 + v5) + 1)] = v137;	// L224
        }
        int v138 = (v3 + 19);	// L226
        if ((((-v4) - v5) + 238) >= 0) {	// L227
          float v139 = v2[v4][((v4 + v5) + 1)];	// L228
          float v140 = (v138 == 0) ? (float)0.000000 : v139;	// L229
          float v141 = v1[(v3 + 19)][v4];	// L230
          float v142 = v1[(v3 + 19)][((v4 + v5) + 1)];	// L231
          float v143 = v141 * v142;	// L232
          float v144 = v140 + v143;	// L233
          v2[v4][((v4 + v5) + 1)] = v144;	// L234
          if (((-v3) + 240) == 0) {	// L235
            v2[((v4 + v5) + 1)][v4] = v144;	// L236
          }
        }
      }
    }
  }
  v2[239][239] = (float)1.000000;	// L242
}

void kernel_correlation_node1(
  hls::stream<bool> &v145,
  float v146[240],
  hls::stream<bool> &v147,
  float v148[240],
  hls::stream<bool> &v149,
  float v150[260][240],
  hls::stream<float> &v151,
  float v152
) {	// L245
  #pragma HLS inline
  v145.read();	// L247
  v147.read();	// L248
  float v153 = sqrt(v152);	// L249
  for (int v154 = 0; v154 < 260; v154 += 1) {	// L250
    for (int v155 = 0; v155 < 240; v155 += 1) {	// L251
      #pragma HLS pipeline II=1
      float v156 = v146[v155];	// L252
      float v157 = v150[v154][v155];	// L253
      float v158 = v157 - v156;	// L254
      float v159 = v148[v155];	// L255
      float v160 = v153 * v159;	// L256
      float v161 = v158 / v160;	// L257
      v150[v154][v155] = v161;	// L258
    }
  }
  v151.write(v153);	// L261
  v149.write(true);	// L262
}

void kernel_correlation_node2(
  float v162[260][240],
  hls::stream<bool> &v163,
  float v164[240],
  hls::stream<bool> &v165,
  float v166[240],
  float v167
) {	// L265
  #pragma HLS inline
  v163.read();	// L270
  for (int v168 = 0; v168 < 260; v168 += 1) {	// L271
    for (int v169 = 0; v169 < 240; v169 += 1) {	// L272
      #pragma HLS pipeline II=1
      float v170 = v166[v169];	// L273
      float v171 = (v168 == 0) ? (float)0.000000 : v170;	// L274
      float v172 = v162[v168][v169];	// L275
      float v173 = v164[v169];	// L276
      float v174 = v172 - v173;	// L277
      float v175 = v174 * v174;	// L278
      float v176 = v171 + v175;	// L279
      float v177 = v176 / v167;	// L280
      float v178 = sqrt(v177);	// L281
      bool v179 = v178 <= (float)0.100000;	// L282
      float v180 = v179 ? (float)1.000000 : v178;	// L283
      float v181 = (((-v168) + 259) == 0) ? v180 : v171;	// L284
      v166[v169] = v181;	// L285
    }
  }
  v165.write(true);	// L288
}

void kernel_correlation_node3(
  hls::stream<bool> &v182,
  float v183[240],
  hls::stream<bool> &v184,
  float v185[240],
  hls::stream<bool> &v186,
  float v187[240]
) {	// L291
  v182.read();	// L293
  for (int v188 = 0; v188 < 240; v188 += 1) {	// L294
    #pragma HLS pipeline II=1
    float v189 = v183[v188];	// L295
    v185[v188] = v189;	// L296
  }
  for (int v190 = 0; v190 < 240; v190 += 1) {	// L298
    #pragma HLS pipeline II=1
    float v191 = v183[v190];	// L299
    v187[v190] = v191;	// L300
  }
  v184.write(true);	// L302
  v186.write(true);	// L303
}

void kernel_correlation_node4(
  float v192[260][240],
  hls::stream<bool> &v193,
  float v194[240],
  float v195
) {	// L306
  #pragma HLS inline
  for (int v196 = 0; v196 < 260; v196 += 1) {	// L309
    for (int v197 = 0; v197 < 240; v197 += 1) {	// L310
      #pragma HLS pipeline II=1
      float v198 = v194[v197];	// L311
      float v199 = (v196 == 0) ? (float)0.000000 : v198;	// L312
      float v200 = v192[v196][v197];	// L313
      float v201 = v199 + v200;	// L314
      float v202 = v201 / v195;	// L315
      float v203 = (((-v196) + 259) == 0) ? v202 : v199;	// L316
      v194[v197] = v203;	// L317
    }
  }
  v193.write(true);	// L320
}

/// This is top function.
void kernel_correlation(
  ap_int<32> v204,
  ap_int<32> v205,
  float v206,
  float v207[260][240],
  float v208[260][240],
  float v209[260][240],
  float v210[260][240],
  float v211[240][240],
  float v212[240],
  float v213[240],
  float v214[240],
  float v215[240],
  float v216[240],
  float v217[240],
  float v218[240],
  float v219[240]
) {	// L323
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v219
  #pragma HLS stable variable=v219

  #pragma HLS interface ap_memory port=v218
  #pragma HLS stable variable=v218

  #pragma HLS interface ap_memory port=v217
  #pragma HLS stable variable=v217

  #pragma HLS interface ap_memory port=v216
  #pragma HLS stable variable=v216

  #pragma HLS interface ap_memory port=v215
  #pragma HLS stable variable=v215

  #pragma HLS interface ap_memory port=v214
  #pragma HLS stable variable=v214

  #pragma HLS interface ap_memory port=v213
  #pragma HLS stable variable=v213

  #pragma HLS interface ap_memory port=v212
  #pragma HLS stable variable=v212

  #pragma HLS interface ap_memory port=v211
  #pragma HLS stable variable=v211

  #pragma HLS interface ap_memory port=v210
  #pragma HLS stable variable=v210

  #pragma HLS interface ap_memory port=v209
  #pragma HLS stable variable=v209

  #pragma HLS interface ap_memory port=v208
  #pragma HLS stable variable=v208

  #pragma HLS interface ap_memory port=v207
  #pragma HLS stable variable=v207
  #pragma HLS array_partition variable=v207 cyclic factor=20 dim=1


  hls::stream<bool> v233;	// L350
  hls::stream<bool> v234;	// L351
  hls::stream<bool> v235;	// L352
  kernel_correlation_node4(v210, v234, v213, v206);	// L353
  hls::stream<bool> v236;	// L354
  hls::stream<bool> v237;	// L355
  kernel_correlation_node3(v234, v212, v236, v216, v237, v218);	// L356
  kernel_correlation_node2(v209, v237, v219, v235, v215, v206);	// L357
  hls::stream<float> v238;	// L358
  kernel_correlation_node1(v236, v217, v235, v214, v233, v208, v238, v206);	// L359
  kernel_correlation_node0(v233, v207, v211);	// L360
}

