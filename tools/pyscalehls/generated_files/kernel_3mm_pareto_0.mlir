func @kernel_3mm(%arg0: memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>, %arg1: memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>, 1>, %arg2: memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>, %arg3: memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>, 1>, %arg4: memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>, %arg5: memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>, %arg6: memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=455, bram=0, nonShareDsp=640>, timing = #hlscpp.t<0 -> 97045, 97045, 97045>} {
  %c0_i32 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0 : i32
  %0 = arith.sitofp %c0_i32 {timing = #hlscpp.t<0 -> 0, 0, 0>} : i32 to f32
  affine.for %arg7 = 0 to 20 {
    affine.for %arg8 = 0 to 5 {
      affine.for %arg9 = 0 to 25 {
        %1 = affine.load %arg0[%arg8 * 8, %arg7 * 3] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %2 = affine.load %arg1[%arg7 * 3, %arg9 * 2] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>, 1>
        %3 = arith.mulf %1, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %4 = affine.load %arg4[%arg8 * 8, %arg9 * 2] {partition_indices = [0, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %5 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %4 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %6 = arith.addf %5, %3 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %7 = affine.load %arg1[%arg7 * 3, %arg9 * 2 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>, 1>
        %8 = arith.mulf %1, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %9 = affine.load %arg4[%arg8 * 8, %arg9 * 2 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %10 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %9 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %11 = arith.addf %10, %8 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %12 = affine.load %arg0[%arg8 * 8 + 1, %arg7 * 3] {partition_indices = [1, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %13 = arith.mulf %12, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %14 = affine.load %arg4[%arg8 * 8 + 1, %arg9 * 2] {partition_indices = [1, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %15 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %14 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %16 = arith.addf %15, %13 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %17 = arith.mulf %12, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %18 = affine.load %arg4[%arg8 * 8 + 1, %arg9 * 2 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %19 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %18 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %20 = arith.addf %19, %17 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %21 = affine.load %arg0[%arg8 * 8 + 2, %arg7 * 3] {partition_indices = [2, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %22 = arith.mulf %21, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %23 = affine.load %arg4[%arg8 * 8 + 2, %arg9 * 2] {partition_indices = [2, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %24 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %23 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %25 = arith.addf %24, %22 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %26 = arith.mulf %21, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %27 = affine.load %arg4[%arg8 * 8 + 2, %arg9 * 2 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %28 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %27 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %29 = arith.addf %28, %26 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %30 = affine.load %arg0[%arg8 * 8 + 3, %arg7 * 3] {partition_indices = [3, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %31 = arith.mulf %30, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %32 = affine.load %arg4[%arg8 * 8 + 3, %arg9 * 2] {partition_indices = [3, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %33 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %32 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %34 = arith.addf %33, %31 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %35 = arith.mulf %30, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %36 = affine.load %arg4[%arg8 * 8 + 3, %arg9 * 2 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %37 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %36 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %38 = arith.addf %37, %35 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %39 = affine.load %arg0[%arg8 * 8 + 4, %arg7 * 3] {partition_indices = [4, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %40 = arith.mulf %39, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %41 = affine.load %arg4[%arg8 * 8 + 4, %arg9 * 2] {partition_indices = [4, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %42 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %41 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %43 = arith.addf %42, %40 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %44 = arith.mulf %39, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %45 = affine.load %arg4[%arg8 * 8 + 4, %arg9 * 2 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %46 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %45 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %47 = arith.addf %46, %44 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %48 = affine.load %arg0[%arg8 * 8 + 5, %arg7 * 3] {partition_indices = [5, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %49 = arith.mulf %48, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %50 = affine.load %arg4[%arg8 * 8 + 5, %arg9 * 2] {partition_indices = [5, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %51 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %50 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %52 = arith.addf %51, %49 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %53 = arith.mulf %48, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %54 = affine.load %arg4[%arg8 * 8 + 5, %arg9 * 2 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %55 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %54 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %56 = arith.addf %55, %53 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %57 = affine.load %arg0[%arg8 * 8 + 6, %arg7 * 3] {partition_indices = [6, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %58 = arith.mulf %57, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %59 = affine.load %arg4[%arg8 * 8 + 6, %arg9 * 2] {partition_indices = [6, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %60 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %59 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %61 = arith.addf %60, %58 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %62 = arith.mulf %57, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %63 = affine.load %arg4[%arg8 * 8 + 6, %arg9 * 2 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %64 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %63 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %65 = arith.addf %64, %62 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %66 = affine.load %arg0[%arg8 * 8 + 7, %arg7 * 3] {partition_indices = [7, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %67 = arith.mulf %66, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %68 = affine.load %arg4[%arg8 * 8 + 7, %arg9 * 2] {partition_indices = [7, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %69 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %68 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %70 = arith.addf %69, %67 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %71 = arith.mulf %66, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %72 = affine.load %arg4[%arg8 * 8 + 7, %arg9 * 2 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %73 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %72 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %74 = arith.addf %73, %71 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %75 = affine.load %arg0[%arg8 * 8, %arg7 * 3 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %76 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 2] {partition_indices = [1, 0], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>, 1>
        %77 = arith.mulf %75, %76 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %78 = arith.addf %6, %77 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %79 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 2 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>, 1>
        %80 = arith.mulf %75, %79 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %81 = arith.addf %11, %80 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %82 = affine.load %arg0[%arg8 * 8 + 1, %arg7 * 3 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %83 = arith.mulf %82, %76 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %84 = arith.addf %16, %83 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %85 = arith.mulf %82, %79 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %86 = arith.addf %20, %85 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %87 = affine.load %arg0[%arg8 * 8 + 2, %arg7 * 3 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %88 = arith.mulf %87, %76 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %89 = arith.addf %25, %88 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %90 = arith.mulf %87, %79 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %91 = arith.addf %29, %90 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %92 = affine.load %arg0[%arg8 * 8 + 3, %arg7 * 3 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %93 = arith.mulf %92, %76 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %94 = arith.addf %34, %93 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %95 = arith.mulf %92, %79 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %96 = arith.addf %38, %95 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %97 = affine.load %arg0[%arg8 * 8 + 4, %arg7 * 3 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %98 = arith.mulf %97, %76 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %99 = arith.addf %43, %98 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %100 = arith.mulf %97, %79 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %101 = arith.addf %47, %100 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %102 = affine.load %arg0[%arg8 * 8 + 5, %arg7 * 3 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %103 = arith.mulf %102, %76 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %104 = arith.addf %52, %103 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %105 = arith.mulf %102, %79 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %106 = arith.addf %56, %105 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %107 = affine.load %arg0[%arg8 * 8 + 6, %arg7 * 3 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %108 = arith.mulf %107, %76 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %109 = arith.addf %61, %108 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %110 = arith.mulf %107, %79 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %111 = arith.addf %65, %110 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %112 = affine.load %arg0[%arg8 * 8 + 7, %arg7 * 3 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %113 = arith.mulf %112, %76 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %114 = arith.addf %70, %113 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %115 = arith.mulf %112, %79 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %116 = arith.addf %74, %115 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %117 = affine.load %arg0[%arg8 * 8, %arg7 * 3 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %118 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 2] {partition_indices = [2, 0], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>, 1>
        %119 = arith.mulf %117, %118 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %120 = arith.addf %78, %119 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %120, %arg4[%arg8 * 8, %arg9 * 2] {partition_indices = [0, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %121 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 2 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>, 1>
        %122 = arith.mulf %117, %121 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %123 = arith.addf %81, %122 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %123, %arg4[%arg8 * 8, %arg9 * 2 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %124 = affine.load %arg0[%arg8 * 8 + 1, %arg7 * 3 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %125 = arith.mulf %124, %118 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %126 = arith.addf %84, %125 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %126, %arg4[%arg8 * 8 + 1, %arg9 * 2] {partition_indices = [1, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %127 = arith.mulf %124, %121 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %128 = arith.addf %86, %127 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %128, %arg4[%arg8 * 8 + 1, %arg9 * 2 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %129 = affine.load %arg0[%arg8 * 8 + 2, %arg7 * 3 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %130 = arith.mulf %129, %118 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %131 = arith.addf %89, %130 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %131, %arg4[%arg8 * 8 + 2, %arg9 * 2] {partition_indices = [2, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %132 = arith.mulf %129, %121 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %133 = arith.addf %91, %132 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %133, %arg4[%arg8 * 8 + 2, %arg9 * 2 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %134 = affine.load %arg0[%arg8 * 8 + 3, %arg7 * 3 + 2] {partition_indices = [3, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %135 = arith.mulf %134, %118 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %136 = arith.addf %94, %135 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %136, %arg4[%arg8 * 8 + 3, %arg9 * 2] {partition_indices = [3, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %137 = arith.mulf %134, %121 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %138 = arith.addf %96, %137 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %138, %arg4[%arg8 * 8 + 3, %arg9 * 2 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %139 = affine.load %arg0[%arg8 * 8 + 4, %arg7 * 3 + 2] {partition_indices = [4, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %140 = arith.mulf %139, %118 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %141 = arith.addf %99, %140 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %141, %arg4[%arg8 * 8 + 4, %arg9 * 2] {partition_indices = [4, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %142 = arith.mulf %139, %121 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %143 = arith.addf %101, %142 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %143, %arg4[%arg8 * 8 + 4, %arg9 * 2 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %144 = affine.load %arg0[%arg8 * 8 + 5, %arg7 * 3 + 2] {partition_indices = [5, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %145 = arith.mulf %144, %118 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %146 = arith.addf %104, %145 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %146, %arg4[%arg8 * 8 + 5, %arg9 * 2] {partition_indices = [5, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %147 = arith.mulf %144, %121 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %148 = arith.addf %106, %147 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %148, %arg4[%arg8 * 8 + 5, %arg9 * 2 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %149 = affine.load %arg0[%arg8 * 8 + 6, %arg7 * 3 + 2] {partition_indices = [6, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %150 = arith.mulf %149, %118 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %151 = arith.addf %109, %150 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %151, %arg4[%arg8 * 8 + 6, %arg9 * 2] {partition_indices = [6, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %152 = arith.mulf %149, %121 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %153 = arith.addf %111, %152 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %153, %arg4[%arg8 * 8 + 6, %arg9 * 2 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %154 = affine.load %arg0[%arg8 * 8 + 7, %arg7 * 3 + 2] {partition_indices = [7, 2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>, 1>
        %155 = arith.mulf %154, %118 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %156 = arith.addf %114, %155 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %156, %arg4[%arg8 * 8 + 7, %arg9 * 2] {partition_indices = [7, 0], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %157 = arith.mulf %154, %121 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %158 = arith.addf %116, %157 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        affine.store %158, %arg4[%arg8 * 8 + 7, %arg9 * 2 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=25, iterLatency=22, minII=1>, resource = #hlscpp.r<lut=0, dsp=240, bram=0, nonShareDsp=240>, timing = #hlscpp.t<94520 -> 94568, 48, 48>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=125, iterLatency=22, minII=1>, resource = #hlscpp.r<lut=0, dsp=240, bram=0, nonShareDsp=240>, timing = #hlscpp.t<94520 -> 94668, 148, 148>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=2500, iterLatency=22, minII=1>, resource = #hlscpp.r<lut=0, dsp=240, bram=0, nonShareDsp=240>, timing = #hlscpp.t<0 -> 2523, 2523, 2523>}
  affine.for %arg7 = 0 to 40 {
    affine.for %arg8 = 0 to 5 {
      affine.for %arg9 = 0 to 35 {
        %1 = affine.load %arg2[%arg8 * 10, %arg7 * 2] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %2 = affine.load %arg3[%arg7 * 2, %arg9 * 2] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>, 1>
        %3 = arith.mulf %1, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %4 = affine.load %arg5[%arg8 * 10, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [0, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %5 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %4 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %6 = arith.addf %5, %3 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %7 = affine.load %arg3[%arg7 * 2, %arg9 * 2 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<1 -> 3, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>, 1>
        %8 = arith.mulf %1, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %9 = affine.load %arg5[%arg8 * 10, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [0, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %10 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %9 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %11 = arith.addf %10, %8 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %12 = affine.load %arg2[%arg8 * 10 + 1, %arg7 * 2] {partition_indices = [1, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %13 = arith.mulf %12, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %14 = affine.load %arg5[%arg8 * 10 + 1, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [1, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %15 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %14 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %16 = arith.addf %15, %13 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %17 = arith.mulf %12, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %18 = affine.load %arg5[%arg8 * 10 + 1, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [1, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %19 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %18 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %20 = arith.addf %19, %17 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %21 = affine.load %arg2[%arg8 * 10 + 2, %arg7 * 2] {partition_indices = [2, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %22 = arith.mulf %21, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %23 = affine.load %arg5[%arg8 * 10 + 2, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [2, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %24 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %23 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %25 = arith.addf %24, %22 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %26 = arith.mulf %21, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %27 = affine.load %arg5[%arg8 * 10 + 2, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [2, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %28 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %27 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %29 = arith.addf %28, %26 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %30 = affine.load %arg2[%arg8 * 10 + 3, %arg7 * 2] {partition_indices = [3, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %31 = arith.mulf %30, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %32 = affine.load %arg5[%arg8 * 10 + 3, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [3, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %33 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %32 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %34 = arith.addf %33, %31 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %35 = arith.mulf %30, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %36 = affine.load %arg5[%arg8 * 10 + 3, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [3, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %37 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %36 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %38 = arith.addf %37, %35 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %39 = affine.load %arg2[%arg8 * 10 + 4, %arg7 * 2] {partition_indices = [4, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %40 = arith.mulf %39, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %41 = affine.load %arg5[%arg8 * 10 + 4, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [4, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %42 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %41 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %43 = arith.addf %42, %40 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %44 = arith.mulf %39, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %45 = affine.load %arg5[%arg8 * 10 + 4, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [4, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %46 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %45 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %47 = arith.addf %46, %44 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %48 = affine.load %arg2[%arg8 * 10 + 5, %arg7 * 2] {partition_indices = [5, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %49 = arith.mulf %48, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %50 = affine.load %arg5[%arg8 * 10 + 5, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [5, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %51 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %50 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %52 = arith.addf %51, %49 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %53 = arith.mulf %48, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %54 = affine.load %arg5[%arg8 * 10 + 5, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [5, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %55 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %54 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %56 = arith.addf %55, %53 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %57 = affine.load %arg2[%arg8 * 10 + 6, %arg7 * 2] {partition_indices = [6, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %58 = arith.mulf %57, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %59 = affine.load %arg5[%arg8 * 10 + 6, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [6, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %60 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %59 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %61 = arith.addf %60, %58 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %62 = arith.mulf %57, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %63 = affine.load %arg5[%arg8 * 10 + 6, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [6, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %64 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %63 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %65 = arith.addf %64, %62 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %66 = affine.load %arg2[%arg8 * 10 + 7, %arg7 * 2] {partition_indices = [7, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %67 = arith.mulf %66, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %68 = affine.load %arg5[%arg8 * 10 + 7, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [7, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %69 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %68 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %70 = arith.addf %69, %67 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %71 = arith.mulf %66, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %72 = affine.load %arg5[%arg8 * 10 + 7, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [7, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %73 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %72 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %74 = arith.addf %73, %71 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %75 = affine.load %arg2[%arg8 * 10 + 8, %arg7 * 2] {partition_indices = [8, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %76 = arith.mulf %75, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %77 = affine.load %arg5[%arg8 * 10 + 8, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [8, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %78 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %77 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %79 = arith.addf %78, %76 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %80 = arith.mulf %75, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %81 = affine.load %arg5[%arg8 * 10 + 8, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [8, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %82 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %81 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %83 = arith.addf %82, %80 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %84 = affine.load %arg2[%arg8 * 10 + 9, %arg7 * 2] {partition_indices = [9, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %85 = arith.mulf %84, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %86 = affine.load %arg5[%arg8 * 10 + 9, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [9, -1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %87 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %86 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %88 = arith.addf %87, %85 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %89 = arith.mulf %84, %7 {timing = #hlscpp.t<3 -> 7, 4, 1>} : f32
        %90 = affine.load %arg5[%arg8 * 10 + 9, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [9, -1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %91 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<7 -> 7, 0, 0>} %90 : f32
        } {timing = #hlscpp.t<7 -> 7, 0, 0>}
        %92 = arith.addf %91, %89 {timing = #hlscpp.t<7 -> 12, 5, 1>} : f32
        %93 = affine.load %arg2[%arg8 * 10, %arg7 * 2 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %94 = affine.load %arg3[%arg7 * 2 + 1, %arg9 * 2] {partition_indices = [1, 0], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>, 1>
        %95 = arith.mulf %93, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %96 = arith.addf %6, %95 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %96, %arg5[%arg8 * 10, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [0, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %97 = affine.load %arg3[%arg7 * 2 + 1, %arg9 * 2 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>, 1>
        %98 = arith.mulf %93, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %99 = arith.addf %11, %98 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %99, %arg5[%arg8 * 10, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [0, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %100 = affine.load %arg2[%arg8 * 10 + 1, %arg7 * 2 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %101 = arith.mulf %100, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %102 = arith.addf %16, %101 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %102, %arg5[%arg8 * 10 + 1, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [1, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %103 = arith.mulf %100, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %104 = arith.addf %20, %103 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %104, %arg5[%arg8 * 10 + 1, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [1, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %105 = affine.load %arg2[%arg8 * 10 + 2, %arg7 * 2 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %106 = arith.mulf %105, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %107 = arith.addf %25, %106 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %107, %arg5[%arg8 * 10 + 2, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [2, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %108 = arith.mulf %105, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %109 = arith.addf %29, %108 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %109, %arg5[%arg8 * 10 + 2, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [2, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %110 = affine.load %arg2[%arg8 * 10 + 3, %arg7 * 2 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %111 = arith.mulf %110, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %112 = arith.addf %34, %111 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %112, %arg5[%arg8 * 10 + 3, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [3, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %113 = arith.mulf %110, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %114 = arith.addf %38, %113 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %114, %arg5[%arg8 * 10 + 3, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [3, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %115 = affine.load %arg2[%arg8 * 10 + 4, %arg7 * 2 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %116 = arith.mulf %115, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %117 = arith.addf %43, %116 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %117, %arg5[%arg8 * 10 + 4, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [4, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %118 = arith.mulf %115, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %119 = arith.addf %47, %118 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %119, %arg5[%arg8 * 10 + 4, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [4, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %120 = affine.load %arg2[%arg8 * 10 + 5, %arg7 * 2 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %121 = arith.mulf %120, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %122 = arith.addf %52, %121 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %122, %arg5[%arg8 * 10 + 5, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [5, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %123 = arith.mulf %120, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %124 = arith.addf %56, %123 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %124, %arg5[%arg8 * 10 + 5, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [5, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %125 = affine.load %arg2[%arg8 * 10 + 6, %arg7 * 2 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %126 = arith.mulf %125, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %127 = arith.addf %61, %126 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %127, %arg5[%arg8 * 10 + 6, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [6, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %128 = arith.mulf %125, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %129 = arith.addf %65, %128 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %129, %arg5[%arg8 * 10 + 6, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [6, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %130 = affine.load %arg2[%arg8 * 10 + 7, %arg7 * 2 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %131 = arith.mulf %130, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %132 = arith.addf %70, %131 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %132, %arg5[%arg8 * 10 + 7, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [7, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %133 = arith.mulf %130, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %134 = arith.addf %74, %133 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %134, %arg5[%arg8 * 10 + 7, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [7, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %135 = affine.load %arg2[%arg8 * 10 + 8, %arg7 * 2 + 1] {partition_indices = [8, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %136 = arith.mulf %135, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %137 = arith.addf %79, %136 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %137, %arg5[%arg8 * 10 + 8, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [8, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %138 = arith.mulf %135, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %139 = arith.addf %83, %138 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %139, %arg5[%arg8 * 10 + 8, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [8, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %140 = affine.load %arg2[%arg8 * 10 + 9, %arg7 * 2 + 1] {partition_indices = [9, 1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>, 1>
        %141 = arith.mulf %140, %94 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %142 = arith.addf %88, %141 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        affine.store %142, %arg5[%arg8 * 10 + 9, %arg9 * 2] {max_mux_size = 5 : i64, partition_indices = [9, -1], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %143 = arith.mulf %140, %97 {timing = #hlscpp.t<8 -> 12, 4, 1>} : f32
        %144 = arith.addf %92, %143 {timing = #hlscpp.t<12 -> 17, 5, 1>} : f32
        affine.store %144, %arg5[%arg8 * 10 + 9, %arg9 * 2 + 1] {max_mux_size = 5 : i64, partition_indices = [9, -1], timing = #hlscpp.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=35, iterLatency=18, minII=13>, resource = #hlscpp.r<lut=0, dsp=15, bram=0, nonShareDsp=200>, timing = #hlscpp.t<3513 -> 3975, 462, 462>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=175, iterLatency=18, minII=13>, resource = #hlscpp.r<lut=0, dsp=15, bram=0, nonShareDsp=200>, timing = #hlscpp.t<3513 -> 5795, 2282, 2282>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=7000, iterLatency=18, minII=13>, resource = #hlscpp.r<lut=0, dsp=15, bram=0, nonShareDsp=200>, timing = #hlscpp.t<2523 -> 93530, 91007, 91007>}
  affine.for %arg7 = 0 to 50 {
    affine.for %arg8 = 0 to 5 {
      affine.for %arg9 = 0 to 14 {
        %1 = affine.load %arg4[%arg8 * 8, %arg7] {max_mux_size = 2 : i64, partition_indices = [0, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %2 = affine.load %arg5[%arg7, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [-1, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %3 = arith.mulf %1, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %4 = affine.load %arg6[%arg8 * 8, %arg9 * 5] {partition_indices = [0, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %5 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %4 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %6 = arith.addf %5, %3 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %6, %arg6[%arg8 * 8, %arg9 * 5] {partition_indices = [0, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %7 = affine.load %arg5[%arg7, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [-1, 1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %8 = arith.mulf %1, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %9 = affine.load %arg6[%arg8 * 8, %arg9 * 5 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %10 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %9 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %11 = arith.addf %10, %8 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %11, %arg6[%arg8 * 8, %arg9 * 5 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %12 = affine.load %arg5[%arg7, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [-1, 2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %13 = arith.mulf %1, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %14 = affine.load %arg6[%arg8 * 8, %arg9 * 5 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %15 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %14 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %16 = arith.addf %15, %13 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %16, %arg6[%arg8 * 8, %arg9 * 5 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %17 = affine.load %arg5[%arg7, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [-1, 3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %18 = arith.mulf %1, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %19 = affine.load %arg6[%arg8 * 8, %arg9 * 5 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %20 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %19 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %21 = arith.addf %20, %18 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %21, %arg6[%arg8 * 8, %arg9 * 5 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %22 = affine.load %arg5[%arg7, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [-1, 4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 5, d0 floordiv 10, d1 floordiv 5)>, 1>
        %23 = arith.mulf %1, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %24 = affine.load %arg6[%arg8 * 8, %arg9 * 5 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %25 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %24 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %26 = arith.addf %25, %23 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %26, %arg6[%arg8 * 8, %arg9 * 5 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %27 = affine.load %arg4[%arg8 * 8 + 1, %arg7] {max_mux_size = 2 : i64, partition_indices = [1, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %28 = arith.mulf %27, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %29 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 5] {partition_indices = [1, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %30 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %29 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %31 = arith.addf %30, %28 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %31, %arg6[%arg8 * 8 + 1, %arg9 * 5] {partition_indices = [1, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %32 = arith.mulf %27, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %33 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 5 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %34 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %33 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %35 = arith.addf %34, %32 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %35, %arg6[%arg8 * 8 + 1, %arg9 * 5 + 1] {partition_indices = [1, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %36 = arith.mulf %27, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %37 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 5 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %38 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %37 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %39 = arith.addf %38, %36 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %39, %arg6[%arg8 * 8 + 1, %arg9 * 5 + 2] {partition_indices = [1, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %40 = arith.mulf %27, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %41 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 5 + 3] {partition_indices = [1, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %42 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %41 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %43 = arith.addf %42, %40 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %43, %arg6[%arg8 * 8 + 1, %arg9 * 5 + 3] {partition_indices = [1, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %44 = arith.mulf %27, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %45 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 5 + 4] {partition_indices = [1, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %46 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %45 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %47 = arith.addf %46, %44 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %47, %arg6[%arg8 * 8 + 1, %arg9 * 5 + 4] {partition_indices = [1, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %48 = affine.load %arg4[%arg8 * 8 + 2, %arg7] {max_mux_size = 2 : i64, partition_indices = [2, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %49 = arith.mulf %48, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %50 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 5] {partition_indices = [2, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %51 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %50 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %52 = arith.addf %51, %49 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %52, %arg6[%arg8 * 8 + 2, %arg9 * 5] {partition_indices = [2, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %53 = arith.mulf %48, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %54 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 5 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %55 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %54 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %56 = arith.addf %55, %53 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %56, %arg6[%arg8 * 8 + 2, %arg9 * 5 + 1] {partition_indices = [2, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %57 = arith.mulf %48, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %58 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 5 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %59 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %58 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %60 = arith.addf %59, %57 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %60, %arg6[%arg8 * 8 + 2, %arg9 * 5 + 2] {partition_indices = [2, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %61 = arith.mulf %48, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %62 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 5 + 3] {partition_indices = [2, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %63 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %62 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %64 = arith.addf %63, %61 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %64, %arg6[%arg8 * 8 + 2, %arg9 * 5 + 3] {partition_indices = [2, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %65 = arith.mulf %48, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %66 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 5 + 4] {partition_indices = [2, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %67 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %66 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %68 = arith.addf %67, %65 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %68, %arg6[%arg8 * 8 + 2, %arg9 * 5 + 4] {partition_indices = [2, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %69 = affine.load %arg4[%arg8 * 8 + 3, %arg7] {max_mux_size = 2 : i64, partition_indices = [3, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %70 = arith.mulf %69, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %71 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 5] {partition_indices = [3, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %72 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %71 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %73 = arith.addf %72, %70 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %73, %arg6[%arg8 * 8 + 3, %arg9 * 5] {partition_indices = [3, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %74 = arith.mulf %69, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %75 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 5 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %76 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %75 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %77 = arith.addf %76, %74 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %77, %arg6[%arg8 * 8 + 3, %arg9 * 5 + 1] {partition_indices = [3, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %78 = arith.mulf %69, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %79 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 5 + 2] {partition_indices = [3, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %80 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %79 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %81 = arith.addf %80, %78 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %81, %arg6[%arg8 * 8 + 3, %arg9 * 5 + 2] {partition_indices = [3, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %82 = arith.mulf %69, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %83 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 5 + 3] {partition_indices = [3, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %84 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %83 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %85 = arith.addf %84, %82 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %85, %arg6[%arg8 * 8 + 3, %arg9 * 5 + 3] {partition_indices = [3, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %86 = arith.mulf %69, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %87 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 5 + 4] {partition_indices = [3, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %88 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %87 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %89 = arith.addf %88, %86 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %89, %arg6[%arg8 * 8 + 3, %arg9 * 5 + 4] {partition_indices = [3, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %90 = affine.load %arg4[%arg8 * 8 + 4, %arg7] {max_mux_size = 2 : i64, partition_indices = [4, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %91 = arith.mulf %90, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %92 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 5] {partition_indices = [4, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %93 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %92 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %94 = arith.addf %93, %91 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %94, %arg6[%arg8 * 8 + 4, %arg9 * 5] {partition_indices = [4, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %95 = arith.mulf %90, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %96 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 5 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %97 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %96 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %98 = arith.addf %97, %95 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %98, %arg6[%arg8 * 8 + 4, %arg9 * 5 + 1] {partition_indices = [4, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %99 = arith.mulf %90, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %100 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 5 + 2] {partition_indices = [4, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %101 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %100 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %102 = arith.addf %101, %99 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %102, %arg6[%arg8 * 8 + 4, %arg9 * 5 + 2] {partition_indices = [4, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %103 = arith.mulf %90, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %104 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 5 + 3] {partition_indices = [4, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %105 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %104 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %106 = arith.addf %105, %103 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %106, %arg6[%arg8 * 8 + 4, %arg9 * 5 + 3] {partition_indices = [4, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %107 = arith.mulf %90, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %108 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 5 + 4] {partition_indices = [4, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %109 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %108 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %110 = arith.addf %109, %107 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %110, %arg6[%arg8 * 8 + 4, %arg9 * 5 + 4] {partition_indices = [4, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %111 = affine.load %arg4[%arg8 * 8 + 5, %arg7] {max_mux_size = 2 : i64, partition_indices = [5, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %112 = arith.mulf %111, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %113 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 5] {partition_indices = [5, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %114 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %113 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %115 = arith.addf %114, %112 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %115, %arg6[%arg8 * 8 + 5, %arg9 * 5] {partition_indices = [5, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %116 = arith.mulf %111, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %117 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 5 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %118 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %117 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %119 = arith.addf %118, %116 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %119, %arg6[%arg8 * 8 + 5, %arg9 * 5 + 1] {partition_indices = [5, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %120 = arith.mulf %111, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %121 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 5 + 2] {partition_indices = [5, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %122 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %121 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %123 = arith.addf %122, %120 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %123, %arg6[%arg8 * 8 + 5, %arg9 * 5 + 2] {partition_indices = [5, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %124 = arith.mulf %111, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %125 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 5 + 3] {partition_indices = [5, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %126 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %125 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %127 = arith.addf %126, %124 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %127, %arg6[%arg8 * 8 + 5, %arg9 * 5 + 3] {partition_indices = [5, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %128 = arith.mulf %111, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %129 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 5 + 4] {partition_indices = [5, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %130 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %129 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %131 = arith.addf %130, %128 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %131, %arg6[%arg8 * 8 + 5, %arg9 * 5 + 4] {partition_indices = [5, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %132 = affine.load %arg4[%arg8 * 8 + 6, %arg7] {max_mux_size = 2 : i64, partition_indices = [6, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %133 = arith.mulf %132, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %134 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 5] {partition_indices = [6, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %135 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %134 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %136 = arith.addf %135, %133 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %136, %arg6[%arg8 * 8 + 6, %arg9 * 5] {partition_indices = [6, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %137 = arith.mulf %132, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %138 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 5 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %139 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %138 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %140 = arith.addf %139, %137 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %140, %arg6[%arg8 * 8 + 6, %arg9 * 5 + 1] {partition_indices = [6, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %141 = arith.mulf %132, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %142 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 5 + 2] {partition_indices = [6, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %143 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %142 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %144 = arith.addf %143, %141 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %144, %arg6[%arg8 * 8 + 6, %arg9 * 5 + 2] {partition_indices = [6, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %145 = arith.mulf %132, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %146 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 5 + 3] {partition_indices = [6, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %147 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %146 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %148 = arith.addf %147, %145 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %148, %arg6[%arg8 * 8 + 6, %arg9 * 5 + 3] {partition_indices = [6, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %149 = arith.mulf %132, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %150 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 5 + 4] {partition_indices = [6, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %151 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %150 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %152 = arith.addf %151, %149 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %152, %arg6[%arg8 * 8 + 6, %arg9 * 5 + 4] {partition_indices = [6, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %153 = affine.load %arg4[%arg8 * 8 + 7, %arg7] {max_mux_size = 2 : i64, partition_indices = [7, -1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>, 1>
        %154 = arith.mulf %153, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %155 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 5] {partition_indices = [7, 0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %156 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %155 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %157 = arith.addf %156, %154 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %157, %arg6[%arg8 * 8 + 7, %arg9 * 5] {partition_indices = [7, 0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %158 = arith.mulf %153, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %159 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 5 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %160 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %159 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %161 = arith.addf %160, %158 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %161, %arg6[%arg8 * 8 + 7, %arg9 * 5 + 1] {partition_indices = [7, 1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %162 = arith.mulf %153, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %163 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 5 + 2] {partition_indices = [7, 2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %164 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %163 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %165 = arith.addf %164, %162 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %165, %arg6[%arg8 * 8 + 7, %arg9 * 5 + 2] {partition_indices = [7, 2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %166 = arith.mulf %153, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %167 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 5 + 3] {partition_indices = [7, 3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %168 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %167 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %169 = arith.addf %168, %166 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %169, %arg6[%arg8 * 8 + 7, %arg9 * 5 + 3] {partition_indices = [7, 3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %170 = arith.mulf %153, %22 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %171 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 5 + 4] {partition_indices = [7, 4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
        %172 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %0 : f32
        } else {
          affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %171 : f32
        } {timing = #hlscpp.t<6 -> 6, 0, 0>}
        %173 = arith.addf %172, %170 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %173, %arg6[%arg8 * 8 + 7, %arg9 * 5 + 4] {partition_indices = [7, 4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 5, d0 floordiv 8, d1 floordiv 5)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=14, iterLatency=12, minII=1>, resource = #hlscpp.r<lut=0, dsp=200, bram=0, nonShareDsp=200>, timing = #hlscpp.t<0 -> 27, 27, 27>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=70, iterLatency=12, minII=1>, resource = #hlscpp.r<lut=0, dsp=200, bram=0, nonShareDsp=200>, timing = #hlscpp.t<0 -> 83, 83, 83>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=3500, iterLatency=12, minII=1>, resource = #hlscpp.r<lut=0, dsp=200, bram=0, nonShareDsp=200>, timing = #hlscpp.t<93530 -> 97043, 3513, 3513>}
  return {timing = #hlscpp.t<97043 -> 97043, 0, 0>}
}
