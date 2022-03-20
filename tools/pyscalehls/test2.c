#include "math.h"

// Function to compute the dot product of data (feature) vector and parameter
// vector
float dotProduct(float param[1024], float feature[1024]) {
  float result = 0;
  Loop0: for (int i = 0; i < 1024; i++) {
    result += param[i] * feature[i];
  }
  return result;
}

float Sigmoid(float exponent) { 
  return 1.0f / (1.0f + expf(-exponent)); 
}

// Compute the gradient of the cost function
void computeGradient(float grad[1024], float feature[1024], float scale) {
  Loop1: for (int i = 0; i < 1024; i++) {
    grad[i] = scale * feature[i];
  }
}

// Update the parameter vector
void updateParameter(float param[1024], float grad[1024], float scale) {
  Loop2: for (int i = 0; i < 1024; i++) {
    param[i] += scale * grad[i];
  }
}

// top-level function
void SgdLR_sw(float data[1024 * 4500], int label[4500], float theta[1024]) {
  // intermediate variable for storing gradient
  float gradient[1024];

  // main loop
  // runs for multiple epochs
  Loop3: for (int epoch = 0; epoch < 5; epoch++) {
    // in each epoch, go through each training instance in sequence
    Loop4: for (int training_id = 0; training_id < 4500; training_id++) {
      // dot product between parameter vector and data sample
      float dot = dotProduct(theta, &data[1024 * training_id]);
      // sigmoid
      float prob = Sigmoid(dot);
      // compute gradient
      computeGradient(gradient, &data[1024 * training_id],
                      (prob - label[training_id]));
      // update parameter vector
      updateParameter(theta, gradient, -60000);
    }
  }
}