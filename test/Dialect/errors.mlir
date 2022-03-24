// RUN: scalehls-opt %s -verify-diagnostics

func @node0() -> (!hlscpp.stream<i1, 1>) {
  // expected-error @+1 {{'hlscpp.stream.channel' op stream channel is written by multiple ops}}
  %channel = "hlscpp.stream.channel"() : () -> !hlscpp.stream<i1, 1>
  return %channel : !hlscpp.stream<i1, 1>
}

func @node1(%channel : !hlscpp.stream<i1, 1>) {
  call @node0() : () -> !hlscpp.stream<i1, 1>
  %false = arith.constant false
  "hlscpp.stream.write"(%channel, %false) : (!hlscpp.stream<i1, 1>, i1) -> ()
  return
}

func @dataflow() {
  %channel = call @node0() : () -> !hlscpp.stream<i1, 1>
  call @node1(%channel) : (!hlscpp.stream<i1, 1>) -> ()
  %false = arith.constant false
  "hlscpp.stream.write"(%channel, %false) : (!hlscpp.stream<i1, 1>, i1) -> ()
  return
}
