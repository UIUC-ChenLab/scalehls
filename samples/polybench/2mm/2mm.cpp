
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

void kernel_2mm_node0(
  hls::stream<bool> &v0,
  float v1[180][190],
  float v2[190][220],
  float v3[180][220],
  float v4
) {	// L6
  #pragma HLS inline
  #pragma HLS array_partition variable=v1 cyclic factor=9 dim=1

  #pragma HLS array_partition variable=v2 cyclic factor=2 dim=2

  #pragma HLS array_partition variable=v3 cyclic factor=9 dim=1
  #pragma HLS array_partition variable=v3 cyclic factor=2 dim=2

  v0.read();	// L7
  for (int v5 = 0; v5 < 190; v5 += 1) {	// L8
    for (int v6 = 0; v6 < 180; v6 += 9) {	// L9
      for (int v7 = 0; v7 < 220; v7 += 2) {	// L10
        #pragma HLS pipeline II=1
        float v8 = v3[v6][v7];	// L11
        float v9 = v8 * v4;	// L12
        float v10 = (v5 == 0) ? v9 : v8;	// L13
        float v11 = v1[v6][v5];	// L14
        float v12 = v2[v5][v7];	// L15
        float v13 = v11 * v12;	// L16
        float v14 = v10 + v13;	// L17
        v3[v6][v7] = v14;	// L18
        float v15 = v3[v6][(v7 + 1)];	// L19
        float v16 = v15 * v4;	// L20
        float v17 = (v5 == 0) ? v16 : v15;	// L21
        float v18 = v2[v5][(v7 + 1)];	// L22
        float v19 = v11 * v18;	// L23
        float v20 = v17 + v19;	// L24
        v3[v6][(v7 + 1)] = v20;	// L25
        float v21 = v3[(v6 + 1)][v7];	// L26
        float v22 = v21 * v4;	// L27
        float v23 = (v5 == 0) ? v22 : v21;	// L28
        float v24 = v1[(v6 + 1)][v5];	// L29
        float v25 = v24 * v12;	// L30
        float v26 = v23 + v25;	// L31
        v3[(v6 + 1)][v7] = v26;	// L32
        float v27 = v3[(v6 + 1)][(v7 + 1)];	// L33
        float v28 = v27 * v4;	// L34
        float v29 = (v5 == 0) ? v28 : v27;	// L35
        float v30 = v24 * v18;	// L36
        float v31 = v29 + v30;	// L37
        v3[(v6 + 1)][(v7 + 1)] = v31;	// L38
        float v32 = v3[(v6 + 2)][v7];	// L39
        float v33 = v32 * v4;	// L40
        float v34 = (v5 == 0) ? v33 : v32;	// L41
        float v35 = v1[(v6 + 2)][v5];	// L42
        float v36 = v35 * v12;	// L43
        float v37 = v34 + v36;	// L44
        v3[(v6 + 2)][v7] = v37;	// L45
        float v38 = v3[(v6 + 2)][(v7 + 1)];	// L46
        float v39 = v38 * v4;	// L47
        float v40 = (v5 == 0) ? v39 : v38;	// L48
        float v41 = v35 * v18;	// L49
        float v42 = v40 + v41;	// L50
        v3[(v6 + 2)][(v7 + 1)] = v42;	// L51
        float v43 = v3[(v6 + 3)][v7];	// L52
        float v44 = v43 * v4;	// L53
        float v45 = (v5 == 0) ? v44 : v43;	// L54
        float v46 = v1[(v6 + 3)][v5];	// L55
        float v47 = v46 * v12;	// L56
        float v48 = v45 + v47;	// L57
        v3[(v6 + 3)][v7] = v48;	// L58
        float v49 = v3[(v6 + 3)][(v7 + 1)];	// L59
        float v50 = v49 * v4;	// L60
        float v51 = (v5 == 0) ? v50 : v49;	// L61
        float v52 = v46 * v18;	// L62
        float v53 = v51 + v52;	// L63
        v3[(v6 + 3)][(v7 + 1)] = v53;	// L64
        float v54 = v3[(v6 + 4)][v7];	// L65
        float v55 = v54 * v4;	// L66
        float v56 = (v5 == 0) ? v55 : v54;	// L67
        float v57 = v1[(v6 + 4)][v5];	// L68
        float v58 = v57 * v12;	// L69
        float v59 = v56 + v58;	// L70
        v3[(v6 + 4)][v7] = v59;	// L71
        float v60 = v3[(v6 + 4)][(v7 + 1)];	// L72
        float v61 = v60 * v4;	// L73
        float v62 = (v5 == 0) ? v61 : v60;	// L74
        float v63 = v57 * v18;	// L75
        float v64 = v62 + v63;	// L76
        v3[(v6 + 4)][(v7 + 1)] = v64;	// L77
        float v65 = v3[(v6 + 5)][v7];	// L78
        float v66 = v65 * v4;	// L79
        float v67 = (v5 == 0) ? v66 : v65;	// L80
        float v68 = v1[(v6 + 5)][v5];	// L81
        float v69 = v68 * v12;	// L82
        float v70 = v67 + v69;	// L83
        v3[(v6 + 5)][v7] = v70;	// L84
        float v71 = v3[(v6 + 5)][(v7 + 1)];	// L85
        float v72 = v71 * v4;	// L86
        float v73 = (v5 == 0) ? v72 : v71;	// L87
        float v74 = v68 * v18;	// L88
        float v75 = v73 + v74;	// L89
        v3[(v6 + 5)][(v7 + 1)] = v75;	// L90
        float v76 = v3[(v6 + 6)][v7];	// L91
        float v77 = v76 * v4;	// L92
        float v78 = (v5 == 0) ? v77 : v76;	// L93
        float v79 = v1[(v6 + 6)][v5];	// L94
        float v80 = v79 * v12;	// L95
        float v81 = v78 + v80;	// L96
        v3[(v6 + 6)][v7] = v81;	// L97
        float v82 = v3[(v6 + 6)][(v7 + 1)];	// L98
        float v83 = v82 * v4;	// L99
        float v84 = (v5 == 0) ? v83 : v82;	// L100
        float v85 = v79 * v18;	// L101
        float v86 = v84 + v85;	// L102
        v3[(v6 + 6)][(v7 + 1)] = v86;	// L103
        float v87 = v3[(v6 + 7)][v7];	// L104
        float v88 = v87 * v4;	// L105
        float v89 = (v5 == 0) ? v88 : v87;	// L106
        float v90 = v1[(v6 + 7)][v5];	// L107
        float v91 = v90 * v12;	// L108
        float v92 = v89 + v91;	// L109
        v3[(v6 + 7)][v7] = v92;	// L110
        float v93 = v3[(v6 + 7)][(v7 + 1)];	// L111
        float v94 = v93 * v4;	// L112
        float v95 = (v5 == 0) ? v94 : v93;	// L113
        float v96 = v90 * v18;	// L114
        float v97 = v95 + v96;	// L115
        v3[(v6 + 7)][(v7 + 1)] = v97;	// L116
        float v98 = v3[(v6 + 8)][v7];	// L117
        float v99 = v98 * v4;	// L118
        float v100 = (v5 == 0) ? v99 : v98;	// L119
        float v101 = v1[(v6 + 8)][v5];	// L120
        float v102 = v101 * v12;	// L121
        float v103 = v100 + v102;	// L122
        v3[(v6 + 8)][v7] = v103;	// L123
        float v104 = v3[(v6 + 8)][(v7 + 1)];	// L124
        float v105 = v104 * v4;	// L125
        float v106 = (v5 == 0) ? v105 : v104;	// L126
        float v107 = v101 * v18;	// L127
        float v108 = v106 + v107;	// L128
        v3[(v6 + 8)][(v7 + 1)] = v108;	// L129
      }
    }
  }
}

