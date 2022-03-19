#include "math.h"





void matrix_vector_product_with_bias_second_layer(double biases[64],
                                                 double weights[64*64],
                                                 double activations[64],
                                                 double input_activations[64]){
    int i,j;
    for (i = 0; i < 64; i++){
        activations[i] = (double)0.0;
        for(j = 0; j < 64; j++){
            activations[i] += weights[i*64 + j] * input_activations[j];
        }
    }
}









