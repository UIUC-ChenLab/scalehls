#include "math.h"








void get_delta_matrix_weights3(double delta_weights3[64*3],
                               double output_difference[3],
                               double last_activations[64]) {
    int i, j;
    Loop11: for( i = 0; i < 64; i++) {
        Loop12: for( j = 0; j < 3; j++) {
            delta_weights3[i*3 + j] = last_activations[i] * output_difference[j];
        }
    }
}






