// *****************************************
// Design Fall 2021 by HyeGang Jun & Chihun Song
// FPGA code of LeNet Convolutional Neural Network
// *****************************************

#include "data.h"
#include "header.h"

// Load input data

void load_input(features input[1][32][32], features input_buf[32][32]) {
    int i, j;
    for (i = 0; i < 32; i++) {
        for (j = 0; j < 32; j++) {
            input_buf[i][j] = input[0][i][j];
        }
    }
}

void convr(features In[150], features Out[16]) {
    int i, j;
    accumulation mul, acc;

    for (i = 0; i < 16; i++) {  //conv
#pragma HLS PIPELINE
        for (j = 0; j < 150; j++) {
            mul = In[j] * conv3_weights[i][j];

            switch (j) {
                case 0:
                    acc = mul;
                    break;
                case 149:
                    acc += mul;
                    acc = acc + conv3_bias[i];
                    Out[i] = (acc > 0) ? acc : 0;
                    break;
                default:
                    acc += mul;
            }
        }
    }
}

void conv1pool2(features input_buf[32][32], features c1p2_output[6][14][14]) {
    int i, j, k;
    int co, h, w, m, n;

    features c1_out[6][28][28];
    accumulation mul, acc;

    // Conv1+relu
    for (co = 0; co < 6; co++) {
        for (h = 0; h < 28; h++) {
            for (w = 0; w < 28; w++) {
#pragma HLS PIPELINE
                for (i = 0; i < 25; i++) {
                    mul = input_buf[h + (i / 5)][w + (i % 5)] * conv1_weights[co][i];

                    if (i == 0) {
                        acc = mul;
                    } else {
                        acc += mul;
                    }

                    if (i == 24) {
                        acc = acc + conv1_bias[co];
                        c1_out[co][h][w] = (acc > 0) ? acc : 0;
                    }
                }
            }
        }
    }

    // Pool2 + relu
    features max_value = 0;

    for (co = 0; co < 6; co++) {
        for (h = 0; h < 14; h++) {
            for (w = 0; w < 14; w++) {
#pragma HLS PIPELINE
                for (i = 0; i < 2; i++) {
                    for (j = 0; j < 2; j++) {
                        if ((i + j) == 0) {
                            max_value = -1000000000000.0;
                        }

                        max_value = (max_value > c1_out[co][h * 2 + i][w * 2 + j]) ? max_value : c1_out[co][h * 2 + i][w * 2 + j];  // changed code for HLS

                        if ((i + j) == 2) {
                            c1p2_output[co][h][w] = (max_value > 0) ? max_value : 0;
                        }
                    }
                }
            }
        }
    }
}

void conv3pool4(features input_c3[6][14][14], features c3p4_output[16][5][5]) {
    //Internal Buffers
    int i, j;
    int ci, co, h, w;

    features cr3_out[16][10][10];
    weights In[150], Out[16];

#pragma HLS ARRAY_PARTITION variable = In cyclic factor = 5 dim = 1
#pragma HLS ARRAY_PARTITION variable = input_c3 cyclic factor = 2 dim = 2
#pragma HLS ARRAY_PARTITION variable = input_c3 cyclic factor = 2 dim = 3

    // Conv3 + relu
    for (h = 0; h < 10; h++) {
        for (w = 0; w < 10; w++) {
            for (ci = 0; ci < 6; ci++) {
#pragma HLS PIPELINE
                for (i = 0; i < 5; i++) {
#pragma HLS PIPELINE
                    for (j = 0; j < 5; j++) {
#pragma HLS PIPELINE
                        In[25 * ci + 5 * i + j] = input_c3[ci][h + i][w + j];
                    }
                }
            }

            convr(In, Out);

            for (i = 0; i < 16; i++) {
                //#pragma HLS PIPELINE off
                cr3_out[i][h][w] = Out[i];
            }
        }
    }

    // Pool4 + relu
    accumulation max_value = 0;

    for (co = 0; co < 16; co++) {
        for (h = 0; h < 5; h++) {
            for (w = 0; w < 5; w++) {
#pragma HLS PIPELINE
                for (i = 0; i < 2; i++) {
                    for (j = 0; j < 2; j++) {
                        if ((i + j) == 0) {
                            max_value = -1000000000000.0;
                        }

                        max_value = (max_value > cr3_out[co][h * 2 + i][w * 2 + j]) ? max_value : cr3_out[co][h * 2 + i][w * 2 + j];  // changed code for HLS

                        if ((i + j) == 2) {
                            c3p4_output[co][h][w] = (max_value > 0) ? max_value : 0;
                        }
                    }
                }
            }
        }
    }
}

