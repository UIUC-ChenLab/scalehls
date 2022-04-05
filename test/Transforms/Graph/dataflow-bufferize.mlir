// RUN: scalehls-opt -scalehls-dataflow-bufferize %s | FileCheck %s

module {
  func @forward() -> tensor<1x32x32x64xi8> attributes {top_func} {
    // CHECK: %false = arith.constant false
    // CHECK: %0:2 = hls.dataflow.node() -> memref<1x32x32x64xi8>, !hls.stream<i1, 1> {
    // CHECK:   %3 = memref.alloc() {alignment = 128 : i64} : memref<1x32x32x64xi8>
    // CHECK:   %4 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>
    // CHECK:   "hls.stream.write"(%4, %false) : (!hls.stream<i1, 1>, i1) -> ()
    // CHECK:   "hls.dataflow.output"(%3, %4) : (memref<1x32x32x64xi8>, !hls.stream<i1, 1>) -> ()
    // CHECK: }
    %0:2 = hls.dataflow.node() -> tensor<1x32x32x64xi8>, i1 {
      %2 = memref.alloc() {alignment = 128 : i64} : memref<1x32x32x64xi8>
      %3 = bufferization.to_tensor %2 : memref<1x32x32x64xi8>
      %4 = "hls.dataflow.source"() : () -> i1
      "hls.dataflow.output"(%3, %4) : (tensor<1x32x32x64xi8>, i1) -> ()
    }

    // CHECK: %1 = "hls.dataflow.buffer"(%0#0) {depth = 2 : i32} : (memref<1x32x32x64xi8>) -> memref<1x32x32x64xi8>
    // CHECK: %2 = bufferization.to_tensor %1 : memref<1x32x32x64xi8>
    %1 = "hls.dataflow.buffer"(%0#0) {depth = 2 : i32} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    hls.dataflow.node() {

      // CHECK: "hls.stream.read"(%0#1) : (!hls.stream<i1, 1>) -> ()
      "hls.dataflow.sink"(%0#1) : (i1) -> ()
    }
    return %1 : tensor<1x32x32x64xi8>
  }
}
