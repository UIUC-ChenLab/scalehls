void conv5(float input_c5[16][5][5], float c5_output[120], float conv5_weights[120][400], float conv5_bias[120]) {

	//Internal Buffers
    int i, j;
    int co, ci;

    float acc;

    for (co = 0; co < 120; co++) {
        acc = 0;
        for (ci = 0; ci < 16; ci++) {
            for (i = 0; i < 5; i++) {
                for (j = 0; j < 5; j++) {            
                    acc += conv5_weights[co][25 * ci + 5 * i + j] * input_c5[ci][i][j];  //changed code for HLS
                }
            }
        }
        acc = acc + conv5_bias[co];
        c5_output[co] = (acc > 0) ? acc : 0;
    }
}