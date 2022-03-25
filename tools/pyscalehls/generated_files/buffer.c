#include "math.h"

void soft_max(double net_outputs[3], double activations[3]) {
    int i;
    double sum;
    sum = (double) 0.0;

    Loop0: for(i=0; i < 3; i++) {
        sum += exp(-activations[i]);
    }
    Loop1: for(i=0; i < 3; i++) {
        net_outputs[i] = exp(-activations[i])/sum;
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





  for (int v4 = 0; v4 < 8; v4 += 1) {	// L6
    for (int v5 = 0; v5 < 13; v5 += 1) {	// L6
      for (int v6 = 0; v6 < 8; v6 += 1) {	// L6
        int v7 = (v6 + (v4 * 8));	// L6
        v2[v7] = 0.000000;	// L5
        double v8 = v1[(v5 + (v7 * 13))];	// L7
        double v9 = v3[v5];	// L8
        double v10 = v8 * v9;	// L9
        double v11 = v2[v7];	// L10
        double v12 = v11 + v10;	// L11
        v2[v7] = v12;	// L12
      }
    }
  }
}

void matrix_vector_product_with_bias_second_layer(
  double v0[64],
  double v1[4096],
  double v2[64],
  double v3[64]
) {	// L2





  for (int v4 = 0; v4 < 8; v4 += 1) {	// L6
    for (int v5 = 0; v5 < 64; v5 += 1) {	// L6
      for (int v6 = 0; v6 < 8; v6 += 1) {	// L6
        int v7 = (v6 + (v4 * 8));	// L6
        v2[v5] = 0.000000;	// L5
        double v8 = v1[(v7 + (v5 * 64))];	// L7
        double v9 = v3[v7];	// L8
        double v10 = v8 * v9;	// L9
        double v11 = v2[v5];	// L10
        double v12 = v11 + v10;	// L11
        v2[v5] = v12;	// L12
      }
    }
  }
}

void matrix_vector_product_with_bias_output_layer(
  double v0[3],
  double v1[192],
  double v2[3],
  double v3[64]
) {	// L2





  for (int v4 = 0; v4 < 8; v4 += 1) {	// L6
    for (int v5 = 0; v5 < 8; v5 += 1) {	// L6
      int v6 = (v5 + (v4 * 8));	// L6
      for (int v7 = 0; v7 < 3; v7 += 1) {	// L6
        v2[v7] = 0.000000;	// L5
        double v8 = v1[(v6 + (v7 * 64))];	// L7
        double v9 = v3[v6];	// L8
        double v10 = v8 * v9;	// L9
        double v11 = v2[v7];	// L10
        double v12 = v11 + v10;	// L11
        v2[v7] = v12;	// L12
      }
    }
  }
}

void take_difference(
  double v0[3],
  double v1[3],
  double v2[3],
  double v3[3]
) {	// L2





  for (int v4 = 0; v4 < 3; v4 += 1) {	// L4
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
  for (int v43 = 0; v43 < 13; v43 += 1) {	// L49
    for (int v44 = 0; v44 < 4; v44 += 1) {	// L49
      for (int v45 = 0; v45 < 16; v45 += 1) {	// L49
        int v46 = (v45 + (v44 * 16));	// L49
        double v47 = v0[(v46 + (v43 * 64))];	// L51
        double v48 = v47 / v29;	// L52
        v0[(v46 + (v43 * 64))] = v48;	// L53
      }
    }
  }
  for (int v49 = 0; v49 < 8; v49 += 1) {	// L56
    for (int v50 = 0; v50 < 8; v50 += 1) {	// L56
      int v51 = (v50 + (v49 * 8));	// L56
      double v52 = v6[v51];	// L57
      double v53 = v52 / v42;	// L58
      v6[v51] = v53;	// L59
    }
  }
  double v54[1];	// L61
  v54[0] = 0.000000;	// L62
  double v55[1];	// L63
  v55[0] = 0.000000;	// L64
  double v56[1];	// L67
  double v57[1];	// L69
  for (int v58 = 0; v58 < 8; v58 += 1) {	// L65
    for (int v59 = 0; v59 < 4; v59 += 1) {	// L65
      for (int v60 = 0; v60 < 8; v60 += 1) {	// L65
        int v61 = (v60 + (v58 * 8));	// L65
        for (int v62 = 0; v62 < 16; v62 += 1) {	// L65
          int v63 = (v62 + (v59 * 16));	// L65
          double v64 = v54[0];	// L66
          v56[0] = v64;	// L68
          v57[0] = v64;	// L70
          double v65 = v56[0];	// L72
          double v66 = v4[(v63 + (v61 * 64))];	// L73
          double v67 = v66 * 0.010000;	// L74
          double v68 = v1[(v63 + (v61 * 64))];	// L75
          double v69 = v68 - v67;	// L76
          v1[(v63 + (v61 * 64))] = v69;	// L77
          double v70 = v69 * v69;	// L78
          double v71 = v65 + v70;	// L79
          v56[0] = v71;	// L80
          v57[0] = v71;	// L81
          double v72 = v57[0];	// L83
          v54[0] = v72;	// L84
          v55[0] = v72;	// L85
        }
      }
    }
  }
  double v73 = v55[0];	// L87
  double v74[1];	// L88
  v74[0] = 0.000000;	// L89
  double v75[1];	// L90
  v75[0] = 0.000000;	// L91
  for (int v76 = 0; v76 < 8; v76 += 1) {	// L92
    for (int v77 = 0; v77 < 8; v77 += 1) {	// L92
      int v78 = (v77 + (v76 * 8));	// L92
      double v79 = v74[0];	// L93
      double v80 = v10[v78];	// L94
      double v81 = v80 * 0.010000;	// L95
      double v82 = v7[v78];	// L96
      double v83 = v82 - v81;	// L97
      v7[v78] = v83;	// L98
      double v84 = v83 * v83;	// L99
      double v85 = v79 + v84;	// L100
      v74[0] = v85;	// L101
      v75[0] = v85;	// L102
    }
  }
  double v86 = v75[0];	// L104
  for (int v87 = 0; v87 < 64; v87 += 1) {	// L105
    for (int v88 = 0; v88 < 4; v88 += 1) {	// L105
      for (int v89 = 0; v89 < 16; v89 += 1) {	// L105
        int v90 = (v89 + (v88 * 16));	// L105
        double v91 = v1[(v90 + (v87 * 64))];	// L107
        double v92 = v91 / v73;	// L108
        v1[(v90 + (v87 * 64))] = v92;	// L109
      }
    }
  }
  for (int v93 = 0; v93 < 8; v93 += 1) {	// L112
    for (int v94 = 0; v94 < 8; v94 += 1) {	// L112
      int v95 = (v94 + (v93 * 8));	// L112
      double v96 = v7[v95];	// L113
      double v97 = v96 / v86;	// L114
      v7[v95] = v97;	// L115
    }
  }
  double v98[1];	// L117
  v98[0] = 0.000000;	// L118
  double v99[1];	// L119
  v99[0] = 0.000000;	// L120
  double v100[1];	// L123
  double v101[1];	// L125
  for (int v102 = 0; v102 < 16; v102 += 1) {	// L121
    for (int v103 = 0; v103 < 4; v103 += 1) {	// L121
      int v104 = (v103 + (v102 * 4));	// L121
      for (int v105 = 0; v105 < 3; v105 += 1) {	// L121
        double v106 = v98[0];	// L122
        v100[0] = v106;	// L124
        v101[0] = v106;	// L126
        double v107 = v100[0];	// L128
        double v108 = v5[(v105 + (v104 * 3))];	// L129
        double v109 = v108 * 0.010000;	// L130
        double v110 = v2[(v105 + (v104 * 3))];	// L131
        double v111 = v110 - v109;	// L132
        v2[(v105 + (v104 * 3))] = v111;	// L133
        double v112 = v111 * v111;	// L134
        double v113 = v107 + v112;	// L135
        v100[0] = v113;	// L136
        v101[0] = v113;	// L137
        double v114 = v101[0];	// L139
        v98[0] = v114;	// L140
        v99[0] = v114;	// L141
      }
    }
  }
  double v115 = v99[0];	// L143
  double v116[1];	// L144
  v116[0] = 0.000000;	// L145
  double v117[1];	// L146
  v117[0] = 0.000000;	// L147
  for (int v118 = 0; v118 < 3; v118 += 1) {	// L148
    double v119 = v116[0];	// L149
    double v120 = v11[v118];	// L150
    double v121 = v120 * 0.010000;	// L151
    double v122 = v8[v118];	// L152
    double v123 = v122 - v121;	// L153
    v8[v118] = v123;	// L154
    double v124 = v123 * v123;	// L155
    double v125 = v119 + v124;	// L156
    v116[0] = v125;	// L157
    v117[0] = v125;	// L158
  }
  double v126 = v117[0];	// L160
  for (int v127 = 0; v127 < 8; v127 += 1) {	// L161
    for (int v128 = 0; v128 < 8; v128 += 1) {	// L161
      int v129 = (v128 + (v127 * 8));	// L161
      for (int v130 = 0; v130 < 3; v130 += 1) {	// L161
        double v131 = v2[(v130 + (v129 * 3))];	// L163
        double v132 = v131 / v115;	// L164
        v2[(v130 + (v129 * 3))] = v132;	// L165
      }
    }
  }
  for (int v133 = 0; v133 < 3; v133 += 1) {	// L168
    double v134 = v8[v133];	// L169
    double v135 = v134 / v126;	// L170
    v8[v133] = v135;	// L171
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