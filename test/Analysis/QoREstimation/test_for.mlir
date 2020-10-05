// RUN: scalehls-opt -qor-estimation %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for(%arg0: memref<16x4x4xindex>, %arg1: memref<16x4x4xindex>) {
  "hlscpp.func_pragma" () {dataflow = true} : () -> ()
  "hlscpp.array_pragma" (%arg0) {partition=true, partition_type=["cyclic", "cyclic", "cyclic"], partition_factor=[4 : ui32, 2 : ui32, 4 : ui32], storage_type="ram_2p", interface=true, interface_mode="bram"} : (memref<16x4x4xindex>) -> ()
  "hlscpp.array_pragma" (%arg1) {partition=true, partition_type=["cyclic", "cyclic", "cyclic"], partition_factor=[4 : ui32, 2 : ui32, 4 : ui32], storage_type="ram_2p", interface=true, interface_mode="bram"} : (memref<16x4x4xindex>) -> ()
  affine.for %i = 0 to 16 {
    "hlscpp.loop_pragma" () {unroll_factor=4 : ui32} : () -> ()
    affine.for %j = 0 to 4 {
      "hlscpp.loop_pragma" () {pipeline=true, unroll_factor=2 : ui32} : () -> ()
      affine.for %k = 0 to 4 {
        "hlscpp.loop_pragma" () {unroll_factor=4 : ui32} : () -> ()
        %0 = affine.load %arg0[%i, %j, %k] : memref<16x4x4xindex>
        %1 = affine.load %arg1[%i, %j, %k] : memref<16x4x4xindex>
        %2 = muli %0, %1 : index
        affine.store %2, %arg0[%i, %j, %k] : memref<16x4x4xindex>
      }
    }
  }
  return
}
