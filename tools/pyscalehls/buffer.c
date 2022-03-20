#include "math.h"

// Function to compute the dot product of data (feature) vector and parameter
// vector
void dotProduct(
  float v0[1024],
  float v1[1024],
  float *v2
) {	// L2



  float v3[1];	// L4
  v3[0] = 0.000000;	// L5
  float v4[1];	// L6
  v4[0] = 0.000000;	// L7
  for (int v5 = 0; v5 < 16; v5 += 1) {	// L8
    for (int v6 = 0; v6 < 64; v6 += 1) {	// L8
      int v7 = (v6 + (v5 * 64));	// L8
      float v8 = v3[0];	// L9
      float v9 = v0[v7];	// L10
      float v10 = v1[v7];	// L11
      float v11 = v9 * v10;	// L12
      float v12 = v8 + v11;	// L13
      v3[0] = v12;	// L14
      v4[0] = v12;	// L15
    }
  }
  *v2 = v4[0];	// L17
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