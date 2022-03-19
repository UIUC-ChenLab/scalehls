#include "math.h"




void matrix_vector_product_with_bias_input_layer(double biases[64],
                                                 double weights[13*64],
                                                 double activations[64],
                                                 double input_sample[13]){
    int i,j;
    for(j = 0; j < 64; j++){
        activations[j] = (double)0.0;
        for (i = 0; i < 13; i++){
            activations[j] += weights[j*13 + i] * input_sample[i];
        }
    }
}










