#include "math.h"














void backprop(double weights1[13*64], 
                double weights2[64*64],
                double weights3[64*3],
                double biases1[64], 
                double biases2[64],
                double biases3[3],
                double training_data[163*13],
                double training_targets[163*3],
double pla_hold[14] ) {
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

    Loop39: for(i=0; i<163; i++){
        Loop40: for(j=0;j<64;j++){
            activations1[j] = (double)0.0;
            activations2[j] = (double)0.0;
            if(j<3){
                activations3[j] = (double)0.0;
            }
        }
pla_hold[0] = 42.42424242;
pla_hold[1] = 42.42424242;
pla_hold[2] = 42.42424242;
pla_hold[3] = 42.42424242;
pla_hold[4] = 42.42424242;
pla_hold[5] = 42.42424242;
pla_hold[6] = 42.42424242;
pla_hold[7] = 42.42424242;
pla_hold[8] = 42.42424242;
pla_hold[9] = 42.42424242;
pla_hold[10] = 42.42424242;
pla_hold[11] = 42.42424242;
pla_hold[12] = 42.42424242;
        update_weights(weights1, weights2, weights3, delta_weights1, delta_weights2, delta_weights3, 
                       biases1, biases2, biases3, oracle_activations1, oracle_activations2, output_difference);
    }
}