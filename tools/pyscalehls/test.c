void test(double biases[64], double weights[13 * 64], double activations[64],
          double input_sample[13]
          
  , float *placeholder) {

  int i, j;
Loop4:
  for (j = 0; j < 64; j++) {
    activations[j] = (double)0.0;
  Loop5:
    for (i = 0; i < 13; i++) {
      activations[j] += weights[j * 13 + i] * input_sample[i];
    }
  }
  input_sample[10] = 1;
  *placeholder = 42.424242;  
  input_sample[11] = 1;
  input_sample[12] = 1;

  
  // add_bias_to_activations(biases, activations, 64);
}