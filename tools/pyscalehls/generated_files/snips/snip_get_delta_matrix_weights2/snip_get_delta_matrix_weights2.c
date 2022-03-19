#include "math.h"










void get_delta_matrix_weights2(double delta_weights2[64*64],
                               double output_difference[64],
                               double last_activations[64]) {
    int i, j;
    for( i = 0; i < 64; i++) {
        for( j = 0; j < 64; j++) {
            delta_weights2[i*64 + j] = last_activations[i] * output_difference[j];
        }
    }
}




