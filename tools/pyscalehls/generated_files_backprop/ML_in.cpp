#include "math.h"

void soft_max(
  double v0[3],
  double v1[3]
) {	// L2



  double v2[1];	// L4
  v2[0] = 0.000000;	// L5
  double v3[1];	// L6
  v3[0] = 0.000000;	// L7
  for (int v4 = 0; v4 < 3; v4 += 1) {	// L8
#pragma HLS pipeline
    double v5 = v2[0];	// L9
    double v6 = v1[v4];	// L10
    double v7 = -(v6);	// L11
    double v8 = exp(v7);	// L12
    double v9 = v5 + v8;	// L13
    v2[0] = v9;	// L14
    v3[0] = v9;	// L15
  }
  double v10 = v3[0];	// L17
  for (int v11 = 0; v11 < 3; v11 += 1) {	// L18
#pragma HLS pipeline
    double v12 = v1[v11];	// L19
    double v13 = -(v12);	// L20
    double v14 = exp(v13);	// L21
    double v15 = v14 / v10;	// L22
    v0[v11] = v15;	// L23
  }
}

void RELU(double activations[64], double dactivations[64], int size) {
    int i;
    Loop2: for( i = 0; i < size; i++) {
        dactivations[i] = activations[i]*(1.0-activations[i]);
        activations[i] = 1.0/(1.0+exp(-activations[i]));
    }
}

void add_bias_to_activations(double biases[64], 
                               double activations[64],
                               int size) {
    int i;
    Loop3: for( i = 0; i < size; i++){
        activations[i] = activations[i] + biases[i];
    }
}

void matrix_vector_product_with_bias_input_layer(
  double v0[64],
  double v1[832],
  double v2[64],
  double v3[13]
) {	// L2





  for (int v5 = 0; v5 < 8; v5 += 1) {	// L7
#pragma HLS pipeline
    for (int v6 = 0; v6 < 13; v6 += 1) {	// L7
      for (int v7 = 0; v7 < 8; v7 += 1) {	// L7
        int v8 = (v7 + (v5 * 8));	// L7
        v2[v8] = 0.000000;	// L6
        double v9 = v1[(v6 + (v8 * 13))];	// L8
        double v10 = v3[v6];	// L9
        double v11 = v9 * v10;	// L10
        double v12 = v2[v8];	// L11
        double v13 = v12 + v11;	// L12
        v2[v8] = v13;	// L13
      }
    }
  }
  add_bias_to_activations(v0, v2, 64);
}

void matrix_vector_product_with_bias_second_layer(
  double v0[64],
  double v1[4096],
  double v2[64],
  double v3[64]
) {	// L2





  for (int v5 = 0; v5 < 8; v5 += 1) {	// L7
    for (int v6 = 0; v6 < 64; v6 += 1) {	// L7
#pragma HLS pipeline
      for (int v7 = 0; v7 < 8; v7 += 1) {	// L7
        int v8 = (v7 + (v5 * 8));	// L7
        v2[v6] = 0.000000;	// L6
        double v9 = v1[(v8 + (v6 * 64))];	// L8
        double v10 = v3[v8];	// L9
        double v11 = v9 * v10;	// L10
        double v12 = v2[v6];	// L11
        double v13 = v12 + v11;	// L12
        v2[v6] = v13;	// L13
      }
    }
  }
  add_bias_to_activations(v0, v2, 64);
}

void matrix_vector_product_with_bias_output_layer(
  double v0[3],
  double v1[192],
  double v2[3],
  double v3[64]
) {	// L2





  for (int v5 = 0; v5 < 8; v5 += 1) {	// L7
#pragma HLS pipeline
    for (int v6 = 0; v6 < 8; v6 += 1) {	// L7
      int v7 = (v6 + (v5 * 8));	// L7
      for (int v8 = 0; v8 < 3; v8 += 1) {	// L7
        v2[v8] = 0.000000;	// L6
        double v9 = v1[(v7 + (v8 * 64))];	// L8
        double v10 = v3[v7];	// L9
        double v11 = v9 * v10;	// L10
        double v12 = v2[v8];	// L11
        double v13 = v12 + v11;	// L12
        v2[v8] = v13;	// L13
      }
    }
  }
  add_bias_to_activations(v0, v2, 3);
}

