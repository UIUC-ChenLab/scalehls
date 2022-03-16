// *****************************************
// Design Fall 2021 by HyeGang Jun & Chihun Song
// FPGA code of LeNet Convolutional Neural Network
// *****************************************

#ifndef HEADER_FILE
#define HEADER_FILE

//#include <ap_fixed.h>

typedef float weights;
typedef float features;
typedef float accumulation;

int lenet_accelerator(features input[1][32][32], features output[10]);

void conv5_scalehls(float v0[16][5][5], float v1[120], float v2[120][400], float v3[120]);

#endif
