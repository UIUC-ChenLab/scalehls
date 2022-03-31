// RUN: scalehls-opt -scalehls-convert-copy-to-affine-loops %s | FileCheck %s

module {
  func @forward_node0(%arg0: !hls.stream<i1, 1>, %arg1: memref<1x32x32x64xi8>) {
    %false = arith.constant false
    "hls.stream.write"(%arg0, %false) : (!hls.stream<i1, 1>, i1) -> ()
    return
  }
  func @forward_node1(%arg0: !hls.stream<i1, 1>) {
    "hls.stream.read"(%arg0) : (!hls.stream<i1, 1>) -> ()
    return
  }
  func @forward(%arg0: memref<1x32x32x64xi8>) attributes {top_func} {
    %0 = "hls.prim.buffer"() {depth = 2 : i32} : () -> memref<1x32x32x64xi8>
    %1 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>
    call @forward_node0(%1, %0) : (!hls.stream<i1, 1>, memref<1x32x32x64xi8>) -> ()
    call @forward_node1(%1) : (!hls.stream<i1, 1>) -> ()

    // CHECK: affine.for %arg1 = 0 to 1 {
    // CHECK:   affine.for %arg2 = 0 to 32 {
    // CHECK:     affine.for %arg3 = 0 to 32 {
    // CHECK:       affine.for %arg4 = 0 to 64 {
    // CHECK:         %2 = affine.load %0[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x64xi8>
    // CHECK:         affine.store %2, %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x64xi8>
    // CHECK:       } {point}
    // CHECK:     } {point}
    // CHECK:   } {point}
    // CHECK: } {point}
    memref.copy %0, %arg0 : memref<1x32x32x64xi8> to memref<1x32x32x64xi8>
    return
  }
}
