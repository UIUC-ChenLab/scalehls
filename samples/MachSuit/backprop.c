#include "math.h"

void soft_max(double net_outputs[3], double activations[3]) {
    int i;
    double sum;
    sum = (double) 0.0;

    for(i=0; i < 3; i++) {
        sum += exp(-activations[i]);
    }
    for(i=0; i < 3; i++) {
        net_outputs[i] = exp(-activations[i])/sum;
    }
}

void RELU(double activations[64], double dactivations[64], int size) {
    int i;
    for( i = 0; i < size; i++) {
        dactivations[i] = activations[i]*(1.0-activations[i]);
        activations[i] = 1.0/(1.0+exp(-activations[i]));
    }
}

void add_bias_to_activations(double biases[64], 
                               double activations[64],
                               int size) {
    int i;
    for( i = 0; i < size; i++){
        activations[i] = activations[i] + biases[i];
    }
}

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
    add_bias_to_activations(biases, activations, 64);
}

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
    add_bias_to_activations(biases, activations, 64);
}

void matrix_vector_product_with_bias_output_layer(double biases[3],
                                                 double weights[64*3],
                                                 double activations[3],
                                                 double input_activations[64]){
    int i, j;
    for(j = 0; j < 3; j++){
        activations[j] = (double)0.0;
        for (i = 0; i < 64; i++){
            activations[j] += weights[j*64 + i] * input_activations[i];
        }
    }
    add_bias_to_activations(biases, activations, 3);
}

void take_difference(double net_outputs[3], 
                     double solutions[3], 
                     double output_difference[3],
                     double dactivations[3]) {
    int i;
    for( i = 0; i < 3; i++){
        output_difference[i] = (((net_outputs[i]) - solutions[i]) * -1.0) * dactivations[i];
    }
}

void get_delta_matrix_weights3(double delta_weights3[64*3],
                               double output_difference[3],
                               double last_activations[64]) {
    int i, j;
    for( i = 0; i < 64; i++) {
        for( j = 0; j < 3; j++) {
            delta_weights3[i*3 + j] = last_activations[i] * output_difference[j];
        }
    }
}

void get_oracle_activations2(double weights3[64*3], 
                             double output_differences[3], 
                             double oracle_activations[64],
                             double dactivations[64]) {
    int i, j;
    for( i = 0; i < 64; i++) {
        oracle_activations[i] = (double)0.0;
        for( j = 0; j < 3; j++) {
            oracle_activations[i] += output_differences[j] * weights3[i*3 + j];
        }
        oracle_activations[i] = oracle_activations[i] * dactivations[i];
    }
}

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

void update_weights(double weights1[13*64],
                    double weights2[64*64],
                    double weights3[64*3],
                    double d_weights1[13*64],
                    double d_weights2[64*64],
                    double d_weights3[64*3],
                    double biases1[64],
                    double biases2[64],
                    double biases3[3],
                    double d_biases1[64],
                    double d_biases2[64],
                    double d_biases3[3]) {
    int i, j;
    double norm, bias_norm;
    norm = 0.0;
    bias_norm = 0.0;

    for(i=0; i < 13; i++){
        for(j = 0; j < 64; j++){
            weights1[i*64 + j] -= (d_weights1[i*64 + j] * 0.01);
            norm += weights1[i*64 + j]*weights1[i*64 + j];
        }
    }
    for(i=0; i < 64; i++){
        biases1[i] -= (d_biases1[i]*0.01);
        bias_norm += biases1[i]*biases1[i];
    }
    
    norm = sqrt(norm);
    bias_norm = sqrt(bias_norm);

    for(i=0; i < 13; i++){
        for(j = 0; j < 64; j++){
            weights1[i*64 + j] = (weights1[i*64 + j]/norm);
        }
    }
    for(i=0; i < 64; i++){
        biases1[i] = (biases1[i]/bias_norm);
    }

    norm = (double)0.0;
    bias_norm = (double)0.0;

    for(i=0; i < 64; i++){
        for(j = 0; j < 64; j++){
            weights2[i*64 + j] -= (d_weights2[i*64 + j] * 0.01);
            norm += weights2[i*64 + j]*weights2[i*64 + j];
        }
    }
    for(i=0; i < 64; i++){
        biases2[i] -= (d_biases2[i]*0.01);
        bias_norm += biases2[i]*biases2[i];
    }

    norm = sqrt(norm);
    bias_norm = sqrt(bias_norm);

    for(i=0; i < 64; i++){
        for(j = 0; j < 64; j++){
            weights2[i*64 + j] = (weights2[i*64 + j]/norm);
        }
    }
    for(i=0; i < 64; i++){
        biases2[i] = (biases2[i]/bias_norm);
    }

    norm = (double)0.0;
    bias_norm = (double)0.0;

    for(i=0; i < 64; i++){
        for(j = 0; j < 3; j++){
            weights3[i*3 + j] -= (d_weights3[i*3 + j] * 0.01);
            norm += weights3[i*3 + j]*weights3[i*3 + j];
        }
    }
    for(i=0; i<3;i++){
        biases3[i] -= d_biases3[i]*0.01;
        bias_norm += biases3[i]*biases3[i];
    }

    norm = sqrt(norm);
    bias_norm = sqrt(bias_norm);

    for(i=0; i < 64; i++){
        for(j = 0; j < 3; j++){
            weights3[i*3 + j] = (weights3[i*3 + j]/norm);
        }
    }
    for(i=0; i < 3; i++){
        biases3[i] = (biases3[i]/bias_norm);
    }
}

void backprop(double weights1[13*64], 
                double weights2[64*64],
                double weights3[64*3],
                double biases1[64], 
                double biases2[64],
                double biases3[3],
                double training_data[163*13],
                double training_targets[163*3]) {
    int i,j;
    //Forward and training structures
    double activations1[64];
    double activations2[64];
    double activations3[3];
    double dactivations1[64];
    double dactivations2[64];
    double dactivations3[3];
    double net_outputs[3];
    //Training structure
    double output_difference[3];
    double delta_weights1[13*64]; 
    double delta_weights2[64*64];
    double delta_weights3[64*3];
    double oracle_activations1[64];
    double oracle_activations2[64];

    for(i=0; i<163; i++){
        for(j=0;j<64;j++){
            activations1[j] = (double)0.0;
            activations2[j] = (double)0.0;
            if(j<3){
                activations3[j] = (double)0.0;
            }
        }
        matrix_vector_product_with_bias_input_layer(biases1, weights1, activations1, &training_data[i*13]);
        RELU(activations1, dactivations1, 64);
        matrix_vector_product_with_bias_second_layer(biases2, weights2, activations2, activations1);
        RELU(activations2, dactivations2, 64);
        matrix_vector_product_with_bias_output_layer(biases3, weights3, activations3, activations2);
        RELU(activations3, dactivations3, 3);
        soft_max(net_outputs, activations3);
        take_difference(net_outputs, &training_targets[i*3], output_difference, dactivations3);
        get_delta_matrix_weights3(delta_weights3, output_difference, activations2);
        get_oracle_activations2(weights3, output_difference, oracle_activations2, dactivations2);
        get_delta_matrix_weights2(delta_weights2, oracle_activations2, activations1);
        get_oracle_activations1(weights2, oracle_activations2, oracle_activations1, dactivations1);
        get_delta_matrix_weights1(delta_weights1, oracle_activations1, &training_data[i*13]);
        update_weights(weights1, weights2, weights3, delta_weights1, delta_weights2, delta_weights3, 
                       biases1, biases2, biases3, oracle_activations1, oracle_activations2, output_difference);
    }
}