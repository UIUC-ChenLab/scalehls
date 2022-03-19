#include "math.h"







void take_difference(double net_outputs[3], 
                     double solutions[3], 
                     double output_difference[3],
                     double dactivations[3]) {
    int i;
    for( i = 0; i < 3; i++){
        output_difference[i] = (((net_outputs[i]) - solutions[i]) * -1.0) * dactivations[i];
    }
}







