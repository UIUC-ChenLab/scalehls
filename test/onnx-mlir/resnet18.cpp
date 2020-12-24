
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
/// Latency=4283850238
/// DSP=126
void main_graph(
  float val0[1][3][224][224],
  float val2[64][3][7][7],
  float val4[64],
  float val6[64][64][3][3],
  float val8[64],
  float val10[64][64][3][3],
  float val12[64],
  float val14[64][64][3][3],
  float val16[64],
  float val18[64][64][3][3],
  float val20[64],
  float val22[128][64][1][1],
  float val24[128],
  float val26[128][64][3][3],
  float val28[128],
  float val30[128][128][3][3],
  float val32[128],
  float val34[128][128][3][3],
  float val36[128],
  float val38[128][128][3][3],
  float val40[128],
  float val42[256][128][1][1],
  float val44[256],
  float val46[256][128][3][3],
  float val48[256],
  float val50[256][256][3][3],
  float val52[256],
  float val54[256][256][3][3],
  float val56[256],
  float val58[256][256][3][3],
  float val60[256],
  float val62[512][256][1][1],
  float val64[512],
  float val66[512][256][3][3],
  float val68[512],
  float val70[512][512][3][3],
  float val72[512],
  float val74[512][512][3][3],
  float val76[512],
  float val78[512][512][3][3],
  float val80[512],
  float val82[1000][512],
  float val84[1000],
  float val86[1][1000]
) {	// L18
  #pragma HLS interface s_axilite port=return bundle=ctrl

  #pragma HLS interface bram port=val84
  #pragma HLS resource variable=val84 core=ram_1p_bram

  #pragma HLS interface bram port=val82
  #pragma HLS resource variable=val82 core=ram_1p_bram

  #pragma HLS interface bram port=val80
  #pragma HLS resource variable=val80 core=ram_1p_bram

  #pragma HLS interface bram port=val78
  #pragma HLS resource variable=val78 core=ram_1p_bram

  #pragma HLS interface bram port=val76
  #pragma HLS resource variable=val76 core=ram_1p_bram

  #pragma HLS interface bram port=val74
  #pragma HLS resource variable=val74 core=ram_1p_bram

  #pragma HLS interface bram port=val72
  #pragma HLS resource variable=val72 core=ram_1p_bram

  #pragma HLS interface bram port=val70
  #pragma HLS resource variable=val70 core=ram_1p_bram

  #pragma HLS interface bram port=val68
  #pragma HLS resource variable=val68 core=ram_1p_bram

  #pragma HLS interface bram port=val66
  #pragma HLS resource variable=val66 core=ram_1p_bram

  #pragma HLS interface bram port=val64
  #pragma HLS resource variable=val64 core=ram_1p_bram

  #pragma HLS interface bram port=val62
  #pragma HLS resource variable=val62 core=ram_1p_bram

  #pragma HLS interface bram port=val60
  #pragma HLS resource variable=val60 core=ram_1p_bram

  #pragma HLS interface bram port=val58
  #pragma HLS resource variable=val58 core=ram_1p_bram

  #pragma HLS interface bram port=val56
  #pragma HLS resource variable=val56 core=ram_1p_bram

  #pragma HLS interface bram port=val54
  #pragma HLS resource variable=val54 core=ram_1p_bram

  #pragma HLS interface bram port=val52
  #pragma HLS resource variable=val52 core=ram_1p_bram

  #pragma HLS interface bram port=val50
  #pragma HLS resource variable=val50 core=ram_1p_bram

  #pragma HLS interface bram port=val48
  #pragma HLS resource variable=val48 core=ram_1p_bram

  #pragma HLS interface bram port=val46
  #pragma HLS resource variable=val46 core=ram_1p_bram

  #pragma HLS interface bram port=val44
  #pragma HLS resource variable=val44 core=ram_1p_bram

  #pragma HLS interface bram port=val42
  #pragma HLS resource variable=val42 core=ram_1p_bram

  #pragma HLS interface bram port=val40
  #pragma HLS resource variable=val40 core=ram_1p_bram

  #pragma HLS interface bram port=val38
  #pragma HLS resource variable=val38 core=ram_1p_bram

  #pragma HLS interface bram port=val36
  #pragma HLS resource variable=val36 core=ram_1p_bram

  #pragma HLS interface bram port=val34
  #pragma HLS resource variable=val34 core=ram_1p_bram

  #pragma HLS interface bram port=val32
  #pragma HLS resource variable=val32 core=ram_1p_bram

  #pragma HLS interface bram port=val30
  #pragma HLS resource variable=val30 core=ram_1p_bram

  #pragma HLS interface bram port=val28
  #pragma HLS resource variable=val28 core=ram_1p_bram

  #pragma HLS interface bram port=val26
  #pragma HLS resource variable=val26 core=ram_1p_bram

  #pragma HLS interface bram port=val24
  #pragma HLS resource variable=val24 core=ram_1p_bram

  #pragma HLS interface bram port=val22
  #pragma HLS resource variable=val22 core=ram_1p_bram

  #pragma HLS interface bram port=val20
  #pragma HLS resource variable=val20 core=ram_1p_bram

  #pragma HLS interface bram port=val18
  #pragma HLS resource variable=val18 core=ram_1p_bram

  #pragma HLS interface bram port=val16
  #pragma HLS resource variable=val16 core=ram_1p_bram

  #pragma HLS interface bram port=val14
  #pragma HLS resource variable=val14 core=ram_1p_bram

  #pragma HLS interface bram port=val12
  #pragma HLS resource variable=val12 core=ram_1p_bram

  #pragma HLS interface bram port=val10
  #pragma HLS resource variable=val10 core=ram_1p_bram

  #pragma HLS interface bram port=val8
  #pragma HLS resource variable=val8 core=ram_1p_bram

  #pragma HLS interface bram port=val6
  #pragma HLS resource variable=val6 core=ram_1p_bram

  #pragma HLS interface bram port=val4
  #pragma HLS resource variable=val4 core=ram_1p_bram

  #pragma HLS interface bram port=val2
  #pragma HLS resource variable=val2 core=ram_1p_bram

  #pragma HLS interface bram port=val0
  #pragma HLS resource variable=val0 core=ram_1p_bram

  #pragma HLS interface bram port=val86
  #pragma HLS resource variable=val86 core=ram_1p_bram

  float val88[1][512];	// L69, S[4273094698,4273094698)
  #pragma HLS resource variable=val88 core=ram_1p_bram

  float val90[1][512][1][1];	// L71, S[4272875556,4272875556)
  #pragma HLS resource variable=val90 core=ram_1p_bram

  float val92[1][512][7][7];	// L73, S[4272741922,4272741922)
  #pragma HLS resource variable=val92 core=ram_1p_bram

  float val94[1][512][7][7];	// L75, S[4272533024,4272533024)
  #pragma HLS resource variable=val94 core=ram_1p_bram

  float val96[1][512][7][7];	// L77, S[2204420638,2204420638)
  #pragma HLS resource variable=val96 core=ram_1p_bram

  float val98[1][512][9][9];	// L79, S[2204285466,2204285466)
  #pragma HLS resource variable=val98 core=ram_1p_bram

  float val100[1][512][7][7];	// L81, S[2204151832,2204151832)
  #pragma HLS resource variable=val100 core=ram_1p_bram

  float val102[1][512][7][7];	// L83, S[136039446,136039446)
  #pragma HLS resource variable=val102 core=ram_1p_bram

  float val104[1][512][9][9];	// L85, S[135904274,135904274)
  #pragma HLS resource variable=val104 core=ram_1p_bram

  float val106[1][512][7][7];	// L87, S[135770640,135770640)
  #pragma HLS resource variable=val106 core=ram_1p_bram

  float val108[1][512][7][7];	// L89, S[135561742,135561742)
  #pragma HLS resource variable=val108 core=ram_1p_bram

  float val110[1][512][7][7];	// L91, S[135561742,135561742)
  #pragma HLS resource variable=val110 core=ram_1p_bram

  float val112[1][512][9][9];	// L93, S[135426570,135426570)
  #pragma HLS resource variable=val112 core=ram_1p_bram

  float val114[1][512][7][7];	// L95, S[135292936,135292936)
  #pragma HLS resource variable=val114 core=ram_1p_bram

  float val116[1][512][7][7];	// L97, S[135292936,135292936)
  #pragma HLS resource variable=val116 core=ram_1p_bram

  float val118[1][256][16][16];	// L99, S[135060484,135060484)
  #pragma HLS resource variable=val118 core=ram_1p_bram

  float val120[1][512][7][7];	// L101, S[25819138,25819138)
  #pragma HLS resource variable=val120 core=ram_1p_bram

  float val122[1][256][14][14];	// L103, S[25560576,25560576)
  #pragma HLS resource variable=val122 core=ram_1p_bram

  float val124[1][256][14][14];	// L105, S[25151486,25151486)
  #pragma HLS resource variable=val124 core=ram_1p_bram

  float val126[1][256][14][14];	// L107, S[25151486,25151486)
  #pragma HLS resource variable=val126 core=ram_1p_bram

  float val128[1][256][16][16];	// L109, S[24919034,24919034)
  #pragma HLS resource variable=val128 core=ram_1p_bram

  float val130[1][256][14][14];	// L111, S[24660472,24660472)
  #pragma HLS resource variable=val130 core=ram_1p_bram

  float val132[1][256][14][14];	// L113, S[24660472,24660472)
  #pragma HLS resource variable=val132 core=ram_1p_bram

  float val134[1][256][16][16];	// L115, S[24428020,24428020)
  #pragma HLS resource variable=val134 core=ram_1p_bram

  float val136[1][256][14][14];	// L117, S[24169458,24169458)
  #pragma HLS resource variable=val136 core=ram_1p_bram

  float val138[1][256][14][14];	// L119, S[23760368,23760368)
  #pragma HLS resource variable=val138 core=ram_1p_bram

  float val140[1][256][14][14];	// L121, S[23760368,23760368)
  #pragma HLS resource variable=val140 core=ram_1p_bram

  float val142[1][256][16][16];	// L123, S[23527916,23527916)
  #pragma HLS resource variable=val142 core=ram_1p_bram

  float val144[1][256][14][14];	// L125, S[23269354,23269354)
  #pragma HLS resource variable=val144 core=ram_1p_bram

  float val146[1][256][14][14];	// L127, S[23269354,23269354)
  #pragma HLS resource variable=val146 core=ram_1p_bram

  float val148[1][128][30][30];	// L129, S[22837734,22837734)
  #pragma HLS resource variable=val148 core=ram_1p_bram

  float val150[1][256][14][14];	// L131, S[23760368,23760368)
  #pragma HLS resource variable=val150 core=ram_1p_bram

  float val152[1][128][28][28];	// L133, S[22328548,22328548)
  #pragma HLS resource variable=val152 core=ram_1p_bram

  float val154[1][128][28][28];	// L135, S[21518306,21518306)
  #pragma HLS resource variable=val154 core=ram_1p_bram

  float val156[1][128][28][28];	// L137, S[21518306,21518306)
  #pragma HLS resource variable=val156 core=ram_1p_bram

  float val158[1][128][30][30];	// L139, S[21086686,21086686)
  #pragma HLS resource variable=val158 core=ram_1p_bram

  float val160[1][128][28][28];	// L141, S[20577500,20577500)
  #pragma HLS resource variable=val160 core=ram_1p_bram

  float val162[1][128][28][28];	// L143, S[20577500,20577500)
  #pragma HLS resource variable=val162 core=ram_1p_bram

  float val164[1][128][30][30];	// L145, S[20145880,20145880)
  #pragma HLS resource variable=val164 core=ram_1p_bram

  float val166[1][128][28][28];	// L147, S[19636694,19636694)
  #pragma HLS resource variable=val166 core=ram_1p_bram

  float val168[1][128][28][28];	// L149, S[18826452,18826452)
  #pragma HLS resource variable=val168 core=ram_1p_bram

  float val170[1][128][28][28];	// L151, S[18826452,18826452)
  #pragma HLS resource variable=val170 core=ram_1p_bram

  float val172[1][128][30][30];	// L153, S[18394832,18394832)
  #pragma HLS resource variable=val172 core=ram_1p_bram

  float val174[1][128][28][28];	// L155, S[17885646,17885646)
  #pragma HLS resource variable=val174 core=ram_1p_bram

  float val176[1][128][28][28];	// L157, S[17885646,17885646)
  #pragma HLS resource variable=val176 core=ram_1p_bram

  float val178[1][64][58][58];	// L159, S[17053386,17053386)
  #pragma HLS resource variable=val178 core=ram_1p_bram

  float val180[1][128][28][28];	// L161, S[18826452,18826452)
  #pragma HLS resource variable=val180 core=ram_1p_bram

  float val182[1][64][56][56];	// L163, S[16042568,16042568)
  #pragma HLS resource variable=val182 core=ram_1p_bram

  float val184[1][64][56][56];	// L165, S[14429638,14429638)
  #pragma HLS resource variable=val184 core=ram_1p_bram

  float val186[1][64][56][56];	// L167, S[14429636,14429636)
  #pragma HLS resource variable=val186 core=ram_1p_bram

  float val188[1][64][58][58];	// L169, S[13597376,13597376)
  #pragma HLS resource variable=val188 core=ram_1p_bram

  float val190[1][64][56][56];	// L171, S[12586558,12586558)
  #pragma HLS resource variable=val190 core=ram_1p_bram

  float val192[1][64][56][56];	// L173, S[12586556,12586556)
  #pragma HLS resource variable=val192 core=ram_1p_bram

  float val194[1][64][58][58];	// L175, S[11754296,11754296)
  #pragma HLS resource variable=val194 core=ram_1p_bram

  float val196[1][64][56][56];	// L177, S[10743478,10743478)
  #pragma HLS resource variable=val196 core=ram_1p_bram

  float val198[1][64][56][56];	// L179, S[9130548,9130548)
  #pragma HLS resource variable=val198 core=ram_1p_bram

  float val200[1][64][56][56];	// L181, S[9130546,9130546)
  #pragma HLS resource variable=val200 core=ram_1p_bram

  float val202[1][64][58][58];	// L183, S[8298286,8298286)
  #pragma HLS resource variable=val202 core=ram_1p_bram

  float val204[1][64][56][56];	// L185, S[7287468,7287468)
  #pragma HLS resource variable=val204 core=ram_1p_bram

  float val206[1][64][56][56];	// L187, S[7287466,7287466)
  #pragma HLS resource variable=val206 core=ram_1p_bram

  float val208[1][64][58][58];	// L189, S[6455206,6455206)
  #pragma HLS resource variable=val208 core=ram_1p_bram

  float val210[1][64][56][56];	// L191, S[4641572,4641572)
  #pragma HLS resource variable=val210 core=ram_1p_bram

  float val212[1][64][112][112];	// L193, S[613026,613026)
  #pragma HLS resource variable=val212 core=ram_1p_bram

  float val214[1][64][112][112];	// L195, S[613024,613024)
  #pragma HLS resource variable=val214 core=ram_1p_bram

  float val216[1][3][230][230];	// L197, S[0,0)
  #pragma HLS resource variable=val216 core=ram_1p_bram

  for (int val218 = 0; val218 < 3; val218 += 1) {	// L199, S[0,160088), latency=53362
    for (int val219 = 0; val219 < 230; val219 += 1) {	// L200, S[0,53362), latency=232
      for (int val220 = 0; val220 < 230; val220 += 1) {	// L201, S[0,232), latency=1
        val216[0][val218][val219][val220] = 0.000000;	// L202, S[0,1)
      }
    }
  }
  for (int val221 = 0; val221 < 3; val221 += 1) {	// L206, S[160088,613024), latency=150978
    for (int val222 = 0; val222 < 224; val222 += 1) {	// L207, S[0,150978), latency=674
      for (int val223 = 0; val223 < 224; val223 += 1) {	// L208, S[0,674), latency=3
        float val224 = val0[0][val221][val222][val223];	// L209, S[0,2)
        val216[0][val221][(val222 + 3)][(val223 + 3)] = val224;	// L210, S[2,3)
      }
    }
  }
  for (int val225 = 0; val225 < 64; val225 += 1) {	// L214, S[613024,613026), latency=0
    for (int val226 = 0; val226 < 112; val226 += 1) {	// L215, S[4262992414,0), latency=285490
      for (int val227 = 0; val227 < 112; val227 += 1) {	// L216, S[0,285490), latency=2549
        for (int val228 = 0; val228 < 3; val228 += 1) {	// L217, S[0,2549), latency=849
          for (int val229 = 0; val229 < 7; val229 += 1) {	// L218, S[0,849), latency=121
            for (int val230 = 0; val230 < 7; val230 += 1) {	// L219, S[0,121), latency=17
              float val231 = val216[0][val228][((val226 * 2) + val229)][((val227 * 2) + val230)];	// L220, S[0,2)
              float val232 = val2[val225][val228][val229][val230];	// L221, S[0,2)
              float val233 = val214[0][val225][val226][val227];	// L222, S[4,6)
              float val234;
              if (val230 == 0 && val229 == 0 && val228 == 0) {	// L223, S[6,6)
                val234 = 0.000000;	// L224, S[6,6)
              } else {
                val234 = val233;	// L226, S[6,6)
              }
              float val235 = val231 * val232;	// L228, S[2,6)
              float val236 = val234 + val235;	// L229, S[6,11)
              val214[0][val225][val226][val227] = val236;	// L230, S[15,16)
              float val237 = val4[val225];	// L231, S[9,11)
              float val238 = val236 + val237;	// L232, S[11,16)
              if (((-val230) + 6) == 0 && ((-val229) + 6) == 0 && ((-val228) + 2) == 0) {	// L233, S[16,16)
                val214[0][val225][val226][val227] = val238;	// L234, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val239 = 0; val239 < 64; val239 += 1) {	// L242, S[613026,4641572), latency=62946
    for (int val240 = 0; val240 < 112; val240 += 1) {	// L243, S[0,62946), latency=562
      for (int val241 = 0; val241 < 112; val241 += 1) {	// L244, S[0,562), latency=5
        float val242 = val214[0][val239][val240][val241];	// L245, S[0,2)
        ap_int<1> val243 = val242 < 0.000000;	// L246, S[2,4)
        float val244 = val243 ? 0.000000 : val242;	// L247, S[4,4)
        val212[0][val239][val240][val241] = val244;	// L248, S[4,5)
      }
    }
  }
  for (int val245 = 0; val245 < 64; val245 += 1) {	// L252, S[4641572,6455206), latency=28338
    for (int val246 = 0; val246 < 56; val246 += 1) {	// L253, S[0,28338), latency=506
      for (int val247 = 0; val247 < 56; val247 += 1) {	// L254, S[0,506), latency=9
        for (int val248 = 0; val248 < min(min(min(112, ((-((val246 * 2) - 1)) + 112)), ((val246 * 2) + 2)), (((val246 * 2) - ((val246 * 2) - 1)) + 2)); val248 += 1) {	// L255, S[0,9), latency=7
          for (int val249 = 0; val249 < min(min(min(112, ((-((val247 * 2) - 1)) + 112)), ((val247 * 2) + 2)), (((val247 * 2) - ((val247 * 2) - 1)) + 2)); val249 += 1) {	// L256, S[0,7), latency=5
            int val250 = max(0, ((val246 * 2) - 1));	// L257, S[0,0)
            int val251 = max(0, ((val247 * 2) - 1));	// L258, S[0,0)
            int val252 = (val248 + val250);	// L259, S[0,0)
            int val253 = (val249 + val251);	// L260, S[0,0)
            float val254 = val212[0][val245][val252][val253];	// L261, S[0,2)
            float val255 = val210[0][val245][val246][val247];	// L262, S[0,2)
            float val256;
            if (val249 == 0 && val248 == 0) {	// L263, S[2,2)
              val256 = -INFINITY;	// L264, S[2,2)
            } else {
              val256 = val255;	// L266, S[2,2)
            }
            ap_int<1> val257 = val256 > val254;	// L268, S[2,4)
            float val258 = val257 ? val256 : val254;	// L269, S[4,4)
            val210[0][val245][val246][val247] = val258;	// L270, S[4,5)
          }
        }
      }
    }
  }
  for (int val259 = 0; val259 < 64; val259 += 1) {	// L276, S[6455206,6678056), latency=3482
    for (int val260 = 0; val260 < 58; val260 += 1) {	// L277, S[0,3482), latency=60
      for (int val261 = 0; val261 < 58; val261 += 1) {	// L278, S[0,60), latency=1
        val208[0][val259][val260][val261] = 0.000000;	// L279, S[0,1)
      }
    }
  }
  for (int val262 = 0; val262 < 64; val262 += 1) {	// L283, S[6678056,7287466), latency=9522
    for (int val263 = 0; val263 < 56; val263 += 1) {	// L284, S[0,9522), latency=170
      for (int val264 = 0; val264 < 56; val264 += 1) {	// L285, S[0,170), latency=3
        float val265 = val210[0][val262][val263][val264];	// L286, S[0,2)
        val208[0][val262][(val263 + 1)][(val264 + 1)] = val265;	// L287, S[2,3)
      }
    }
  }
  for (int val266 = 0; val266 < 64; val266 += 1) {	// L291, S[7287466,7287468), latency=0
    for (int val267 = 0; val267 < 56; val267 += 1) {	// L292, S[4262647566,0), latency=577138
      for (int val268 = 0; val268 < 56; val268 += 1) {	// L293, S[0,577138), latency=10306
        for (int val269 = 0; val269 < 64; val269 += 1) {	// L294, S[0,10306), latency=161
          for (int val270 = 0; val270 < 3; val270 += 1) {	// L295, S[0,161), latency=53
            for (int val271 = 0; val271 < 3; val271 += 1) {	// L296, S[0,53), latency=17
              float val272 = val208[0][val269][(val267 + val270)][(val268 + val271)];	// L297, S[0,2)
              float val273 = val6[val266][val269][val270][val271];	// L298, S[0,2)
              float val274 = val206[0][val266][val267][val268];	// L299, S[4,6)
              float val275;
              if (val271 == 0 && val270 == 0 && val269 == 0) {	// L300, S[6,6)
                val275 = 0.000000;	// L301, S[6,6)
              } else {
                val275 = val274;	// L303, S[6,6)
              }
              float val276 = val272 * val273;	// L305, S[2,6)
              float val277 = val275 + val276;	// L306, S[6,11)
              val206[0][val266][val267][val268] = val277;	// L307, S[15,16)
              float val278 = val8[val266];	// L308, S[9,11)
              float val279 = val277 + val278;	// L309, S[11,16)
              if (((-val271) + 2) == 0 && ((-val270) + 2) == 0 && ((-val269) + 63) == 0) {	// L310, S[16,16)
                val206[0][val266][val267][val268] = val279;	// L311, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val280 = 0; val280 < 64; val280 += 1) {	// L319, S[7287468,8298286), latency=15794
    for (int val281 = 0; val281 < 56; val281 += 1) {	// L320, S[0,15794), latency=282
      for (int val282 = 0; val282 < 56; val282 += 1) {	// L321, S[0,282), latency=5
        float val283 = val206[0][val280][val281][val282];	// L322, S[0,2)
        ap_int<1> val284 = val283 < 0.000000;	// L323, S[2,4)
        float val285 = val284 ? 0.000000 : val283;	// L324, S[4,4)
        val204[0][val280][val281][val282] = val285;	// L325, S[4,5)
      }
    }
  }
  for (int val286 = 0; val286 < 64; val286 += 1) {	// L329, S[8298286,8521136), latency=3482
    for (int val287 = 0; val287 < 58; val287 += 1) {	// L330, S[0,3482), latency=60
      for (int val288 = 0; val288 < 58; val288 += 1) {	// L331, S[0,60), latency=1
        val202[0][val286][val287][val288] = 0.000000;	// L332, S[0,1)
      }
    }
  }
  for (int val289 = 0; val289 < 64; val289 += 1) {	// L336, S[8521136,9130546), latency=9522
    for (int val290 = 0; val290 < 56; val290 += 1) {	// L337, S[0,9522), latency=170
      for (int val291 = 0; val291 < 56; val291 += 1) {	// L338, S[0,170), latency=3
        float val292 = val204[0][val289][val290][val291];	// L339, S[0,2)
        val202[0][val289][(val290 + 1)][(val291 + 1)] = val292;	// L340, S[2,3)
      }
    }
  }
  for (int val293 = 0; val293 < 64; val293 += 1) {	// L344, S[9130546,9130548), latency=0
    for (int val294 = 0; val294 < 56; val294 += 1) {	// L345, S[4262647566,0), latency=577138
      for (int val295 = 0; val295 < 56; val295 += 1) {	// L346, S[0,577138), latency=10306
        for (int val296 = 0; val296 < 64; val296 += 1) {	// L347, S[0,10306), latency=161
          for (int val297 = 0; val297 < 3; val297 += 1) {	// L348, S[0,161), latency=53
            for (int val298 = 0; val298 < 3; val298 += 1) {	// L349, S[0,53), latency=17
              float val299 = val202[0][val296][(val294 + val297)][(val295 + val298)];	// L350, S[0,2)
              float val300 = val10[val293][val296][val297][val298];	// L351, S[0,2)
              float val301 = val200[0][val293][val294][val295];	// L352, S[4,6)
              float val302;
              if (val298 == 0 && val297 == 0 && val296 == 0) {	// L353, S[6,6)
                val302 = 0.000000;	// L354, S[6,6)
              } else {
                val302 = val301;	// L356, S[6,6)
              }
              float val303 = val299 * val300;	// L358, S[2,6)
              float val304 = val302 + val303;	// L359, S[6,11)
              val200[0][val293][val294][val295] = val304;	// L360, S[15,16)
              float val305 = val12[val293];	// L361, S[9,11)
              float val306 = val304 + val305;	// L362, S[11,16)
              if (((-val298) + 2) == 0 && ((-val297) + 2) == 0 && ((-val296) + 63) == 0) {	// L363, S[16,16)
                val200[0][val293][val294][val295] = val306;	// L364, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val307 = 0; val307 < 64; val307 += 1) {	// L372, S[9130548,10743478), latency=25202
    for (int val308 = 0; val308 < 56; val308 += 1) {	// L373, S[0,25202), latency=450
      for (int val309 = 0; val309 < 56; val309 += 1) {	// L374, S[0,450), latency=8
        float val310 = val210[0][val307][val308][val309];	// L375, S[0,2)
        float val311 = val200[0][val307][val308][val309];	// L376, S[0,2)
        float val312 = val310 + val311;	// L377, S[2,7)
        val198[0][val307][val308][val309] = val312;	// L378, S[7,8)
      }
    }
  }
  for (int val313 = 0; val313 < 64; val313 += 1) {	// L382, S[10743478,11754296), latency=15794
    for (int val314 = 0; val314 < 56; val314 += 1) {	// L383, S[0,15794), latency=282
      for (int val315 = 0; val315 < 56; val315 += 1) {	// L384, S[0,282), latency=5
        float val316 = val198[0][val313][val314][val315];	// L385, S[0,2)
        ap_int<1> val317 = val316 < 0.000000;	// L386, S[2,4)
        float val318 = val317 ? 0.000000 : val316;	// L387, S[4,4)
        val196[0][val313][val314][val315] = val318;	// L388, S[4,5)
      }
    }
  }
  for (int val319 = 0; val319 < 64; val319 += 1) {	// L392, S[11754296,11977146), latency=3482
    for (int val320 = 0; val320 < 58; val320 += 1) {	// L393, S[0,3482), latency=60
      for (int val321 = 0; val321 < 58; val321 += 1) {	// L394, S[0,60), latency=1
        val194[0][val319][val320][val321] = 0.000000;	// L395, S[0,1)
      }
    }
  }
  for (int val322 = 0; val322 < 64; val322 += 1) {	// L399, S[11977146,12586556), latency=9522
    for (int val323 = 0; val323 < 56; val323 += 1) {	// L400, S[0,9522), latency=170
      for (int val324 = 0; val324 < 56; val324 += 1) {	// L401, S[0,170), latency=3
        float val325 = val196[0][val322][val323][val324];	// L402, S[0,2)
        val194[0][val322][(val323 + 1)][(val324 + 1)] = val325;	// L403, S[2,3)
      }
    }
  }
  for (int val326 = 0; val326 < 64; val326 += 1) {	// L407, S[12586556,12586558), latency=0
    for (int val327 = 0; val327 < 56; val327 += 1) {	// L408, S[4262647566,0), latency=577138
      for (int val328 = 0; val328 < 56; val328 += 1) {	// L409, S[0,577138), latency=10306
        for (int val329 = 0; val329 < 64; val329 += 1) {	// L410, S[0,10306), latency=161
          for (int val330 = 0; val330 < 3; val330 += 1) {	// L411, S[0,161), latency=53
            for (int val331 = 0; val331 < 3; val331 += 1) {	// L412, S[0,53), latency=17
              float val332 = val194[0][val329][(val327 + val330)][(val328 + val331)];	// L413, S[0,2)
              float val333 = val14[val326][val329][val330][val331];	// L414, S[0,2)
              float val334 = val192[0][val326][val327][val328];	// L415, S[4,6)
              float val335;
              if (val331 == 0 && val330 == 0 && val329 == 0) {	// L416, S[6,6)
                val335 = 0.000000;	// L417, S[6,6)
              } else {
                val335 = val334;	// L419, S[6,6)
              }
              float val336 = val332 * val333;	// L421, S[2,6)
              float val337 = val335 + val336;	// L422, S[6,11)
              val192[0][val326][val327][val328] = val337;	// L423, S[15,16)
              float val338 = val16[val326];	// L424, S[9,11)
              float val339 = val337 + val338;	// L425, S[11,16)
              if (((-val331) + 2) == 0 && ((-val330) + 2) == 0 && ((-val329) + 63) == 0) {	// L426, S[16,16)
                val192[0][val326][val327][val328] = val339;	// L427, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val340 = 0; val340 < 64; val340 += 1) {	// L435, S[12586558,13597376), latency=15794
    for (int val341 = 0; val341 < 56; val341 += 1) {	// L436, S[0,15794), latency=282
      for (int val342 = 0; val342 < 56; val342 += 1) {	// L437, S[0,282), latency=5
        float val343 = val192[0][val340][val341][val342];	// L438, S[0,2)
        ap_int<1> val344 = val343 < 0.000000;	// L439, S[2,4)
        float val345 = val344 ? 0.000000 : val343;	// L440, S[4,4)
        val190[0][val340][val341][val342] = val345;	// L441, S[4,5)
      }
    }
  }
  for (int val346 = 0; val346 < 64; val346 += 1) {	// L445, S[13597376,13820226), latency=3482
    for (int val347 = 0; val347 < 58; val347 += 1) {	// L446, S[0,3482), latency=60
      for (int val348 = 0; val348 < 58; val348 += 1) {	// L447, S[0,60), latency=1
        val188[0][val346][val347][val348] = 0.000000;	// L448, S[0,1)
      }
    }
  }
  for (int val349 = 0; val349 < 64; val349 += 1) {	// L452, S[13820226,14429636), latency=9522
    for (int val350 = 0; val350 < 56; val350 += 1) {	// L453, S[0,9522), latency=170
      for (int val351 = 0; val351 < 56; val351 += 1) {	// L454, S[0,170), latency=3
        float val352 = val190[0][val349][val350][val351];	// L455, S[0,2)
        val188[0][val349][(val350 + 1)][(val351 + 1)] = val352;	// L456, S[2,3)
      }
    }
  }
  for (int val353 = 0; val353 < 64; val353 += 1) {	// L460, S[14429636,14429638), latency=0
    for (int val354 = 0; val354 < 56; val354 += 1) {	// L461, S[4262647566,0), latency=577138
      for (int val355 = 0; val355 < 56; val355 += 1) {	// L462, S[0,577138), latency=10306
        for (int val356 = 0; val356 < 64; val356 += 1) {	// L463, S[0,10306), latency=161
          for (int val357 = 0; val357 < 3; val357 += 1) {	// L464, S[0,161), latency=53
            for (int val358 = 0; val358 < 3; val358 += 1) {	// L465, S[0,53), latency=17
              float val359 = val188[0][val356][(val354 + val357)][(val355 + val358)];	// L466, S[0,2)
              float val360 = val18[val353][val356][val357][val358];	// L467, S[0,2)
              float val361 = val186[0][val353][val354][val355];	// L468, S[4,6)
              float val362;
              if (val358 == 0 && val357 == 0 && val356 == 0) {	// L469, S[6,6)
                val362 = 0.000000;	// L470, S[6,6)
              } else {
                val362 = val361;	// L472, S[6,6)
              }
              float val363 = val359 * val360;	// L474, S[2,6)
              float val364 = val362 + val363;	// L475, S[6,11)
              val186[0][val353][val354][val355] = val364;	// L476, S[15,16)
              float val365 = val20[val353];	// L477, S[9,11)
              float val366 = val364 + val365;	// L478, S[11,16)
              if (((-val358) + 2) == 0 && ((-val357) + 2) == 0 && ((-val356) + 63) == 0) {	// L479, S[16,16)
                val186[0][val353][val354][val355] = val366;	// L480, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val367 = 0; val367 < 64; val367 += 1) {	// L488, S[14429638,16042568), latency=25202
    for (int val368 = 0; val368 < 56; val368 += 1) {	// L489, S[0,25202), latency=450
      for (int val369 = 0; val369 < 56; val369 += 1) {	// L490, S[0,450), latency=8
        float val370 = val196[0][val367][val368][val369];	// L491, S[0,2)
        float val371 = val186[0][val367][val368][val369];	// L492, S[0,2)
        float val372 = val370 + val371;	// L493, S[2,7)
        val184[0][val367][val368][val369] = val372;	// L494, S[7,8)
      }
    }
  }
  for (int val373 = 0; val373 < 64; val373 += 1) {	// L498, S[16042568,17053386), latency=15794
    for (int val374 = 0; val374 < 56; val374 += 1) {	// L499, S[0,15794), latency=282
      for (int val375 = 0; val375 < 56; val375 += 1) {	// L500, S[0,282), latency=5
        float val376 = val184[0][val373][val374][val375];	// L501, S[0,2)
        ap_int<1> val377 = val376 < 0.000000;	// L502, S[2,4)
        float val378 = val377 ? 0.000000 : val376;	// L503, S[4,4)
        val182[0][val373][val374][val375] = val378;	// L504, S[4,5)
      }
    }
  }
  for (int val379 = 0; val379 < 128; val379 += 1) {	// L508, S[4202629576,17053386), latency=854618
    for (int val380 = 0; val380 < 28; val380 += 1) {	// L509, S[0,854618), latency=30522
      for (int val381 = 0; val381 < 28; val381 += 1) {	// L510, S[0,30522), latency=1090
        for (int val382 = 0; val382 < 64; val382 += 1) {	// L511, S[0,1090), latency=17
          float val383 = val182[0][val382][(val380 * 2)][(val381 * 2)];	// L512, S[0,2)
          float val384 = val22[val379][val382][0][0];	// L513, S[0,2)
          float val385 = val180[0][val379][val380][val381];	// L514, S[4,6)
          float val386;
          if (0 == 0 && 0 == 0 && val382 == 0) {	// L515, S[6,6)
            val386 = 0.000000;	// L516, S[6,6)
          } else {
            val386 = val385;	// L518, S[6,6)
          }
          float val387 = val383 * val384;	// L520, S[2,6)
          float val388 = val386 + val387;	// L521, S[6,11)
          val180[0][val379][val380][val381] = val388;	// L522, S[15,16)
          float val389 = val24[val379];	// L523, S[9,11)
          float val390 = val388 + val389;	// L524, S[11,16)
          if (0 == 0 && 0 == 0 && ((-val382) + 63) == 0) {	// L525, S[16,16)
            val180[0][val379][val380][val381] = val390;	// L526, S[16,17)
          }
        }
      }
    }
  }
  for (int val391 = 0; val391 < 64; val391 += 1) {	// L532, S[17053386,17276236), latency=3482
    for (int val392 = 0; val392 < 58; val392 += 1) {	// L533, S[0,3482), latency=60
      for (int val393 = 0; val393 < 58; val393 += 1) {	// L534, S[0,60), latency=1
        val178[0][val391][val392][val393] = 0.000000;	// L535, S[0,1)
      }
    }
  }
  for (int val394 = 0; val394 < 64; val394 += 1) {	// L539, S[17276236,17885646), latency=9522
    for (int val395 = 0; val395 < 56; val395 += 1) {	// L540, S[0,9522), latency=170
      for (int val396 = 0; val396 < 56; val396 += 1) {	// L541, S[0,170), latency=3
        float val397 = val182[0][val394][val395][val396];	// L542, S[0,2)
        val178[0][val394][(val395 + 1)][(val396 + 1)] = val397;	// L543, S[2,3)
      }
    }
  }
  for (int val398 = 0; val398 < 128; val398 += 1) {	// L547, S[3278617804,17885646), latency=8079962
    for (int val399 = 0; val399 < 28; val399 += 1) {	// L548, S[0,8079962), latency=288570
      for (int val400 = 0; val400 < 28; val400 += 1) {	// L549, S[0,288570), latency=10306
        for (int val401 = 0; val401 < 64; val401 += 1) {	// L550, S[0,10306), latency=161
          for (int val402 = 0; val402 < 3; val402 += 1) {	// L551, S[0,161), latency=53
            for (int val403 = 0; val403 < 3; val403 += 1) {	// L552, S[0,53), latency=17
              float val404 = val178[0][val401][((val399 * 2) + val402)][((val400 * 2) + val403)];	// L553, S[0,2)
              float val405 = val26[val398][val401][val402][val403];	// L554, S[0,2)
              float val406 = val176[0][val398][val399][val400];	// L555, S[4,6)
              float val407;
              if (val403 == 0 && val402 == 0 && val401 == 0) {	// L556, S[6,6)
                val407 = 0.000000;	// L557, S[6,6)
              } else {
                val407 = val406;	// L559, S[6,6)
              }
              float val408 = val404 * val405;	// L561, S[2,6)
              float val409 = val407 + val408;	// L562, S[6,11)
              val176[0][val398][val399][val400] = val409;	// L563, S[15,16)
              float val410 = val28[val398];	// L564, S[9,11)
              float val411 = val409 + val410;	// L565, S[11,16)
              if (((-val403) + 2) == 0 && ((-val402) + 2) == 0 && ((-val401) + 63) == 0) {	// L566, S[16,16)
                val176[0][val398][val399][val400] = val411;	// L567, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val412 = 0; val412 < 128; val412 += 1) {	// L575, S[17885646,18394832), latency=3978
    for (int val413 = 0; val413 < 28; val413 += 1) {	// L576, S[0,3978), latency=142
      for (int val414 = 0; val414 < 28; val414 += 1) {	// L577, S[0,142), latency=5
        float val415 = val176[0][val412][val413][val414];	// L578, S[0,2)
        ap_int<1> val416 = val415 < 0.000000;	// L579, S[2,4)
        float val417 = val416 ? 0.000000 : val415;	// L580, S[4,4)
        val174[0][val412][val413][val414] = val417;	// L581, S[4,5)
      }
    }
  }
  for (int val418 = 0; val418 < 128; val418 += 1) {	// L585, S[18394832,18517970), latency=962
    for (int val419 = 0; val419 < 30; val419 += 1) {	// L586, S[0,962), latency=32
      for (int val420 = 0; val420 < 30; val420 += 1) {	// L587, S[0,32), latency=1
        val172[0][val418][val419][val420] = 0.000000;	// L588, S[0,1)
      }
    }
  }
  for (int val421 = 0; val421 < 128; val421 += 1) {	// L592, S[18517970,18826452), latency=2410
    for (int val422 = 0; val422 < 28; val422 += 1) {	// L593, S[0,2410), latency=86
      for (int val423 = 0; val423 < 28; val423 += 1) {	// L594, S[0,86), latency=3
        float val424 = val174[0][val421][val422][val423];	// L595, S[0,2)
        val172[0][val421][(val422 + 1)][(val423 + 1)] = val424;	// L596, S[2,3)
      }
    }
  }
  for (int val425 = 0; val425 < 128; val425 += 1) {	// L600, S[2245531602,18826452), latency=16158298
    for (int val426 = 0; val426 < 28; val426 += 1) {	// L601, S[0,16158298), latency=577082
      for (int val427 = 0; val427 < 28; val427 += 1) {	// L602, S[0,577082), latency=20610
        for (int val428 = 0; val428 < 128; val428 += 1) {	// L603, S[0,20610), latency=161
          for (int val429 = 0; val429 < 3; val429 += 1) {	// L604, S[0,161), latency=53
            for (int val430 = 0; val430 < 3; val430 += 1) {	// L605, S[0,53), latency=17
              float val431 = val172[0][val428][(val426 + val429)][(val427 + val430)];	// L606, S[0,2)
              float val432 = val30[val425][val428][val429][val430];	// L607, S[0,2)
              float val433 = val170[0][val425][val426][val427];	// L608, S[4,6)
              float val434;
              if (val430 == 0 && val429 == 0 && val428 == 0) {	// L609, S[6,6)
                val434 = 0.000000;	// L610, S[6,6)
              } else {
                val434 = val433;	// L612, S[6,6)
              }
              float val435 = val431 * val432;	// L614, S[2,6)
              float val436 = val434 + val435;	// L615, S[6,11)
              val170[0][val425][val426][val427] = val436;	// L616, S[15,16)
              float val437 = val32[val425];	// L617, S[9,11)
              float val438 = val436 + val437;	// L618, S[11,16)
              if (((-val430) + 2) == 0 && ((-val429) + 2) == 0 && ((-val428) + 127) == 0) {	// L619, S[16,16)
                val170[0][val425][val426][val427] = val438;	// L620, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val439 = 0; val439 < 128; val439 += 1) {	// L628, S[18826452,19636694), latency=6330
    for (int val440 = 0; val440 < 28; val440 += 1) {	// L629, S[0,6330), latency=226
      for (int val441 = 0; val441 < 28; val441 += 1) {	// L630, S[0,226), latency=8
        float val442 = val180[0][val439][val440][val441];	// L631, S[0,2)
        float val443 = val170[0][val439][val440][val441];	// L632, S[0,2)
        float val444 = val442 + val443;	// L633, S[2,7)
        val168[0][val439][val440][val441] = val444;	// L634, S[7,8)
      }
    }
  }
  for (int val445 = 0; val445 < 128; val445 += 1) {	// L638, S[19636694,20145880), latency=3978
    for (int val446 = 0; val446 < 28; val446 += 1) {	// L639, S[0,3978), latency=142
      for (int val447 = 0; val447 < 28; val447 += 1) {	// L640, S[0,142), latency=5
        float val448 = val168[0][val445][val446][val447];	// L641, S[0,2)
        ap_int<1> val449 = val448 < 0.000000;	// L642, S[2,4)
        float val450 = val449 ? 0.000000 : val448;	// L643, S[4,4)
        val166[0][val445][val446][val447] = val450;	// L644, S[4,5)
      }
    }
  }
  for (int val451 = 0; val451 < 128; val451 += 1) {	// L648, S[20145880,20269018), latency=962
    for (int val452 = 0; val452 < 30; val452 += 1) {	// L649, S[0,962), latency=32
      for (int val453 = 0; val453 < 30; val453 += 1) {	// L650, S[0,32), latency=1
        val164[0][val451][val452][val453] = 0.000000;	// L651, S[0,1)
      }
    }
  }
  for (int val454 = 0; val454 < 128; val454 += 1) {	// L655, S[20269018,20577500), latency=2410
    for (int val455 = 0; val455 < 28; val455 += 1) {	// L656, S[0,2410), latency=86
      for (int val456 = 0; val456 < 28; val456 += 1) {	// L657, S[0,86), latency=3
        float val457 = val166[0][val454][val455][val456];	// L658, S[0,2)
        val164[0][val454][(val455 + 1)][(val456 + 1)] = val457;	// L659, S[2,3)
      }
    }
  }
  for (int val458 = 0; val458 < 128; val458 += 1) {	// L663, S[2247282650,20577500), latency=16158298
    for (int val459 = 0; val459 < 28; val459 += 1) {	// L664, S[0,16158298), latency=577082
      for (int val460 = 0; val460 < 28; val460 += 1) {	// L665, S[0,577082), latency=20610
        for (int val461 = 0; val461 < 128; val461 += 1) {	// L666, S[0,20610), latency=161
          for (int val462 = 0; val462 < 3; val462 += 1) {	// L667, S[0,161), latency=53
            for (int val463 = 0; val463 < 3; val463 += 1) {	// L668, S[0,53), latency=17
              float val464 = val164[0][val461][(val459 + val462)][(val460 + val463)];	// L669, S[0,2)
              float val465 = val34[val458][val461][val462][val463];	// L670, S[0,2)
              float val466 = val162[0][val458][val459][val460];	// L671, S[4,6)
              float val467;
              if (val463 == 0 && val462 == 0 && val461 == 0) {	// L672, S[6,6)
                val467 = 0.000000;	// L673, S[6,6)
              } else {
                val467 = val466;	// L675, S[6,6)
              }
              float val468 = val464 * val465;	// L677, S[2,6)
              float val469 = val467 + val468;	// L678, S[6,11)
              val162[0][val458][val459][val460] = val469;	// L679, S[15,16)
              float val470 = val36[val458];	// L680, S[9,11)
              float val471 = val469 + val470;	// L681, S[11,16)
              if (((-val463) + 2) == 0 && ((-val462) + 2) == 0 && ((-val461) + 127) == 0) {	// L682, S[16,16)
                val162[0][val458][val459][val460] = val471;	// L683, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val472 = 0; val472 < 128; val472 += 1) {	// L691, S[20577500,21086686), latency=3978
    for (int val473 = 0; val473 < 28; val473 += 1) {	// L692, S[0,3978), latency=142
      for (int val474 = 0; val474 < 28; val474 += 1) {	// L693, S[0,142), latency=5
        float val475 = val162[0][val472][val473][val474];	// L694, S[0,2)
        ap_int<1> val476 = val475 < 0.000000;	// L695, S[2,4)
        float val477 = val476 ? 0.000000 : val475;	// L696, S[4,4)
        val160[0][val472][val473][val474] = val477;	// L697, S[4,5)
      }
    }
  }
  for (int val478 = 0; val478 < 128; val478 += 1) {	// L701, S[21086686,21209824), latency=962
    for (int val479 = 0; val479 < 30; val479 += 1) {	// L702, S[0,962), latency=32
      for (int val480 = 0; val480 < 30; val480 += 1) {	// L703, S[0,32), latency=1
        val158[0][val478][val479][val480] = 0.000000;	// L704, S[0,1)
      }
    }
  }
  for (int val481 = 0; val481 < 128; val481 += 1) {	// L708, S[21209824,21518306), latency=2410
    for (int val482 = 0; val482 < 28; val482 += 1) {	// L709, S[0,2410), latency=86
      for (int val483 = 0; val483 < 28; val483 += 1) {	// L710, S[0,86), latency=3
        float val484 = val160[0][val481][val482][val483];	// L711, S[0,2)
        val158[0][val481][(val482 + 1)][(val483 + 1)] = val484;	// L712, S[2,3)
      }
    }
  }
  for (int val485 = 0; val485 < 128; val485 += 1) {	// L716, S[2248223456,21518306), latency=16158298
    for (int val486 = 0; val486 < 28; val486 += 1) {	// L717, S[0,16158298), latency=577082
      for (int val487 = 0; val487 < 28; val487 += 1) {	// L718, S[0,577082), latency=20610
        for (int val488 = 0; val488 < 128; val488 += 1) {	// L719, S[0,20610), latency=161
          for (int val489 = 0; val489 < 3; val489 += 1) {	// L720, S[0,161), latency=53
            for (int val490 = 0; val490 < 3; val490 += 1) {	// L721, S[0,53), latency=17
              float val491 = val158[0][val488][(val486 + val489)][(val487 + val490)];	// L722, S[0,2)
              float val492 = val38[val485][val488][val489][val490];	// L723, S[0,2)
              float val493 = val156[0][val485][val486][val487];	// L724, S[4,6)
              float val494;
              if (val490 == 0 && val489 == 0 && val488 == 0) {	// L725, S[6,6)
                val494 = 0.000000;	// L726, S[6,6)
              } else {
                val494 = val493;	// L728, S[6,6)
              }
              float val495 = val491 * val492;	// L730, S[2,6)
              float val496 = val494 + val495;	// L731, S[6,11)
              val156[0][val485][val486][val487] = val496;	// L732, S[15,16)
              float val497 = val40[val485];	// L733, S[9,11)
              float val498 = val496 + val497;	// L734, S[11,16)
              if (((-val490) + 2) == 0 && ((-val489) + 2) == 0 && ((-val488) + 127) == 0) {	// L735, S[16,16)
                val156[0][val485][val486][val487] = val498;	// L736, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val499 = 0; val499 < 128; val499 += 1) {	// L744, S[21518306,22328548), latency=6330
    for (int val500 = 0; val500 < 28; val500 += 1) {	// L745, S[0,6330), latency=226
      for (int val501 = 0; val501 < 28; val501 += 1) {	// L746, S[0,226), latency=8
        float val502 = val166[0][val499][val500][val501];	// L747, S[0,2)
        float val503 = val156[0][val499][val500][val501];	// L748, S[0,2)
        float val504 = val502 + val503;	// L749, S[2,7)
        val154[0][val499][val500][val501] = val504;	// L750, S[7,8)
      }
    }
  }
  for (int val505 = 0; val505 < 128; val505 += 1) {	// L754, S[22328548,22837734), latency=3978
    for (int val506 = 0; val506 < 28; val506 += 1) {	// L755, S[0,3978), latency=142
      for (int val507 = 0; val507 < 28; val507 += 1) {	// L756, S[0,142), latency=5
        float val508 = val154[0][val505][val506][val507];	// L757, S[0,2)
        ap_int<1> val509 = val508 < 0.000000;	// L758, S[2,4)
        float val510 = val509 ? 0.000000 : val508;	// L759, S[4,4)
        val152[0][val505][val506][val507] = val510;	// L760, S[4,5)
      }
    }
  }
  for (int val511 = 0; val511 < 256; val511 += 1) {	// L764, S[4208514020,22837734), latency=426918
    for (int val512 = 0; val512 < 14; val512 += 1) {	// L765, S[0,426918), latency=30494
      for (int val513 = 0; val513 < 14; val513 += 1) {	// L766, S[0,30494), latency=2178
        for (int val514 = 0; val514 < 128; val514 += 1) {	// L767, S[0,2178), latency=17
          float val515 = val152[0][val514][(val512 * 2)][(val513 * 2)];	// L768, S[0,2)
          float val516 = val42[val511][val514][0][0];	// L769, S[0,2)
          float val517 = val150[0][val511][val512][val513];	// L770, S[4,6)
          float val518;
          if (0 == 0 && 0 == 0 && val514 == 0) {	// L771, S[6,6)
            val518 = 0.000000;	// L772, S[6,6)
          } else {
            val518 = val517;	// L774, S[6,6)
          }
          float val519 = val515 * val516;	// L776, S[2,6)
          float val520 = val518 + val519;	// L777, S[6,11)
          val150[0][val511][val512][val513] = val520;	// L778, S[15,16)
          float val521 = val44[val511];	// L779, S[9,11)
          float val522 = val520 + val521;	// L780, S[11,16)
          if (0 == 0 && 0 == 0 && ((-val514) + 127) == 0) {	// L781, S[16,16)
            val150[0][val511][val512][val513] = val522;	// L782, S[16,17)
          }
        }
      }
    }
  }
  for (int val523 = 0; val523 < 128; val523 += 1) {	// L788, S[22837734,22960872), latency=962
    for (int val524 = 0; val524 < 30; val524 += 1) {	// L789, S[0,962), latency=32
      for (int val525 = 0; val525 < 30; val525 += 1) {	// L790, S[0,32), latency=1
        val148[0][val523][val524][val525] = 0.000000;	// L791, S[0,1)
      }
    }
  }
  for (int val526 = 0; val526 < 128; val526 += 1) {	// L795, S[22960872,23269354), latency=2410
    for (int val527 = 0; val527 < 28; val527 += 1) {	// L796, S[0,2410), latency=86
      for (int val528 = 0; val528 < 28; val528 += 1) {	// L797, S[0,86), latency=3
        float val529 = val152[0][val526][val527][val528];	// L798, S[0,2)
        val148[0][val526][(val527 + 1)][(val528 + 1)] = val529;	// L799, S[2,3)
      }
    }
  }
  for (int val530 = 0; val530 < 256; val530 += 1) {	// L803, S[3284101608,23269354), latency=4039590
    for (int val531 = 0; val531 < 14; val531 += 1) {	// L804, S[0,4039590), latency=288542
      for (int val532 = 0; val532 < 14; val532 += 1) {	// L805, S[0,288542), latency=20610
        for (int val533 = 0; val533 < 128; val533 += 1) {	// L806, S[0,20610), latency=161
          for (int val534 = 0; val534 < 3; val534 += 1) {	// L807, S[0,161), latency=53
            for (int val535 = 0; val535 < 3; val535 += 1) {	// L808, S[0,53), latency=17
              float val536 = val148[0][val533][((val531 * 2) + val534)][((val532 * 2) + val535)];	// L809, S[0,2)
              float val537 = val46[val530][val533][val534][val535];	// L810, S[0,2)
              float val538 = val146[0][val530][val531][val532];	// L811, S[4,6)
              float val539;
              if (val535 == 0 && val534 == 0 && val533 == 0) {	// L812, S[6,6)
                val539 = 0.000000;	// L813, S[6,6)
              } else {
                val539 = val538;	// L815, S[6,6)
              }
              float val540 = val536 * val537;	// L817, S[2,6)
              float val541 = val539 + val540;	// L818, S[6,11)
              val146[0][val530][val531][val532] = val541;	// L819, S[15,16)
              float val542 = val48[val530];	// L820, S[9,11)
              float val543 = val541 + val542;	// L821, S[11,16)
              if (((-val535) + 2) == 0 && ((-val534) + 2) == 0 && ((-val533) + 127) == 0) {	// L822, S[16,16)
                val146[0][val530][val531][val532] = val543;	// L823, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val544 = 0; val544 < 256; val544 += 1) {	// L831, S[23269354,23527916), latency=1010
    for (int val545 = 0; val545 < 14; val545 += 1) {	// L832, S[0,1010), latency=72
      for (int val546 = 0; val546 < 14; val546 += 1) {	// L833, S[0,72), latency=5
        float val547 = val146[0][val544][val545][val546];	// L834, S[0,2)
        ap_int<1> val548 = val547 < 0.000000;	// L835, S[2,4)
        float val549 = val548 ? 0.000000 : val547;	// L836, S[4,4)
        val144[0][val544][val545][val546] = val549;	// L837, S[4,5)
      }
    }
  }
  for (int val550 = 0; val550 < 256; val550 += 1) {	// L841, S[23527916,23602158), latency=290
    for (int val551 = 0; val551 < 16; val551 += 1) {	// L842, S[0,290), latency=18
      for (int val552 = 0; val552 < 16; val552 += 1) {	// L843, S[0,18), latency=1
        val142[0][val550][val551][val552] = 0.000000;	// L844, S[0,1)
      }
    }
  }
  for (int val553 = 0; val553 < 256; val553 += 1) {	// L848, S[23602158,23760368), latency=618
    for (int val554 = 0; val554 < 14; val554 += 1) {	// L849, S[0,618), latency=44
      for (int val555 = 0; val555 < 14; val555 += 1) {	// L850, S[0,44), latency=3
        float val556 = val144[0][val553][val554][val555];	// L851, S[0,2)
        val142[0][val553][(val554 + 1)][(val555 + 1)] = val556;	// L852, S[2,3)
      }
    }
  }
  for (int val557 = 0; val557 < 256; val557 += 1) {	// L856, S[2250565614,23760368), latency=8078758
    for (int val558 = 0; val558 < 14; val558 += 1) {	// L857, S[0,8078758), latency=577054
      for (int val559 = 0; val559 < 14; val559 += 1) {	// L858, S[0,577054), latency=41218
        for (int val560 = 0; val560 < 256; val560 += 1) {	// L859, S[0,41218), latency=161
          for (int val561 = 0; val561 < 3; val561 += 1) {	// L860, S[0,161), latency=53
            for (int val562 = 0; val562 < 3; val562 += 1) {	// L861, S[0,53), latency=17
              float val563 = val142[0][val560][(val558 + val561)][(val559 + val562)];	// L862, S[0,2)
              float val564 = val50[val557][val560][val561][val562];	// L863, S[0,2)
              float val565 = val140[0][val557][val558][val559];	// L864, S[4,6)
              float val566;
              if (val562 == 0 && val561 == 0 && val560 == 0) {	// L865, S[6,6)
                val566 = 0.000000;	// L866, S[6,6)
              } else {
                val566 = val565;	// L868, S[6,6)
              }
              float val567 = val563 * val564;	// L870, S[2,6)
              float val568 = val566 + val567;	// L871, S[6,11)
              val140[0][val557][val558][val559] = val568;	// L872, S[15,16)
              float val569 = val52[val557];	// L873, S[9,11)
              float val570 = val568 + val569;	// L874, S[11,16)
              if (((-val562) + 2) == 0 && ((-val561) + 2) == 0 && ((-val560) + 255) == 0) {	// L875, S[16,16)
                val140[0][val557][val558][val559] = val570;	// L876, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val571 = 0; val571 < 256; val571 += 1) {	// L884, S[23760368,24169458), latency=1598
    for (int val572 = 0; val572 < 14; val572 += 1) {	// L885, S[0,1598), latency=114
      for (int val573 = 0; val573 < 14; val573 += 1) {	// L886, S[0,114), latency=8
        float val574 = val150[0][val571][val572][val573];	// L887, S[0,2)
        float val575 = val140[0][val571][val572][val573];	// L888, S[0,2)
        float val576 = val574 + val575;	// L889, S[2,7)
        val138[0][val571][val572][val573] = val576;	// L890, S[7,8)
      }
    }
  }
  for (int val577 = 0; val577 < 256; val577 += 1) {	// L894, S[24169458,24428020), latency=1010
    for (int val578 = 0; val578 < 14; val578 += 1) {	// L895, S[0,1010), latency=72
      for (int val579 = 0; val579 < 14; val579 += 1) {	// L896, S[0,72), latency=5
        float val580 = val138[0][val577][val578][val579];	// L897, S[0,2)
        ap_int<1> val581 = val580 < 0.000000;	// L898, S[2,4)
        float val582 = val581 ? 0.000000 : val580;	// L899, S[4,4)
        val136[0][val577][val578][val579] = val582;	// L900, S[4,5)
      }
    }
  }
  for (int val583 = 0; val583 < 256; val583 += 1) {	// L904, S[24428020,24502262), latency=290
    for (int val584 = 0; val584 < 16; val584 += 1) {	// L905, S[0,290), latency=18
      for (int val585 = 0; val585 < 16; val585 += 1) {	// L906, S[0,18), latency=1
        val134[0][val583][val584][val585] = 0.000000;	// L907, S[0,1)
      }
    }
  }
  for (int val586 = 0; val586 < 256; val586 += 1) {	// L911, S[24502262,24660472), latency=618
    for (int val587 = 0; val587 < 14; val587 += 1) {	// L912, S[0,618), latency=44
      for (int val588 = 0; val588 < 14; val588 += 1) {	// L913, S[0,44), latency=3
        float val589 = val136[0][val586][val587][val588];	// L914, S[0,2)
        val134[0][val586][(val587 + 1)][(val588 + 1)] = val589;	// L915, S[2,3)
      }
    }
  }
  for (int val590 = 0; val590 < 256; val590 += 1) {	// L919, S[2251465718,24660472), latency=8078758
    for (int val591 = 0; val591 < 14; val591 += 1) {	// L920, S[0,8078758), latency=577054
      for (int val592 = 0; val592 < 14; val592 += 1) {	// L921, S[0,577054), latency=41218
        for (int val593 = 0; val593 < 256; val593 += 1) {	// L922, S[0,41218), latency=161
          for (int val594 = 0; val594 < 3; val594 += 1) {	// L923, S[0,161), latency=53
            for (int val595 = 0; val595 < 3; val595 += 1) {	// L924, S[0,53), latency=17
              float val596 = val134[0][val593][(val591 + val594)][(val592 + val595)];	// L925, S[0,2)
              float val597 = val54[val590][val593][val594][val595];	// L926, S[0,2)
              float val598 = val132[0][val590][val591][val592];	// L927, S[4,6)
              float val599;
              if (val595 == 0 && val594 == 0 && val593 == 0) {	// L928, S[6,6)
                val599 = 0.000000;	// L929, S[6,6)
              } else {
                val599 = val598;	// L931, S[6,6)
              }
              float val600 = val596 * val597;	// L933, S[2,6)
              float val601 = val599 + val600;	// L934, S[6,11)
              val132[0][val590][val591][val592] = val601;	// L935, S[15,16)
              float val602 = val56[val590];	// L936, S[9,11)
              float val603 = val601 + val602;	// L937, S[11,16)
              if (((-val595) + 2) == 0 && ((-val594) + 2) == 0 && ((-val593) + 255) == 0) {	// L938, S[16,16)
                val132[0][val590][val591][val592] = val603;	// L939, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val604 = 0; val604 < 256; val604 += 1) {	// L947, S[24660472,24919034), latency=1010
    for (int val605 = 0; val605 < 14; val605 += 1) {	// L948, S[0,1010), latency=72
      for (int val606 = 0; val606 < 14; val606 += 1) {	// L949, S[0,72), latency=5
        float val607 = val132[0][val604][val605][val606];	// L950, S[0,2)
        ap_int<1> val608 = val607 < 0.000000;	// L951, S[2,4)
        float val609 = val608 ? 0.000000 : val607;	// L952, S[4,4)
        val130[0][val604][val605][val606] = val609;	// L953, S[4,5)
      }
    }
  }
  for (int val610 = 0; val610 < 256; val610 += 1) {	// L957, S[24919034,24993276), latency=290
    for (int val611 = 0; val611 < 16; val611 += 1) {	// L958, S[0,290), latency=18
      for (int val612 = 0; val612 < 16; val612 += 1) {	// L959, S[0,18), latency=1
        val128[0][val610][val611][val612] = 0.000000;	// L960, S[0,1)
      }
    }
  }
  for (int val613 = 0; val613 < 256; val613 += 1) {	// L964, S[24993276,25151486), latency=618
    for (int val614 = 0; val614 < 14; val614 += 1) {	// L965, S[0,618), latency=44
      for (int val615 = 0; val615 < 14; val615 += 1) {	// L966, S[0,44), latency=3
        float val616 = val130[0][val613][val614][val615];	// L967, S[0,2)
        val128[0][val613][(val614 + 1)][(val615 + 1)] = val616;	// L968, S[2,3)
      }
    }
  }
  for (int val617 = 0; val617 < 256; val617 += 1) {	// L972, S[2251956732,25151486), latency=8078758
    for (int val618 = 0; val618 < 14; val618 += 1) {	// L973, S[0,8078758), latency=577054
      for (int val619 = 0; val619 < 14; val619 += 1) {	// L974, S[0,577054), latency=41218
        for (int val620 = 0; val620 < 256; val620 += 1) {	// L975, S[0,41218), latency=161
          for (int val621 = 0; val621 < 3; val621 += 1) {	// L976, S[0,161), latency=53
            for (int val622 = 0; val622 < 3; val622 += 1) {	// L977, S[0,53), latency=17
              float val623 = val128[0][val620][(val618 + val621)][(val619 + val622)];	// L978, S[0,2)
              float val624 = val58[val617][val620][val621][val622];	// L979, S[0,2)
              float val625 = val126[0][val617][val618][val619];	// L980, S[4,6)
              float val626;
              if (val622 == 0 && val621 == 0 && val620 == 0) {	// L981, S[6,6)
                val626 = 0.000000;	// L982, S[6,6)
              } else {
                val626 = val625;	// L984, S[6,6)
              }
              float val627 = val623 * val624;	// L986, S[2,6)
              float val628 = val626 + val627;	// L987, S[6,11)
              val126[0][val617][val618][val619] = val628;	// L988, S[15,16)
              float val629 = val60[val617];	// L989, S[9,11)
              float val630 = val628 + val629;	// L990, S[11,16)
              if (((-val622) + 2) == 0 && ((-val621) + 2) == 0 && ((-val620) + 255) == 0) {	// L991, S[16,16)
                val126[0][val617][val618][val619] = val630;	// L992, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val631 = 0; val631 < 256; val631 += 1) {	// L1000, S[25151486,25560576), latency=1598
    for (int val632 = 0; val632 < 14; val632 += 1) {	// L1001, S[0,1598), latency=114
      for (int val633 = 0; val633 < 14; val633 += 1) {	// L1002, S[0,114), latency=8
        float val634 = val136[0][val631][val632][val633];	// L1003, S[0,2)
        float val635 = val126[0][val631][val632][val633];	// L1004, S[0,2)
        float val636 = val634 + val635;	// L1005, S[2,7)
        val124[0][val631][val632][val633] = val636;	// L1006, S[7,8)
      }
    }
  }
  for (int val637 = 0; val637 < 256; val637 += 1) {	// L1010, S[25560576,25819138), latency=1010
    for (int val638 = 0; val638 < 14; val638 += 1) {	// L1011, S[0,1010), latency=72
      for (int val639 = 0; val639 < 14; val639 += 1) {	// L1012, S[0,72), latency=5
        float val640 = val124[0][val637][val638][val639];	// L1013, S[0,2)
        ap_int<1> val641 = val640 < 0.000000;	// L1014, S[2,4)
        float val642 = val641 ? 0.000000 : val640;	// L1015, S[4,4)
        val122[0][val637][val638][val639] = val642;	// L1016, S[4,5)
      }
    }
  }
  for (int val643 = 0; val643 < 512; val643 += 1) {	// L1020, S[25819138,135060484), latency=213362
    for (int val644 = 0; val644 < 7; val644 += 1) {	// L1021, S[0,213362), latency=30480
      for (int val645 = 0; val645 < 7; val645 += 1) {	// L1022, S[0,30480), latency=4354
        for (int val646 = 0; val646 < 256; val646 += 1) {	// L1023, S[0,4354), latency=17
          float val647 = val122[0][val646][(val644 * 2)][(val645 * 2)];	// L1024, S[0,2)
          float val648 = val62[val643][val646][0][0];	// L1025, S[0,2)
          float val649 = val120[0][val643][val644][val645];	// L1026, S[4,6)
          float val650;
          if (0 == 0 && 0 == 0 && val646 == 0) {	// L1027, S[6,6)
            val650 = 0.000000;	// L1028, S[6,6)
          } else {
            val650 = val649;	// L1030, S[6,6)
          }
          float val651 = val647 * val648;	// L1032, S[2,6)
          float val652 = val650 + val651;	// L1033, S[6,11)
          val120[0][val643][val644][val645] = val652;	// L1034, S[15,16)
          float val653 = val64[val643];	// L1035, S[9,11)
          float val654 = val652 + val653;	// L1036, S[11,16)
          if (0 == 0 && 0 == 0 && ((-val646) + 255) == 0) {	// L1037, S[16,16)
            val120[0][val643][val644][val645] = val654;	// L1038, S[16,17)
          }
        }
      }
    }
  }
  for (int val655 = 0; val655 < 256; val655 += 1) {	// L1044, S[135060484,135134726), latency=290
    for (int val656 = 0; val656 < 16; val656 += 1) {	// L1045, S[0,290), latency=18
      for (int val657 = 0; val657 < 16; val657 += 1) {	// L1046, S[0,18), latency=1
        val118[0][val655][val656][val657] = 0.000000;	// L1047, S[0,1)
      }
    }
  }
  for (int val658 = 0; val658 < 256; val658 += 1) {	// L1051, S[135134726,135292936), latency=618
    for (int val659 = 0; val659 < 14; val659 += 1) {	// L1052, S[0,618), latency=44
      for (int val660 = 0; val660 < 14; val660 += 1) {	// L1053, S[0,44), latency=3
        float val661 = val122[0][val658][val659][val660];	// L1054, S[0,2)
        val118[0][val658][(val659 + 1)][(val660 + 1)] = val661;	// L1055, S[2,3)
      }
    }
  }
  for (int val662 = 0; val662 < 512; val662 += 1) {	// L1059, S[3396174854,135292936), latency=2019698
    for (int val663 = 0; val663 < 7; val663 += 1) {	// L1060, S[0,2019698), latency=288528
      for (int val664 = 0; val664 < 7; val664 += 1) {	// L1061, S[0,288528), latency=41218
        for (int val665 = 0; val665 < 256; val665 += 1) {	// L1062, S[0,41218), latency=161
          for (int val666 = 0; val666 < 3; val666 += 1) {	// L1063, S[0,161), latency=53
            for (int val667 = 0; val667 < 3; val667 += 1) {	// L1064, S[0,53), latency=17
              float val668 = val118[0][val665][((val663 * 2) + val666)][((val664 * 2) + val667)];	// L1065, S[0,2)
              float val669 = val66[val662][val665][val666][val667];	// L1066, S[0,2)
              float val670 = val116[0][val662][val663][val664];	// L1067, S[4,6)
              float val671;
              if (val667 == 0 && val666 == 0 && val665 == 0) {	// L1068, S[6,6)
                val671 = 0.000000;	// L1069, S[6,6)
              } else {
                val671 = val670;	// L1071, S[6,6)
              }
              float val672 = val668 * val669;	// L1073, S[2,6)
              float val673 = val671 + val672;	// L1074, S[6,11)
              val116[0][val662][val663][val664] = val673;	// L1075, S[15,16)
              float val674 = val68[val662];	// L1076, S[9,11)
              float val675 = val673 + val674;	// L1077, S[11,16)
              if (((-val667) + 2) == 0 && ((-val666) + 2) == 0 && ((-val665) + 255) == 0) {	// L1078, S[16,16)
                val116[0][val662][val663][val664] = val675;	// L1079, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val676 = 0; val676 < 512; val676 += 1) {	// L1087, S[135292936,135426570), latency=261
    for (int val677 = 0; val677 < 7; val677 += 1) {	// L1088, S[0,261), latency=37
      for (int val678 = 0; val678 < 7; val678 += 1) {	// L1089, S[0,37), latency=5
        float val679 = val116[0][val676][val677][val678];	// L1090, S[0,2)
        ap_int<1> val680 = val679 < 0.000000;	// L1091, S[2,4)
        float val681 = val680 ? 0.000000 : val679;	// L1092, S[4,4)
        val114[0][val676][val677][val678] = val681;	// L1093, S[4,5)
      }
    }
  }
  for (int val682 = 0; val682 < 512; val682 += 1) {	// L1097, S[135426570,135478284), latency=101
    for (int val683 = 0; val683 < 9; val683 += 1) {	// L1098, S[0,101), latency=11
      for (int val684 = 0; val684 < 9; val684 += 1) {	// L1099, S[0,11), latency=1
        val112[0][val682][val683][val684] = 0.000000;	// L1100, S[0,1)
      }
    }
  }
  for (int val685 = 0; val685 < 512; val685 += 1) {	// L1104, S[135478284,135561742), latency=163
    for (int val686 = 0; val686 < 7; val686 += 1) {	// L1105, S[0,163), latency=23
      for (int val687 = 0; val687 < 7; val687 += 1) {	// L1106, S[0,23), latency=3
        float val688 = val114[0][val685][val686][val687];	// L1107, S[0,2)
        val112[0][val685][(val686 + 1)][(val687 + 1)] = val688;	// L1108, S[2,3)
      }
    }
  }
  for (int val689 = 0; val689 < 512; val689 += 1) {	// L1112, S[2362416652,135561742), latency=4039282
    for (int val690 = 0; val690 < 7; val690 += 1) {	// L1113, S[0,4039282), latency=577040
      for (int val691 = 0; val691 < 7; val691 += 1) {	// L1114, S[0,577040), latency=82434
        for (int val692 = 0; val692 < 512; val692 += 1) {	// L1115, S[0,82434), latency=161
          for (int val693 = 0; val693 < 3; val693 += 1) {	// L1116, S[0,161), latency=53
            for (int val694 = 0; val694 < 3; val694 += 1) {	// L1117, S[0,53), latency=17
              float val695 = val112[0][val692][(val690 + val693)][(val691 + val694)];	// L1118, S[0,2)
              float val696 = val70[val689][val692][val693][val694];	// L1119, S[0,2)
              float val697 = val110[0][val689][val690][val691];	// L1120, S[4,6)
              float val698;
              if (val694 == 0 && val693 == 0 && val692 == 0) {	// L1121, S[6,6)
                val698 = 0.000000;	// L1122, S[6,6)
              } else {
                val698 = val697;	// L1124, S[6,6)
              }
              float val699 = val695 * val696;	// L1126, S[2,6)
              float val700 = val698 + val699;	// L1127, S[6,11)
              val110[0][val689][val690][val691] = val700;	// L1128, S[15,16)
              float val701 = val72[val689];	// L1129, S[9,11)
              float val702 = val700 + val701;	// L1130, S[11,16)
              if (((-val694) + 2) == 0 && ((-val693) + 2) == 0 && ((-val692) + 511) == 0) {	// L1131, S[16,16)
                val110[0][val689][val690][val691] = val702;	// L1132, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val703 = 0; val703 < 512; val703 += 1) {	// L1140, S[135561742,135770640), latency=408
    for (int val704 = 0; val704 < 7; val704 += 1) {	// L1141, S[0,408), latency=58
      for (int val705 = 0; val705 < 7; val705 += 1) {	// L1142, S[0,58), latency=8
        float val706 = val120[0][val703][val704][val705];	// L1143, S[0,2)
        float val707 = val110[0][val703][val704][val705];	// L1144, S[0,2)
        float val708 = val706 + val707;	// L1145, S[2,7)
        val108[0][val703][val704][val705] = val708;	// L1146, S[7,8)
      }
    }
  }
  for (int val709 = 0; val709 < 512; val709 += 1) {	// L1150, S[135770640,135904274), latency=261
    for (int val710 = 0; val710 < 7; val710 += 1) {	// L1151, S[0,261), latency=37
      for (int val711 = 0; val711 < 7; val711 += 1) {	// L1152, S[0,37), latency=5
        float val712 = val108[0][val709][val710][val711];	// L1153, S[0,2)
        ap_int<1> val713 = val712 < 0.000000;	// L1154, S[2,4)
        float val714 = val713 ? 0.000000 : val712;	// L1155, S[4,4)
        val106[0][val709][val710][val711] = val714;	// L1156, S[4,5)
      }
    }
  }
  for (int val715 = 0; val715 < 512; val715 += 1) {	// L1160, S[135904274,135955988), latency=101
    for (int val716 = 0; val716 < 9; val716 += 1) {	// L1161, S[0,101), latency=11
      for (int val717 = 0; val717 < 9; val717 += 1) {	// L1162, S[0,11), latency=1
        val104[0][val715][val716][val717] = 0.000000;	// L1163, S[0,1)
      }
    }
  }
  for (int val718 = 0; val718 < 512; val718 += 1) {	// L1167, S[135955988,136039446), latency=163
    for (int val719 = 0; val719 < 7; val719 += 1) {	// L1168, S[0,163), latency=23
      for (int val720 = 0; val720 < 7; val720 += 1) {	// L1169, S[0,23), latency=3
        float val721 = val106[0][val718][val719][val720];	// L1170, S[0,2)
        val104[0][val718][(val719 + 1)][(val720 + 1)] = val721;	// L1171, S[2,3)
      }
    }
  }
  for (int val722 = 0; val722 < 512; val722 += 1) {	// L1175, S[136039446,2204151832), latency=4039282
    for (int val723 = 0; val723 < 7; val723 += 1) {	// L1176, S[0,4039282), latency=577040
      for (int val724 = 0; val724 < 7; val724 += 1) {	// L1177, S[0,577040), latency=82434
        for (int val725 = 0; val725 < 512; val725 += 1) {	// L1178, S[0,82434), latency=161
          for (int val726 = 0; val726 < 3; val726 += 1) {	// L1179, S[0,161), latency=53
            for (int val727 = 0; val727 < 3; val727 += 1) {	// L1180, S[0,53), latency=17
              float val728 = val104[0][val725][(val723 + val726)][(val724 + val727)];	// L1181, S[0,2)
              float val729 = val74[val722][val725][val726][val727];	// L1182, S[0,2)
              float val730 = val102[0][val722][val723][val724];	// L1183, S[4,6)
              float val731;
              if (val727 == 0 && val726 == 0 && val725 == 0) {	// L1184, S[6,6)
                val731 = 0.000000;	// L1185, S[6,6)
              } else {
                val731 = val730;	// L1187, S[6,6)
              }
              float val732 = val728 * val729;	// L1189, S[2,6)
              float val733 = val731 + val732;	// L1190, S[6,11)
              val102[0][val722][val723][val724] = val733;	// L1191, S[15,16)
              float val734 = val76[val722];	// L1192, S[9,11)
              float val735 = val733 + val734;	// L1193, S[11,16)
              if (((-val727) + 2) == 0 && ((-val726) + 2) == 0 && ((-val725) + 511) == 0) {	// L1194, S[16,16)
                val102[0][val722][val723][val724] = val735;	// L1195, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val736 = 0; val736 < 512; val736 += 1) {	// L1203, S[2204151832,2204285466), latency=261
    for (int val737 = 0; val737 < 7; val737 += 1) {	// L1204, S[0,261), latency=37
      for (int val738 = 0; val738 < 7; val738 += 1) {	// L1205, S[0,37), latency=5
        float val739 = val102[0][val736][val737][val738];	// L1206, S[0,2)
        ap_int<1> val740 = val739 < 0.000000;	// L1207, S[2,4)
        float val741 = val740 ? 0.000000 : val739;	// L1208, S[4,4)
        val100[0][val736][val737][val738] = val741;	// L1209, S[4,5)
      }
    }
  }
  for (int val742 = 0; val742 < 512; val742 += 1) {	// L1213, S[2204285466,2204337180), latency=101
    for (int val743 = 0; val743 < 9; val743 += 1) {	// L1214, S[0,101), latency=11
      for (int val744 = 0; val744 < 9; val744 += 1) {	// L1215, S[0,11), latency=1
        val98[0][val742][val743][val744] = 0.000000;	// L1216, S[0,1)
      }
    }
  }
  for (int val745 = 0; val745 < 512; val745 += 1) {	// L1220, S[2204337180,2204420638), latency=163
    for (int val746 = 0; val746 < 7; val746 += 1) {	// L1221, S[0,163), latency=23
      for (int val747 = 0; val747 < 7; val747 += 1) {	// L1222, S[0,23), latency=3
        float val748 = val100[0][val745][val746][val747];	// L1223, S[0,2)
        val98[0][val745][(val746 + 1)][(val747 + 1)] = val748;	// L1224, S[2,3)
      }
    }
  }
  for (int val749 = 0; val749 < 512; val749 += 1) {	// L1228, S[2204420638,4272533024), latency=4039282
    for (int val750 = 0; val750 < 7; val750 += 1) {	// L1229, S[0,4039282), latency=577040
      for (int val751 = 0; val751 < 7; val751 += 1) {	// L1230, S[0,577040), latency=82434
        for (int val752 = 0; val752 < 512; val752 += 1) {	// L1231, S[0,82434), latency=161
          for (int val753 = 0; val753 < 3; val753 += 1) {	// L1232, S[0,161), latency=53
            for (int val754 = 0; val754 < 3; val754 += 1) {	// L1233, S[0,53), latency=17
              float val755 = val98[0][val752][(val750 + val753)][(val751 + val754)];	// L1234, S[0,2)
              float val756 = val78[val749][val752][val753][val754];	// L1235, S[0,2)
              float val757 = val96[0][val749][val750][val751];	// L1236, S[4,6)
              float val758;
              if (val754 == 0 && val753 == 0 && val752 == 0) {	// L1237, S[6,6)
                val758 = 0.000000;	// L1238, S[6,6)
              } else {
                val758 = val757;	// L1240, S[6,6)
              }
              float val759 = val755 * val756;	// L1242, S[2,6)
              float val760 = val758 + val759;	// L1243, S[6,11)
              val96[0][val749][val750][val751] = val760;	// L1244, S[15,16)
              float val761 = val80[val749];	// L1245, S[9,11)
              float val762 = val760 + val761;	// L1246, S[11,16)
              if (((-val754) + 2) == 0 && ((-val753) + 2) == 0 && ((-val752) + 511) == 0) {	// L1247, S[16,16)
                val96[0][val749][val750][val751] = val762;	// L1248, S[16,17)
              }
            }
          }
        }
      }
    }
  }
  for (int val763 = 0; val763 < 512; val763 += 1) {	// L1256, S[4272533024,4272741922), latency=408
    for (int val764 = 0; val764 < 7; val764 += 1) {	// L1257, S[0,408), latency=58
      for (int val765 = 0; val765 < 7; val765 += 1) {	// L1258, S[0,58), latency=8
        float val766 = val106[0][val763][val764][val765];	// L1259, S[0,2)
        float val767 = val96[0][val763][val764][val765];	// L1260, S[0,2)
        float val768 = val766 + val767;	// L1261, S[2,7)
        val94[0][val763][val764][val765] = val768;	// L1262, S[7,8)
      }
    }
  }
  for (int val769 = 0; val769 < 512; val769 += 1) {	// L1266, S[4272741922,4272875556), latency=261
    for (int val770 = 0; val770 < 7; val770 += 1) {	// L1267, S[0,261), latency=37
      for (int val771 = 0; val771 < 7; val771 += 1) {	// L1268, S[0,37), latency=5
        float val772 = val94[0][val769][val770][val771];	// L1269, S[0,2)
        ap_int<1> val773 = val772 < 0.000000;	// L1270, S[2,4)
        float val774 = val773 ? 0.000000 : val772;	// L1271, S[4,4)
        val92[0][val769][val770][val771] = val774;	// L1272, S[4,5)
      }
    }
  }
  for (int val775 = 0; val775 < 512; val775 += 1) {	// L1276, S[4272875556,4272876070), latency=1
    val90[0][val775][0][0] = 0.000000;	// L1277, S[0,1)
  }
  for (int val776 = 0; val776 < 512; val776 += 1) {	// L1279, S[4272876070,4273084968), latency=408
    for (int val777 = 0; val777 < 7; val777 += 1) {	// L1280, S[0,408), latency=58
      for (int val778 = 0; val778 < 7; val778 += 1) {	// L1281, S[0,58), latency=8
        float val779 = val92[0][val776][val777][val778];	// L1282, S[0,2)
        float val780 = val90[0][val776][0][0];	// L1283, S[0,2)
        float val781 = val780 + val779;	// L1284, S[2,7)
        val90[0][val776][0][0] = val781;	// L1285, S[7,8)
      }
    }
  }
  float val782 = 49;	// L1289
  for (int val783 = 0; val783 < 512; val783 += 1) {	// L1290, S[4273084968,4273094698), latency=19
    float val784 = val90[0][val783][0][0];	// L1291, S[0,2)
    float val785 = val784 / val782;	// L1292, S[2,18)
    val90[0][val783][0][0] = val785;	// L1293, S[18,19)
  }
  for (int val786 = 0; val786 < 512; val786 += 1) {	// L1295, S[4273094698,4273096236), latency=3
    float val787 = val90[0][val786][0][0];	// L1296, S[0,2)
    val88[0][val786] = val787;	// L1297, S[2,3)
  }
  for (int val788 = 0; val788 < 1000; val788 += 1) {	// L1299, S[4273096236,4283850238), latency=10754
    for (int val789 = 0; val789 < 512; val789 += 1) {	// L1300, S[0,10754), latency=21
      float val790 = val88[0][val789];	// L1301, S[0,2)
      float val791 = val82[val788][val789];	// L1302, S[0,2)
      float val792 = val86[0][val788];	// L1303, S[4,6)
      float val793;
      if (val789 == 0) {	// L1304, S[6,6)
        val793 = 0.000000;	// L1305, S[6,6)
      } else {
        val793 = val792;	// L1307, S[6,6)
      }
      float val794 = val790 * val791;	// L1309, S[2,6)
      float val795 = val793 + val794;	// L1310, S[6,11)
      val86[0][val788] = val795;	// L1311, S[19,20)
      float val796 = 1.000000 * val795;	// L1312, S[11,15)
      float val797 = val84[val788];	// L1313, S[9,11)
      float val798 = 1.000000 * val797;	// L1314, S[11,15)
      float val799 = val796 + val798;	// L1315, S[15,20)
      if (((-val789) + 511) == 0) {	// L1316, S[20,20)
        val86[0][val788] = val799;	// L1317, S[20,21)
      }
    }
  }
}

