// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

#two = affine_map<(d0)[s0] -> (d0, d0 + s0)>
#three = affine_map<(d0)[s0] -> (d0 - s0, d0, d0 + s0)>

func @test_affine_for(%arg0: memref<16xindex>, %arg1: index) {
  %c11 = constant 11 : index

  // CHECK: for (int val2 = 0; val2 < min(val1, (val1 + 11)); val2 += 2) {
  affine.for %i = 0 to min #two (%arg1)[%c11] step 2 {

    // CHECK: for (int val3 = max(max((val1 - 11), val1), (val1 + 11)); val3 < 16; val3 += 1) {
    affine.for %j = max #three (%arg1)[%c11] to 16 {

      // CHECK: for (int val4 = 0; val4 < 16; val4 += 2) {
      affine.for %k = 0 to 16 step 2 {

        // CHECK: int val5 = val0[val2];
        %0 = memref.load %arg0[%i] : memref<16xindex>

        // CHECK: int val6 = val5 + val3;
        %1 = addi %0, %j : index

        // CHECK: val0[val4] = val6;
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

  // CHECK: int val8;
  // CHECK: int val9;
  // CHECK: for (int val10 = 0; val10 < 2; val10 += 1) {
  // CHECK:   for (int val11 = 0; val11 < 4; val11 += 2) {
  // CHECK:     for (int val12 = 0; val12 < 8; val12 += 3) {
  %0:2 = affine.parallel (%x, %y, %z) = (0, 0, 0) to (2, 4, 8) step (1, 2, 3) reduce ("maxs", "addi") -> (index, index){

    // CHECK: int val13 = val7[val10];
    %1 = memref.load %arg0[%x] : memref<16xindex>

    // CHECK: int val14 = val13 + val11;
    %2 = addi %1, %y : index

    // CHECK: int val15 = val14 - val12;
    %3 = subi %2, %z : index

    // CHECK: if (val10 == 0 && val11 == 0 && val12 == 0) {
    // CHECK:   val8 = val14;
    // CHECK:   val9 = val15;
    // CHECK: } else {
    // CHECK:   val8 = max(val8, val14);
    // CHECK:   val9 += val15;
    // CHECK: }
    affine.yield %2, %3 : index, index

  // CHECK:     }
  // CHECK:   }
  // CHECK: }
  }
  return
}
