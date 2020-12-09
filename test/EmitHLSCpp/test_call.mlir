// RUN: scalehls-translate -emit-hlscpp %s | FileCheck %s

func @callee(%arg0: index, %arg1: memref<16xindex>) -> (index, index, memref<16xindex>, memref<16xindex>) {
  %0 = affine.load %arg1[%arg0] : memref<16xindex>
  %1 = affine.load %arg1[%arg0 + 1] : memref<16xindex>
  %2 = alloc() : memref<16xindex>
  %3 = alloc() : memref<16xindex>
  return %0, %1, %2, %3 : index, index, memref<16xindex>, memref<16xindex>
}

func @test_call(%arg0: index, %arg1: memref<16xindex>) -> (index, memref<16xindex>) {

  // CHECK: int val10;
  // CHECK: int val11[16];
  // CHECK: callee(val6, val7, &*val8, &val10, val9, val11);
  %0:4 = call @callee(%arg0, %arg1) : (index, memref<16xindex>) -> (index, index, memref<16xindex>, memref<16xindex>)
  return %0#0, %0#2 : index, memref<16xindex>
}
