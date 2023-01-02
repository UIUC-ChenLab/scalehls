// RUN: scalehls-translate -scalehls-emit-hlscpp %s | FileCheck %s

func.func @callee(%arg0: index, %arg1: memref<16xindex>) -> (index, index, memref<16xindex>, memref<16xindex>) attributes {func_directive = #hls.func<pipeline = false, target_interval = 1, dataflow = false>} {
  // CHECK-NOT: #pragma HLS interface s_axilite port=return bundle=ctrl
  // CHECK-NOT: #pragma HLS interface s_axilite port=v0 bundle=ctrl
  // CHECK-NOT: #pragma HLS interface s_axilite port=v2 bundle=ctrl
  // CHECK-NOT: #pragma HLS interface s_axilite port=v3 bundle=ctrl

  %0 = affine.load %arg1[%arg0] : memref<16xindex>
  %1 = affine.load %arg1[%arg0 + 1] : memref<16xindex>
  %2 = memref.alloc() : memref<16xindex>
  %3 = memref.alloc() : memref<16xindex>
  return %0, %1, %2, %3 : index, index, memref<16xindex>, memref<16xindex>
}

func.func @test_call(%arg0: index, %arg1: memref<16xindex>) -> (index, memref<16xindex>) attributes {func_directive = #hls.func<pipeline = false, target_interval = 1, dataflow = false>, top_func} {
  // CHECK: #pragma HLS interface s_axilite port=return bundle=ctrl
  // CHECK: #pragma HLS interface s_axilite port=v6 bundle=ctrl
  // CHECK: #pragma HLS interface s_axilite port=v8 bundle=ctrl

  // CHECK: int v10;
  // CHECK: int v11[16];
  // CHECK: callee(v6, v7, &*v8, &v10, v9, v11);
  %0:4 = call @callee(%arg0, %arg1) : (index, memref<16xindex>) -> (index, index, memref<16xindex>, memref<16xindex>)
  return %0#0, %0#2 : index, memref<16xindex>
}
