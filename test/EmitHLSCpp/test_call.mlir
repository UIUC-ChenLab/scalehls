// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @callee(%arg0: index, %arg1: memref<16xindex>) -> (index, index, memref<16xindex>, memref<16xindex>) attributes {top_function = false} {
  // CHECK-NOT: #pragma HLS interface s_axilite port=return bundle=ctrl
  // CHECK-NOT: #pragma HLS interface s_axilite port=val0 bundle=ctrl
  // CHECK-NOT: #pragma HLS interface s_axilite port=val2 bundle=ctrl
  // CHECK-NOT: #pragma HLS interface s_axilite port=val3 bundle=ctrl

  %0 = affine.load %arg1[%arg0] : memref<16xindex>
  %1 = affine.load %arg1[%arg0 + 1] : memref<16xindex>
  %2 = memref.alloc() : memref<16xindex>
  %3 = memref.alloc() : memref<16xindex>
  return %0, %1, %2, %3 : index, index, memref<16xindex>, memref<16xindex>
}

func @test_call(%arg0: index, %arg1: memref<16xindex>) -> (index, memref<16xindex>) attributes {top_function = true} {
  // CHECK: #pragma HLS interface s_axilite port=return bundle=ctrl
  // CHECK: #pragma HLS interface s_axilite port=val6 bundle=ctrl
  // CHECK: #pragma HLS interface s_axilite port=val8 bundle=ctrl

  // CHECK: int val10;
  // CHECK: int val11[16];
  // CHECK: callee(val6, val7, &*val8, &val10, val9, val11);
  %0:4 = call @callee(%arg0, %arg1) : (index, memref<16xindex>) -> (index, index, memref<16xindex>, memref<16xindex>)
  return %0#0, %0#2 : index, memref<16xindex>
}