void kernel_2mm_node1(
  float v109[180][210],
  float v110[210][190],
  hls::stream<bool> &v111,
  float v112[180][190],
  float v113
) {	// L135
  #pragma HLS inline
  #pragma HLS array_partition variable=v109 cyclic factor=9 dim=1

  #pragma HLS array_partition variable=v110 cyclic factor=2 dim=2

  #pragma HLS array_partition variable=v112 cyclic factor=9 dim=1
  #pragma HLS array_partition variable=v112 cyclic factor=2 dim=2

  for (int v114 = 0; v114 < 210; v114 += 1) {	// L138
    for (int v115 = 0; v115 < 180; v115 += 9) {	// L139
      for (int v116 = 0; v116 < 190; v116 += 2) {	// L140
        #pragma HLS pipeline II=1
        float v117 = v112[v115][v116];	// L141
        float v118 = (v114 == 0) ? (float)0.000000 : v117;	// L142
        float v119 = v109[v115][v114];	// L143
        float v120 = v113 * v119;	// L144
        float v121 = v110[v114][v116];	// L145
        float v122 = v120 * v121;	// L146
        float v123 = v118 + v122;	// L147
        v112[v115][v116] = v123;	// L148
        float v124 = v112[v115][(v116 + 1)];	// L149
        float v125 = (v114 == 0) ? (float)0.000000 : v124;	// L150
        float v126 = v113 * v119;	// L151
        float v127 = v110[v114][(v116 + 1)];	// L152
        float v128 = v126 * v127;	// L153
        float v129 = v125 + v128;	// L154
        v112[v115][(v116 + 1)] = v129;	// L155
        float v130 = v112[(v115 + 1)][v116];	// L156
        float v131 = (v114 == 0) ? (float)0.000000 : v130;	// L157
        float v132 = v109[(v115 + 1)][v114];	// L158
        float v133 = v113 * v132;	// L159
        float v134 = v133 * v121;	// L160
        float v135 = v131 + v134;	// L161
        v112[(v115 + 1)][v116] = v135;	// L162
        float v136 = v112[(v115 + 1)][(v116 + 1)];	// L163
        float v137 = (v114 == 0) ? (float)0.000000 : v136;	// L164
        float v138 = v113 * v132;	// L165
        float v139 = v138 * v127;	// L166
        float v140 = v137 + v139;	// L167
        v112[(v115 + 1)][(v116 + 1)] = v140;	// L168
        float v141 = v112[(v115 + 2)][v116];	// L169
        float v142 = (v114 == 0) ? (float)0.000000 : v141;	// L170
        float v143 = v109[(v115 + 2)][v114];	// L171
        float v144 = v113 * v143;	// L172
        float v145 = v144 * v121;	// L173
        float v146 = v142 + v145;	// L174
        v112[(v115 + 2)][v116] = v146;	// L175
        float v147 = v112[(v115 + 2)][(v116 + 1)];	// L176
        float v148 = (v114 == 0) ? (float)0.000000 : v147;	// L177
        float v149 = v113 * v143;	// L178
        float v150 = v149 * v127;	// L179
        float v151 = v148 + v150;	// L180
        v112[(v115 + 2)][(v116 + 1)] = v151;	// L181
        float v152 = v112[(v115 + 3)][v116];	// L182
        float v153 = (v114 == 0) ? (float)0.000000 : v152;	// L183
        float v154 = v109[(v115 + 3)][v114];	// L184
        float v155 = v113 * v154;	// L185
        float v156 = v155 * v121;	// L186
        float v157 = v153 + v156;	// L187
        v112[(v115 + 3)][v116] = v157;	// L188
        float v158 = v112[(v115 + 3)][(v116 + 1)];	// L189
        float v159 = (v114 == 0) ? (float)0.000000 : v158;	// L190
        float v160 = v113 * v154;	// L191
        float v161 = v160 * v127;	// L192
        float v162 = v159 + v161;	// L193
        v112[(v115 + 3)][(v116 + 1)] = v162;	// L194
        float v163 = v112[(v115 + 4)][v116];	// L195
        float v164 = (v114 == 0) ? (float)0.000000 : v163;	// L196
        float v165 = v109[(v115 + 4)][v114];	// L197
        float v166 = v113 * v165;	// L198
        float v167 = v166 * v121;	// L199
        float v168 = v164 + v167;	// L200
        v112[(v115 + 4)][v116] = v168;	// L201
        float v169 = v112[(v115 + 4)][(v116 + 1)];	// L202
        float v170 = (v114 == 0) ? (float)0.000000 : v169;	// L203
        float v171 = v113 * v165;	// L204
        float v172 = v171 * v127;	// L205
        float v173 = v170 + v172;	// L206
        v112[(v115 + 4)][(v116 + 1)] = v173;	// L207
        float v174 = v112[(v115 + 5)][v116];	// L208
        float v175 = (v114 == 0) ? (float)0.000000 : v174;	// L209
        float v176 = v109[(v115 + 5)][v114];	// L210
        float v177 = v113 * v176;	// L211
        float v178 = v177 * v121;	// L212
        float v179 = v175 + v178;	// L213
        v112[(v115 + 5)][v116] = v179;	// L214
        float v180 = v112[(v115 + 5)][(v116 + 1)];	// L215
        float v181 = (v114 == 0) ? (float)0.000000 : v180;	// L216
        float v182 = v113 * v176;	// L217
        float v183 = v182 * v127;	// L218
        float v184 = v181 + v183;	// L219
        v112[(v115 + 5)][(v116 + 1)] = v184;	// L220
        float v185 = v112[(v115 + 6)][v116];	// L221
        float v186 = (v114 == 0) ? (float)0.000000 : v185;	// L222
        float v187 = v109[(v115 + 6)][v114];	// L223
        float v188 = v113 * v187;	// L224
        float v189 = v188 * v121;	// L225
        float v190 = v186 + v189;	// L226
        v112[(v115 + 6)][v116] = v190;	// L227
        float v191 = v112[(v115 + 6)][(v116 + 1)];	// L228
        float v192 = (v114 == 0) ? (float)0.000000 : v191;	// L229
        float v193 = v113 * v187;	// L230
        float v194 = v193 * v127;	// L231
        float v195 = v192 + v194;	// L232
        v112[(v115 + 6)][(v116 + 1)] = v195;	// L233
        float v196 = v112[(v115 + 7)][v116];	// L234
        float v197 = (v114 == 0) ? (float)0.000000 : v196;	// L235
        float v198 = v109[(v115 + 7)][v114];	// L236
        float v199 = v113 * v198;	// L237
        float v200 = v199 * v121;	// L238
        float v201 = v197 + v200;	// L239
        v112[(v115 + 7)][v116] = v201;	// L240
        float v202 = v112[(v115 + 7)][(v116 + 1)];	// L241
        float v203 = (v114 == 0) ? (float)0.000000 : v202;	// L242
        float v204 = v113 * v198;	// L243
        float v205 = v204 * v127;	// L244
        float v206 = v203 + v205;	// L245
        v112[(v115 + 7)][(v116 + 1)] = v206;	// L246
        float v207 = v112[(v115 + 8)][v116];	// L247
        float v208 = (v114 == 0) ? (float)0.000000 : v207;	// L248
        float v209 = v109[(v115 + 8)][v114];	// L249
        float v210 = v113 * v209;	// L250
        float v211 = v210 * v121;	// L251
        float v212 = v208 + v211;	// L252
        v112[(v115 + 8)][v116] = v212;	// L253
        float v213 = v112[(v115 + 8)][(v116 + 1)];	// L254
        float v214 = (v114 == 0) ? (float)0.000000 : v213;	// L255
        float v215 = v113 * v209;	// L256
        float v216 = v215 * v127;	// L257
        float v217 = v214 + v216;	// L258
        v112[(v115 + 8)][(v116 + 1)] = v217;	// L259
      }
    }
  }
  v111.write(true);	// L263
}

