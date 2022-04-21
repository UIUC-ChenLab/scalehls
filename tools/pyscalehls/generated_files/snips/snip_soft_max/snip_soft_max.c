#include "math.h"

void soft_max(double net_outputs[3], double activations[3]) {
    int i;
    double sum;
    sum = (double) 0.0;

    Loop0: for(i=0; i < 3; i++) {
        sum += exp(-activations[i]);
    }
    Loop1: for(i=0; i < 3; i++) {
        net_outputs[i] = exp(-activations[i])/sum;
    }
}