void conv5(features input_c5[16][5][5], features c5_output[120]) {

	//Internal Buffers
    int i, j;
    int co, ci;

    accumulation acc;

// Convolution Layer 5
    /*for (co = 0; co < 120; co++) {
        for (ci = 0; ci < 16; ci++) {
//#pragma HLS PIPELINE
            for (i = 0; i < 5; i++) {
                for (j = 0; j < 5; j++) {
                    mul = conv5_weights[co][25 * ci + 5 * i + j] * input_c5[ci][i][j];  //changed code for HLS

                    if ((ci + i + j) == 0) {
                        acc = mul;
                    } else {
                        acc += mul;
                    }

                    if ((ci + i + j) == 23) {
                        acc = acc + conv5_bias[co];
                        c5_output[co] = (acc > 0) ? acc : 0;
                    }
                }
            }
        }
    }*/

    for (co = 0; co < 120; co++) {
        acc = 0;
        for (ci = 0; ci < 16; ci++) {
#pragma HLS PIPELINE
            for (i = 0; i < 5; i++) {
                for (j = 0; j < 5; j++) {            
                    acc += conv5_weights[co][25 * ci + 5 * i + j] * input_c5[ci][i][j];  //changed code for HLS
                }
            }
        }
        acc = acc + conv5_bias[co];
        c5_output[co] = (acc > 0) ? acc : 0;
    }
}

void fc6(features input_fc6[120], features fin_out[10]) {
    //Internal Buffers
    features In[150], Out[16];
    accumulation mul, acc;
    int i, j;

    for (i = 0; i < 10; i++) {  //conv
#pragma HLS PIPELINE
        for (j = 0; j < 120; j++) {
            mul = input_fc6[j] * fc6_weights[i][j];

            switch (j) {
                case 0:
                    acc = mul;
                    break;
                case 119:
                    acc += mul;
                    fin_out[i] = acc + fc6_bias[i];
                    break;
                default:
                    acc += mul;
            }
        }
    }
}

void store_output(features fin_out[10], features output[10]) {
    int i;
    for (i = 0; i < 10; i++) {
        output[i] = fin_out[i];
    }
}

int lenet_accelerator(features input[1][32][32], features output[10]) {
#pragma HLS INTERFACE m_axi depth = 1024 port = input offset = slave bundle = DATA_INPUT  //1*32*32=1024
#pragma HLS INTERFACE m_axi depth = 10 port = output offset = slave bundle = DATA_OUTPUT
#pragma HLS INTERFACE s_axilite register port = return bundle = CTL

    features input_buf[32][32];
    features c1p2_output[6][14][14];
    features c3p4_output[16][5][5];
    features c5_output[120];
    features fin_out[10];

    // Load Data
    load_input(input, input_buf);

    //CONV1 + RE1 + POOL2 + RE2
    conv1pool2(input_buf, c1p2_output);

    //CONV3 + RE3 + POOL4 + RE4
    conv3pool4(c1p2_output, c3p4_output);

    //CONV5	+ RE5
    conv5(c3p4_output, c5_output);
    //conv5_scalehls(c3p4_output, c5_output, conv5_weights, conv5_bias);

    //FC6 + RE6
    fc6(c5_output, fin_out);

    //Store Output
    store_output(fin_out, output);

    return 0;
}
