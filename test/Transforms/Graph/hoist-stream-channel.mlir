// RUN: scalehls-opt -scalehls-hoist-stream-channel %s | FileCheck %s

// CHECK: module {
// CHECK:   func @forward_dataflow5(%arg0: !hlscpp.stream<i1, 1>, %arg1: !hlscpp.stream<i1, 1>, %arg2: !hlscpp.stream<i1, 1>, %arg3: !hlscpp.stream<i1, 1>) {
// CHECK:     %false = arith.constant false
// CHECK:     "hlscpp.stream.read"(%arg1) : (!hlscpp.stream<i1, 1>) -> ()
// CHECK:     "hlscpp.stream.read"(%arg0) : (!hlscpp.stream<i1, 1>) -> ()
// CHECK:     "hlscpp.stream.write"(%arg2, %false) : (!hlscpp.stream<i1, 1>, i1) -> ()
// CHECK:     "hlscpp.stream.write"(%arg3, %false) : (!hlscpp.stream<i1, 1>, i1) -> ()
// CHECK:     return
// CHECK:   }
// CHECK:   func @forward(%arg0: !hlscpp.stream<i1, 1>, %arg1: !hlscpp.stream<i1, 1>) {
// CHECK:     %0 = "hlscpp.stream.channel"() : () -> !hlscpp.stream<i1, 1>
// CHECK:     %1 = "hlscpp.stream.channel"() : () -> !hlscpp.stream<i1, 1>
// CHECK:     call @forward_dataflow5(%arg0, %arg1, %0, %1) : (!hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>) -> ()
// CHECK:     return
// CHECK:   }
// CHECK: }

module {
  func @forward_dataflow5(%arg0: !hlscpp.stream<i1, 1>, %arg1: !hlscpp.stream<i1, 1>) -> (!hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>) {
    %false = arith.constant false
    "hlscpp.stream.read"(%arg0) : (!hlscpp.stream<i1, 1>) -> ()
    %0 = "hlscpp.stream.channel"() : () -> !hlscpp.stream<i1, 1>
    "hlscpp.stream.write"(%0, %false) : (!hlscpp.stream<i1, 1>, i1) -> ()
    %1 = "hlscpp.stream.buffer"(%arg1) : (!hlscpp.stream<i1, 1>) -> !hlscpp.stream<i1, 1>
    return %0, %1 : !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>
  }
  func @forward(%arg0: !hlscpp.stream<i1, 1>, %arg1: !hlscpp.stream<i1, 1>) {
    %0:2 = call @forward_dataflow5(%arg0, %arg1) : (!hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>) -> (!hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>)
    return
  }
}