void take_difference(
  double v0[3],
  double v1[3],
  double v2[3],
  double v3[3]
) {	// L2





  for (int v4 = 0; v4 < 3; v4 += 1) {	// L4
#pragma HLS pipeline
    double v5 = v0[v4];	// L5
    double v6 = v1[v4];	// L6
    double v7 = v5 - v6;	// L7
    double v8 = v7 * -1.000000;	// L8
    double v9 = v3[v4];	// L9
    double v10 = v8 * v9;	// L10
    v2[v4] = v10;	// L11
  }
}

void get_delta_matrix_weights3(
  double v0[192],
  double v1[3],
  double v2[64]
) {	// L2




  for (int v3 = 0; v3 < 8; v3 += 1) {	// L3
#pragma HLS pipeline
    for (int v4 = 0; v4 < 8; v4 += 1) {	// L3
      int v5 = (v4 + (v3 * 8));	// L3
      for (int v6 = 0; v6 < 3; v6 += 1) {	// L3
        double v7 = v2[v5];	// L5
        double v8 = v1[v6];	// L6
        double v9 = v7 * v8;	// L7
        v0[(v6 + (v5 * 3))] = v9;	// L8
      }
    }
  }
}

void get_oracle_activations2(
  double v0[192],
  double v1[3],
  double v2[64],
  double v3[64]
) {	// L2





  for (int v4 = 0; v4 < 8; v4 += 1) {	// L6
#pragma HLS pipeline
    for (int v5 = 0; v5 < 3; v5 += 1) {	// L6
      for (int v6 = 0; v6 < 8; v6 += 1) {	// L6
        int v7 = (v6 + (v4 * 8));	// L6
        v2[v7] = 0.000000;	// L5
        double v8 = v1[v5];	// L7
        double v9 = v0[(v5 + (v7 * 3))];	// L8
        double v10 = v8 * v9;	// L9
        double v11 = v2[v7];	// L10
        double v12 = v11 + v10;	// L11
        v2[v7] = v12;	// L12
        double v13 = v2[v7];	// L14
        double v14 = v3[v7];	// L15
        double v15 = v13 * v14;	// L16
        v2[v7] = v15;	// L17
      }
    }
  }
}

void get_delta_matrix_weights2(
  double v0[4096],
  double v1[64],
  double v2[64]
) {	// L2




  for (int v3 = 0; v3 < 64; v3 += 1) {	// L3
    for (int v4 = 0; v4 < 4; v4 += 1) {	// L3
#pragma HLS pipeline
      for (int v5 = 0; v5 < 16; v5 += 1) {	// L3
        int v6 = (v5 + (v4 * 16));	// L3
        double v7 = v2[v3];	// L5
        double v8 = v1[v6];	// L6
        double v9 = v7 * v8;	// L7
        v0[(v6 + (v3 * 64))] = v9;	// L8
      }
    }
  }
}

void get_oracle_activations1(
  double v0[4096],
  double v1[64],
  double v2[64],
  double v3[64]
) {	// L2





  for (int v4 = 0; v4 < 4; v4 += 1) {	// L6
    for (int v5 = 0; v5 < 64; v5 += 1) {	// L6
#pragma HLS pipeline
      for (int v6 = 0; v6 < 16; v6 += 1) {	// L6
        int v7 = (v6 + (v4 * 16));	// L6
        v2[v5] = 0.000000;	// L5
        double v8 = v1[v7];	// L7
        double v9 = v0[(v7 + (v5 * 64))];	// L8
        double v10 = v8 * v9;	// L9
        double v11 = v2[v5];	// L10
        double v12 = v11 + v10;	// L11
        v2[v5] = v12;	// L12
        double v13 = v2[v5];	// L14
        double v14 = v3[v5];	// L15
        double v15 = v13 * v14;	// L16
        v2[v5] = v15;	// L17
      }
    }
  }
}

