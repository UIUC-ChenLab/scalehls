#include "math.h"













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
                    double d_biases3[3],
                    double test) {
    
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
    
    // norm = sqrt(norm);
    // bias_norm = sqrt(bias_norm);
    norm = test;
    bias_norm = test;

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

    // norm = sqrt(norm);
    // bias_norm = sqrt(bias_norm);
    norm = test;
    bias_norm = test;

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

    // norm = sqrt(norm);
    // bias_norm = sqrt(bias_norm);
    norm = test;
    bias_norm = test;

    for(i=0; i < 64; i++){
        for(j = 0; j < 3; j++){
            weights3[i*3 + j] = (weights3[i*3 + j]/norm);
        }
    }
    for(i=0; i < 3; i++){
        biases3[i] = (biases3[i]/bias_norm);
    }
}

