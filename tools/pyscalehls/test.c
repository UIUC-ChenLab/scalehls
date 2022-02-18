void dataflow7(
  float v0,
  float v1[1][64][32][32],
  float v2[64][64][3][3],
  float v3[1][64][32][32],
  float v4[128][64][3][3],
  float v5[1][128][16][16],
  float v6[1][64][32][32]
) {	// L8
  float v7[1][64][34][34];	// L9

  float v11[1][64][32][32];	// L13
  
  for (int v20 = 0; v20 < 64; v20 += 1) {	// L30
    for (int v21 = 0; v21 < 32; v21 += 1) {	// L31
      for (int v22 = 0; v22 < 32; v22 += 1) {	// L32
        for (int v23 = 0; v23 < 64; v23 += 1) {	// L33
          for (int v24 = 0; v24 < 3; v24 += 1) {	// L34
            for (int v25 = 0; v25 < 3; v25 += 1) {	// L35
              float v26 = v7[0][v23][(v21 + v24)][(v22 + v25)];	// L36
              float v27 = v2[v20][v23][v24][v25];	// L37
              float v28 = v11[0][v20][v21][v22];	// L38
              float v29;
              if (v23 == 0 && v24 == 0 && v25 == 0) {	// L39
                v29 = v0;	// L40
              } else {
                v29 = v28;	// L42
              }
              float v30 = v26 * v27;	// L44
              float v31 = v29 + v30;	// L45
              v11[0][v20][v21][v22] = v31;	// L46
            }
          }
        }
      }
    }
  }
  

}

// mlir-clang test.c -function=dataflow7 -memref-fullrank -raise-scf-to-affine -S \
//     | scalehls-opt -dse="top-func=dataflow7 target-spec=scalehls_dse_config.json" -debug-only=scalehls > /dev/null \
//     && scalehls-translate -emit-hlscpp test_gemm_pareto_0.mlir > test_gemm_pareto_0.cpp