/// This is top function.
void kernel_2mm(
  ap_int<32> v218,
  ap_int<32> v219,
  ap_int<32> v220,
  ap_int<32> v221,
  float v222,
  float v223,
  float v224[180][190],
  float v225[180][190],
  float v226[180][210],
  float v227[210][190],
  float v228[190][220],
  float v229[180][220]
) {	// L266
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS dataflow

  #pragma HLS interface ap_memory port=v229
  #pragma HLS stable variable=v229
  #pragma HLS array_partition variable=v229 cyclic factor=9 dim=1
  #pragma HLS array_partition variable=v229 cyclic factor=2 dim=2


  #pragma HLS interface ap_memory port=v228
  #pragma HLS stable variable=v228
  #pragma HLS array_partition variable=v228 cyclic factor=2 dim=2


  #pragma HLS interface ap_memory port=v227
  #pragma HLS stable variable=v227
  #pragma HLS array_partition variable=v227 cyclic factor=2 dim=2


  #pragma HLS interface ap_memory port=v226
  #pragma HLS stable variable=v226
  #pragma HLS array_partition variable=v226 cyclic factor=9 dim=1


  #pragma HLS interface ap_memory port=v225
  #pragma HLS stable variable=v225
  #pragma HLS array_partition variable=v225 cyclic factor=9 dim=1
  #pragma HLS array_partition variable=v225 cyclic factor=2 dim=2


  #pragma HLS interface ap_memory port=v224
  #pragma HLS stable variable=v224
  #pragma HLS array_partition variable=v224 cyclic factor=9 dim=1


  hls::stream<bool> v236;	// L279
  kernel_2mm_node1(v226, v227, v236, v225, v222);	// L280
  kernel_2mm_node0(v236, v224, v228, v229, v223);	// L281
}

