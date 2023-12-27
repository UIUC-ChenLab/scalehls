// RUN: scalehls-translate -scalehls-emit-hlscpp %s | FileCheck %s

#two = affine_map<(d0)[s0] -> (d0, d0 + s0)>
#three = affine_map<(d0)[s0] -> (d0 - s0, d0, d0 + s0)>

func.func @test_affine_for(%arg0: memref<16xindex>, %arg1: index) {
  %c11 = arith.constant 11 : index

  // CHECK: for (int v2 = 0; v2 < min(v1, (v1 + (int)11)); v2 += 2) {
  affine.for %i = 0 to min #two (%arg1)[%c11] step 2 {

    // CHECK: for (int v3 = max(max((v1 - (int)11), v1), (v1 + (int)11)); v3 < 16; v3 += 1) {
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
