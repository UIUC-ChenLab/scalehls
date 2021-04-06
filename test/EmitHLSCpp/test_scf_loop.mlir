// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_scf_for(%arg0: memref<16xindex>, %arg1: index) {
  %c11 = constant 11 : index
  %c0 = constant 0 : index
  %c1 = constant 1 : index
  %c2 = constant 2 : index
  %c16 = constant 16 : index

  // CHECK: int v2 = v1 + 11;
  // CHECK: int v3 = v1 - 11;
  %ub = std.addi %arg1, %c11 : index
  %lb = std.subi %arg1, %c11 : index

  // CHECK: for (int v4 = 0; v4 < v2; v4 += 2) {
  scf.for %i = %c0 to %ub step %c2 {

    // CHECK: for (int v5 = v3; v5 < 16; v5 += 1) {
    scf.for %j = %lb to %c16 step %c1 {

      // CHECK: for (int v6 = 0; v6 < 16; v6 += 2) {
      scf.for %k = %c0 to %c16 step %c2 {

        // CHECK: int v7 = v0[v4];
        %0 = memref.load %arg0[%i] : memref<16xindex>

        // CHECK: int v8 = v7 + v5;
        %1 = addi %0, %j : index

        // CHECK: v0[v6] = v8;
        memref.store %1, %arg0[%k] : memref<16xindex>

      // CHECK: }
      }
    // CHECK: }
    }
  // CHECK: }
  }
  return
}
