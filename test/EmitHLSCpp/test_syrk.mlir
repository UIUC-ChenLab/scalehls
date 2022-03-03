// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

// CHECK: /// This is top function.
// CHECK: void test_syrk(
// CHECK:   float v0,
// CHECK:   float v1,
// CHECK:   float v2[16][16],
// CHECK:   float v3[16][16]
// CHECK: ) {
// CHECK:   #pragma HLS interface s_axilite port=return bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v0 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v1 bundle=ctrl
// CHECK:   #pragma HLS interface bram port=v2
// CHECK:   #pragma HLS interface bram port=v3

// CHECK:   #pragma HLS array_partition variable=v2 cyclic factor=2 dim=2
// CHECK:   #pragma HLS resource variable=v2 core=ram_s2p_bram

// CHECK:   #pragma HLS resource variable=v3 core=ram_s2p_bram

// CHECK:   for (int v4 = 0; v4 < 16; v4 += 2) {
// CHECK:     for (int v5 = 0; v5 < 16; v5 += 1) {
// CHECK:       for (int v6 = 0; v6 < 16; v6 += 1) {
// CHECK:         #pragma HLS pipeline II=2
// CHECK:         if ((v5 - v6) >= 0) {
// CHECK:           float v7 = v3[v5][v6];
// CHECK:           float v8 = v1 * v7;
// CHECK:           float v9 = v2[v5][v4];
// CHECK:           float v10 = v2[v6][v4];
// CHECK:           float v11;
// CHECK:           if (v4 == 0) {
// CHECK:             v11 = v8;
// CHECK:           } else {
// CHECK:             v11 = v7;
// CHECK:           }
// CHECK:           float v12 = v0 * v9;
// CHECK:           float v13 = v12 * v10;
// CHECK:           float v14 = v13 + v11;
// CHECK:           float v15 = v2[v5][(v4 + 1)];
// CHECK:           float v16 = v2[v6][(v4 + 1)];
// CHECK:           float v17 = v0 * v15;
// CHECK:           float v18 = v17 * v16;
// CHECK:           float v19 = v18 + v14;
// CHECK:           v3[v5][v6] = v19;
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

#map0 = affine_map<(d0, d1) -> (0, d1 mod 2, d0, d1 floordiv 2)>
#map1 = affine_map<(d0, d1) -> (0, 0, d0, d1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, #map0>, %arg3: memref<16x16xf32, #map1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {
            %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, #map1>
            %1 = arith.mulf %arg1, %0 : f32
            %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, #map0>
            %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, #map0>
            %4 = affine.if #set1(%arg4) -> f32 {
              affine.yield %1 : f32
            } else {
              affine.yield %0 : f32
            }
            %5 = arith.mulf %arg0, %2 : f32
            %6 = arith.mulf %5, %3 : f32
            %7 = arith.addf %6, %4 : f32
            %8 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, #map0>
            %9 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, #map0>
            %10 = arith.mulf %arg0, %8 : f32
            %11 = arith.mulf %10, %9 : f32
            %12 = arith.addf %11, %7 : f32
            affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32, #map1>
          }
        } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>}
      } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}
