// RUN: scalehls-translate -scalehls-emit-hlscpp %s | FileCheck %s

#set0 = affine_set<(d0)[s0]: (d0 + s0 >= 0, d0 * s0 == 0)>

func.func @test_affine_if(%arg0: index, %arg1: memref<16xindex>) -> index {
  %c11 = arith.constant 11 : index

  // CHECK: int v3;
  // CHECK: int v4[16];
  // CHECK: if ((v0 + (int)11) >= 0 && (v0 * (int)11) == 0) {
  %0:2 = affine.if #set0 (%arg0)[%c11] -> (index, memref<16xindex>) {

    // CHECK: v3 = v0;
    // CHECK: for (int iv0 = 0; iv0 < 16; ++iv0) {
    // CHECK:   v4[iv0] = v1[iv0];
    // CHECK: }
    affine.yield %arg0, %arg1 : index, memref<16xindex>

  // CHECK: } else {
  } else {
    affine.yield %arg0, %arg1 : index, memref<16xindex>
  // CHECK: }
  }

  %1 = affine.load %0#1[%c11] : memref<16xindex>
  %2 = arith.addi %0#0, %1 : index
  return %2 : index
}
