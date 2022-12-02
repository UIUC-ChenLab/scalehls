// RUN: scalehls-translate -scalehls-emit-hlscpp %s | FileCheck %s

#map0 = affine_map<(d0, d1) -> (0, d1 mod 2, d0, d1 floordiv 2)>
#map1 = affine_map<(d0, d1) -> (0, 0, d0, d1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, #map0>, %arg3: memref<16x16xf32, #map1>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
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
        } {loop_directive = #hls.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}

// CHECK: #include <algorithm>
// CHECK: #include <ap_axi_sdata.h>
// CHECK: #include <ap_fixed.h>
// CHECK: #include <ap_int.h>
// CHECK: #include <hls_math.h>
// CHECK: #include <hls_stream.h>
// CHECK: #include <math.h>
// CHECK: #include <stdint.h>
// CHECK: #include <string.h>

// CHECK: using namespace std;

// CHECK: /// This is top function.
// CHECK: void test_syrk(
// CHECK:   float v0,
// CHECK:   float v1,
// CHECK:   float v2[16][16],
// CHECK:   float v3[16][16]
// CHECK: ) {	// L8
// CHECK:   #pragma HLS interface s_axilite port=return bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v0 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v1 bundle=ctrl
// CHECK:   #pragma HLS array_partition variable=v2 cyclic factor=2 dim=2
// CHECK:   #pragma HLS resource variable=v2 core=ram_t2p_bram

// CHECK:   #pragma HLS resource variable=v3 core=ram_t2p_bram

// CHECK:   for (int v4 = 0; v4 < 16; v4 += 2) {	// L9
// CHECK:     for (int v5 = 0; v5 < 16; v5 += 1) {	// L10
// CHECK:       for (int v6 = 0; v6 < 16; v6 += 1) {	// L11
// CHECK:         #pragma HLS pipeline II=2
// CHECK:         if ((v5 - v6) >= 0) {	// L12
// CHECK:           float v7 = v3[v5][v6];	// L13
// CHECK:           float v8 = v1 * v7;	// L14
// CHECK:           float v9 = v2[v5][v4];	// L15
// CHECK:           float v10 = v2[v6][v4];	// L16
// CHECK:           float v11;
// CHECK:           if (v4 == 0) {	// L17
// CHECK:             v11 = v8;	// L18
// CHECK:           } else {
// CHECK:             v11 = v7;	// L20
// CHECK:           }
// CHECK:           float v12 = v0 * v9;	// L22
// CHECK:           float v13 = v12 * v10;	// L23
// CHECK:           float v14 = v13 + v11;	// L24
// CHECK:           float v15 = v2[v5][(v4 + 1)];	// L25
// CHECK:           float v16 = v2[v6][(v4 + 1)];	// L26
// CHECK:           float v17 = v0 * v15;	// L27
// CHECK:           float v18 = v17 * v16;	// L28
// CHECK:           float v19 = v18 + v14;	// L29
// CHECK:           v3[v5][v6] = v19;	// L30
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }
