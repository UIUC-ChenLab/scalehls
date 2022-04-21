#include "math.h"






void matrix_vector_product_with_bias_output_layer(double biases[3],
                                                 double weights[64*3],
                                                 double activations[3],
                                                 double input_activations[64]){
    int i, j;
    Loop8: for(j = 0; j < 3; j++){
        activations[j] = (double)0.0;
        Loop9: for (i = 0; i < 64; i++){
            activations[j] += weights[j*64 + i] * input_activations[i];
        }
    }
    add_bias_to_activations(biases, activations, 3);
}








