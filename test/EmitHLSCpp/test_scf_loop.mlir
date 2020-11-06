// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @test_scf_for(%arg0: memref<16xindex>, %arg1: index) {
  %c11 = constant 11 : index
  %c0 = constant 0 : index
  %c1 = constant 1 : index
  %c2 = constant 2 : index
  %c16 = constant 16 : index

  // CHECK: int val2 = val1 + 11;
  // CHECK: int val3 = val1 - 11;
  %ub = std.addi %arg1, %c11 : index
  %lb = std.subi %arg1, %c11 : index

  // CHECK: for (int val4 = 0; val4 < val2; val4 += 2) {
  scf.for %i = %c0 to %ub step %c2 {

    // CHECK: for (int val5 = val3; val5 < 16; val5 += 1) {
    scf.for %j = %lb to %c16 step %c1 {

      // CHECK: for (int val6 = 0; val6 < 16; val6 += 2) {
      scf.for %k = %c0 to %c16 step %c2 {

        // CHECK: int val7 = val0[val4];
        %0 = load %arg0[%i] : memref<16xindex>

        // CHECK: int val8 = val7 + val5;
        %1 = addi %0, %j : index

        // CHECK: val0[val6] = val8;
        store %1, %arg0[%k] : memref<16xindex>

      // CHECK: }
      }
    // CHECK: }
    }
  // CHECK: }
  }
  return
}
