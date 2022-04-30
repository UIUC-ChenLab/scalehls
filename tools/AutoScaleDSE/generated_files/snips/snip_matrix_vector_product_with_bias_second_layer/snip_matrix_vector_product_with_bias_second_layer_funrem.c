#include "math.h"





void matrix_vector_product_with_bias_second_layer(double biases[64],
                                                 double weights[64*64],
                                                 double activations[64],
                                                 double input_activations[64],
double pla_hold[1] ) {
    int i,j;
    Loop6: for (i = 0; i < 64; i++){
        activations[i] = (double)0.0;
        Loop7: for(j = 0; j < 64; j++){
            activations[i] += weights[i*64 + j] * input_activations[j];
        }
    }
pla_hold[0] = 42.42424242;
}









