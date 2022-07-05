// RUN: scalehls-opt %s -verify-diagnostics

func.func @node0() -> (!hls.stream<i1, 1>) {
  // expected-error @+1 {{'hls.stream.channel' op stream channel is written by multiple ops}}
  %channel = "hls.stream.channel"() : () -> !hls.stream<i1, 1>
  return %channel : !hls.stream<i1, 1>
}

func.func @node1(%channel : !hls.stream<i1, 1>) {
  call @node0() : () -> !hls.stream<i1, 1>
  %false = arith.constant false
  "hls.stream.write"(%channel, %false) : (!hls.stream<i1, 1>, i1) -> ()
  return
}

func.func @dataflow() {
  %channel = call @node0() : () -> !hls.stream<i1, 1>
  call @node1(%channel) : (!hls.stream<i1, 1>) -> ()
  %false = arith.constant false
  "hls.stream.write"(%channel, %false) : (!hls.stream<i1, 1>, i1) -> ()
  return
}