void get_delta_matrix_weights1(
  double v0[832],
  double v1[64],
  double v2[13]
) {	// L2




  for (int v3 = 0; v3 < 13; v3 += 1) {	// L3
    for (int v4 = 0; v4 < 4; v4 += 1) {	// L3
#pragma HLS pipeline
      for (int v5 = 0; v5 < 16; v5 += 1) {	// L3
        int v6 = (v5 + (v4 * 16));	// L3
        double v7 = v2[v3];	// L5
        double v8 = v1[v6];	// L6
        double v9 = v7 * v8;	// L7
        v0[(v6 + (v3 * 64))] = v9;	// L8
      }
    }
  }
}

void update_weights(
  double v0[832],
  double v1[4096],
  double v2[192],
  double v3[832],
  double v4[4096],
  double v5[192],
  double v6[64],
  double v7[64],
  double v8[3],
  double v9[64],
  double v10[64],
  double v11[3]
) {	// L2













  double v12[1];	// L5
  v12[0] = 0.000000;	// L6
  double v13[1];	// L7
  v13[0] = 0.000000;	// L8
  double v14[1];	// L11
  double v15[1];	// L13
  for (int v16 = 0; v16 < 13; v16 += 1) {	// L9
    for (int v17 = 0; v17 < 4; v17 += 1) {	// L9
#pragma HLS pipeline
      for (int v18 = 0; v18 < 16; v18 += 1) {	// L9
        int v19 = (v18 + (v17 * 16));	// L9
        double v20 = v12[0];	// L10
        v14[0] = v20;	// L12
        v15[0] = v20;	// L14
        double v21 = v14[0];	// L16
        double v22 = v3[(v19 + (v16 * 64))];	// L17
        double v23 = v22 * 0.010000;	// L18
        double v24 = v0[(v19 + (v16 * 64))];	// L19
        double v25 = v24 - v23;	// L20
        v0[(v19 + (v16 * 64))] = v25;	// L21
        double v26 = v25 * v25;	// L22
        double v27 = v21 + v26;	// L23
        v14[0] = v27;	// L24
        v15[0] = v27;	// L25
        double v28 = v15[0];	// L27
        v12[0] = v28;	// L28
        v13[0] = v28;	// L29
      }
    }
  }
  double v29 = v13[0];	// L31
  double v30[1];	// L32
  v30[0] = 0.000000;	// L33
  double v31[1];	// L34
  v31[0] = 0.000000;	// L35
  for (int v32 = 0; v32 < 8; v32 += 1) {	// L36
#pragma HLS pipeline
    for (int v33 = 0; v33 < 8; v33 += 1) {	// L36
      int v34 = (v33 + (v32 * 8));	// L36
      double v35 = v30[0];	// L37
      double v36 = v9[v34];	// L38
      double v37 = v36 * 0.010000;	// L39
      double v38 = v6[v34];	// L40
      double v39 = v38 - v37;	// L41
      v6[v34] = v39;	// L42
      double v40 = v39 * v39;	// L43
      double v41 = v35 + v40;	// L44
      v30[0] = v41;	// L45
      v31[0] = v41;	// L46
    }
  }
  double v42 = v31[0];	// L48
  double v43 = sqrt(v29);	// L49
  double v44 = sqrt(v42);	// L50
  for (int v45 = 0; v45 < 13; v45 += 1) {	// L51
    for (int v46 = 0; v46 < 4; v46 += 1) {	// L51
#pragma HLS pipeline
      for (int v47 = 0; v47 < 16; v47 += 1) {	// L51
        int v48 = (v47 + (v46 * 16));	// L51
        double v49 = v0[(v48 + (v45 * 64))];	// L53
        double v50 = v49 / v43;	// L54
        v0[(v48 + (v45 * 64))] = v50;	// L55
      }
    }
  }
  for (int v51 = 0; v51 < 8; v51 += 1) {	// L58
#pragma HLS pipeline
    for (int v52 = 0; v52 < 8; v52 += 1) {	// L58
      int v53 = (v52 + (v51 * 8));	// L58
      double v54 = v6[v53];	// L59
      double v55 = v54 / v44;	// L60
      v6[v53] = v55;	// L61
    }
  }
  double v56[1];	// L63
  v56[0] = 0.000000;	// L64
  double v57[1];	// L65
  v57[0] = 0.000000;	// L66
  double v58[1];	// L69
  double v59[1];	// L71
  for (int v60 = 0; v60 < 8; v60 += 1) {	// L67
    for (int v61 = 0; v61 < 4; v61 += 1) {	// L67
#pragma HLS pipeline
      for (int v62 = 0; v62 < 8; v62 += 1) {	// L67
        int v63 = (v62 + (v60 * 8));	// L67
        for (int v64 = 0; v64 < 16; v64 += 1) {	// L67
          int v65 = (v64 + (v61 * 16));	// L67
          double v66 = v56[0];	// L68
          v58[0] = v66;	// L70
          v59[0] = v66;	// L72
          double v67 = v58[0];	// L74
          double v68 = v4[(v65 + (v63 * 64))];	// L75
          double v69 = v68 * 0.010000;	// L76
          double v70 = v1[(v65 + (v63 * 64))];	// L77
          double v71 = v70 - v69;	// L78
          v1[(v65 + (v63 * 64))] = v71;	// L79
          double v72 = v71 * v71;	// L80
          double v73 = v67 + v72;	// L81
          v58[0] = v73;	// L82
          v59[0] = v73;	// L83
          double v74 = v59[0];	// L85
          v56[0] = v74;	// L86
          v57[0] = v74;	// L87
        }
      }
    }
  }
  double v75 = v57[0];	// L89
  double v76[1];	// L90
  v76[0] = 0.000000;	// L91
  double v77[1];	// L92
  v77[0] = 0.000000;	// L93
  for (int v78 = 0; v78 < 8; v78 += 1) {	// L94
#pragma HLS pipeline
    for (int v79 = 0; v79 < 8; v79 += 1) {	// L94
      int v80 = (v79 + (v78 * 8));	// L94
      double v81 = v76[0];	// L95
      double v82 = v10[v80];	// L96
      double v83 = v82 * 0.010000;	// L97
      double v84 = v7[v80];	// L98
      double v85 = v84 - v83;	// L99
      v7[v80] = v85;	// L100
      double v86 = v85 * v85;	// L101
      double v87 = v81 + v86;	// L102
      v76[0] = v87;	// L103
      v77[0] = v87;	// L104
    }
  }
  double v88 = v77[0];	// L106
  double v89 = sqrt(v75);	// L107
  double v90 = sqrt(v88);	// L108
  for (int v91 = 0; v91 < 64; v91 += 1) {	// L109
    for (int v92 = 0; v92 < 4; v92 += 1) {	// L109
#pragma HLS pipeline
      for (int v93 = 0; v93 < 16; v93 += 1) {	// L109
        int v94 = (v93 + (v92 * 16));	// L109
        double v95 = v1[(v94 + (v91 * 64))];	// L111
        double v96 = v95 / v89;	// L112
        v1[(v94 + (v91 * 64))] = v96;	// L113
      }
    }
  }
  for (int v97 = 0; v97 < 8; v97 += 1) {	// L116
#pragma HLS pipeline
    for (int v98 = 0; v98 < 8; v98 += 1) {	// L116
      int v99 = (v98 + (v97 * 8));	// L116
      double v100 = v7[v99];	// L117
      double v101 = v100 / v90;	// L118
      v7[v99] = v101;	// L119
    }
  }
  double v102[1];	// L121
  v102[0] = 0.000000;	// L122
  double v103[1];	// L123
  v103[0] = 0.000000;	// L124
  double v104[1];	// L127
  double v105[1];	// L129
  for (int v106 = 0; v106 < 16; v106 += 1) {	// L125
#pragma HLS pipeline
    for (int v107 = 0; v107 < 4; v107 += 1) {	// L125
      int v108 = (v107 + (v106 * 4));	// L125
      for (int v109 = 0; v109 < 3; v109 += 1) {	// L125
        double v110 = v102[0];	// L126
        v104[0] = v110;	// L128
        v105[0] = v110;	// L130
        double v111 = v104[0];	// L132
        double v112 = v5[(v109 + (v108 * 3))];	// L133
        double v113 = v112 * 0.010000;	// L134
        double v114 = v2[(v109 + (v108 * 3))];	// L135
        double v115 = v114 - v113;	// L136
        v2[(v109 + (v108 * 3))] = v115;	// L137
        double v116 = v115 * v115;	// L138
        double v117 = v111 + v116;	// L139
        v104[0] = v117;	// L140
        v105[0] = v117;	// L141
        double v118 = v105[0];	// L143
        v102[0] = v118;	// L144
        v103[0] = v118;	// L145
      }
    }
  }
  double v119 = v103[0];	// L147
  double v120[1];	// L148
  v120[0] = 0.000000;	// L149
  double v121[1];	// L150
  v121[0] = 0.000000;	// L151
  for (int v122 = 0; v122 < 3; v122 += 1) {	// L152
#pragma HLS pipeline
    double v123 = v120[0];	// L153
    double v124 = v11[v122];	// L154
    double v125 = v124 * 0.010000;	// L155
    double v126 = v8[v122];	// L156
    double v127 = v126 - v125;	// L157
    v8[v122] = v127;	// L158
    double v128 = v127 * v127;	// L159
    double v129 = v123 + v128;	// L160
    v120[0] = v129;	// L161
    v121[0] = v129;	// L162
  }
  double v130 = v121[0];	// L164
  double v131 = sqrt(v119);	// L165
  double v132 = sqrt(v130);	// L166
  for (int v133 = 0; v133 < 8; v133 += 1) {	// L167
#pragma HLS pipeline
    for (int v134 = 0; v134 < 8; v134 += 1) {	// L167
      int v135 = (v134 + (v133 * 8));	// L167
      for (int v136 = 0; v136 < 3; v136 += 1) {	// L167
        double v137 = v2[(v136 + (v135 * 3))];	// L169
        double v138 = v137 / v131;	// L170
        v2[(v136 + (v135 * 3))] = v138;	// L171
      }
    }
  }
  for (int v139 = 0; v139 < 3; v139 += 1) {	// L174
#pragma HLS pipeline
    double v140 = v8[v139];	// L175
    double v141 = v140 / v132;	// L176
    v8[v139] = v141;	// L177
  }
}

