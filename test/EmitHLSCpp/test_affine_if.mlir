// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

#set0 = affine_set<(d0)[s0]: (d0 + s0 >= 0, d0 * s0 == 0)>

func @test_affine_if(%arg0: index, %arg1: memref<16xindex>) -> index {
  %c11 = constant 11 : index

  // CHECK: int val3;
  // CHECK: int val4[16];
  // CHECK: if ((val0 + 11) >= 0 && (val0 * 11) == 0) {
  %0:2 = affine.if #set0 (%arg0)[%c11] -> (index, memref<16xindex>) {

    // CHECK: val3 = val0;
    // CHECK: for (int idx0 = 0; idx0 < 16; ++idx0) {
    // CHECK:   val4[idx0] = val1[idx0];
    // CHECK: }
    affine.yield %arg0, %arg1 : index, memref<16xindex>

  // CHECK: } else {
  } else {
    affine.yield %arg0, %arg1 : index, memref<16xindex>
  // CHECK: }
  }

  %1 = affine.load %0#1[%c11] : memref<16xindex>
  %2 = addi %0#0, %1 : index
  return %2 : index
}
