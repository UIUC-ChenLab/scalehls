// RUN: scalehls-opt -scalehls-create-axi-interface %s | FileCheck %s

module {
  // CHECK: func.func @forward_dataflow2(%arg0: memref<1x1x1x64xi8, 3>, %arg1: !hls.stream<i1, 1>, %arg2: memref<1x64x10xi8, 3>, %arg3: memref<1x1x10xi8, 3>, %arg4: !hls.stream<i1, 1>) {
  func.func @forward_dataflow2(%arg0: memref<1x1x1x64xi8>, %arg1: !hls.stream<i1, 1>, %arg2: memref<1x64x10xi8>, %arg3: memref<1x1x10xi8>, %arg4: !hls.stream<i1, 1>) {
    %false = arith.constant false
    %c0_i8 = arith.constant 0 : i8
    "hls.stream.read"(%arg1) : (!hls.stream<i1, 1>) -> ()
    affine.for %arg5 = 0 to 10 {
      affine.store %c0_i8, %arg3[0, 0, %arg5] : memref<1x1x10xi8>
      affine.for %arg6 = 0 to 64 {
        %0 = affine.load %arg0[0, 0, 0, %arg6] : memref<1x1x1x64xi8>
        %1 = affine.load %arg2[0, %arg6, %arg5] : memref<1x64x10xi8>
        %2 = affine.load %arg3[0, 0, %arg5] : memref<1x1x10xi8>
        %3 = arith.muli %0, %1 : i8
        %4 = arith.addi %2, %3 : i8
        affine.store %4, %arg3[0, 0, %arg5] : memref<1x1x10xi8>
      }
    }
    "hls.stream.write"(%arg4, %false) : (!hls.stream<i1, 1>, i1) -> ()
    return
  }

  // CHECK: func.func @forward_dataflow3(%arg0: memref<1x32x32x64xi8, 3>, %arg1: !hls.stream<i1, 1>, %arg2: memref<1x1x1x64xi8, 3>, %arg3: !hls.stream<i1, 1>) {
  func.func @forward_dataflow3(%arg0: memref<1x32x32x64xi8>, %arg1: !hls.stream<i1, 1>, %arg2: memref<1x1x1x64xi8>, %arg3: !hls.stream<i1, 1>) {
    %false = arith.constant false
    %c127_i32 = arith.constant 127 : i32
    %c-128_i32 = arith.constant -128 : i32
    %c0_i32 = arith.constant 0 : i32
    %c536870912_i64 = arith.constant 536870912 : i64
    %c1048576_i64 = arith.constant 1048576 : i64
    %c30_i64 = arith.constant 30 : i64
    %0 = memref.alloc() : memref<1x1x1x1xi32>
    "hls.stream.read"(%arg1) : (!hls.stream<i1, 1>) -> ()
    affine.for %arg4 = 0 to 64 {
      affine.store %c0_i32, %0[0, 0, 0, 0] : memref<1x1x1x1xi32>
      affine.for %arg5 = 0 to 32 {
        affine.for %arg6 = 0 to 32 {
          %12 = affine.load %arg0[0, %arg5, %arg6, %arg4] : memref<1x32x32x64xi8>
          %13 = affine.load %0[0, 0, 0, 0] : memref<1x1x1x1xi32>
          %14 = arith.extsi %12 : i8 to i32
          %15 = arith.addi %13, %14 : i32
          affine.store %15, %0[0, 0, 0, 0] : memref<1x1x1x1xi32>
        }
      }
      %1 = affine.load %0[0, 0, 0, 0] : memref<1x1x1x1xi32>
      %2 = arith.extsi %1 : i32 to i64
      %3 = arith.muli %2, %c1048576_i64 : i64
      %4 = arith.addi %3, %c536870912_i64 : i64
      %5 = arith.shrsi %4, %c30_i64 : i64
      %6 = arith.trunci %5 : i64 to i32
      %7 = arith.cmpi slt, %6, %c-128_i32 : i32
      %8 = arith.select %7, %c-128_i32, %6 : i32
      %9 = arith.cmpi slt, %c127_i32, %6 : i32
      %10 = arith.select %9, %c127_i32, %8 : i32
      %11 = arith.trunci %10 : i32 to i8
      affine.store %11, %arg2[0, 0, 0, %arg4] : memref<1x1x1x64xi8>
    }
    "hls.stream.write"(%arg3, %false) : (!hls.stream<i1, 1>, i1) -> ()
    return
  }

  // CHECK: func.func @forward(%arg0: memref<1x32x32x64xi8, 3>, %arg1: memref<1x64x10xi8, 3>, %arg2: memref<1x1x1x64xi8, 3>, %arg3: memref<1x1x10xi8, 3>) attributes {top_func} {
  func.func @forward(%arg0: memref<1x32x32x64xi8>, %arg4: memref<1x64x10xi8>) attributes {top_func} {
    %9 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>

    // CHECK-NOT: memref.alloc() : memref<1x1x1x64xi8>
    %10 = memref.alloc() : memref<1x1x1x64xi8>
    %11 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>

    // CHECK: call @forward_dataflow3(%arg0, %0, %arg2, %1) : (memref<1x32x32x64xi8, 3>, !hls.stream<i1, 1>, memref<1x1x1x64xi8, 3>, !hls.stream<i1, 1>) -> ()
    call @forward_dataflow3(%arg0, %9, %10, %11) : (memref<1x32x32x64xi8>, !hls.stream<i1, 1>, memref<1x1x1x64xi8>, !hls.stream<i1, 1>) -> ()

    // CHECK-NOT: memref.alloc() : memref<1x1x10xi8>
    %12 = memref.alloc() : memref<1x1x10xi8>
    %13 = "hls.stream.channel"() : () -> !hls.stream<i1, 1>

    // CHECK: call @forward_dataflow2(%arg2, %1, %arg1, %arg3, %2) : (memref<1x1x1x64xi8, 3>, !hls.stream<i1, 1>, memref<1x64x10xi8, 3>, memref<1x1x10xi8, 3>, !hls.stream<i1, 1>) -> ()
    call @forward_dataflow2(%10, %11, %arg4, %12, %13) : (memref<1x1x1x64xi8>, !hls.stream<i1, 1>, memref<1x64x10xi8>, memref<1x1x10xi8>, !hls.stream<i1, 1>) -> ()
    return
  }

  // CHECK: func.func @main(%arg0: memref<1x32x32x64xi8, 3>) attributes {runtime} {
  func.func @main(%arg0: memref<1x32x32x64xi8>) attributes {runtime} {
    %cst_2 = arith.constant dense<1> : tensor<1x64x10xi8>
    %3 = bufferization.to_memref %cst_2 : memref<1x64x10xi8>

    // CHECK: %1 = memref.alloc() : memref<1x1x1x64xi8, 3>
    // CHECK: %2 = memref.alloc() : memref<1x1x10xi8, 3>
    // CHECK: call @forward(%arg0, %0, %1, %2) : (memref<1x32x32x64xi8, 3>, memref<1x64x10xi8, 3>, memref<1x1x1x64xi8, 3>, memref<1x1x10xi8, 3>) -> ()
    call @forward(%arg0, %3) : (memref<1x32x32x64xi8>, memref<1x64x10xi8>) -> ()
    return
  }
}

