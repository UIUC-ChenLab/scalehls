#include "math.h"












void get_delta_matrix_weights1(double delta_weights1[13*64],
                               double output_difference[64],
                               double last_activations[13]) {
    int i, j;
    for( i = 0; i < 13; i++) {
        for( j = 0; j < 64; j++) {
            delta_weights1[i*64 + j] = last_activations[i] * output_difference[j];
        }
    }
}


