// RUN: scalehls-opt -scalehls-convert-dataflow-to-func %s | FileCheck %s

// CHECK: func @forward_node0
// CHECK:   %false = arith.constant false
// CHECK:   "hls.stream.write"
// CHECK:   return
// CHECK: }

// CHECK: func @forward_node1
// CHECK:   "hls.stream.read"
// CHECK:   return
// CHECK: }

module {
  // CHECK: func @forward(%arg0: memref<1x32x32x64xi8>) attributes {top_func} {
  func @forward(%arg0: memref<1x32x32x64xi8>) attributes {top_func} {

    // CHECK: %0 = "hls.prim.buffer"() {depth = 2 : i32} : () -> memref<1x32x32x64xi8>
    // CHECK: %1 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>
    // CHECK: call @forward_node0
    // CHECK: call @forward_node1
    %false = arith.constant false
    %0:2 = hls.dataflow.node() -> memref<1x32x32x64xi8>, !hls.stream<i1, 1> {
      %2 = memref.alloc() {alignment = 128 : i64} : memref<1x32x32x64xi8>
      %3 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>
      "hls.stream.write"(%3, %false) : (!hls.stream<i1, 1>, i1) -> ()
      "hls.dataflow.output"(%2, %3) : (memref<1x32x32x64xi8>, !hls.stream<i1, 1>) -> ()
    }
    %1 = "hls.dataflow.buffer"(%0#0) {depth = 2 : i32} : (memref<1x32x32x64xi8>) -> memref<1x32x32x64xi8>
    hls.dataflow.node() {
      "hls.stream.read"(%0#1) : (!hls.stream<i1, 1>) -> ()
    }

    // CHECK: memref.copy %0, %arg0 : memref<1x32x32x64xi8> to memref<1x32x32x64xi8>
    memref.copy %1, %arg0 : memref<1x32x32x64xi8> to memref<1x32x32x64xi8>
    return
  }
}
