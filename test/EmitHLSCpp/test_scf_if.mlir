// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_scf_if(%arg0: index, %arg1: memref<16xindex>) {
  %c11 = constant 11 : index
  %c0 = constant 0 : index

  // CHECK: int v2 = v0 + 11;
  // CHECK: bool v3 = v2 > 0;
  // CHECK: int v4;
  // CHECK: int v5[16];
  // CHECK: if (v3) {
  %add = std.addi %arg0, %c11 : index
  %condition = std.cmpi "sgt", %add, %c0 : index
  %0:2 = scf.if %condition -> (index, memref<16xindex>) {

    // CHECK: v4 = v0;
    // CHECK: for (int iv0 = 0; iv0 < 16; ++iv0) {
    // CHECK:   v5[iv0] = v1[iv0];
    // CHECK: }
    scf.yield %arg0, %arg1 : index, memref<16xindex>

  // CHECK: } else {
  } else {
    scf.yield %arg0, %arg1 : index, memref<16xindex>
  // CHECK: }
  }
  return
}
