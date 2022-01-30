func @kernel_3mm(%arg0: memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>, %arg1: memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>, %arg2: memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>, %arg3: memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>, %arg4: memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>, %arg5: memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>, %arg6: memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=219, bram=0, nonShareDsp=1495>, timing = #hlscpp.t<0 -> 140085, 140085, 140085>} {
  %c0_i32 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0 : i32
  %0 = arith.sitofp %c0_i32 {timing = #hlscpp.t<0 -> 0, 0, 0>} : i32 to f32
  affine.for %arg7 = 0 to 20 {
    affine.for %arg8 = 0 to 8 {
      affine.for %arg9 = 0 to 10 {
        %1 = affine.load %arg0[%arg8 * 5, %arg7 * 3] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %2 = affine.load %arg1[%arg7 * 3, %arg9 * 5] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %3 = arith.mulf %1, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %4 = affine.load %arg4[%arg8 * 5, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %5 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %4 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %6 = arith.addf %5, %3 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %7 = affine.load %arg1[%arg7 * 3, %arg9 * 5 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %8 = arith.mulf %1, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %9 = affine.load %arg4[%arg8 * 5, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %10 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %9 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %11 = arith.addf %10, %8 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %12 = affine.load %arg1[%arg7 * 3, %arg9 * 5 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %13 = arith.mulf %1, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %14 = affine.load %arg4[%arg8 * 5, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %15 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %14 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %16 = arith.addf %15, %13 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %17 = affine.load %arg1[%arg7 * 3, %arg9 * 5 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %18 = arith.mulf %1, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %19 = affine.load %arg4[%arg8 * 5, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %20 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %19 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %21 = arith.addf %20, %18 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %22 = affine.load %arg1[%arg7 * 3, %arg9 * 5 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %23 = arith.mulf %1, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %24 = affine.load %arg4[%arg8 * 5, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %25 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %24 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %26 = arith.addf %25, %23 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %27 = affine.load %arg0[%arg8 * 5 + 1, %arg7 * 3] {partition_indices = [1, 0], timing = #hlscpp.t<1 -> 3, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %28 = arith.mulf %27, %2 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %29 = affine.load %arg4[%arg8 * 5 + 1, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %30 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %29 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %31 = arith.addf %30, %28 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %32 = arith.mulf %27, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %33 = affine.load %arg4[%arg8 * 5 + 1, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %34 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %33 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %35 = arith.addf %34, %32 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %36 = arith.mulf %27, %12 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %37 = affine.load %arg4[%arg8 * 5 + 1, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %38 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %37 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %39 = arith.addf %38, %36 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %40 = arith.mulf %27, %17 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %41 = affine.load %arg4[%arg8 * 5 + 1, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %42 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %41 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %43 = arith.addf %42, %40 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %44 = arith.mulf %27, %22 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %45 = affine.load %arg4[%arg8 * 5 + 1, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %46 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %45 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %47 = arith.addf %46, %44 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %48 = affine.load %arg0[%arg8 * 5 + 2, %arg7 * 3] {partition_indices = [2, 0], timing = #hlscpp.t<2 -> 4, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %49 = arith.mulf %48, %2 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f32
        %50 = affine.load %arg4[%arg8 * 5 + 2, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %51 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %50 : f32
        } {timing = #hlscpp.t<8 -> 8, 0, 0>}
        %52 = arith.addf %51, %49 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f32
        %53 = arith.mulf %48, %7 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f32
        %54 = affine.load %arg4[%arg8 * 5 + 2, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %55 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %54 : f32
        } {timing = #hlscpp.t<8 -> 8, 0, 0>}
        %56 = arith.addf %55, %53 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f32
        %57 = arith.mulf %48, %12 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f32
        %58 = affine.load %arg4[%arg8 * 5 + 2, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %59 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %58 : f32
        } {timing = #hlscpp.t<8 -> 8, 0, 0>}
        %60 = arith.addf %59, %57 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f32
        %61 = arith.mulf %48, %17 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f32
        %62 = affine.load %arg4[%arg8 * 5 + 2, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %63 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %62 : f32
        } {timing = #hlscpp.t<8 -> 8, 0, 0>}
        %64 = arith.addf %63, %61 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f32
        %65 = arith.mulf %48, %22 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f32
        %66 = affine.load %arg4[%arg8 * 5 + 2, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %67 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %66 : f32
        } {timing = #hlscpp.t<8 -> 8, 0, 0>}
        %68 = arith.addf %67, %65 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f32
        %69 = affine.load %arg0[%arg8 * 5 + 3, %arg7 * 3] {partition_indices = [3, 0], timing = #hlscpp.t<3 -> 5, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %70 = arith.mulf %69, %2 {timing = #hlscpp.t<5 -> 9, 4, 1>} : f32
        %71 = affine.load %arg4[%arg8 * 5 + 3, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %72 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %71 : f32
        } {timing = #hlscpp.t<9 -> 9, 0, 0>}
        %73 = arith.addf %72, %70 {timing = #hlscpp.t<9 -> 14, 5, 1>} : f32
        %74 = arith.mulf %69, %7 {timing = #hlscpp.t<5 -> 9, 4, 1>} : f32
        %75 = affine.load %arg4[%arg8 * 5 + 3, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %76 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %75 : f32
        } {timing = #hlscpp.t<9 -> 9, 0, 0>}
        %77 = arith.addf %76, %74 {timing = #hlscpp.t<9 -> 14, 5, 1>} : f32
        %78 = arith.mulf %69, %12 {timing = #hlscpp.t<5 -> 9, 4, 1>} : f32
        %79 = affine.load %arg4[%arg8 * 5 + 3, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %80 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %79 : f32
        } {timing = #hlscpp.t<9 -> 9, 0, 0>}
        %81 = arith.addf %80, %78 {timing = #hlscpp.t<9 -> 14, 5, 1>} : f32
        %82 = arith.mulf %69, %17 {timing = #hlscpp.t<5 -> 9, 4, 1>} : f32
        %83 = affine.load %arg4[%arg8 * 5 + 3, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %84 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %83 : f32
        } {timing = #hlscpp.t<9 -> 9, 0, 0>}
        %85 = arith.addf %84, %82 {timing = #hlscpp.t<9 -> 14, 5, 1>} : f32
        %86 = arith.mulf %69, %22 {timing = #hlscpp.t<5 -> 9, 4, 1>} : f32
        %87 = affine.load %arg4[%arg8 * 5 + 3, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %88 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %87 : f32
        } {timing = #hlscpp.t<9 -> 9, 0, 0>}
        %89 = arith.addf %88, %86 {timing = #hlscpp.t<9 -> 14, 5, 1>} : f32
        %90 = affine.load %arg0[%arg8 * 5 + 4, %arg7 * 3] {partition_indices = [4, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %91 = arith.mulf %90, %2 {timing = #hlscpp.t<6 -> 10, 4, 1>} : f32
        %92 = affine.load %arg4[%arg8 * 5 + 4, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %93 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %92 : f32
        } {timing = #hlscpp.t<10 -> 10, 0, 0>}
        %94 = arith.addf %93, %91 {timing = #hlscpp.t<10 -> 15, 5, 1>} : f32
        %95 = arith.mulf %90, %7 {timing = #hlscpp.t<6 -> 10, 4, 1>} : f32
        %96 = affine.load %arg4[%arg8 * 5 + 4, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %97 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %96 : f32
        } {timing = #hlscpp.t<10 -> 10, 0, 0>}
        %98 = arith.addf %97, %95 {timing = #hlscpp.t<10 -> 15, 5, 1>} : f32
        %99 = arith.mulf %90, %12 {timing = #hlscpp.t<6 -> 10, 4, 1>} : f32
        %100 = affine.load %arg4[%arg8 * 5 + 4, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %101 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %100 : f32
        } {timing = #hlscpp.t<10 -> 10, 0, 0>}
        %102 = arith.addf %101, %99 {timing = #hlscpp.t<10 -> 15, 5, 1>} : f32
        %103 = arith.mulf %90, %17 {timing = #hlscpp.t<6 -> 10, 4, 1>} : f32
        %104 = affine.load %arg4[%arg8 * 5 + 4, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %105 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %104 : f32
        } {timing = #hlscpp.t<10 -> 10, 0, 0>}
        %106 = arith.addf %105, %103 {timing = #hlscpp.t<10 -> 15, 5, 1>} : f32
        %107 = arith.mulf %90, %22 {timing = #hlscpp.t<6 -> 10, 4, 1>} : f32
        %108 = affine.load %arg4[%arg8 * 5 + 4, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %109 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %108 : f32
        } {timing = #hlscpp.t<10 -> 10, 0, 0>}
        %110 = arith.addf %109, %107 {timing = #hlscpp.t<10 -> 15, 5, 1>} : f32
        %111 = affine.load %arg0[%arg8 * 5, %arg7 * 3 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %112 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 5] {partition_indices = [1, 0], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %113 = arith.mulf %111, %112 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %114 = arith.addf %6, %113 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %115 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 5 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %116 = arith.mulf %111, %115 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %117 = arith.addf %11, %116 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %118 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 5 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %119 = arith.mulf %111, %118 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %120 = arith.addf %16, %119 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %121 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 5 + 3] {partition_indices = [1, 3], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %122 = arith.mulf %111, %121 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %123 = arith.addf %21, %122 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %124 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 5 + 4] {partition_indices = [1, 4], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %125 = arith.mulf %111, %124 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %126 = arith.addf %26, %125 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %127 = affine.load %arg0[%arg8 * 5 + 1, %arg7 * 3 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %128 = arith.mulf %127, %112 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %129 = arith.addf %31, %128 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %130 = arith.mulf %127, %115 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %131 = arith.addf %35, %130 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %132 = arith.mulf %127, %118 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %133 = arith.addf %39, %132 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %134 = arith.mulf %127, %121 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %135 = arith.addf %43, %134 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %136 = arith.mulf %127, %124 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %137 = arith.addf %47, %136 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %138 = affine.load %arg0[%arg8 * 5 + 2, %arg7 * 3 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %139 = arith.mulf %138, %112 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f32
        %140 = arith.addf %52, %139 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f32
        %141 = arith.mulf %138, %115 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f32
        %142 = arith.addf %56, %141 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f32
        %143 = arith.mulf %138, %118 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f32
        %144 = arith.addf %60, %143 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f32
        %145 = arith.mulf %138, %121 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f32
        %146 = arith.addf %64, %145 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f32
        %147 = arith.mulf %138, %124 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f32
        %148 = arith.addf %68, %147 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f32
        %149 = affine.load %arg0[%arg8 * 5 + 3, %arg7 * 3 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %150 = arith.mulf %149, %112 {timing = #hlscpp.t<10 -> 14, 4, 1>} : f32
        %151 = arith.addf %73, %150 {timing = #hlscpp.t<14 -> 19, 5, 1>} : f32
        %152 = arith.mulf %149, %115 {timing = #hlscpp.t<10 -> 14, 4, 1>} : f32
        %153 = arith.addf %77, %152 {timing = #hlscpp.t<14 -> 19, 5, 1>} : f32
        %154 = arith.mulf %149, %118 {timing = #hlscpp.t<10 -> 14, 4, 1>} : f32
        %155 = arith.addf %81, %154 {timing = #hlscpp.t<14 -> 19, 5, 1>} : f32
        %156 = arith.mulf %149, %121 {timing = #hlscpp.t<10 -> 14, 4, 1>} : f32
        %157 = arith.addf %85, %156 {timing = #hlscpp.t<14 -> 19, 5, 1>} : f32
        %158 = arith.mulf %149, %124 {timing = #hlscpp.t<10 -> 14, 4, 1>} : f32
        %159 = arith.addf %89, %158 {timing = #hlscpp.t<14 -> 19, 5, 1>} : f32
        %160 = affine.load %arg0[%arg8 * 5 + 4, %arg7 * 3 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %161 = arith.mulf %160, %112 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f32
        %162 = arith.addf %94, %161 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f32
        %163 = arith.mulf %160, %115 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f32
        %164 = arith.addf %98, %163 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f32
        %165 = arith.mulf %160, %118 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f32
        %166 = arith.addf %102, %165 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f32
        %167 = arith.mulf %160, %121 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f32
        %168 = arith.addf %106, %167 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f32
        %169 = arith.mulf %160, %124 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f32
        %170 = arith.addf %110, %169 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f32
        %171 = affine.load %arg0[%arg8 * 5, %arg7 * 3 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %172 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 5] {partition_indices = [2, 0], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %173 = arith.mulf %171, %172 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %174 = arith.addf %114, %173 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %174, %arg4[%arg8 * 5, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %175 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 5 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %176 = arith.mulf %171, %175 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %177 = arith.addf %117, %176 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %177, %arg4[%arg8 * 5, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %178 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 5 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %179 = arith.mulf %171, %178 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %180 = arith.addf %120, %179 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %180, %arg4[%arg8 * 5, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %181 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 5 + 3] {partition_indices = [2, 3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %182 = arith.mulf %171, %181 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %183 = arith.addf %123, %182 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %183, %arg4[%arg8 * 5, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %184 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 5 + 4] {partition_indices = [2, 4], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 5, d0 floordiv 3, d1 floordiv 5)>, 1>
        %185 = arith.mulf %171, %184 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %186 = arith.addf %126, %185 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %186, %arg4[%arg8 * 5, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %187 = affine.load %arg0[%arg8 * 5 + 1, %arg7 * 3 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<11 -> 13, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %188 = arith.mulf %187, %172 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %189 = arith.addf %129, %188 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        affine.store %189, %arg4[%arg8 * 5 + 1, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<22 -> 23, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %190 = arith.mulf %187, %175 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %191 = arith.addf %131, %190 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        affine.store %191, %arg4[%arg8 * 5 + 1, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<22 -> 23, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %192 = arith.mulf %187, %178 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %193 = arith.addf %133, %192 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        affine.store %193, %arg4[%arg8 * 5 + 1, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<22 -> 23, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %194 = arith.mulf %187, %181 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %195 = arith.addf %135, %194 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        affine.store %195, %arg4[%arg8 * 5 + 1, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<22 -> 23, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %196 = arith.mulf %187, %184 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %197 = arith.addf %137, %196 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        affine.store %197, %arg4[%arg8 * 5 + 1, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<22 -> 23, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %198 = affine.load %arg0[%arg8 * 5 + 2, %arg7 * 3 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<12 -> 14, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %199 = arith.mulf %198, %172 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f32
        %200 = arith.addf %140, %199 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f32
        affine.store %200, %arg4[%arg8 * 5 + 2, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<23 -> 24, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %201 = arith.mulf %198, %175 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f32
        %202 = arith.addf %142, %201 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f32
        affine.store %202, %arg4[%arg8 * 5 + 2, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<23 -> 24, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %203 = arith.mulf %198, %178 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f32
        %204 = arith.addf %144, %203 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f32
        affine.store %204, %arg4[%arg8 * 5 + 2, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<23 -> 24, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %205 = arith.mulf %198, %181 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f32
        %206 = arith.addf %146, %205 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f32
        affine.store %206, %arg4[%arg8 * 5 + 2, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<23 -> 24, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %207 = arith.mulf %198, %184 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f32
        %208 = arith.addf %148, %207 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f32
        affine.store %208, %arg4[%arg8 * 5 + 2, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<23 -> 24, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %209 = affine.load %arg0[%arg8 * 5 + 3, %arg7 * 3 + 2] {partition_indices = [3, 2], timing = #hlscpp.t<13 -> 15, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %210 = arith.mulf %209, %172 {timing = #hlscpp.t<15 -> 19, 4, 1>} : f32
        %211 = arith.addf %151, %210 {timing = #hlscpp.t<19 -> 24, 5, 1>} : f32
        affine.store %211, %arg4[%arg8 * 5 + 3, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<24 -> 25, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %212 = arith.mulf %209, %175 {timing = #hlscpp.t<15 -> 19, 4, 1>} : f32
        %213 = arith.addf %153, %212 {timing = #hlscpp.t<19 -> 24, 5, 1>} : f32
        affine.store %213, %arg4[%arg8 * 5 + 3, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<24 -> 25, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %214 = arith.mulf %209, %178 {timing = #hlscpp.t<15 -> 19, 4, 1>} : f32
        %215 = arith.addf %155, %214 {timing = #hlscpp.t<19 -> 24, 5, 1>} : f32
        affine.store %215, %arg4[%arg8 * 5 + 3, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<24 -> 25, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %216 = arith.mulf %209, %181 {timing = #hlscpp.t<15 -> 19, 4, 1>} : f32
        %217 = arith.addf %157, %216 {timing = #hlscpp.t<19 -> 24, 5, 1>} : f32
        affine.store %217, %arg4[%arg8 * 5 + 3, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<24 -> 25, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %218 = arith.mulf %209, %184 {timing = #hlscpp.t<15 -> 19, 4, 1>} : f32
        %219 = arith.addf %159, %218 {timing = #hlscpp.t<19 -> 24, 5, 1>} : f32
        affine.store %219, %arg4[%arg8 * 5 + 3, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<24 -> 25, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %220 = affine.load %arg0[%arg8 * 5 + 4, %arg7 * 3 + 2] {partition_indices = [4, 2], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 3, d0 floordiv 5, d1 floordiv 3)>, 1>
        %221 = arith.mulf %220, %172 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f32
        %222 = arith.addf %162, %221 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f32
        affine.store %222, %arg4[%arg8 * 5 + 4, %arg9 * 5] {max_mux_size = 8 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %223 = arith.mulf %220, %175 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f32
        %224 = arith.addf %164, %223 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f32
        affine.store %224, %arg4[%arg8 * 5 + 4, %arg9 * 5 + 1] {max_mux_size = 8 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %225 = arith.mulf %220, %178 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f32
        %226 = arith.addf %166, %225 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f32
        affine.store %226, %arg4[%arg8 * 5 + 4, %arg9 * 5 + 2] {max_mux_size = 8 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %227 = arith.mulf %220, %181 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f32
        %228 = arith.addf %168, %227 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f32
        affine.store %228, %arg4[%arg8 * 5 + 4, %arg9 * 5 + 3] {max_mux_size = 8 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %229 = arith.mulf %220, %184 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f32
        %230 = arith.addf %170, %229 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f32
        affine.store %230, %arg4[%arg8 * 5 + 4, %arg9 * 5 + 4] {max_mux_size = 8 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=10, iterLatency=26, minII=18>, resource = #hlscpp.r<lut=0, dsp=20, bram=0, nonShareDsp=375>, timing = #hlscpp.t<111273 -> 111463, 190, 190>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=80, iterLatency=26, minII=18>, resource = #hlscpp.r<lut=0, dsp=20, bram=0, nonShareDsp=375>, timing = #hlscpp.t<111273 -> 112723, 1450, 1450>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=1600, iterLatency=26, minII=18>, resource = #hlscpp.r<lut=0, dsp=20, bram=0, nonShareDsp=375>, timing = #hlscpp.t<0 -> 28810, 28810, 28810>}
  affine.for %arg7 = 0 to 10 {
    affine.for %arg8 = 0 to 25 {
      affine.for %arg9 = 0 to 10 {
        %1 = affine.load %arg2[%arg8 * 2, %arg7 * 8] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %2 = affine.load %arg3[%arg7 * 8, %arg9 * 7] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %3 = arith.mulf %1, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %4 = affine.load %arg5[%arg8 * 2, %arg9 * 7] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %5 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %4 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %6 = arith.addf %5, %3 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %7 = affine.load %arg3[%arg7 * 8, %arg9 * 7 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<1 -> 3, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %8 = arith.mulf %1, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %9 = affine.load %arg5[%arg8 * 2, %arg9 * 7 + 1] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %10 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %9 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %11 = arith.addf %10, %8 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %12 = affine.load %arg3[%arg7 * 8, %arg9 * 7 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<2 -> 4, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %13 = arith.mulf %1, %12 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f32
        %14 = affine.load %arg5[%arg8 * 2, %arg9 * 7 + 2] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %15 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %14 : f32
        } {timing = #hlscpp.t<8 -> 8, 0, 0>}
        %16 = arith.addf %15, %13 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f32
        %17 = affine.load %arg3[%arg7 * 8, %arg9 * 7 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<3 -> 5, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %18 = arith.mulf %1, %17 {timing = #hlscpp.t<5 -> 9, 4, 1>} : f32
        %19 = affine.load %arg5[%arg8 * 2, %arg9 * 7 + 3] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %20 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %19 : f32
        } {timing = #hlscpp.t<9 -> 9, 0, 0>}
        %21 = arith.addf %20, %18 {timing = #hlscpp.t<9 -> 14, 5, 1>} : f32
        %22 = affine.load %arg3[%arg7 * 8, %arg9 * 7 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %23 = arith.mulf %1, %22 {timing = #hlscpp.t<6 -> 10, 4, 1>} : f32
        %24 = affine.load %arg5[%arg8 * 2, %arg9 * 7 + 4] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %25 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %24 : f32
        } {timing = #hlscpp.t<10 -> 10, 0, 0>}
        %26 = arith.addf %25, %23 {timing = #hlscpp.t<10 -> 15, 5, 1>} : f32
        %27 = affine.load %arg3[%arg7 * 8, %arg9 * 7 + 5] {partition_indices = [0, 5], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %28 = arith.mulf %1, %27 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %29 = affine.load %arg5[%arg8 * 2, %arg9 * 7 + 5] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %30 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<11 -> 11, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<11 -> 11, 0, 0>} %29 : f32
        } {timing = #hlscpp.t<11 -> 11, 0, 0>}
        %31 = arith.addf %30, %28 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %32 = affine.load %arg3[%arg7 * 8, %arg9 * 7 + 6] {partition_indices = [0, 6], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %33 = arith.mulf %1, %32 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %34 = affine.load %arg5[%arg8 * 2, %arg9 * 7 + 6] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %35 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<12 -> 12, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<12 -> 12, 0, 0>} %34 : f32
        } {timing = #hlscpp.t<12 -> 12, 0, 0>}
        %36 = arith.addf %35, %33 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %37 = affine.load %arg2[%arg8 * 2 + 1, %arg7 * 8] {partition_indices = [1, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %38 = arith.mulf %37, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %39 = affine.load %arg5[%arg8 * 2 + 1, %arg9 * 7] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %40 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %39 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %41 = arith.addf %40, %38 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %42 = arith.mulf %37, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %43 = affine.load %arg5[%arg8 * 2 + 1, %arg9 * 7 + 1] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %44 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %43 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %45 = arith.addf %44, %42 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %46 = arith.mulf %37, %12 {timing = #hlscpp.t<4 -> 8, 4, 1>} : f32
        %47 = affine.load %arg5[%arg8 * 2 + 1, %arg9 * 7 + 2] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %48 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<8 -> 8, 0, 0>} %47 : f32
        } {timing = #hlscpp.t<8 -> 8, 0, 0>}
        %49 = arith.addf %48, %46 {timing = #hlscpp.t<8 -> 13, 5, 1>} : f32
        %50 = arith.mulf %37, %17 {timing = #hlscpp.t<5 -> 9, 4, 1>} : f32
        %51 = affine.load %arg5[%arg8 * 2 + 1, %arg9 * 7 + 3] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %52 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<9 -> 9, 0, 0>} %51 : f32
        } {timing = #hlscpp.t<9 -> 9, 0, 0>}
        %53 = arith.addf %52, %50 {timing = #hlscpp.t<9 -> 14, 5, 1>} : f32
        %54 = arith.mulf %37, %22 {timing = #hlscpp.t<6 -> 10, 4, 1>} : f32
        %55 = affine.load %arg5[%arg8 * 2 + 1, %arg9 * 7 + 4] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %56 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<10 -> 10, 0, 0>} %55 : f32
        } {timing = #hlscpp.t<10 -> 10, 0, 0>}
        %57 = arith.addf %56, %54 {timing = #hlscpp.t<10 -> 15, 5, 1>} : f32
        %58 = arith.mulf %37, %27 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %59 = affine.load %arg5[%arg8 * 2 + 1, %arg9 * 7 + 5] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %60 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<11 -> 11, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<11 -> 11, 0, 0>} %59 : f32
        } {timing = #hlscpp.t<11 -> 11, 0, 0>}
        %61 = arith.addf %60, %58 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %62 = arith.mulf %37, %32 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %63 = affine.load %arg5[%arg8 * 2 + 1, %arg9 * 7 + 6] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %64 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<12 -> 12, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<12 -> 12, 0, 0>} %63 : f32
        } {timing = #hlscpp.t<12 -> 12, 0, 0>}
        %65 = arith.addf %64, %62 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %66 = affine.load %arg2[%arg8 * 2, %arg7 * 8 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %67 = affine.load %arg3[%arg7 * 8 + 1, %arg9 * 7] {partition_indices = [1, 0], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %68 = arith.mulf %66, %67 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %69 = arith.addf %6, %68 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %70 = affine.load %arg3[%arg7 * 8 + 1, %arg9 * 7 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %71 = arith.mulf %66, %70 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %72 = arith.addf %11, %71 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %73 = affine.load %arg3[%arg7 * 8 + 1, %arg9 * 7 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %74 = arith.mulf %66, %73 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f32
        %75 = arith.addf %16, %74 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f32
        %76 = affine.load %arg3[%arg7 * 8 + 1, %arg9 * 7 + 3] {partition_indices = [1, 3], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %77 = arith.mulf %66, %76 {timing = #hlscpp.t<10 -> 14, 4, 1>} : f32
        %78 = arith.addf %21, %77 {timing = #hlscpp.t<14 -> 19, 5, 1>} : f32
        %79 = affine.load %arg3[%arg7 * 8 + 1, %arg9 * 7 + 4] {partition_indices = [1, 4], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %80 = arith.mulf %66, %79 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f32
        %81 = arith.addf %26, %80 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f32
        %82 = affine.load %arg3[%arg7 * 8 + 1, %arg9 * 7 + 5] {partition_indices = [1, 5], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %83 = arith.mulf %66, %82 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %84 = arith.addf %31, %83 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        %85 = affine.load %arg3[%arg7 * 8 + 1, %arg9 * 7 + 6] {partition_indices = [1, 6], timing = #hlscpp.t<11 -> 13, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %86 = arith.mulf %66, %85 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %87 = arith.addf %36, %86 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        %88 = affine.load %arg2[%arg8 * 2 + 1, %arg7 * 8 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %89 = arith.mulf %88, %67 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %90 = arith.addf %41, %89 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %91 = arith.mulf %88, %70 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %92 = arith.addf %45, %91 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        %93 = arith.mulf %88, %73 {timing = #hlscpp.t<9 -> 13, 4, 1>} : f32
        %94 = arith.addf %49, %93 {timing = #hlscpp.t<13 -> 18, 5, 1>} : f32
        %95 = arith.mulf %88, %76 {timing = #hlscpp.t<10 -> 14, 4, 1>} : f32
        %96 = arith.addf %53, %95 {timing = #hlscpp.t<14 -> 19, 5, 1>} : f32
        %97 = arith.mulf %88, %79 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f32
        %98 = arith.addf %57, %97 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f32
        %99 = arith.mulf %88, %82 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %100 = arith.addf %61, %99 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        %101 = arith.mulf %88, %85 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %102 = arith.addf %65, %101 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        %103 = affine.load %arg2[%arg8 * 2, %arg7 * 8 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %104 = affine.load %arg3[%arg7 * 8 + 2, %arg9 * 7] {partition_indices = [2, 0], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %105 = arith.mulf %103, %104 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %106 = arith.addf %69, %105 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        %107 = affine.load %arg3[%arg7 * 8 + 2, %arg9 * 7 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<11 -> 13, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %108 = arith.mulf %103, %107 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %109 = arith.addf %72, %108 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        %110 = affine.load %arg3[%arg7 * 8 + 2, %arg9 * 7 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<12 -> 14, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %111 = arith.mulf %103, %110 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f32
        %112 = arith.addf %75, %111 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f32
        %113 = affine.load %arg3[%arg7 * 8 + 2, %arg9 * 7 + 3] {partition_indices = [2, 3], timing = #hlscpp.t<13 -> 15, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %114 = arith.mulf %103, %113 {timing = #hlscpp.t<15 -> 19, 4, 1>} : f32
        %115 = arith.addf %78, %114 {timing = #hlscpp.t<19 -> 24, 5, 1>} : f32
        %116 = affine.load %arg3[%arg7 * 8 + 2, %arg9 * 7 + 4] {partition_indices = [2, 4], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %117 = arith.mulf %103, %116 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f32
        %118 = arith.addf %81, %117 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f32
        %119 = affine.load %arg3[%arg7 * 8 + 2, %arg9 * 7 + 5] {partition_indices = [2, 5], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %120 = arith.mulf %103, %119 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f32
        %121 = arith.addf %84, %120 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f32
        %122 = affine.load %arg3[%arg7 * 8 + 2, %arg9 * 7 + 6] {partition_indices = [2, 6], timing = #hlscpp.t<16 -> 18, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %123 = arith.mulf %103, %122 {timing = #hlscpp.t<18 -> 22, 4, 1>} : f32
        %124 = arith.addf %87, %123 {timing = #hlscpp.t<22 -> 27, 5, 1>} : f32
        %125 = affine.load %arg2[%arg8 * 2 + 1, %arg7 * 8 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %126 = arith.mulf %125, %104 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %127 = arith.addf %90, %126 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        %128 = arith.mulf %125, %107 {timing = #hlscpp.t<13 -> 17, 4, 1>} : f32
        %129 = arith.addf %92, %128 {timing = #hlscpp.t<17 -> 22, 5, 1>} : f32
        %130 = arith.mulf %125, %110 {timing = #hlscpp.t<14 -> 18, 4, 1>} : f32
        %131 = arith.addf %94, %130 {timing = #hlscpp.t<18 -> 23, 5, 1>} : f32
        %132 = arith.mulf %125, %113 {timing = #hlscpp.t<15 -> 19, 4, 1>} : f32
        %133 = arith.addf %96, %132 {timing = #hlscpp.t<19 -> 24, 5, 1>} : f32
        %134 = arith.mulf %125, %116 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f32
        %135 = arith.addf %98, %134 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f32
        %136 = arith.mulf %125, %119 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f32
        %137 = arith.addf %100, %136 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f32
        %138 = arith.mulf %125, %122 {timing = #hlscpp.t<18 -> 22, 4, 1>} : f32
        %139 = arith.addf %102, %138 {timing = #hlscpp.t<22 -> 27, 5, 1>} : f32
        %140 = affine.load %arg2[%arg8 * 2, %arg7 * 8 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %141 = affine.load %arg3[%arg7 * 8 + 3, %arg9 * 7] {partition_indices = [3, 0], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %142 = arith.mulf %140, %141 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f32
        %143 = arith.addf %106, %142 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f32
        %144 = affine.load %arg3[%arg7 * 8 + 3, %arg9 * 7 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<16 -> 18, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %145 = arith.mulf %140, %144 {timing = #hlscpp.t<18 -> 22, 4, 1>} : f32
        %146 = arith.addf %109, %145 {timing = #hlscpp.t<22 -> 27, 5, 1>} : f32
        %147 = affine.load %arg3[%arg7 * 8 + 3, %arg9 * 7 + 2] {partition_indices = [3, 2], timing = #hlscpp.t<17 -> 19, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %148 = arith.mulf %140, %147 {timing = #hlscpp.t<19 -> 23, 4, 1>} : f32
        %149 = arith.addf %112, %148 {timing = #hlscpp.t<23 -> 28, 5, 1>} : f32
        %150 = affine.load %arg3[%arg7 * 8 + 3, %arg9 * 7 + 3] {partition_indices = [3, 3], timing = #hlscpp.t<18 -> 20, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %151 = arith.mulf %140, %150 {timing = #hlscpp.t<20 -> 24, 4, 1>} : f32
        %152 = arith.addf %115, %151 {timing = #hlscpp.t<24 -> 29, 5, 1>} : f32
        %153 = affine.load %arg3[%arg7 * 8 + 3, %arg9 * 7 + 4] {partition_indices = [3, 4], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %154 = arith.mulf %140, %153 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f32
        %155 = arith.addf %118, %154 {timing = #hlscpp.t<25 -> 30, 5, 1>} : f32
        %156 = affine.load %arg3[%arg7 * 8 + 3, %arg9 * 7 + 5] {partition_indices = [3, 5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %157 = arith.mulf %140, %156 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f32
        %158 = arith.addf %121, %157 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f32
        %159 = affine.load %arg3[%arg7 * 8 + 3, %arg9 * 7 + 6] {partition_indices = [3, 6], timing = #hlscpp.t<21 -> 23, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %160 = arith.mulf %140, %159 {timing = #hlscpp.t<23 -> 27, 4, 1>} : f32
        %161 = arith.addf %124, %160 {timing = #hlscpp.t<27 -> 32, 5, 1>} : f32
        %162 = affine.load %arg2[%arg8 * 2 + 1, %arg7 * 8 + 3] {partition_indices = [1, 3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %163 = arith.mulf %162, %141 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f32
        %164 = arith.addf %127, %163 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f32
        %165 = arith.mulf %162, %144 {timing = #hlscpp.t<18 -> 22, 4, 1>} : f32
        %166 = arith.addf %129, %165 {timing = #hlscpp.t<22 -> 27, 5, 1>} : f32
        %167 = arith.mulf %162, %147 {timing = #hlscpp.t<19 -> 23, 4, 1>} : f32
        %168 = arith.addf %131, %167 {timing = #hlscpp.t<23 -> 28, 5, 1>} : f32
        %169 = arith.mulf %162, %150 {timing = #hlscpp.t<20 -> 24, 4, 1>} : f32
        %170 = arith.addf %133, %169 {timing = #hlscpp.t<24 -> 29, 5, 1>} : f32
        %171 = arith.mulf %162, %153 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f32
        %172 = arith.addf %135, %171 {timing = #hlscpp.t<25 -> 30, 5, 1>} : f32
        %173 = arith.mulf %162, %156 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f32
        %174 = arith.addf %137, %173 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f32
        %175 = arith.mulf %162, %159 {timing = #hlscpp.t<23 -> 27, 4, 1>} : f32
        %176 = arith.addf %139, %175 {timing = #hlscpp.t<27 -> 32, 5, 1>} : f32
        %177 = affine.load %arg2[%arg8 * 2, %arg7 * 8 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %178 = affine.load %arg3[%arg7 * 8 + 4, %arg9 * 7] {partition_indices = [4, 0], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %179 = arith.mulf %177, %178 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f32
        %180 = arith.addf %143, %179 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f32
        %181 = affine.load %arg3[%arg7 * 8 + 4, %arg9 * 7 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<21 -> 23, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %182 = arith.mulf %177, %181 {timing = #hlscpp.t<23 -> 27, 4, 1>} : f32
        %183 = arith.addf %146, %182 {timing = #hlscpp.t<27 -> 32, 5, 1>} : f32
        %184 = affine.load %arg3[%arg7 * 8 + 4, %arg9 * 7 + 2] {partition_indices = [4, 2], timing = #hlscpp.t<22 -> 24, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %185 = arith.mulf %177, %184 {timing = #hlscpp.t<24 -> 28, 4, 1>} : f32
        %186 = arith.addf %149, %185 {timing = #hlscpp.t<28 -> 33, 5, 1>} : f32
        %187 = affine.load %arg3[%arg7 * 8 + 4, %arg9 * 7 + 3] {partition_indices = [4, 3], timing = #hlscpp.t<23 -> 25, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %188 = arith.mulf %177, %187 {timing = #hlscpp.t<25 -> 29, 4, 1>} : f32
        %189 = arith.addf %152, %188 {timing = #hlscpp.t<29 -> 34, 5, 1>} : f32
        %190 = affine.load %arg3[%arg7 * 8 + 4, %arg9 * 7 + 4] {partition_indices = [4, 4], timing = #hlscpp.t<24 -> 26, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %191 = arith.mulf %177, %190 {timing = #hlscpp.t<26 -> 30, 4, 1>} : f32
        %192 = arith.addf %155, %191 {timing = #hlscpp.t<30 -> 35, 5, 1>} : f32
        %193 = affine.load %arg3[%arg7 * 8 + 4, %arg9 * 7 + 5] {partition_indices = [4, 5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %194 = arith.mulf %177, %193 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f32
        %195 = arith.addf %158, %194 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f32
        %196 = affine.load %arg3[%arg7 * 8 + 4, %arg9 * 7 + 6] {partition_indices = [4, 6], timing = #hlscpp.t<26 -> 28, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %197 = arith.mulf %177, %196 {timing = #hlscpp.t<28 -> 32, 4, 1>} : f32
        %198 = arith.addf %161, %197 {timing = #hlscpp.t<32 -> 37, 5, 1>} : f32
        %199 = affine.load %arg2[%arg8 * 2 + 1, %arg7 * 8 + 4] {partition_indices = [1, 4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %200 = arith.mulf %199, %178 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f32
        %201 = arith.addf %164, %200 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f32
        %202 = arith.mulf %199, %181 {timing = #hlscpp.t<23 -> 27, 4, 1>} : f32
        %203 = arith.addf %166, %202 {timing = #hlscpp.t<27 -> 32, 5, 1>} : f32
        %204 = arith.mulf %199, %184 {timing = #hlscpp.t<24 -> 28, 4, 1>} : f32
        %205 = arith.addf %168, %204 {timing = #hlscpp.t<28 -> 33, 5, 1>} : f32
        %206 = arith.mulf %199, %187 {timing = #hlscpp.t<25 -> 29, 4, 1>} : f32
        %207 = arith.addf %170, %206 {timing = #hlscpp.t<29 -> 34, 5, 1>} : f32
        %208 = arith.mulf %199, %190 {timing = #hlscpp.t<26 -> 30, 4, 1>} : f32
        %209 = arith.addf %172, %208 {timing = #hlscpp.t<30 -> 35, 5, 1>} : f32
        %210 = arith.mulf %199, %193 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f32
        %211 = arith.addf %174, %210 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f32
        %212 = arith.mulf %199, %196 {timing = #hlscpp.t<28 -> 32, 4, 1>} : f32
        %213 = arith.addf %176, %212 {timing = #hlscpp.t<32 -> 37, 5, 1>} : f32
        %214 = affine.load %arg2[%arg8 * 2, %arg7 * 8 + 5] {partition_indices = [0, 5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %215 = affine.load %arg3[%arg7 * 8 + 5, %arg9 * 7] {partition_indices = [5, 0], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %216 = arith.mulf %214, %215 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f32
        %217 = arith.addf %180, %216 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f32
        %218 = affine.load %arg3[%arg7 * 8 + 5, %arg9 * 7 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<26 -> 28, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %219 = arith.mulf %214, %218 {timing = #hlscpp.t<28 -> 32, 4, 1>} : f32
        %220 = arith.addf %183, %219 {timing = #hlscpp.t<32 -> 37, 5, 1>} : f32
        %221 = affine.load %arg3[%arg7 * 8 + 5, %arg9 * 7 + 2] {partition_indices = [5, 2], timing = #hlscpp.t<27 -> 29, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %222 = arith.mulf %214, %221 {timing = #hlscpp.t<29 -> 33, 4, 1>} : f32
        %223 = arith.addf %186, %222 {timing = #hlscpp.t<33 -> 38, 5, 1>} : f32
        %224 = affine.load %arg3[%arg7 * 8 + 5, %arg9 * 7 + 3] {partition_indices = [5, 3], timing = #hlscpp.t<28 -> 30, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %225 = arith.mulf %214, %224 {timing = #hlscpp.t<30 -> 34, 4, 1>} : f32
        %226 = arith.addf %189, %225 {timing = #hlscpp.t<34 -> 39, 5, 1>} : f32
        %227 = affine.load %arg3[%arg7 * 8 + 5, %arg9 * 7 + 4] {partition_indices = [5, 4], timing = #hlscpp.t<29 -> 31, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %228 = arith.mulf %214, %227 {timing = #hlscpp.t<31 -> 35, 4, 1>} : f32
        %229 = arith.addf %192, %228 {timing = #hlscpp.t<35 -> 40, 5, 1>} : f32
        %230 = affine.load %arg3[%arg7 * 8 + 5, %arg9 * 7 + 5] {partition_indices = [5, 5], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %231 = arith.mulf %214, %230 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f32
        %232 = arith.addf %195, %231 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f32
        %233 = affine.load %arg3[%arg7 * 8 + 5, %arg9 * 7 + 6] {partition_indices = [5, 6], timing = #hlscpp.t<31 -> 33, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %234 = arith.mulf %214, %233 {timing = #hlscpp.t<33 -> 37, 4, 1>} : f32
        %235 = arith.addf %198, %234 {timing = #hlscpp.t<37 -> 42, 5, 1>} : f32
        %236 = affine.load %arg2[%arg8 * 2 + 1, %arg7 * 8 + 5] {partition_indices = [1, 5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %237 = arith.mulf %236, %215 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f32
        %238 = arith.addf %201, %237 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f32
        %239 = arith.mulf %236, %218 {timing = #hlscpp.t<28 -> 32, 4, 1>} : f32
        %240 = arith.addf %203, %239 {timing = #hlscpp.t<32 -> 37, 5, 1>} : f32
        %241 = arith.mulf %236, %221 {timing = #hlscpp.t<29 -> 33, 4, 1>} : f32
        %242 = arith.addf %205, %241 {timing = #hlscpp.t<33 -> 38, 5, 1>} : f32
        %243 = arith.mulf %236, %224 {timing = #hlscpp.t<30 -> 34, 4, 1>} : f32
        %244 = arith.addf %207, %243 {timing = #hlscpp.t<34 -> 39, 5, 1>} : f32
        %245 = arith.mulf %236, %227 {timing = #hlscpp.t<31 -> 35, 4, 1>} : f32
        %246 = arith.addf %209, %245 {timing = #hlscpp.t<35 -> 40, 5, 1>} : f32
        %247 = arith.mulf %236, %230 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f32
        %248 = arith.addf %211, %247 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f32
        %249 = arith.mulf %236, %233 {timing = #hlscpp.t<33 -> 37, 4, 1>} : f32
        %250 = arith.addf %213, %249 {timing = #hlscpp.t<37 -> 42, 5, 1>} : f32
        %251 = affine.load %arg2[%arg8 * 2, %arg7 * 8 + 6] {partition_indices = [0, 6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %252 = affine.load %arg3[%arg7 * 8 + 6, %arg9 * 7] {partition_indices = [6, 0], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %253 = arith.mulf %251, %252 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f32
        %254 = arith.addf %217, %253 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f32
        %255 = affine.load %arg3[%arg7 * 8 + 6, %arg9 * 7 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<31 -> 33, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %256 = arith.mulf %251, %255 {timing = #hlscpp.t<33 -> 37, 4, 1>} : f32
        %257 = arith.addf %220, %256 {timing = #hlscpp.t<37 -> 42, 5, 1>} : f32
        %258 = affine.load %arg3[%arg7 * 8 + 6, %arg9 * 7 + 2] {partition_indices = [6, 2], timing = #hlscpp.t<32 -> 34, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %259 = arith.mulf %251, %258 {timing = #hlscpp.t<34 -> 38, 4, 1>} : f32
        %260 = arith.addf %223, %259 {timing = #hlscpp.t<38 -> 43, 5, 1>} : f32
        %261 = affine.load %arg3[%arg7 * 8 + 6, %arg9 * 7 + 3] {partition_indices = [6, 3], timing = #hlscpp.t<33 -> 35, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %262 = arith.mulf %251, %261 {timing = #hlscpp.t<35 -> 39, 4, 1>} : f32
        %263 = arith.addf %226, %262 {timing = #hlscpp.t<39 -> 44, 5, 1>} : f32
        %264 = affine.load %arg3[%arg7 * 8 + 6, %arg9 * 7 + 4] {partition_indices = [6, 4], timing = #hlscpp.t<34 -> 36, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %265 = arith.mulf %251, %264 {timing = #hlscpp.t<36 -> 40, 4, 1>} : f32
        %266 = arith.addf %229, %265 {timing = #hlscpp.t<40 -> 45, 5, 1>} : f32
        %267 = affine.load %arg3[%arg7 * 8 + 6, %arg9 * 7 + 5] {partition_indices = [6, 5], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %268 = arith.mulf %251, %267 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f32
        %269 = arith.addf %232, %268 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f32
        %270 = affine.load %arg3[%arg7 * 8 + 6, %arg9 * 7 + 6] {partition_indices = [6, 6], timing = #hlscpp.t<36 -> 38, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %271 = arith.mulf %251, %270 {timing = #hlscpp.t<38 -> 42, 4, 1>} : f32
        %272 = arith.addf %235, %271 {timing = #hlscpp.t<42 -> 47, 5, 1>} : f32
        %273 = affine.load %arg2[%arg8 * 2 + 1, %arg7 * 8 + 6] {partition_indices = [1, 6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %274 = arith.mulf %273, %252 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f32
        %275 = arith.addf %238, %274 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f32
        %276 = arith.mulf %273, %255 {timing = #hlscpp.t<33 -> 37, 4, 1>} : f32
        %277 = arith.addf %240, %276 {timing = #hlscpp.t<37 -> 42, 5, 1>} : f32
        %278 = arith.mulf %273, %258 {timing = #hlscpp.t<34 -> 38, 4, 1>} : f32
        %279 = arith.addf %242, %278 {timing = #hlscpp.t<38 -> 43, 5, 1>} : f32
        %280 = arith.mulf %273, %261 {timing = #hlscpp.t<35 -> 39, 4, 1>} : f32
        %281 = arith.addf %244, %280 {timing = #hlscpp.t<39 -> 44, 5, 1>} : f32
        %282 = arith.mulf %273, %264 {timing = #hlscpp.t<36 -> 40, 4, 1>} : f32
        %283 = arith.addf %246, %282 {timing = #hlscpp.t<40 -> 45, 5, 1>} : f32
        %284 = arith.mulf %273, %267 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f32
        %285 = arith.addf %248, %284 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f32
        %286 = arith.mulf %273, %270 {timing = #hlscpp.t<38 -> 42, 4, 1>} : f32
        %287 = arith.addf %250, %286 {timing = #hlscpp.t<42 -> 47, 5, 1>} : f32
        %288 = affine.load %arg2[%arg8 * 2, %arg7 * 8 + 7] {partition_indices = [0, 7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %289 = affine.load %arg3[%arg7 * 8 + 7, %arg9 * 7] {partition_indices = [7, 0], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %290 = arith.mulf %288, %289 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f32
        %291 = arith.addf %254, %290 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f32
        affine.store %291, %arg5[%arg8 * 2, %arg9 * 7] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<46 -> 47, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %292 = affine.load %arg3[%arg7 * 8 + 7, %arg9 * 7 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<36 -> 38, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %293 = arith.mulf %288, %292 {timing = #hlscpp.t<38 -> 42, 4, 1>} : f32
        %294 = arith.addf %257, %293 {timing = #hlscpp.t<42 -> 47, 5, 1>} : f32
        affine.store %294, %arg5[%arg8 * 2, %arg9 * 7 + 1] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<47 -> 48, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %295 = affine.load %arg3[%arg7 * 8 + 7, %arg9 * 7 + 2] {partition_indices = [7, 2], timing = #hlscpp.t<37 -> 39, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %296 = arith.mulf %288, %295 {timing = #hlscpp.t<39 -> 43, 4, 1>} : f32
        %297 = arith.addf %260, %296 {timing = #hlscpp.t<43 -> 48, 5, 1>} : f32
        affine.store %297, %arg5[%arg8 * 2, %arg9 * 7 + 2] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<48 -> 49, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %298 = affine.load %arg3[%arg7 * 8 + 7, %arg9 * 7 + 3] {partition_indices = [7, 3], timing = #hlscpp.t<38 -> 40, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %299 = arith.mulf %288, %298 {timing = #hlscpp.t<40 -> 44, 4, 1>} : f32
        %300 = arith.addf %263, %299 {timing = #hlscpp.t<44 -> 49, 5, 1>} : f32
        affine.store %300, %arg5[%arg8 * 2, %arg9 * 7 + 3] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<49 -> 50, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %301 = affine.load %arg3[%arg7 * 8 + 7, %arg9 * 7 + 4] {partition_indices = [7, 4], timing = #hlscpp.t<39 -> 41, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %302 = arith.mulf %288, %301 {timing = #hlscpp.t<41 -> 45, 4, 1>} : f32
        %303 = arith.addf %266, %302 {timing = #hlscpp.t<45 -> 50, 5, 1>} : f32
        affine.store %303, %arg5[%arg8 * 2, %arg9 * 7 + 4] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<50 -> 51, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %304 = affine.load %arg3[%arg7 * 8 + 7, %arg9 * 7 + 5] {partition_indices = [7, 5], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %305 = arith.mulf %288, %304 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f32
        %306 = arith.addf %269, %305 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f32
        affine.store %306, %arg5[%arg8 * 2, %arg9 * 7 + 5] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<51 -> 52, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %307 = affine.load %arg3[%arg7 * 8 + 7, %arg9 * 7 + 6] {partition_indices = [7, 6], timing = #hlscpp.t<41 -> 43, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 7, d0 floordiv 8, d1 floordiv 7)>, 1>
        %308 = arith.mulf %288, %307 {timing = #hlscpp.t<43 -> 47, 4, 1>} : f32
        %309 = arith.addf %272, %308 {timing = #hlscpp.t<47 -> 52, 5, 1>} : f32
        affine.store %309, %arg5[%arg8 * 2, %arg9 * 7 + 6] {max_mux_size = 14 : i64, partition_indices = [0, -1], timing = #hlscpp.t<52 -> 53, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %310 = affine.load %arg2[%arg8 * 2 + 1, %arg7 * 8 + 7] {partition_indices = [1, 7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 8, d0 floordiv 2, d1 floordiv 8)>, 1>
        %311 = arith.mulf %310, %289 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f32
        %312 = arith.addf %275, %311 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f32
        affine.store %312, %arg5[%arg8 * 2 + 1, %arg9 * 7] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<46 -> 47, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %313 = arith.mulf %310, %292 {timing = #hlscpp.t<38 -> 42, 4, 1>} : f32
        %314 = arith.addf %277, %313 {timing = #hlscpp.t<42 -> 47, 5, 1>} : f32
        affine.store %314, %arg5[%arg8 * 2 + 1, %arg9 * 7 + 1] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<47 -> 48, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %315 = arith.mulf %310, %295 {timing = #hlscpp.t<39 -> 43, 4, 1>} : f32
        %316 = arith.addf %279, %315 {timing = #hlscpp.t<43 -> 48, 5, 1>} : f32
        affine.store %316, %arg5[%arg8 * 2 + 1, %arg9 * 7 + 2] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<48 -> 49, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %317 = arith.mulf %310, %298 {timing = #hlscpp.t<40 -> 44, 4, 1>} : f32
        %318 = arith.addf %281, %317 {timing = #hlscpp.t<44 -> 49, 5, 1>} : f32
        affine.store %318, %arg5[%arg8 * 2 + 1, %arg9 * 7 + 3] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<49 -> 50, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %319 = arith.mulf %310, %301 {timing = #hlscpp.t<41 -> 45, 4, 1>} : f32
        %320 = arith.addf %283, %319 {timing = #hlscpp.t<45 -> 50, 5, 1>} : f32
        affine.store %320, %arg5[%arg8 * 2 + 1, %arg9 * 7 + 4] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<50 -> 51, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %321 = arith.mulf %310, %304 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f32
        %322 = arith.addf %285, %321 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f32
        affine.store %322, %arg5[%arg8 * 2 + 1, %arg9 * 7 + 5] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<51 -> 52, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %323 = arith.mulf %310, %307 {timing = #hlscpp.t<43 -> 47, 4, 1>} : f32
        %324 = arith.addf %287, %323 {timing = #hlscpp.t<47 -> 52, 5, 1>} : f32
        affine.store %324, %arg5[%arg8 * 2 + 1, %arg9 * 7 + 6] {max_mux_size = 14 : i64, partition_indices = [1, -1], timing = #hlscpp.t<52 -> 53, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=3, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=10, iterLatency=53, minII=43>, resource = #hlscpp.r<lut=0, dsp=13, bram=0, nonShareDsp=560>, timing = #hlscpp.t<3761 -> 4203, 442, 442>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=250, iterLatency=53, minII=43>, resource = #hlscpp.r<lut=0, dsp=13, bram=0, nonShareDsp=560>, timing = #hlscpp.t<3761 -> 14523, 10762, 10762>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=2500, iterLatency=53, minII=43>, resource = #hlscpp.r<lut=0, dsp=13, bram=0, nonShareDsp=560>, timing = #hlscpp.t<28810 -> 136322, 107512, 107512>}
  affine.for %arg7 = 0 to 50 {
    affine.for %arg8 = 0 to 5 {
      affine.for %arg9 = 0 to 5 {
        %1 = affine.load %arg4[%arg8 * 8, %arg7] {max_mux_size = 5 : i64, partition_indices = [0, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %2 = affine.load %arg5[%arg7, %arg9 * 14] {max_mux_size = 2 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %3 = arith.mulf %1, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %4 = affine.load %arg6[%arg8 * 8, %arg9 * 14] {partition_indices = [0, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %5 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %4 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %6 = arith.addf %5, %3 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %6, %arg6[%arg8 * 8, %arg9 * 14] {partition_indices = [0, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %7 = affine.load %arg5[%arg7, %arg9 * 14 + 1] {max_mux_size = 2 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %8 = arith.mulf %1, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %9 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %10 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %9 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %11 = arith.addf %10, %8 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %11, %arg6[%arg8 * 8, %arg9 * 14 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %12 = affine.load %arg5[%arg7, %arg9 * 14 + 2] {max_mux_size = 2 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %13 = arith.mulf %1, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %14 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %15 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %14 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %16 = arith.addf %15, %13 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %16, %arg6[%arg8 * 8, %arg9 * 14 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %17 = affine.load %arg5[%arg7, %arg9 * 14 + 3] {max_mux_size = 2 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %18 = arith.mulf %1, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %19 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %20 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %19 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %21 = arith.addf %20, %18 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %21, %arg6[%arg8 * 8, %arg9 * 14 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %22 = affine.load %arg5[%arg7, %arg9 * 14 + 4] {max_mux_size = 2 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %23 = arith.mulf %1, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %24 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %25 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %24 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %26 = arith.addf %25, %23 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %26, %arg6[%arg8 * 8, %arg9 * 14 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %27 = affine.load %arg5[%arg7, %arg9 * 14 + 5] {max_mux_size = 2 : i64, partition_indices = [-1, 5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %28 = arith.mulf %1, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %29 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 5] {partition_indices = [0, 5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %30 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %29 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %31 = arith.addf %30, %28 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %31, %arg6[%arg8 * 8, %arg9 * 14 + 5] {partition_indices = [0, 5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %32 = affine.load %arg5[%arg7, %arg9 * 14 + 6] {max_mux_size = 2 : i64, partition_indices = [-1, 6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %33 = arith.mulf %1, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %34 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 6] {partition_indices = [0, 6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %35 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %34 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %36 = arith.addf %35, %33 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %36, %arg6[%arg8 * 8, %arg9 * 14 + 6] {partition_indices = [0, 6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %37 = affine.load %arg5[%arg7, %arg9 * 14 + 7] {max_mux_size = 2 : i64, partition_indices = [-1, 7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %38 = arith.mulf %1, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %39 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 7] {partition_indices = [0, 7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %40 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %39 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %41 = arith.addf %40, %38 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %41, %arg6[%arg8 * 8, %arg9 * 14 + 7] {partition_indices = [0, 7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %42 = affine.load %arg5[%arg7, %arg9 * 14 + 8] {max_mux_size = 2 : i64, partition_indices = [-1, 8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %43 = arith.mulf %1, %42 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %44 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 8] {partition_indices = [0, 8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %45 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %44 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %46 = arith.addf %45, %43 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %46, %arg6[%arg8 * 8, %arg9 * 14 + 8] {partition_indices = [0, 8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %47 = affine.load %arg5[%arg7, %arg9 * 14 + 9] {max_mux_size = 2 : i64, partition_indices = [-1, 9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %48 = arith.mulf %1, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %49 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 9] {partition_indices = [0, 9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %50 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %49 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %51 = arith.addf %50, %48 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %51, %arg6[%arg8 * 8, %arg9 * 14 + 9] {partition_indices = [0, 9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %52 = affine.load %arg5[%arg7, %arg9 * 14 + 10] {max_mux_size = 2 : i64, partition_indices = [-1, 10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %53 = arith.mulf %1, %52 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %54 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 10] {partition_indices = [0, 10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %55 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %54 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %56 = arith.addf %55, %53 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %56, %arg6[%arg8 * 8, %arg9 * 14 + 10] {partition_indices = [0, 10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %57 = affine.load %arg5[%arg7, %arg9 * 14 + 11] {max_mux_size = 2 : i64, partition_indices = [-1, 11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %58 = arith.mulf %1, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %59 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 11] {partition_indices = [0, 11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %60 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %59 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %61 = arith.addf %60, %58 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %61, %arg6[%arg8 * 8, %arg9 * 14 + 11] {partition_indices = [0, 11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %62 = affine.load %arg5[%arg7, %arg9 * 14 + 12] {max_mux_size = 2 : i64, partition_indices = [-1, 12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %63 = arith.mulf %1, %62 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %64 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 12] {partition_indices = [0, 12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %65 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %64 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %66 = arith.addf %65, %63 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %66, %arg6[%arg8 * 8, %arg9 * 14 + 12] {partition_indices = [0, 12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %67 = affine.load %arg5[%arg7, %arg9 * 14 + 13] {max_mux_size = 2 : i64, partition_indices = [-1, 13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 14, d0 floordiv 2, d1 floordiv 14)>, 1>
        %68 = arith.mulf %1, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %69 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 13] {partition_indices = [0, 13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %70 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %69 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %71 = arith.addf %70, %68 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %71, %arg6[%arg8 * 8, %arg9 * 14 + 13] {partition_indices = [0, 13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %72 = affine.load %arg4[%arg8 * 8 + 1, %arg7] {max_mux_size = 5 : i64, partition_indices = [1, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %73 = arith.mulf %72, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %74 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14] {partition_indices = [1, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %75 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %74 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %76 = arith.addf %75, %73 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %76, %arg6[%arg8 * 8 + 1, %arg9 * 14] {partition_indices = [1, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %77 = arith.mulf %72, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %78 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %79 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %78 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %80 = arith.addf %79, %77 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %80, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %81 = arith.mulf %72, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %82 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %83 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %82 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %84 = arith.addf %83, %81 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %84, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %85 = arith.mulf %72, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %86 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 3] {partition_indices = [1, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %87 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %86 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %88 = arith.addf %87, %85 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %88, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 3] {partition_indices = [1, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %89 = arith.mulf %72, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %90 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 4] {partition_indices = [1, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %91 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %90 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %92 = arith.addf %91, %89 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %92, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 4] {partition_indices = [1, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %93 = arith.mulf %72, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %94 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 5] {partition_indices = [1, 5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %95 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %94 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %96 = arith.addf %95, %93 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %96, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 5] {partition_indices = [1, 5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %97 = arith.mulf %72, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %98 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 6] {partition_indices = [1, 6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %99 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %98 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %100 = arith.addf %99, %97 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %100, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 6] {partition_indices = [1, 6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %101 = arith.mulf %72, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %102 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 7] {partition_indices = [1, 7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %103 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %102 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %104 = arith.addf %103, %101 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %104, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 7] {partition_indices = [1, 7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %105 = arith.mulf %72, %42 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %106 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 8] {partition_indices = [1, 8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %107 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %106 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %108 = arith.addf %107, %105 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %108, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 8] {partition_indices = [1, 8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %109 = arith.mulf %72, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %110 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 9] {partition_indices = [1, 9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %111 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %110 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %112 = arith.addf %111, %109 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %112, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 9] {partition_indices = [1, 9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %113 = arith.mulf %72, %52 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %114 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 10] {partition_indices = [1, 10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %115 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %114 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %116 = arith.addf %115, %113 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %116, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 10] {partition_indices = [1, 10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %117 = arith.mulf %72, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %118 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 11] {partition_indices = [1, 11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %119 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %118 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %120 = arith.addf %119, %117 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %120, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 11] {partition_indices = [1, 11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %121 = arith.mulf %72, %62 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %122 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 12] {partition_indices = [1, 12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %123 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %122 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %124 = arith.addf %123, %121 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %124, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 12] {partition_indices = [1, 12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %125 = arith.mulf %72, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %126 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 13] {partition_indices = [1, 13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %127 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %126 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %128 = arith.addf %127, %125 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %128, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 13] {partition_indices = [1, 13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %129 = affine.load %arg4[%arg8 * 8 + 2, %arg7] {max_mux_size = 5 : i64, partition_indices = [2, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %130 = arith.mulf %129, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %131 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14] {partition_indices = [2, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %132 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %131 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %133 = arith.addf %132, %130 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %133, %arg6[%arg8 * 8 + 2, %arg9 * 14] {partition_indices = [2, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %134 = arith.mulf %129, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %135 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %136 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %135 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %137 = arith.addf %136, %134 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %137, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %138 = arith.mulf %129, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %139 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %140 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %139 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %141 = arith.addf %140, %138 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %141, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %142 = arith.mulf %129, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %143 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 3] {partition_indices = [2, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %144 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %143 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %145 = arith.addf %144, %142 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %145, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 3] {partition_indices = [2, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %146 = arith.mulf %129, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %147 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 4] {partition_indices = [2, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %148 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %147 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %149 = arith.addf %148, %146 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %149, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 4] {partition_indices = [2, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %150 = arith.mulf %129, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %151 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 5] {partition_indices = [2, 5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %152 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %151 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %153 = arith.addf %152, %150 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %153, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 5] {partition_indices = [2, 5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %154 = arith.mulf %129, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %155 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 6] {partition_indices = [2, 6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %156 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %155 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %157 = arith.addf %156, %154 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %157, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 6] {partition_indices = [2, 6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %158 = arith.mulf %129, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %159 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 7] {partition_indices = [2, 7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %160 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %159 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %161 = arith.addf %160, %158 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %161, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 7] {partition_indices = [2, 7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %162 = arith.mulf %129, %42 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %163 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 8] {partition_indices = [2, 8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %164 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %163 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %165 = arith.addf %164, %162 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %165, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 8] {partition_indices = [2, 8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %166 = arith.mulf %129, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %167 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 9] {partition_indices = [2, 9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %168 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %167 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %169 = arith.addf %168, %166 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %169, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 9] {partition_indices = [2, 9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %170 = arith.mulf %129, %52 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %171 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 10] {partition_indices = [2, 10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %172 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %171 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %173 = arith.addf %172, %170 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %173, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 10] {partition_indices = [2, 10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %174 = arith.mulf %129, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %175 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 11] {partition_indices = [2, 11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %176 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %175 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %177 = arith.addf %176, %174 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %177, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 11] {partition_indices = [2, 11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %178 = arith.mulf %129, %62 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %179 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 12] {partition_indices = [2, 12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %180 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %179 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %181 = arith.addf %180, %178 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %181, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 12] {partition_indices = [2, 12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %182 = arith.mulf %129, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %183 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 13] {partition_indices = [2, 13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %184 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %183 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %185 = arith.addf %184, %182 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %185, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 13] {partition_indices = [2, 13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %186 = affine.load %arg4[%arg8 * 8 + 3, %arg7] {max_mux_size = 5 : i64, partition_indices = [3, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %187 = arith.mulf %186, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %188 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14] {partition_indices = [3, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %189 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %188 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %190 = arith.addf %189, %187 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %190, %arg6[%arg8 * 8 + 3, %arg9 * 14] {partition_indices = [3, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %191 = arith.mulf %186, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %192 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %193 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %192 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %194 = arith.addf %193, %191 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %194, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %195 = arith.mulf %186, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %196 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 2] {partition_indices = [3, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %197 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %196 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %198 = arith.addf %197, %195 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %198, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 2] {partition_indices = [3, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %199 = arith.mulf %186, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %200 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 3] {partition_indices = [3, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %201 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %200 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %202 = arith.addf %201, %199 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %202, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 3] {partition_indices = [3, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %203 = arith.mulf %186, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %204 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 4] {partition_indices = [3, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %205 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %204 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %206 = arith.addf %205, %203 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %206, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 4] {partition_indices = [3, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %207 = arith.mulf %186, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %208 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 5] {partition_indices = [3, 5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %209 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %208 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %210 = arith.addf %209, %207 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %210, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 5] {partition_indices = [3, 5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %211 = arith.mulf %186, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %212 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 6] {partition_indices = [3, 6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %213 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %212 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %214 = arith.addf %213, %211 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %214, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 6] {partition_indices = [3, 6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %215 = arith.mulf %186, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %216 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 7] {partition_indices = [3, 7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %217 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %216 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %218 = arith.addf %217, %215 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %218, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 7] {partition_indices = [3, 7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %219 = arith.mulf %186, %42 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %220 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 8] {partition_indices = [3, 8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %221 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %220 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %222 = arith.addf %221, %219 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %222, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 8] {partition_indices = [3, 8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %223 = arith.mulf %186, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %224 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 9] {partition_indices = [3, 9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %225 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %224 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %226 = arith.addf %225, %223 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %226, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 9] {partition_indices = [3, 9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %227 = arith.mulf %186, %52 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %228 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 10] {partition_indices = [3, 10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %229 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %228 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %230 = arith.addf %229, %227 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %230, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 10] {partition_indices = [3, 10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %231 = arith.mulf %186, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %232 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 11] {partition_indices = [3, 11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %233 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %232 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %234 = arith.addf %233, %231 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %234, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 11] {partition_indices = [3, 11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %235 = arith.mulf %186, %62 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %236 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 12] {partition_indices = [3, 12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %237 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %236 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %238 = arith.addf %237, %235 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %238, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 12] {partition_indices = [3, 12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %239 = arith.mulf %186, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %240 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 13] {partition_indices = [3, 13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %241 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %240 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %242 = arith.addf %241, %239 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %242, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 13] {partition_indices = [3, 13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %243 = affine.load %arg4[%arg8 * 8 + 4, %arg7] {max_mux_size = 5 : i64, partition_indices = [4, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %244 = arith.mulf %243, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %245 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14] {partition_indices = [4, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %246 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %245 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %247 = arith.addf %246, %244 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %247, %arg6[%arg8 * 8 + 4, %arg9 * 14] {partition_indices = [4, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %248 = arith.mulf %243, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %249 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %250 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %249 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %251 = arith.addf %250, %248 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %251, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %252 = arith.mulf %243, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %253 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 2] {partition_indices = [4, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %254 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %253 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %255 = arith.addf %254, %252 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %255, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 2] {partition_indices = [4, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %256 = arith.mulf %243, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %257 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 3] {partition_indices = [4, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %258 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %257 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %259 = arith.addf %258, %256 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %259, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 3] {partition_indices = [4, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %260 = arith.mulf %243, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %261 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 4] {partition_indices = [4, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %262 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %261 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %263 = arith.addf %262, %260 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %263, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 4] {partition_indices = [4, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %264 = arith.mulf %243, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %265 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 5] {partition_indices = [4, 5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %266 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %265 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %267 = arith.addf %266, %264 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %267, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 5] {partition_indices = [4, 5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %268 = arith.mulf %243, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %269 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 6] {partition_indices = [4, 6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %270 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %269 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %271 = arith.addf %270, %268 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %271, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 6] {partition_indices = [4, 6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %272 = arith.mulf %243, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %273 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 7] {partition_indices = [4, 7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %274 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %273 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %275 = arith.addf %274, %272 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %275, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 7] {partition_indices = [4, 7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %276 = arith.mulf %243, %42 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %277 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 8] {partition_indices = [4, 8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %278 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %277 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %279 = arith.addf %278, %276 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %279, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 8] {partition_indices = [4, 8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %280 = arith.mulf %243, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %281 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 9] {partition_indices = [4, 9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %282 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %281 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %283 = arith.addf %282, %280 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %283, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 9] {partition_indices = [4, 9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %284 = arith.mulf %243, %52 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %285 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 10] {partition_indices = [4, 10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %286 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %285 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %287 = arith.addf %286, %284 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %287, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 10] {partition_indices = [4, 10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %288 = arith.mulf %243, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %289 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 11] {partition_indices = [4, 11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %290 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %289 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %291 = arith.addf %290, %288 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %291, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 11] {partition_indices = [4, 11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %292 = arith.mulf %243, %62 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %293 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 12] {partition_indices = [4, 12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %294 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %293 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %295 = arith.addf %294, %292 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %295, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 12] {partition_indices = [4, 12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %296 = arith.mulf %243, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %297 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 13] {partition_indices = [4, 13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %298 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %297 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %299 = arith.addf %298, %296 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %299, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 13] {partition_indices = [4, 13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %300 = affine.load %arg4[%arg8 * 8 + 5, %arg7] {max_mux_size = 5 : i64, partition_indices = [5, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %301 = arith.mulf %300, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %302 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14] {partition_indices = [5, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %303 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %302 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %304 = arith.addf %303, %301 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %304, %arg6[%arg8 * 8 + 5, %arg9 * 14] {partition_indices = [5, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %305 = arith.mulf %300, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %306 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %307 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %306 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %308 = arith.addf %307, %305 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %308, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %309 = arith.mulf %300, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %310 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 2] {partition_indices = [5, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %311 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %310 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %312 = arith.addf %311, %309 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %312, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 2] {partition_indices = [5, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %313 = arith.mulf %300, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %314 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 3] {partition_indices = [5, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %315 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %314 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %316 = arith.addf %315, %313 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %316, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 3] {partition_indices = [5, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %317 = arith.mulf %300, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %318 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 4] {partition_indices = [5, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %319 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %318 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %320 = arith.addf %319, %317 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %320, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 4] {partition_indices = [5, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %321 = arith.mulf %300, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %322 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 5] {partition_indices = [5, 5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %323 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %322 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %324 = arith.addf %323, %321 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %324, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 5] {partition_indices = [5, 5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %325 = arith.mulf %300, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %326 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 6] {partition_indices = [5, 6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %327 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %326 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %328 = arith.addf %327, %325 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %328, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 6] {partition_indices = [5, 6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %329 = arith.mulf %300, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %330 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 7] {partition_indices = [5, 7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %331 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %330 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %332 = arith.addf %331, %329 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %332, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 7] {partition_indices = [5, 7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %333 = arith.mulf %300, %42 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %334 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 8] {partition_indices = [5, 8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %335 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %334 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %336 = arith.addf %335, %333 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %336, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 8] {partition_indices = [5, 8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %337 = arith.mulf %300, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %338 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 9] {partition_indices = [5, 9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %339 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %338 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %340 = arith.addf %339, %337 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %340, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 9] {partition_indices = [5, 9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %341 = arith.mulf %300, %52 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %342 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 10] {partition_indices = [5, 10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %343 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %342 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %344 = arith.addf %343, %341 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %344, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 10] {partition_indices = [5, 10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %345 = arith.mulf %300, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %346 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 11] {partition_indices = [5, 11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %347 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %346 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %348 = arith.addf %347, %345 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %348, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 11] {partition_indices = [5, 11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %349 = arith.mulf %300, %62 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %350 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 12] {partition_indices = [5, 12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %351 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %350 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %352 = arith.addf %351, %349 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %352, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 12] {partition_indices = [5, 12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %353 = arith.mulf %300, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %354 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 13] {partition_indices = [5, 13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %355 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %354 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %356 = arith.addf %355, %353 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %356, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 13] {partition_indices = [5, 13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %357 = affine.load %arg4[%arg8 * 8 + 6, %arg7] {max_mux_size = 5 : i64, partition_indices = [6, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %358 = arith.mulf %357, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %359 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14] {partition_indices = [6, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %360 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %359 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %361 = arith.addf %360, %358 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %361, %arg6[%arg8 * 8 + 6, %arg9 * 14] {partition_indices = [6, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %362 = arith.mulf %357, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %363 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %364 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %363 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %365 = arith.addf %364, %362 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %365, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %366 = arith.mulf %357, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %367 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 2] {partition_indices = [6, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %368 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %367 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %369 = arith.addf %368, %366 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %369, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 2] {partition_indices = [6, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %370 = arith.mulf %357, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %371 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 3] {partition_indices = [6, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %372 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %371 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %373 = arith.addf %372, %370 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %373, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 3] {partition_indices = [6, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %374 = arith.mulf %357, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %375 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 4] {partition_indices = [6, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %376 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %375 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %377 = arith.addf %376, %374 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %377, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 4] {partition_indices = [6, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %378 = arith.mulf %357, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %379 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 5] {partition_indices = [6, 5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %380 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %379 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %381 = arith.addf %380, %378 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %381, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 5] {partition_indices = [6, 5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %382 = arith.mulf %357, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %383 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 6] {partition_indices = [6, 6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %384 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %383 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %385 = arith.addf %384, %382 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %385, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 6] {partition_indices = [6, 6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %386 = arith.mulf %357, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %387 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 7] {partition_indices = [6, 7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %388 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %387 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %389 = arith.addf %388, %386 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %389, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 7] {partition_indices = [6, 7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %390 = arith.mulf %357, %42 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %391 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 8] {partition_indices = [6, 8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %392 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %391 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %393 = arith.addf %392, %390 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %393, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 8] {partition_indices = [6, 8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %394 = arith.mulf %357, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %395 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 9] {partition_indices = [6, 9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %396 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %395 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %397 = arith.addf %396, %394 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %397, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 9] {partition_indices = [6, 9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %398 = arith.mulf %357, %52 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %399 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 10] {partition_indices = [6, 10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %400 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %399 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %401 = arith.addf %400, %398 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %401, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 10] {partition_indices = [6, 10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %402 = arith.mulf %357, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %403 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 11] {partition_indices = [6, 11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %404 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %403 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %405 = arith.addf %404, %402 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %405, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 11] {partition_indices = [6, 11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %406 = arith.mulf %357, %62 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %407 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 12] {partition_indices = [6, 12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %408 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %407 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %409 = arith.addf %408, %406 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %409, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 12] {partition_indices = [6, 12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %410 = arith.mulf %357, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %411 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 13] {partition_indices = [6, 13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %412 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %411 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %413 = arith.addf %412, %410 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %413, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 13] {partition_indices = [6, 13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %414 = affine.load %arg4[%arg8 * 8 + 7, %arg7] {max_mux_size = 5 : i64, partition_indices = [7, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %415 = arith.mulf %414, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %416 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14] {partition_indices = [7, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %417 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %416 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %418 = arith.addf %417, %415 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %418, %arg6[%arg8 * 8 + 7, %arg9 * 14] {partition_indices = [7, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %419 = arith.mulf %414, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %420 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %421 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %420 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %422 = arith.addf %421, %419 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %422, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %423 = arith.mulf %414, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %424 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 2] {partition_indices = [7, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %425 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %424 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %426 = arith.addf %425, %423 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %426, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 2] {partition_indices = [7, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %427 = arith.mulf %414, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %428 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 3] {partition_indices = [7, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %429 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %428 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %430 = arith.addf %429, %427 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %430, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 3] {partition_indices = [7, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %431 = arith.mulf %414, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %432 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 4] {partition_indices = [7, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %433 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %432 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %434 = arith.addf %433, %431 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %434, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 4] {partition_indices = [7, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %435 = arith.mulf %414, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %436 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 5] {partition_indices = [7, 5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %437 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %436 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %438 = arith.addf %437, %435 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %438, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 5] {partition_indices = [7, 5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %439 = arith.mulf %414, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %440 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 6] {partition_indices = [7, 6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %441 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %440 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %442 = arith.addf %441, %439 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %442, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 6] {partition_indices = [7, 6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %443 = arith.mulf %414, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %444 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 7] {partition_indices = [7, 7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %445 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %444 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %446 = arith.addf %445, %443 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %446, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 7] {partition_indices = [7, 7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %447 = arith.mulf %414, %42 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %448 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 8] {partition_indices = [7, 8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %449 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %448 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %450 = arith.addf %449, %447 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %450, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 8] {partition_indices = [7, 8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %451 = arith.mulf %414, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %452 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 9] {partition_indices = [7, 9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %453 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %452 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %454 = arith.addf %453, %451 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %454, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 9] {partition_indices = [7, 9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %455 = arith.mulf %414, %52 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %456 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 10] {partition_indices = [7, 10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %457 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %456 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %458 = arith.addf %457, %455 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %458, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 10] {partition_indices = [7, 10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %459 = arith.mulf %414, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %460 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 11] {partition_indices = [7, 11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %461 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %460 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %462 = arith.addf %461, %459 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %462, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 11] {partition_indices = [7, 11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %463 = arith.mulf %414, %62 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %464 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 12] {partition_indices = [7, 12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %465 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %464 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %466 = arith.addf %465, %463 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %466, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 12] {partition_indices = [7, 12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %467 = arith.mulf %414, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %468 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 13] {partition_indices = [7, 13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
        %469 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %468 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %470 = arith.addf %469, %467 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %470, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 13] {partition_indices = [7, 13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=3, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=5, iterLatency=12, minII=3>, resource = #hlscpp.r<lut=0, dsp=186, bram=0, nonShareDsp=560>, timing = #hlscpp.t<0 -> 26, 26, 26>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=25, iterLatency=12, minII=3>, resource = #hlscpp.r<lut=0, dsp=186, bram=0, nonShareDsp=560>, timing = #hlscpp.t<0 -> 86, 86, 86>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=1250, iterLatency=12, minII=3>, resource = #hlscpp.r<lut=0, dsp=186, bram=0, nonShareDsp=560>, timing = #hlscpp.t<136322 -> 140083, 3761, 3761>}
  return {timing = #hlscpp.t<140083 -> 140083, 0, 0>}
}
