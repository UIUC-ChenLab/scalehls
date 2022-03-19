#include "math.h"











void get_oracle_activations1(double weights2[64*64], 
                             double output_differences[64], 
                             double oracle_activations[64],
                             double dactivations[64]) {
    int i, j;
    for( i = 0; i < 64; i++) {
        oracle_activations[i] = (double)0.0;
        for( j = 0; j < 64; j++) {
            oracle_activations[i] += output_differences[j] * weights2[i*64 + j];
        }
        oracle_activations[i] = oracle_activations[i] * dactivations[i];
    }
}



