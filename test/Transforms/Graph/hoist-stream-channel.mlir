// RUN: scalehls-opt -scalehls-hoist-stream-channel %s | FileCheck %s

// CHECK: module {
// CHECK:   func @forward_dataflow5(%arg0: !hls.stream<i1, 1>, %arg1: !hls.stream<i1, 1>, %arg2: !hls.stream<i1, 1>, %arg3: !hls.stream<i1, 1>) {
// CHECK:     %false = arith.constant false
// CHECK:     "hls.stream.read"(%arg1) : (!hls.stream<i1, 1>) -> ()
// CHECK:     "hls.stream.read"(%arg0) : (!hls.stream<i1, 1>) -> ()
// CHECK:     "hls.stream.write"(%arg2, %false) : (!hls.stream<i1, 1>, i1) -> ()
// CHECK:     "hls.stream.write"(%arg3, %false) : (!hls.stream<i1, 1>, i1) -> ()
// CHECK:     return
// CHECK:   }
// CHECK:   func @forward(%arg0: !hls.stream<i1, 1>, %arg1: !hls.stream<i1, 1>) {
// CHECK:     %0 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>
// CHECK:     %1 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>
// CHECK:     call @forward_dataflow5(%arg0, %arg1, %0, %1) : (!hls.stream<i1, 1>, !hls.stream<i1, 1>, !hls.stream<i1, 1>, !hls.stream<i1, 1>) -> ()
// CHECK:     return
// CHECK:   }
// CHECK: }

module {
  func @forward_dataflow5(%arg0: !hls.stream<i1, 1>, %arg1: !hls.stream<i1, 1>) -> (!hls.stream<i1, 1>, !hls.stream<i1, 1>) {
    %false = arith.constant false
    "hls.stream.read"(%arg0) : (!hls.stream<i1, 1>) -> ()
    %0 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>
    "hls.stream.write"(%0, %false) : (!hls.stream<i1, 1>, i1) -> ()
    %1 = "hls.stream.buffer"(%arg1) : (!hls.stream<i1, 1>) -> !hls.stream<i1, 1>
    return %0, %1 : !hls.stream<i1, 1>, !hls.stream<i1, 1>
  }
  func @forward(%arg0: !hls.stream<i1, 1>, %arg1: !hls.stream<i1, 1>) {
    %0:2 = call @forward_dataflow5(%arg0, %arg1) : (!hls.stream<i1, 1>, !hls.stream<i1, 1>) -> (!hls.stream<i1, 1>, !hls.stream<i1, 1>)
    return
  }
}
