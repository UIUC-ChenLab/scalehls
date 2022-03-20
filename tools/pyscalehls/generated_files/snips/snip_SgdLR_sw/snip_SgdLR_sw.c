#include "math.h"

// Function to compute the dot product of data (feature) vector and parameter
// vector


// Compute the gradient of the cost function

// Update the parameter vector

// top-level function
void SgdLR_sw(float data[1024 * 4500], int label[4500], float theta[1024]) {
  float gradient[1024];

  // main loop
  Loop3: for (int epoch = 0; epoch < 5; epoch++) {
    // in each epoch, go through each training instance in sequence
    Loop4: for (int training_id = 0; training_id < 4500; training_id++) {
      // dot product between parameter vector and data sample
      // sigmoid
      // compute gradient
                      (prob - label[training_id]));
      // update parameter vector
    }
  }
}