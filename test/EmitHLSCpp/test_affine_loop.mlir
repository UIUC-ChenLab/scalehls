// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

#two = affine_map<(d0)[s0] -> (d0, d0 + s0)>
#three = affine_map<(d0)[s0] -> (d0 - s0, d0, d0 + s0)>

func @test_affine_for(%arg0: memref<16xindex>, %arg1: index) {
  %c11 = arith.constant 11 : index

  // CHECK: for (int v2 = 0; v2 < min(v1, (v1 + 11)); v2 += 2) {
  affine.for %i = 0 to min #two (%arg1)[%c11] step 2 {

    // CHECK: for (int v3 = max(max((v1 - 11), v1), (v1 + 11)); v3 < 16; v3 += 1) {
    affine.for %j = max #three (%arg1)[%c11] to 16 {

      // CHECK: for (int v4 = 0; v4 < 16; v4 += 2) {
      affine.for %k = 0 to 16 step 2 {

        // CHECK: int v5 = v0[v2];
        %0 = memref.load %arg0[%i] : memref<16xindex>

        // CHECK: int v6 = v5 + v3;
        %1 = arith.addi %0, %j : index

        // CHECK: v0[v4] = v6;
        memref.store %1, %arg0[%k] : memref<16xindex>

      // CHECK: }
      }
    // CHECK: }
    }
  // CHECK: }
  }
  return
}

func @test_affine_parallel(%arg0: memref<16xindex>) {

  // CHECK: int v8;
  // CHECK: int v9;
  // CHECK: for (int v10 = 0; v10 < 2; v10 += 1) {
  // CHECK:   for (int v11 = 0; v11 < 4; v11 += 2) {
  // CHECK:     for (int v12 = 0; v12 < 8; v12 += 3) {
  %0:2 = affine.parallel (%x, %y, %z) = (0, 0, 0) to (2, 4, 8) step (1, 2, 3) reduce ("maxs", "addi") -> (index, index){

    // CHECK: int v13 = v7[v10];
    %1 = memref.load %arg0[%x] : memref<16xindex>

    // CHECK: int v14 = v13 + v11;
    %2 = arith.addi %1, %y : index

    // CHECK: int v15 = v14 - v12;
    %3 = arith.subi %2, %z : index

    // CHECK: if (v10 == 0 && v11 == 0 && v12 == 0) {
    // CHECK:   v8 = v14;
    // CHECK:   v9 = v15;
    // CHECK: } else {
    // CHECK:   v8 = max(v8, v14);
    // CHECK:   v9 += v15;
    // CHECK: }
    affine.yield %2, %3 : index, index

  // CHECK:     }
  // CHECK:   }
  // CHECK: }
  }
  return
}
