#include "math.h"




void test(double biases[64],
                                                 double weights[13*64],
                                                 double activations[64],
                                                 double input_sample[13],
float ph0[0] ) {
    int i,j;
    Loop4: for(j = 0; j < 64; j++){
        activations[j] = (double)0.0;
        Loop5: for (i = 0; i < 13; i++){
            activations[j] += weights[j*13 + i] * input_sample[i];
        }
    }
ph0[0] = 42.42424242;
}
