#include "math.h"

void soft_max(
  double v0[3],
  double v1[3]
) {	// L2
  for (int v2 = 0; v2 < 3; v2 += 1) {	// L4
#pragma HLS pipeline
    double v3 = v1[v2];	// L5
    double v4 = -(v3);	// L6
    double v5 = exp(v4);	// L7
    double v6 = double v7 + v5;	// L8
  }
  for (int v8 = 0; v8 < 3; v8 += 1) {	// L11
    double v9 = v1[v8];	// L12
    double v10 = -(v9);	// L13
    double v11 = exp(v10);	// L14
    double v12 = v11 / double v13;	// L15
    v0[v8] = v12;	// L16
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
    for (int v6 = 0; v6 < 13; v6 += 1) {	// L7
#pragma HLS pipeline
      for (int v7 = 0; v7 < 8; v7 += 1) {	// L7
        v2[(v7 + (v5 * 8))] = 0.000000;	// L6
        double v8 = v1[((v6 + (v7 * 13)) + (v5 * 104))];	// L8
        double v9 = v3[v6];	// L9
        double v10 = v8 * v9;	// L10
        double v11 = v2[(v7 + (v5 * 8))];	// L11
        double v12 = v11 + v10;	// L12
        v2[(v7 + (v5 * 8))] = v12;	// L13
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
        v2[v6] = 0.000000;	// L6
        double v8 = v1[(((v6 * 64) + v7) + (v5 * 8))];	// L8
        double v9 = v3[(v7 + (v5 * 8))];	// L9
        double v10 = v8 * v9;	// L10
        double v11 = v2[v6];	// L11
        double v12 = v11 + v10;	// L12
        v2[v6] = v12;	// L13
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
  for (int v5 = 0; v5 < 2; v5 += 1) {	// L7
    for (int v6 = 0; v6 < 32; v6 += 1) {	// L7
#pragma HLS pipeline
      for (int v7 = 0; v7 < 3; v7 += 1) {	// L7
        v2[v7] = 0.000000;	// L6
        double v8 = v1[(((v7 * 64) + v6) + (v5 * 32))];	// L8
        double v9 = v3[(v6 + (v5 * 32))];	// L9
        double v10 = v8 * v9;	// L10
        double v11 = v2[v7];	// L11
        double v12 = v11 + v10;	// L12
        v2[v7] = v12;	// L13
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
  for (int v3 = 0; v3 < 4; v3 += 1) {	// L3
    for (int v4 = 0; v4 < 16; v4 += 1) {	// L3
#pragma HLS pipeline
      for (int v5 = 0; v5 < 3; v5 += 1) {	// L3
        double v6 = v2[(v4 + (v3 * 16))];	// L5
        double v7 = v1[v5];	// L6
        double v8 = v6 * v7;	// L7
        v0[((v5 + (v4 * 3)) + (v3 * 48))] = v8;	// L8
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
  for (int v4 = 0; v4 < 2; v4 += 1) {	// L6
    for (int v5 = 0; v5 < 3; v5 += 1) {	// L6
#pragma HLS pipeline
      for (int v6 = 0; v6 < 32; v6 += 1) {	// L6
        v2[(v6 + (v4 * 32))] = 0.000000;	// L5
        double v7 = v1[v5];	// L7
        double v8 = v0[((v5 + (v6 * 3)) + (v4 * 96))];	// L8
        double v9 = v7 * v8;	// L9
        double v10 = v2[(v6 + (v4 * 32))];	// L10
        double v11 = v10 + v9;	// L11
        v2[(v6 + (v4 * 32))] = v11;	// L12
        double v12 = v2[(v6 + (v4 * 32))];	// L14
        double v13 = v3[(v6 + (v4 * 32))];	// L15
        double v14 = v12 * v13;	// L16
        v2[(v6 + (v4 * 32))] = v14;	// L17
      }
    }
  }
}

void get_delta_matrix_weights2(
  double v0[4096],
  double v1[64],
  double v2[64]
) {	// L2
  for (int v3 = 0; v3 < 32; v3 += 1) {	// L3
    for (int v4 = 0; v4 < 2; v4 += 1) {	// L3
#pragma HLS pipeline
      for (int v5 = 0; v5 < 64; v5 += 1) {	// L3
        double v6 = v2[(v4 + (v3 * 2))];	// L5
        double v7 = v1[v5];	// L6
        double v8 = v6 * v7;	// L7
        v0[((v5 + (v4 * 64)) + (v3 * 128))] = v8;	// L8
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
  for (int v4 = 0; v4 < 2; v4 += 1) {	// L6
    for (int v5 = 0; v5 < 64; v5 += 1) {	// L6
#pragma HLS pipeline
      for (int v6 = 0; v6 < 32; v6 += 1) {	// L6
        v2[v5] = 0.000000;	// L5
        double v7 = v1[(v6 + (v4 * 32))];	// L7
        double v8 = v0[(((v5 * 64) + v6) + (v4 * 32))];	// L8
        double v9 = v7 * v8;	// L9
        double v10 = v2[v5];	// L10
        double v11 = v10 + v9;	// L11
        v2[v5] = v11;	// L12
        double v12 = v2[v5];	// L14
        double v13 = v3[v5];	// L15
        double v14 = v12 * v13;	// L16
        v2[v5] = v14;	// L17
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
    for (int v4 = 0; v4 < 64; v4 += 1) {	// L3
#pragma HLS pipeline
      double v5 = v2[v3];	// L5
      double v6 = v1[v4];	// L6
      double v7 = v5 * v6;	// L7
      v0[(v4 + (v3 * 64))] = v7;	// L8
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
  for (int v12 = 0; v12 < 13; v12 += 1) {	// L5
#pragma HLS pipeline
    for (int v13 = 0; v13 < 64; v13 += 1) {	// L6
      double v14 = v3[(v13 + (v12 * 64))];	// L7
      double v15 = v14 * 0.010000;	// L8
      double v16 = v0[(v13 + (v12 * 64))];	// L9
      double v17 = v16 - v15;	// L10
      v0[(v13 + (v12 * 64))] = v17;	// L11
      double v18 = v17 * v17;	// L12
      double v19 = double v20 + v18;	// L13
    }
  }
  for (int v21 = 0; v21 < 64; v21 += 1) {	// L18
#pragma HLS pipeline
    double v22 = v9[v21];	// L19
    double v23 = v22 * 0.010000;	// L20
    double v24 = v6[v21];	// L21
    double v25 = v24 - v23;	// L22
    v6[v21] = v25;	// L23
    double v26 = v25 * v25;	// L24
    double v27 = double v28 + v26;	// L25
  }
  double v29 = sqrt(double v30);	// L28
  double v31 = sqrt(double v32);	// L29
  for (int v33 = 0; v33 < 13; v33 += 1) {	// L30
    for (int v34 = 0; v34 < 64; v34 += 1) {	// L30
      double v35 = v0[(v34 + (v33 * 64))];	// L32
      double v36 = v35 / v29;	// L33
      v0[(v34 + (v33 * 64))] = v36;	// L34
    }
  }
  for (int v37 = 0; v37 < 2; v37 += 1) {	// L37
#pragma HLS pipeline
    for (int v38 = 0; v38 < 32; v38 += 1) {	// L37
      double v39 = v6[(v38 + (v37 * 32))];	// L38
      double v40 = v39 / v31;	// L39
      v6[(v38 + (v37 * 32))] = v40;	// L40
    }
  }
  for (int v41 = 0; v41 < 64; v41 += 1) {	// L42
#pragma HLS pipeline
    for (int v42 = 0; v42 < 64; v42 += 1) {	// L43
#pragma HLS pipeline
      double v43 = v4[(v42 + (v41 * 64))];	// L44
      double v44 = v43 * 0.010000;	// L45
      double v45 = v1[(v42 + (v41 * 64))];	// L46
      double v46 = v45 - v44;	// L47
      v1[(v42 + (v41 * 64))] = v46;	// L48
      double v47 = v46 * v46;	// L49
      double v48 = double v49 + v47;	// L50
    }
  }
  for (int v50 = 0; v50 < 64; v50 += 1) {	// L55
    double v51 = v10[v50];	// L56
    double v52 = v51 * 0.010000;	// L57
    double v53 = v7[v50];	// L58
    double v54 = v53 - v52;	// L59
    v7[v50] = v54;	// L60
    double v55 = v54 * v54;	// L61
    double v56 = double v57 + v55;	// L62
  }
  double v58 = sqrt(double v59);	// L65
  double v60 = sqrt(double v61);	// L66
  for (int v62 = 0; v62 < 32; v62 += 1) {	// L67
#pragma HLS pipeline
    for (int v63 = 0; v63 < 2; v63 += 1) {	// L67
      for (int v64 = 0; v64 < 64; v64 += 1) {	// L67
        double v65 = v1[((v64 + (v63 * 64)) + (v62 * 128))];	// L69
        double v66 = v65 / v58;	// L70
        v1[((v64 + (v63 * 64)) + (v62 * 128))] = v66;	// L71
      }
    }
  }
  for (int v67 = 0; v67 < 2; v67 += 1) {	// L74
#pragma HLS pipeline
    for (int v68 = 0; v68 < 32; v68 += 1) {	// L74
      double v69 = v7[(v68 + (v67 * 32))];	// L75
      double v70 = v69 / v60;	// L76
      v7[(v68 + (v67 * 32))] = v70;	// L77
    }
  }
  for (int v71 = 0; v71 < 64; v71 += 1) {	// L79
    for (int v72 = 0; v72 < 3; v72 += 1) {	// L80
#pragma HLS pipeline
      double v73 = v5[(v72 + (v71 * 3))];	// L81
      double v74 = v73 * 0.010000;	// L82
      double v75 = v2[(v72 + (v71 * 3))];	// L83
      double v76 = v75 - v74;	// L84
      v2[(v72 + (v71 * 3))] = v76;	// L85
      double v77 = v76 * v76;	// L86
      double v78 = double v79 + v77;	// L87
    }
  }
  for (int v80 = 0; v80 < 3; v80 += 1) {	// L92
#pragma HLS pipeline
    double v81 = v11[v80];	// L93
    double v82 = v81 * 0.010000;	// L94
    double v83 = v8[v80];	// L95
    double v84 = v83 - v82;	// L96
    v8[v80] = v84;	// L97
    double v85 = v84 * v84;	// L98
    double v86 = double v87 + v85;	// L99
  }
  double v88 = sqrt(double v89);	// L102
  double v90 = sqrt(double v91);	// L103
  for (int v92 = 0; v92 < 2; v92 += 1) {	// L104
    for (int v93 = 0; v93 < 32; v93 += 1) {	// L104
      for (int v94 = 0; v94 < 3; v94 += 1) {	// L104
#pragma HLS pipeline
        double v95 = v2[((v94 + (v93 * 3)) + (v92 * 96))];	// L106
        double v96 = v95 / v88;	// L107
        v2[((v94 + (v93 * 3)) + (v92 * 96))] = v96;	// L108
      }
    }
  }
  for (int v97 = 0; v97 < 3; v97 += 1) {	// L111
    double v98 = v8[v97];	// L112
    double v99 = v98 / v90;	// L113
    v8[v97] = v99;	// L114
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