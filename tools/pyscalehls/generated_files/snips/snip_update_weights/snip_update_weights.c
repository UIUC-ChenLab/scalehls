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
                    double d_biases3[3]) {
    int i, j;
    double norm, bias_norm;
    norm = 0.0;
    bias_norm = 0.0;

    Loop21: for(i=0; i < 13; i++){
        Loop22: for(j = 0; j < 64; j++){
            weights1[i*64 + j] -= (d_weights1[i*64 + j] * 0.01);
            norm += weights1[i*64 + j]*weights1[i*64 + j];
        }
    }
    Loop23: for(i=0; i < 64; i++){
        biases1[i] -= (d_biases1[i]*0.01);
        bias_norm += biases1[i]*biases1[i];
    }
    

    Loop24: for(i=0; i < 13; i++){
        Loop25: for(j = 0; j < 64; j++){
            weights1[i*64 + j] = (weights1[i*64 + j]/norm);
        }
    }
    Loop26: for(i=0; i < 64; i++){
        biases1[i] = (biases1[i]/bias_norm);
    }

    norm = (double)0.0;
    bias_norm = (double)0.0;

    Loop27: for(i=0; i < 64; i++){
        Loop28: for(j = 0; j < 64; j++){
            weights2[i*64 + j] -= (d_weights2[i*64 + j] * 0.01);
            norm += weights2[i*64 + j]*weights2[i*64 + j];
        }
    }
    Loop29: for(i=0; i < 64; i++){
        biases2[i] -= (d_biases2[i]*0.01);
        bias_norm += biases2[i]*biases2[i];
    }


    Loop30: for(i=0; i < 64; i++){
        Loop31: for(j = 0; j < 64; j++){
            weights2[i*64 + j] = (weights2[i*64 + j]/norm);
        }
    }
    Loop32: for(i=0; i < 64; i++){
        biases2[i] = (biases2[i]/bias_norm);
    }

    norm = (double)0.0;
    bias_norm = (double)0.0;

    Loop33: for(i=0; i < 64; i++){
        Loop34: for(j = 0; j < 3; j++){
            weights3[i*3 + j] -= (d_weights3[i*3 + j] * 0.01);
            norm += weights3[i*3 + j]*weights3[i*3 + j];
        }
    }
    Loop35: for(i=0; i<3;i++){
        biases3[i] -= d_biases3[i]*0.01;
        bias_norm += biases3[i]*biases3[i];
    }


    Loop36: for(i=0; i < 64; i++){
        Loop37: for(j = 0; j < 3; j++){
            weights3[i*3 + j] = (weights3[i*3 + j]/norm);
        }
    }
    Loop38: for(i=0; i < 3; i++){
        biases3[i] = (biases3[i]/bias_norm);
    }
}
