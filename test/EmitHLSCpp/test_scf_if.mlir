// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_scf_if(%arg0: index, %arg1: memref<16xindex>) {
  %c11 = constant 11 : index
  %c0 = constant 0 : index

  // CHECK: int val2 = val0 + 11;
  // CHECK: ap_int<1> val3 = val2 > 0;
  // CHECK: int val4;
  // CHECK: int val5[16];
  // CHECK: if (val3) {
  %add = std.addi %arg0, %c11 : index
  %condition = std.cmpi "sgt", %add, %c0 : index
  %0:2 = scf.if %condition -> (index, memref<16xindex>) {

    // CHECK: val4 = val0;
    // CHECK: for (int idx0 = 0; idx0 < 16; ++idx0) {
    // CHECK:   val5[idx0] = val1[idx0];
    // CHECK: }
    scf.yield %arg0, %arg1 : index, memref<16xindex>

  // CHECK: } else {
  } else {
    scf.yield %arg0, %arg1 : index, memref<16xindex>
  // CHECK: }
  }
  return
}
