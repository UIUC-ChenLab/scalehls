// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

#set0 = affine_set<(d0)[s0]: (d0 + s0 >= 0, d0 * s0 == 0)>

func @test_affine_if(%arg0: index, %arg1: memref<16xindex>) {
  %c11 = constant 11 : index

  // CHECK: int val2;
  // CHECK: int val3[16];
  // CHECK: if ((val0 + 11) >= 0 && (val0 * 11) == 0) {
  %0:2 = affine.if #set0 (%arg0)[%c11] -> (index, memref<16xindex>) {

    // CHECK: val2 = val0;
    // CHECK: for (int idx0 = 0; idx0 < 16; ++idx0) {
    // CHECK:   val3[idx0] = val1[idx0];
    // CHECK: }
    affine.yield %arg0, %arg1 : index, memref<16xindex>

  // CHECK: } else {
  } else {
    affine.yield %arg0, %arg1 : index, memref<16xindex>
  // CHECK: }
  }
  return
}
