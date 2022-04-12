func @matrix_vector_product_with_bias_output_layer(%arg0: memref<3xf64>, %arg1: memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>, %arg2: memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg4: memref<1xf64, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=5, bram=0>, timing = #hlscpp.t<0 -> 355, 355, 355>} {
  %cst = arith.constant {timing = #hlscpp.t<352 -> 352, 0, 0>} 42.424242419999999 : f64
  %cst_0 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg5 = 0 to 8 {
    %0 = affine.load %arg1[%arg5 * 8] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %1 = affine.load %arg3[%arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<2 -> 4, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f64
    %3 = affine.load %arg2[0] {partition_indices = [0], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %4 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f64 {
      affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %cst_0 : f64
    } else {
      affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %3 : f64
    } {timing = #hlscpp.t<8 -> 8, 0, 0>}
    %5 = arith.addf %4, %2 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f64
    %6 = affine.load %arg1[%arg5 * 8 + 64] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<1 -> 3, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %7 = arith.mulf %6, %1 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f64
    %8 = affine.load %arg2[1] {partition_indices = [1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %9 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f64 {
      affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %cst_0 : f64
    } else {
      affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %8 : f64
    } {timing = #hlscpp.t<8 -> 8, 0, 0>}
    %10 = arith.addf %9, %7 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f64
    %11 = affine.load %arg1[%arg5 * 8 + 128] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<2 -> 4, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %12 = arith.mulf %11, %1 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f64
    %13 = affine.load %arg2[2] {partition_indices = [2], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %14 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f64 {
      affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %cst_0 : f64
    } else {
      affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %13 : f64
    } {timing = #hlscpp.t<8 -> 8, 0, 0>}
    %15 = arith.addf %14, %12 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f64
    %16 = affine.load %arg1[%arg5 * 8 + 1] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %17 = affine.load %arg3[%arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %18 = arith.mulf %16, %17 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f64
    %19 = arith.addf %5, %18 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f64
    %20 = affine.load %arg1[%arg5 * 8 + 65] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %21 = arith.mulf %20, %17 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f64
    %22 = arith.addf %10, %21 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f64
    %23 = affine.load %arg1[%arg5 * 8 + 129] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %24 = arith.mulf %23, %17 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f64
    %25 = arith.addf %15, %24 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f64
    %26 = affine.load %arg1[%arg5 * 8 + 2] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %27 = affine.load %arg3[%arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<12 -> 14, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %28 = arith.mulf %26, %27 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f64
    %29 = arith.addf %19, %28 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f64
    %30 = affine.load %arg1[%arg5 * 8 + 66] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<11 -> 13, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %31 = arith.mulf %30, %27 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f64
    %32 = arith.addf %22, %31 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f64
    %33 = affine.load %arg1[%arg5 * 8 + 130] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<12 -> 14, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %34 = arith.mulf %33, %27 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f64
    %35 = arith.addf %25, %34 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f64
    %36 = affine.load %arg1[%arg5 * 8 + 3] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %37 = affine.load %arg3[%arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<17 -> 19, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %38 = arith.mulf %36, %37 {timing = #hlscpp.t<19 -> 23, 4, 1>} : f64
    %39 = arith.addf %29, %38 {timing = #hlscpp.t<23 -> 28, 5, 1>} : f64
    %40 = affine.load %arg1[%arg5 * 8 + 67] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<16 -> 18, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %41 = arith.mulf %40, %37 {timing = #hlscpp.t<19 -> 23, 4, 1>} : f64
    %42 = arith.addf %32, %41 {timing = #hlscpp.t<23 -> 28, 5, 1>} : f64
    %43 = affine.load %arg1[%arg5 * 8 + 131] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<17 -> 19, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %44 = arith.mulf %43, %37 {timing = #hlscpp.t<19 -> 23, 4, 1>} : f64
    %45 = arith.addf %35, %44 {timing = #hlscpp.t<23 -> 28, 5, 1>} : f64
    %46 = affine.load %arg1[%arg5 * 8 + 4] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %47 = affine.load %arg3[%arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<22 -> 24, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %48 = arith.mulf %46, %47 {timing = #hlscpp.t<24 -> 28, 4, 1>} : f64
    %49 = arith.addf %39, %48 {timing = #hlscpp.t<28 -> 33, 5, 1>} : f64
    %50 = affine.load %arg1[%arg5 * 8 + 68] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<21 -> 23, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %51 = arith.mulf %50, %47 {timing = #hlscpp.t<24 -> 28, 4, 1>} : f64
    %52 = arith.addf %42, %51 {timing = #hlscpp.t<28 -> 33, 5, 1>} : f64
    %53 = affine.load %arg1[%arg5 * 8 + 132] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<22 -> 24, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %54 = arith.mulf %53, %47 {timing = #hlscpp.t<24 -> 28, 4, 1>} : f64
    %55 = arith.addf %45, %54 {timing = #hlscpp.t<28 -> 33, 5, 1>} : f64
    %56 = affine.load %arg1[%arg5 * 8 + 5] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %57 = affine.load %arg3[%arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<27 -> 29, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %58 = arith.mulf %56, %57 {timing = #hlscpp.t<29 -> 33, 4, 1>} : f64
    %59 = arith.addf %49, %58 {timing = #hlscpp.t<33 -> 38, 5, 1>} : f64
    %60 = affine.load %arg1[%arg5 * 8 + 69] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<26 -> 28, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %61 = arith.mulf %60, %57 {timing = #hlscpp.t<29 -> 33, 4, 1>} : f64
    %62 = arith.addf %52, %61 {timing = #hlscpp.t<33 -> 38, 5, 1>} : f64
    %63 = affine.load %arg1[%arg5 * 8 + 133] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<27 -> 29, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %64 = arith.mulf %63, %57 {timing = #hlscpp.t<29 -> 33, 4, 1>} : f64
    %65 = arith.addf %55, %64 {timing = #hlscpp.t<33 -> 38, 5, 1>} : f64
    %66 = affine.load %arg1[%arg5 * 8 + 6] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %67 = affine.load %arg3[%arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<32 -> 34, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %68 = arith.mulf %66, %67 {timing = #hlscpp.t<34 -> 38, 4, 1>} : f64
    %69 = arith.addf %59, %68 {timing = #hlscpp.t<38 -> 43, 5, 1>} : f64
    %70 = affine.load %arg1[%arg5 * 8 + 70] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<31 -> 33, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %71 = arith.mulf %70, %67 {timing = #hlscpp.t<34 -> 38, 4, 1>} : f64
    %72 = arith.addf %62, %71 {timing = #hlscpp.t<38 -> 43, 5, 1>} : f64
    %73 = affine.load %arg1[%arg5 * 8 + 134] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<32 -> 34, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %74 = arith.mulf %73, %67 {timing = #hlscpp.t<34 -> 38, 4, 1>} : f64
    %75 = arith.addf %65, %74 {timing = #hlscpp.t<38 -> 43, 5, 1>} : f64
    %76 = affine.load %arg1[%arg5 * 8 + 7] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %77 = affine.load %arg3[%arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<37 -> 39, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %78 = arith.mulf %76, %77 {timing = #hlscpp.t<39 -> 43, 4, 1>} : f64
    %79 = arith.addf %69, %78 {timing = #hlscpp.t<43 -> 48, 5, 1>} : f64
    affine.store %79, %arg2[0] {partition_indices = [0], timing = #hlscpp.t<48 -> 49, 1, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %80 = affine.load %arg1[%arg5 * 8 + 71] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<36 -> 38, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %81 = arith.mulf %80, %77 {timing = #hlscpp.t<39 -> 43, 4, 1>} : f64
    %82 = arith.addf %72, %81 {timing = #hlscpp.t<43 -> 48, 5, 1>} : f64
    affine.store %82, %arg2[1] {partition_indices = [1], timing = #hlscpp.t<48 -> 49, 1, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %83 = affine.load %arg1[%arg5 * 8 + 135] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<37 -> 39, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 floordiv 8, d0 mod 8)>, 1>
    %84 = arith.mulf %83, %77 {timing = #hlscpp.t<39 -> 43, 4, 1>} : f64
    %85 = arith.addf %75, %84 {timing = #hlscpp.t<43 -> 48, 5, 1>} : f64
    affine.store %85, %arg2[2] {partition_indices = [2], timing = #hlscpp.t<48 -> 49, 1, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=43, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=49, minII=43>, timing = #hlscpp.t<0 -> 352, 352, 352>}
  affine.store %cst, %arg4[0] {partition_indices = [0], timing = #hlscpp.t<352 -> 353, 1, 1>} : memref<1xf64, 1>
  return {timing = #hlscpp.t<353 -> 353, 0, 0>}
}