void backprop(double weights1[13*64], 
                double weights2[64*64],
                double weights3[64*3],
                double biases1[64], 
                double biases2[64],
                double biases3[3],
                double training_data[163*13],
                double training_targets[163*3]) {
    int i,j;
    //Forward and training structures
    double activations1[64];
    double activations2[64];
    double activations3[3];
    double dactivations1[64];
    double dactivations2[64];
    double dactivations3[3];
    double net_outputs[3];
    //Training structure
    double output_difference[3];
    double delta_weights1[13*64]; 
    double delta_weights2[64*64];
    double delta_weights3[64*3];
    double oracle_activations1[64];
    double oracle_activations2[64];

    Loop39: for(i=0; i<163; i++){
        Loop40: for(j=0;j<64;j++){
            activations1[j] = (double)0.0;
            activations2[j] = (double)0.0;
            if(j<3){
                activations3[j] = (double)0.0;
            }
        }
        matrix_vector_product_with_bias_input_layer(biases1, weights1, activations1, &training_data[i*13]);
        RELU(activations1, dactivations1, 64);
        matrix_vector_product_with_bias_second_layer(biases2, weights2, activations2, activations1);
        RELU(activations2, dactivations2, 64);
        matrix_vector_product_with_bias_output_layer(biases3, weights3, activations3, activations2);
        RELU(activations3, dactivations3, 3);
        soft_max(net_outputs, activations3);
        take_difference(net_outputs, &training_targets[i*3], output_difference, dactivations3);
        get_delta_matrix_weights3(delta_weights3, output_difference, activations2);
        get_oracle_activations2(weights3, output_difference, oracle_activations2, dactivations2);
        get_delta_matrix_weights2(delta_weights2, oracle_activations2, activations1);
        get_oracle_activations1(weights2, oracle_activations2, oracle_activations1, dactivations1);
        get_delta_matrix_weights1(delta_weights1, oracle_activations1, &training_data[i*13]);
        update_weights(weights1, weights2, weights3, delta_weights1, delta_weights2, delta_weights3, 
                       biases1, biases2, biases3, oracle_activations1, oracle_activations2, output_difference);
    }
}