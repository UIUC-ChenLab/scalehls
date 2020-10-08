// RUN: scalehls-opt -qor-estimation %s | FileCheck %s

// CHECK-LABEL: func @test_for
func @test_for(%arg0: memref<16x4x4xindex>, %arg1: memref<16x4x4xindex>) attributes {dataflow = false} {
  %array0 = "hlscpp.array"(%arg0) {interface = false, storage = false, partition = false} : (memref<16x4x4xindex>) -> memref<16x4x4xindex>
  %array1 = "hlscpp.array"(%arg1) {interface = false, storage = false, partition = false} : (memref<16x4x4xindex>) -> memref<16x4x4xindex>
  //"hlscpp.array_pragma" (%arg0) {partition=true, partition_type=["cyclic", "cyclic", "cyclic"], partition_factor=[4 : ui32, 2 : ui32, 4 : ui32], storage_type="ram_2p", interface=true, interface_mode="bram"} : (memref<16x4x4xindex>) -> ()
  //"hlscpp.array_pragma" (%arg1) {partition=true, partition_type=["cyclic", "cyclic", "cyclic"], partition_factor=[4 : ui32, 2 : ui32, 4 : ui32], storage_type="ram_2p", interface=true, interface_mode="bram"} : (memref<16x4x4xindex>) -> ()
  affine.for %i = 0 to 16 {
    affine.for %j = 0 to 4 {
      affine.for %k = 0 to 4 {
        %0 = affine.load %array0[%i, %j, %i + %k] : memref<16x4x4xindex>
        %1 = affine.load %array1[%i, %j, %k] : memref<16x4x4xindex>
        %2 = muli %0, %1 : index
        affine.store %2, %array1[%i, %j, %k] : memref<16x4x4xindex>
      } {pipeline = false, unroll = false, flatten = false}
    } {pipeline = true, unroll = false, flatten = false}
  } {pipeline = false, unroll = false, flatten = false}
  return
}
