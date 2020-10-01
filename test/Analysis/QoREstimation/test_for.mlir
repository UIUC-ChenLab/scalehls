// RUN: scalehls-opt -qor-estimation %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for(%arg0: memref<16xindex>, %arg1: index) {
  %c11 = constant 11 : index

  affine.for %i = 0 to 16 step 2 {
    "hlscpp.loop_pragma" () {II = 1 : ui32, enable_flush = false, rewind = false, off = true, factor = 4 : ui32, region = false, skip_exit_check = true} : () -> ()
    affine.for %j = 0 to 8 {
      "hlscpp.loop_pragma" () {II = 1 : ui32, enable_flush = false, rewind = false, off = false, factor = 1 : ui32, region = false, skip_exit_check = true} : () -> ()
      affine.for %k = 0 to 8 step 2 {
        "hlscpp.loop_pragma" () {II = 1 : ui32, enable_flush = false, rewind = false, off = true, factor = 4 : ui32, region = false, skip_exit_check = true} : () -> ()
        %0 = load %arg0[%i] : memref<16xindex>
        %1 = addi %0, %j : index
        store %1, %arg0[%k] : memref<16xindex>
      }
    }
  }
  return
}
