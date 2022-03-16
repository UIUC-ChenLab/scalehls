/*===============================================================*/
/*                                                               */
/*                          digitrec.cpp                         */
/*                                                               */
/*             Hardware function for digit recognition           */
/*                                                               */
/*===============================================================*/

#include "../host/typedefs.h"

// popcount function
int popcount(ap_uint<256> x) {
  // most straightforward implementation
  // actually not bad on FPGA
  int cnt = 0;
  for (int i = 0; i < 256; i++)
    cnt = cnt + x[i];

  return cnt;
}

// Given the test instance and a (new) training instance, this
// function maintains/updates an array of K minimum
// distances per training set.
void update_knn(ap_uint<256> test_inst, ap_uint<256> train_inst,
                int min_distances[3]) {

  // Compute the difference using XOR
  ap_uint<256> diff = test_inst ^ train_inst;

  int dist = 0;

  dist = popcount(diff);

  int max_dist = 0;
  int max_dist_id = 3 + 1;
  int k = 0;

// Find the max distance
  for (int k = 0; k < 3; ++k) {
    if (min_distances[k] > max_dist) {
      max_dist = min_distances[k];
      max_dist_id = k;
    }
  }

  // Replace the entry with the max distance
  if (dist < max_dist)
    min_distances[max_dist_id] = dist;

  return;
}

// Given 10xK minimum distance values, this function
// finds the actual K nearest neighbors and determines the
// final output based on the most common int represented by
// these nearest neighbors (i.e., a vote among KNNs).
unsigned knn_vote(int knn_set[40 * 3]) {

  // final K nearest neighbors
  int min_distance_list[3];
  // labels for the K nearest neighbors
  int label_list[3];
  // voting boxes
  int vote_list[10];

  int pos = 1000;

// initialize
  for (int i = 0; i < 3; i++) {
    min_distance_list[i] = 256;
    label_list[i] = 9;
  }

  for (int i = 0; i < 10; i++) {
    vote_list[i] = 0;
  }

// go through all the lanes
// do an insertion sort to keep a sorted neighbor list
  for (int i = 0; i < 40; i++) {
    for (int j = 0; j < 3; j++) {
      pos = 1000;
      for (int r = 0; r < 3; r++) {
        pos = ((knn_set[i * 3 + j] < min_distance_list[r]) && (pos > 3)) ? r : pos;
      }

      for (int r = 3; r > 0; r--) {
        if (r - 1 > pos) {
          min_distance_list[r - 1] = min_distance_list[r - 2];
          label_list[r - 1] = label_list[r - 2];
        } else if (r - 1 == pos) {
          min_distance_list[r - 1] = knn_set[i * 3 + j];
          label_list[r - 1] = i / (40 / 10);
        }
      }
    }
  }

// vote
  for (int i = 0; i < 3; i++) {
    vote_list[label_list[i]] += 1;
  }

  unsigned max_vote;
  max_vote = 0;

// find the maximum value
  for (int i = 0; i < 10; i++) {
    if (vote_list[i] >= vote_list[max_vote]) {
      max_vote = i;
    }
  }

  return max_vote;
}

// top-level hardware function
// since AXIDMA_SIMPLE interface does not support arrays with size more than
// 16384 on interface we call this function twice to transfer data
void DigitRec(ap_uint<256> global_training_set[18000 / 2],
              ap_uint<256> global_test_set[2000],
              unsigned global_results[2000], int run) {

  // This array stores K minimum distances per training set
  int knn_set[40 * 3];

  static ap_uint<256> training_set[18000];
  // to be used in a pragma
  const int unroll_factor = 40;
    unroll_factor dim = 0

  static ap_uint<256> test_set[2000];
  static unsigned results[2000];

  // the first time, just do data transfer and return
  if (run == 0) {
    // copy the training set for the first time
    for (int i = 0; i < 18000 / 2; i++)
      training_set[i] = global_training_set[i];
    return;
  }

  // for the second time
  for (int i = 0; i < 18000 / 2; i++)
    training_set[i + 18000 / 2] = global_training_set[i];
  // copy the test set
  for (int i = 0; i < 2000; i++)
    test_set[i] = global_test_set[i];

// loop through test set
  for (int t = 0; t < 2000; ++t) {
    // fetch one instance
    ap_uint<256> test_instance = test_set[t];

    // Initialize the knn set
    for (int i = 0; i < 3 * 40; ++i) {
      // Note that the max distance is 256
      knn_set[i] = 256;
    }

    for (int i = 0; i < 18000 / 40; ++i) {
      for (int j = 0; j < 40; j++) {
        // Read a new instance from the training set
        ap_uint<256> training_instance = training_set[j * 18000 / 40 + i];

        // Update the KNN set
        update_knn(test_instance, training_instance, &knn_set[j * 3]);
      }
    }
    // Compute the final output
    unsigned max_vote = knn_vote(knn_set);
    results[t] = max_vote;
  }

  // copy the results out
  for (int i = 0; i < 2000; i++)
    global_results[i] = results[i];
}