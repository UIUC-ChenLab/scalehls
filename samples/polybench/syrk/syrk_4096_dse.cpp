
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
/// Latency=51539607558
/// DSP=0
void syrk_4096(
  float v0,
  float v1,
  float v2[4096][4096],
  float v3[4096][4096]
) {	// L1
  #pragma HLS interface s_axilite port=return bundle=ctrl
  #pragma HLS interface s_axilite port=v0 bundle=ctrl
  #pragma HLS interface s_axilite port=v1 bundle=ctrl
  #pragma HLS interface bram port=v2
  #pragma HLS interface bram port=v3

  #pragma HLS resource variable=v2 core=ram_s2p_bram

  #pragma HLS array_partition variable=v3 cyclic factor=64 dim=2
  #pragma HLS resource variable=v3 core=ram_s2p_bram

  for (int v4 = 0; v4 < 4096; v4 += 64) {	// L2
    for (int v5 = 0; v5 < 4096; v5 += 1) {	// L3
      for (int v6 = 0; v6 < 4096; v6 += 1) {	// L4
        #pragma HLS pipeline II=3
        if ((v5 - v6) >= 0) {	// L5, S[16,16)
          float v7 = v2[v5][v6];	// L6, S[16,16)
          float v8 = v1 * v7;	// L7, S[16,16)
          float v9 = v3[v5][v4];	// L8, S[16,16)
          float v10 = v3[v6][v4];	// L9, S[16,16)
          float v11;
          if (v4 == 0) {	// L10
            v11 = v8;	// L11
          } else {
            v11 = v7;	// L13
          }
          float v12 = v0 * v9;	// L15, S[16,16)
          float v13 = v12 * v10;	// L16, S[16,16)
          float v14 = v11 + v13;	// L17, S[16,16)
          float v15 = v3[v5][(v4 + 1)];	// L18
          float v16 = v3[v6][(v4 + 1)];	// L19
          float v17 = v0 * v15;	// L20, S[16,16)
          float v18 = v17 * v16;	// L21, S[16,16)
          float v19 = v14 + v18;	// L22, S[16,16)
          float v20 = v3[v5][(v4 + 2)];	// L23
          float v21 = v3[v6][(v4 + 2)];	// L24
          float v22 = v0 * v20;	// L25, S[16,16)
          float v23 = v22 * v21;	// L26, S[16,16)
          float v24 = v19 + v23;	// L27, S[16,16)
          float v25 = v3[v5][(v4 + 3)];	// L28
          float v26 = v3[v6][(v4 + 3)];	// L29
          float v27 = v0 * v25;	// L30, S[16,16)
          float v28 = v27 * v26;	// L31, S[16,16)
          float v29 = v24 + v28;	// L32, S[16,16)
          float v30 = v3[v5][(v4 + 4)];	// L33
          float v31 = v3[v6][(v4 + 4)];	// L34
          float v32 = v0 * v30;	// L35, S[16,16)
          float v33 = v32 * v31;	// L36, S[16,16)
          float v34 = v29 + v33;	// L37, S[16,16)
          float v35 = v3[v5][(v4 + 5)];	// L38
          float v36 = v3[v6][(v4 + 5)];	// L39
          float v37 = v0 * v35;	// L40, S[16,16)
          float v38 = v37 * v36;	// L41, S[16,16)
          float v39 = v34 + v38;	// L42, S[16,16)
          float v40 = v3[v5][(v4 + 6)];	// L43
          float v41 = v3[v6][(v4 + 6)];	// L44
          float v42 = v0 * v40;	// L45, S[16,16)
          float v43 = v42 * v41;	// L46, S[16,16)
          float v44 = v39 + v43;	// L47, S[16,16)
          float v45 = v3[v5][(v4 + 7)];	// L48
          float v46 = v3[v6][(v4 + 7)];	// L49
          float v47 = v0 * v45;	// L50, S[16,16)
          float v48 = v47 * v46;	// L51, S[16,16)
          float v49 = v44 + v48;	// L52, S[16,16)
          float v50 = v3[v5][(v4 + 8)];	// L53
          float v51 = v3[v6][(v4 + 8)];	// L54
          float v52 = v0 * v50;	// L55, S[16,16)
          float v53 = v52 * v51;	// L56, S[16,16)
          float v54 = v49 + v53;	// L57, S[16,16)
          float v55 = v3[v5][(v4 + 9)];	// L58
          float v56 = v3[v6][(v4 + 9)];	// L59
          float v57 = v0 * v55;	// L60, S[16,16)
          float v58 = v57 * v56;	// L61, S[16,16)
          float v59 = v54 + v58;	// L62, S[16,16)
          float v60 = v3[v5][(v4 + 10)];	// L63
          float v61 = v3[v6][(v4 + 10)];	// L64
          float v62 = v0 * v60;	// L65, S[16,16)
          float v63 = v62 * v61;	// L66, S[16,16)
          float v64 = v59 + v63;	// L67, S[16,16)
          float v65 = v3[v5][(v4 + 11)];	// L68
          float v66 = v3[v6][(v4 + 11)];	// L69
          float v67 = v0 * v65;	// L70, S[16,16)
          float v68 = v67 * v66;	// L71, S[16,16)
          float v69 = v64 + v68;	// L72, S[16,16)
          float v70 = v3[v5][(v4 + 12)];	// L73
          float v71 = v3[v6][(v4 + 12)];	// L74
          float v72 = v0 * v70;	// L75, S[16,16)
          float v73 = v72 * v71;	// L76, S[16,16)
          float v74 = v69 + v73;	// L77, S[16,16)
          float v75 = v3[v5][(v4 + 13)];	// L78
          float v76 = v3[v6][(v4 + 13)];	// L79
          float v77 = v0 * v75;	// L80, S[16,16)
          float v78 = v77 * v76;	// L81, S[16,16)
          float v79 = v74 + v78;	// L82, S[16,16)
          float v80 = v3[v5][(v4 + 14)];	// L83
          float v81 = v3[v6][(v4 + 14)];	// L84
          float v82 = v0 * v80;	// L85, S[16,16)
          float v83 = v82 * v81;	// L86, S[16,16)
          float v84 = v79 + v83;	// L87, S[16,16)
          float v85 = v3[v5][(v4 + 15)];	// L88
          float v86 = v3[v6][(v4 + 15)];	// L89
          float v87 = v0 * v85;	// L90, S[16,16)
          float v88 = v87 * v86;	// L91, S[16,16)
          float v89 = v84 + v88;	// L92, S[16,16)
          float v90 = v3[v5][(v4 + 16)];	// L93
          float v91 = v3[v6][(v4 + 16)];	// L94
          float v92 = v0 * v90;	// L95, S[16,16)
          float v93 = v92 * v91;	// L96, S[16,16)
          float v94 = v89 + v93;	// L97, S[16,16)
          float v95 = v3[v5][(v4 + 17)];	// L98
          float v96 = v3[v6][(v4 + 17)];	// L99
          float v97 = v0 * v95;	// L100, S[16,16)
          float v98 = v97 * v96;	// L101, S[16,16)
          float v99 = v94 + v98;	// L102, S[16,16)
          float v100 = v3[v5][(v4 + 18)];	// L103
          float v101 = v3[v6][(v4 + 18)];	// L104
          float v102 = v0 * v100;	// L105, S[16,16)
          float v103 = v102 * v101;	// L106, S[16,16)
          float v104 = v99 + v103;	// L107, S[16,16)
          float v105 = v3[v5][(v4 + 19)];	// L108
          float v106 = v3[v6][(v4 + 19)];	// L109
          float v107 = v0 * v105;	// L110, S[16,16)
          float v108 = v107 * v106;	// L111, S[16,16)
          float v109 = v104 + v108;	// L112, S[16,16)
          float v110 = v3[v5][(v4 + 20)];	// L113
          float v111 = v3[v6][(v4 + 20)];	// L114
          float v112 = v0 * v110;	// L115, S[16,16)
          float v113 = v112 * v111;	// L116, S[16,16)
          float v114 = v109 + v113;	// L117, S[16,16)
          float v115 = v3[v5][(v4 + 21)];	// L118
          float v116 = v3[v6][(v4 + 21)];	// L119
          float v117 = v0 * v115;	// L120, S[16,16)
          float v118 = v117 * v116;	// L121, S[16,16)
          float v119 = v114 + v118;	// L122, S[16,16)
          float v120 = v3[v5][(v4 + 22)];	// L123
          float v121 = v3[v6][(v4 + 22)];	// L124
          float v122 = v0 * v120;	// L125, S[16,16)
          float v123 = v122 * v121;	// L126, S[16,16)
          float v124 = v119 + v123;	// L127, S[16,16)
          float v125 = v3[v5][(v4 + 23)];	// L128
          float v126 = v3[v6][(v4 + 23)];	// L129
          float v127 = v0 * v125;	// L130, S[16,16)
          float v128 = v127 * v126;	// L131, S[16,16)
          float v129 = v124 + v128;	// L132, S[16,16)
          float v130 = v3[v5][(v4 + 24)];	// L133
          float v131 = v3[v6][(v4 + 24)];	// L134
          float v132 = v0 * v130;	// L135, S[16,16)
          float v133 = v132 * v131;	// L136, S[16,16)
          float v134 = v129 + v133;	// L137, S[16,16)
          float v135 = v3[v5][(v4 + 25)];	// L138
          float v136 = v3[v6][(v4 + 25)];	// L139
          float v137 = v0 * v135;	// L140, S[16,16)
          float v138 = v137 * v136;	// L141, S[16,16)
          float v139 = v134 + v138;	// L142, S[16,16)
          float v140 = v3[v5][(v4 + 26)];	// L143
          float v141 = v3[v6][(v4 + 26)];	// L144
          float v142 = v0 * v140;	// L145, S[16,16)
          float v143 = v142 * v141;	// L146, S[16,16)
          float v144 = v139 + v143;	// L147, S[16,16)
          float v145 = v3[v5][(v4 + 27)];	// L148
          float v146 = v3[v6][(v4 + 27)];	// L149
          float v147 = v0 * v145;	// L150, S[16,16)
          float v148 = v147 * v146;	// L151, S[16,16)
          float v149 = v144 + v148;	// L152, S[16,16)
          float v150 = v3[v5][(v4 + 28)];	// L153
          float v151 = v3[v6][(v4 + 28)];	// L154
          float v152 = v0 * v150;	// L155, S[16,16)
          float v153 = v152 * v151;	// L156, S[16,16)
          float v154 = v149 + v153;	// L157, S[16,16)
          float v155 = v3[v5][(v4 + 29)];	// L158
          float v156 = v3[v6][(v4 + 29)];	// L159
          float v157 = v0 * v155;	// L160, S[16,16)
          float v158 = v157 * v156;	// L161, S[16,16)
          float v159 = v154 + v158;	// L162, S[16,16)
          float v160 = v3[v5][(v4 + 30)];	// L163
          float v161 = v3[v6][(v4 + 30)];	// L164
          float v162 = v0 * v160;	// L165, S[16,16)
          float v163 = v162 * v161;	// L166, S[16,16)
          float v164 = v159 + v163;	// L167, S[16,16)
          float v165 = v3[v5][(v4 + 31)];	// L168
          float v166 = v3[v6][(v4 + 31)];	// L169
          float v167 = v0 * v165;	// L170, S[16,16)
          float v168 = v167 * v166;	// L171, S[16,16)
          float v169 = v164 + v168;	// L172, S[16,16)
          float v170 = v3[v5][(v4 + 32)];	// L173
          float v171 = v3[v6][(v4 + 32)];	// L174
          float v172 = v0 * v170;	// L175, S[16,16)
          float v173 = v172 * v171;	// L176, S[16,16)
          float v174 = v169 + v173;	// L177, S[16,16)
          float v175 = v3[v5][(v4 + 33)];	// L178
          float v176 = v3[v6][(v4 + 33)];	// L179
          float v177 = v0 * v175;	// L180, S[16,16)
          float v178 = v177 * v176;	// L181, S[16,16)
          float v179 = v174 + v178;	// L182, S[16,16)
          float v180 = v3[v5][(v4 + 34)];	// L183
          float v181 = v3[v6][(v4 + 34)];	// L184
          float v182 = v0 * v180;	// L185, S[16,16)
          float v183 = v182 * v181;	// L186, S[16,16)
          float v184 = v179 + v183;	// L187, S[16,16)
          float v185 = v3[v5][(v4 + 35)];	// L188
          float v186 = v3[v6][(v4 + 35)];	// L189
          float v187 = v0 * v185;	// L190, S[16,16)
          float v188 = v187 * v186;	// L191, S[16,16)
          float v189 = v184 + v188;	// L192, S[16,16)
          float v190 = v3[v5][(v4 + 36)];	// L193
          float v191 = v3[v6][(v4 + 36)];	// L194
          float v192 = v0 * v190;	// L195, S[16,16)
          float v193 = v192 * v191;	// L196, S[16,16)
          float v194 = v189 + v193;	// L197, S[16,16)
          float v195 = v3[v5][(v4 + 37)];	// L198
          float v196 = v3[v6][(v4 + 37)];	// L199
          float v197 = v0 * v195;	// L200, S[16,16)
          float v198 = v197 * v196;	// L201, S[16,16)
          float v199 = v194 + v198;	// L202, S[16,16)
          float v200 = v3[v5][(v4 + 38)];	// L203
          float v201 = v3[v6][(v4 + 38)];	// L204
          float v202 = v0 * v200;	// L205, S[16,16)
          float v203 = v202 * v201;	// L206, S[16,16)
          float v204 = v199 + v203;	// L207, S[16,16)
          float v205 = v3[v5][(v4 + 39)];	// L208
          float v206 = v3[v6][(v4 + 39)];	// L209
          float v207 = v0 * v205;	// L210, S[16,16)
          float v208 = v207 * v206;	// L211, S[16,16)
          float v209 = v204 + v208;	// L212, S[16,16)
          float v210 = v3[v5][(v4 + 40)];	// L213
          float v211 = v3[v6][(v4 + 40)];	// L214
          float v212 = v0 * v210;	// L215, S[16,16)
          float v213 = v212 * v211;	// L216, S[16,16)
          float v214 = v209 + v213;	// L217, S[16,16)
          float v215 = v3[v5][(v4 + 41)];	// L218
          float v216 = v3[v6][(v4 + 41)];	// L219
          float v217 = v0 * v215;	// L220, S[16,16)
          float v218 = v217 * v216;	// L221, S[16,16)
          float v219 = v214 + v218;	// L222, S[16,16)
          float v220 = v3[v5][(v4 + 42)];	// L223
          float v221 = v3[v6][(v4 + 42)];	// L224
          float v222 = v0 * v220;	// L225, S[16,16)
          float v223 = v222 * v221;	// L226, S[16,16)
          float v224 = v219 + v223;	// L227, S[16,16)
          float v225 = v3[v5][(v4 + 43)];	// L228
          float v226 = v3[v6][(v4 + 43)];	// L229
          float v227 = v0 * v225;	// L230, S[16,16)
          float v228 = v227 * v226;	// L231, S[16,16)
          float v229 = v224 + v228;	// L232, S[16,16)
          float v230 = v3[v5][(v4 + 44)];	// L233
          float v231 = v3[v6][(v4 + 44)];	// L234
          float v232 = v0 * v230;	// L235, S[16,16)
          float v233 = v232 * v231;	// L236, S[16,16)
          float v234 = v229 + v233;	// L237, S[16,16)
          float v235 = v3[v5][(v4 + 45)];	// L238
          float v236 = v3[v6][(v4 + 45)];	// L239
          float v237 = v0 * v235;	// L240, S[16,16)
          float v238 = v237 * v236;	// L241, S[16,16)
          float v239 = v234 + v238;	// L242, S[16,16)
          float v240 = v3[v5][(v4 + 46)];	// L243
          float v241 = v3[v6][(v4 + 46)];	// L244
          float v242 = v0 * v240;	// L245, S[16,16)
          float v243 = v242 * v241;	// L246, S[16,16)
          float v244 = v239 + v243;	// L247, S[16,16)
          float v245 = v3[v5][(v4 + 47)];	// L248
          float v246 = v3[v6][(v4 + 47)];	// L249
          float v247 = v0 * v245;	// L250, S[16,16)
          float v248 = v247 * v246;	// L251, S[16,16)
          float v249 = v244 + v248;	// L252, S[16,16)
          float v250 = v3[v5][(v4 + 48)];	// L253
          float v251 = v3[v6][(v4 + 48)];	// L254
          float v252 = v0 * v250;	// L255, S[16,16)
          float v253 = v252 * v251;	// L256, S[16,16)
          float v254 = v249 + v253;	// L257, S[16,16)
          float v255 = v3[v5][(v4 + 49)];	// L258
          float v256 = v3[v6][(v4 + 49)];	// L259
          float v257 = v0 * v255;	// L260, S[16,16)
          float v258 = v257 * v256;	// L261, S[16,16)
          float v259 = v254 + v258;	// L262, S[16,16)
          float v260 = v3[v5][(v4 + 50)];	// L263
          float v261 = v3[v6][(v4 + 50)];	// L264
          float v262 = v0 * v260;	// L265, S[16,16)
          float v263 = v262 * v261;	// L266, S[16,16)
          float v264 = v259 + v263;	// L267, S[16,16)
          float v265 = v3[v5][(v4 + 51)];	// L268
          float v266 = v3[v6][(v4 + 51)];	// L269
          float v267 = v0 * v265;	// L270, S[16,16)
          float v268 = v267 * v266;	// L271, S[16,16)
          float v269 = v264 + v268;	// L272, S[16,16)
          float v270 = v3[v5][(v4 + 52)];	// L273
          float v271 = v3[v6][(v4 + 52)];	// L274
          float v272 = v0 * v270;	// L275, S[16,16)
          float v273 = v272 * v271;	// L276, S[16,16)
          float v274 = v269 + v273;	// L277, S[16,16)
          float v275 = v3[v5][(v4 + 53)];	// L278
          float v276 = v3[v6][(v4 + 53)];	// L279
          float v277 = v0 * v275;	// L280, S[16,16)
          float v278 = v277 * v276;	// L281, S[16,16)
          float v279 = v274 + v278;	// L282, S[16,16)
          float v280 = v3[v5][(v4 + 54)];	// L283
          float v281 = v3[v6][(v4 + 54)];	// L284
          float v282 = v0 * v280;	// L285, S[16,16)
          float v283 = v282 * v281;	// L286, S[16,16)
          float v284 = v279 + v283;	// L287, S[16,16)
          float v285 = v3[v5][(v4 + 55)];	// L288
          float v286 = v3[v6][(v4 + 55)];	// L289
          float v287 = v0 * v285;	// L290, S[16,16)
          float v288 = v287 * v286;	// L291, S[16,16)
          float v289 = v284 + v288;	// L292, S[16,16)
          float v290 = v3[v5][(v4 + 56)];	// L293
          float v291 = v3[v6][(v4 + 56)];	// L294
          float v292 = v0 * v290;	// L295, S[16,16)
          float v293 = v292 * v291;	// L296, S[16,16)
          float v294 = v289 + v293;	// L297, S[16,16)
          float v295 = v3[v5][(v4 + 57)];	// L298
          float v296 = v3[v6][(v4 + 57)];	// L299
          float v297 = v0 * v295;	// L300, S[16,16)
          float v298 = v297 * v296;	// L301, S[16,16)
          float v299 = v294 + v298;	// L302, S[16,16)
          float v300 = v3[v5][(v4 + 58)];	// L303
          float v301 = v3[v6][(v4 + 58)];	// L304
          float v302 = v0 * v300;	// L305, S[16,16)
          float v303 = v302 * v301;	// L306, S[16,16)
          float v304 = v299 + v303;	// L307, S[16,16)
          float v305 = v3[v5][(v4 + 59)];	// L308
          float v306 = v3[v6][(v4 + 59)];	// L309
          float v307 = v0 * v305;	// L310, S[16,16)
          float v308 = v307 * v306;	// L311, S[16,16)
          float v309 = v304 + v308;	// L312, S[16,16)
          float v310 = v3[v5][(v4 + 60)];	// L313
          float v311 = v3[v6][(v4 + 60)];	// L314
          float v312 = v0 * v310;	// L315, S[16,16)
          float v313 = v312 * v311;	// L316, S[16,16)
          float v314 = v309 + v313;	// L317, S[16,16)
          float v315 = v3[v5][(v4 + 61)];	// L318
          float v316 = v3[v6][(v4 + 61)];	// L319
          float v317 = v0 * v315;	// L320, S[16,16)
          float v318 = v317 * v316;	// L321, S[16,16)
          float v319 = v314 + v318;	// L322, S[16,16)
          float v320 = v3[v5][(v4 + 62)];	// L323
          float v321 = v3[v6][(v4 + 62)];	// L324
          float v322 = v0 * v320;	// L325, S[16,16)
          float v323 = v322 * v321;	// L326, S[16,16)
          float v324 = v319 + v323;	// L327, S[16,16)
          float v325 = v3[v5][(v4 + 63)];	// L328
          float v326 = v3[v6][(v4 + 63)];	// L329
          float v327 = v0 * v325;	// L330, S[16,16)
          float v328 = v327 * v326;	// L331, S[16,16)
          float v329 = v324 + v328;	// L332, S[16,16)
          v2[v5][v6] = v329;	// L333, S[16,16)
        }
      }
    }
  }
}

