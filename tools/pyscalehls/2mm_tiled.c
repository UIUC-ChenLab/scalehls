void kernel_2mm(float v0, float v2[40][50], float v3[40][70],
                float v4[70][50], float v5[50][80],
                float v6[40][80]) { // L2
#pragma HLS array_partition variable = v2 cyclic factor = 10 dim = 1
#pragma HLS array_partition variable = v2 cyclic factor = 10 dim = 2

#pragma HLS array_partition variable = v3 cyclic factor = 5 dim = 1

#pragma HLS array_partition variable = v4 cyclic factor = 10 dim = 2

#pragma HLS array_partition variable = v5 cyclic factor = 10 dim = 2

#pragma HLS array_partition variable = v6 cyclic factor = 10 dim = 1
#pragma HLS array_partition variable = v6 cyclic factor = 10 dim = 2

  for (int v7 = 0; v7 < 70; v7 += 1) {                           // L7
    for (int v8 = 0; v8 < 8; v8 += 1) {                          // L7
      for (int v9 = 0; v9 < 5; v9 += 1) {                        // L7
        for (int v10 = 0; v10 < 5; v10 += 1) {                   // L7
          for (int v11 = 0; v11 < 10; v11 += 1) {                // L7
            v2[(v10 + (v8 * 5))][(v11 + (v9 * 10))] = 0.000000;  // L6
            float v12 = v3[(v10 + (v8 * 5))][v7];                // L8
            float v13 = v0 * v12;                                // L9
            float v14 = v4[v7][(v11 + (v9 * 10))];               // L10
            float v15 = v13 * v14;                               // L11
            float v16 = v2[(v10 + (v8 * 5))][(v11 + (v9 * 10))]; // L12
            float v17 = v16 + v15;                               // L13
            v2[(v10 + (v8 * 5))][(v11 + (v9 * 10))] = v17;       // L14
          }
        }
      }
    }
  }
}

