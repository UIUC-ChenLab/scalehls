#include "math.h"

// Function to compute the dot product of data (feature) vector and parameter
// vector


// Compute the gradient of the cost function

// Update the parameter vector
void updateParameter(float param[1024], float grad[1024], float scale) {
  Loop2: for (int i = 0; i < 1024; i++) {
    param[i] += scale * grad[i];
  }
}

// top-level function
