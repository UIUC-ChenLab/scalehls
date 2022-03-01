
#include "digitrec_sw.h"

// sw top function
void DigitRec_sw(const DigitType training_set[NUM_TRAINING * DIGIT_WIDTH],
                 const DigitType test_set[NUM_TEST * DIGIT_WIDTH],
                 LabelType results[NUM_TEST]) {

  // nearest neighbor set
  int dists[K_CONST];
  int labels[K_CONST];

  // loop through test set
  for (int t = 0; t < NUM_TEST; ++t) {
    // Initialize the neighbor set
    for (int i = 0; i < K_CONST; ++i) {
      // Note that the max distance is 256
      dists[i] = 256;
      labels[i] = 0;
    }

    // for each training instance, compare it with the test instance, and update
    // the nearest neighbor set
    for (int i = 0; i < NUM_TRAINING; ++i) {
      int dist = 0;

      for (int j = 0; j < DIGIT_WIDTH; j++) {
        DigitType diff =
            test_set[t * DIGIT_WIDTH + j] ^ training_set[i * DIGIT_WIDTH + j];
        // types and constants used in the functions below
        unsigned long long m1 = 0x5555555555555555;
        unsigned long long m2 = 0x3333333333333333;
        unsigned long long m4 = 0x0f0f0f0f0f0f0f0f;

        // source: wikipedia (https://en.wikipedia.org/wiki/Hamming_weight)
        diff -= (diff >> 1) & m1;
        diff = (diff & m2) + ((diff >> 2) & m2);
        diff = (diff + (diff >> 4)) & m4;
        diff += diff >> 8;
        diff += diff >> 16;
        diff += diff >> 32;
        dist += diff & 0x7f;
      }

      int max_dist = 0;
      int max_dist_id = K_CONST + 1;

      // Find the max distance
      for (int k = 0; k < K_CONST; ++k) {
        if (dists[k] > max_dist) {
          max_dist = dists[k];
          max_dist_id = k;
        }
      }

      // Replace the entry with the max distance
      if (dist < max_dist) {
        dists[max_dist_id] = dist;
        labels[max_dist_id] = i / CLASS_SIZE;
      }
    }

    // Compute the final output
    int max_vote = 0;
    LabelType max_label = 0;

    int votes[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

    for (int i = 0; i < K_CONST; i++)
      votes[labels[i]]++;

    for (int i = 0; i < 10; i++) {
      if (votes[i] > max_vote) {
        max_vote = votes[i];
        max_label = i;
      }
    }
    results[t] = max_vote;
  }
}
