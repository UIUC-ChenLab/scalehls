func @kernel_3mm(%arg0: memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>, %arg1: memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>>, %arg2: memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>, %arg3: memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>>, %arg4: memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>, %arg5: memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>, %arg6: memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>) attributes {llvm.linkage = #llvm.linkage<external>, resource = #hls.r<lut=0, dsp=240, bram=0>, timing = #hls.t<0 -> 20055, 20055, 20055>, top_func} {
  %cst = arith.constant {timing = #hls.t<0 -> 0, 0, 0>} 0.000000e+00 : f32
  affine.for %arg7 = 0 to 20 {
    affine.for %arg8 = 0 to 5 {
      affine.for %arg9 = 0 to 25 {
        %0 = affine.load %arg0[%arg8 * 8, %arg7 * 3] {partition_indices = [0, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %1 = affine.load %arg1[%arg7 * 3, %arg9 * 2] {partition_indices = [0, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>>
        %2 = arith.mulf %0, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %3 = affine.load %arg4[%arg8 * 8, %arg9 * 2] {partition_indices = [0, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %4 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %3 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %5 = arith.addf %4, %2 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %6 = affine.load %arg1[%arg7 * 3, %arg9 * 2 + 1] {partition_indices = [0, 1], timing = #hls.t<0 -> 2, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>>
        %7 = arith.mulf %0, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %8 = affine.load %arg4[%arg8 * 8, %arg9 * 2 + 1] {partition_indices = [0, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %9 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %8 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %10 = arith.addf %9, %7 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %11 = affine.load %arg0[%arg8 * 8 + 1, %arg7 * 3] {partition_indices = [1, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %12 = arith.mulf %11, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %13 = affine.load %arg4[%arg8 * 8 + 1, %arg9 * 2] {partition_indices = [1, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %14 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %13 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %15 = arith.addf %14, %12 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %16 = arith.mulf %11, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %17 = affine.load %arg4[%arg8 * 8 + 1, %arg9 * 2 + 1] {partition_indices = [1, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %18 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %17 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %19 = arith.addf %18, %16 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %20 = affine.load %arg0[%arg8 * 8 + 2, %arg7 * 3] {partition_indices = [2, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %21 = arith.mulf %20, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %22 = affine.load %arg4[%arg8 * 8 + 2, %arg9 * 2] {partition_indices = [2, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %23 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %22 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %24 = arith.addf %23, %21 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %25 = arith.mulf %20, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %26 = affine.load %arg4[%arg8 * 8 + 2, %arg9 * 2 + 1] {partition_indices = [2, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %27 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %26 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %28 = arith.addf %27, %25 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %29 = affine.load %arg0[%arg8 * 8 + 3, %arg7 * 3] {partition_indices = [3, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %30 = arith.mulf %29, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %31 = affine.load %arg4[%arg8 * 8 + 3, %arg9 * 2] {partition_indices = [3, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %32 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %31 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %33 = arith.addf %32, %30 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %34 = arith.mulf %29, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %35 = affine.load %arg4[%arg8 * 8 + 3, %arg9 * 2 + 1] {partition_indices = [3, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %36 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %35 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %37 = arith.addf %36, %34 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %38 = affine.load %arg0[%arg8 * 8 + 4, %arg7 * 3] {partition_indices = [4, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %39 = arith.mulf %38, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %40 = affine.load %arg4[%arg8 * 8 + 4, %arg9 * 2] {partition_indices = [4, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %41 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %40 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %42 = arith.addf %41, %39 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %43 = arith.mulf %38, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %44 = affine.load %arg4[%arg8 * 8 + 4, %arg9 * 2 + 1] {partition_indices = [4, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %45 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %44 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %46 = arith.addf %45, %43 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %47 = affine.load %arg0[%arg8 * 8 + 5, %arg7 * 3] {partition_indices = [5, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %48 = arith.mulf %47, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %49 = affine.load %arg4[%arg8 * 8 + 5, %arg9 * 2] {partition_indices = [5, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %50 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %49 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %51 = arith.addf %50, %48 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %52 = arith.mulf %47, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %53 = affine.load %arg4[%arg8 * 8 + 5, %arg9 * 2 + 1] {partition_indices = [5, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %54 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %53 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %55 = arith.addf %54, %52 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %56 = affine.load %arg0[%arg8 * 8 + 6, %arg7 * 3] {partition_indices = [6, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %57 = arith.mulf %56, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %58 = affine.load %arg4[%arg8 * 8 + 6, %arg9 * 2] {partition_indices = [6, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %59 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %58 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %60 = arith.addf %59, %57 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %61 = arith.mulf %56, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %62 = affine.load %arg4[%arg8 * 8 + 6, %arg9 * 2 + 1] {partition_indices = [6, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %63 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %62 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %64 = arith.addf %63, %61 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %65 = affine.load %arg0[%arg8 * 8 + 7, %arg7 * 3] {partition_indices = [7, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %66 = arith.mulf %65, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %67 = affine.load %arg4[%arg8 * 8 + 7, %arg9 * 2] {partition_indices = [7, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %68 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %67 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %69 = arith.addf %68, %66 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %70 = arith.mulf %65, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %71 = affine.load %arg4[%arg8 * 8 + 7, %arg9 * 2 + 1] {partition_indices = [7, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %72 = affine.if affine_set<(d0) : (d0 * 3 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %71 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %73 = arith.addf %72, %70 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %74 = affine.load %arg0[%arg8 * 8, %arg7 * 3 + 1] {partition_indices = [0, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %75 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 2] {partition_indices = [1, 0], timing = #hls.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>>
        %76 = arith.mulf %74, %75 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %77 = arith.addf %5, %76 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %78 = affine.load %arg1[%arg7 * 3 + 1, %arg9 * 2 + 1] {partition_indices = [1, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>>
        %79 = arith.mulf %74, %78 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %80 = arith.addf %10, %79 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %81 = affine.load %arg0[%arg8 * 8 + 1, %arg7 * 3 + 1] {partition_indices = [1, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %82 = arith.mulf %81, %75 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %83 = arith.addf %15, %82 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %84 = arith.mulf %81, %78 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %85 = arith.addf %19, %84 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %86 = affine.load %arg0[%arg8 * 8 + 2, %arg7 * 3 + 1] {partition_indices = [2, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %87 = arith.mulf %86, %75 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %88 = arith.addf %24, %87 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %89 = arith.mulf %86, %78 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %90 = arith.addf %28, %89 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %91 = affine.load %arg0[%arg8 * 8 + 3, %arg7 * 3 + 1] {partition_indices = [3, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %92 = arith.mulf %91, %75 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %93 = arith.addf %33, %92 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %94 = arith.mulf %91, %78 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %95 = arith.addf %37, %94 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %96 = affine.load %arg0[%arg8 * 8 + 4, %arg7 * 3 + 1] {partition_indices = [4, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %97 = arith.mulf %96, %75 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %98 = arith.addf %42, %97 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %99 = arith.mulf %96, %78 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %100 = arith.addf %46, %99 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %101 = affine.load %arg0[%arg8 * 8 + 5, %arg7 * 3 + 1] {partition_indices = [5, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %102 = arith.mulf %101, %75 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %103 = arith.addf %51, %102 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %104 = arith.mulf %101, %78 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %105 = arith.addf %55, %104 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %106 = affine.load %arg0[%arg8 * 8 + 6, %arg7 * 3 + 1] {partition_indices = [6, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %107 = arith.mulf %106, %75 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %108 = arith.addf %60, %107 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %109 = arith.mulf %106, %78 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %110 = arith.addf %64, %109 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %111 = affine.load %arg0[%arg8 * 8 + 7, %arg7 * 3 + 1] {partition_indices = [7, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %112 = arith.mulf %111, %75 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %113 = arith.addf %69, %112 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %114 = arith.mulf %111, %78 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %115 = arith.addf %73, %114 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %116 = affine.load %arg0[%arg8 * 8, %arg7 * 3 + 2] {partition_indices = [0, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %117 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 2] {partition_indices = [2, 0], timing = #hls.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>>
        %118 = arith.mulf %116, %117 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %119 = arith.addf %77, %118 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %119, %arg4[%arg8 * 8, %arg9 * 2] {partition_indices = [0, 0], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %120 = affine.load %arg1[%arg7 * 3 + 2, %arg9 * 2 + 1] {partition_indices = [2, 1], timing = #hls.t<10 -> 12, 2, 1>} : memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>>
        %121 = arith.mulf %116, %120 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %122 = arith.addf %80, %121 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %122, %arg4[%arg8 * 8, %arg9 * 2 + 1] {partition_indices = [0, 1], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %123 = affine.load %arg0[%arg8 * 8 + 1, %arg7 * 3 + 2] {partition_indices = [1, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %124 = arith.mulf %123, %117 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %125 = arith.addf %83, %124 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %125, %arg4[%arg8 * 8 + 1, %arg9 * 2] {partition_indices = [1, 0], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %126 = arith.mulf %123, %120 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %127 = arith.addf %85, %126 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %127, %arg4[%arg8 * 8 + 1, %arg9 * 2 + 1] {partition_indices = [1, 1], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %128 = affine.load %arg0[%arg8 * 8 + 2, %arg7 * 3 + 2] {partition_indices = [2, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %129 = arith.mulf %128, %117 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %130 = arith.addf %88, %129 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %130, %arg4[%arg8 * 8 + 2, %arg9 * 2] {partition_indices = [2, 0], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %131 = arith.mulf %128, %120 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %132 = arith.addf %90, %131 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %132, %arg4[%arg8 * 8 + 2, %arg9 * 2 + 1] {partition_indices = [2, 1], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %133 = affine.load %arg0[%arg8 * 8 + 3, %arg7 * 3 + 2] {partition_indices = [3, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %134 = arith.mulf %133, %117 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %135 = arith.addf %93, %134 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %135, %arg4[%arg8 * 8 + 3, %arg9 * 2] {partition_indices = [3, 0], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %136 = arith.mulf %133, %120 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %137 = arith.addf %95, %136 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %137, %arg4[%arg8 * 8 + 3, %arg9 * 2 + 1] {partition_indices = [3, 1], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %138 = affine.load %arg0[%arg8 * 8 + 4, %arg7 * 3 + 2] {partition_indices = [4, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %139 = arith.mulf %138, %117 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %140 = arith.addf %98, %139 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %140, %arg4[%arg8 * 8 + 4, %arg9 * 2] {partition_indices = [4, 0], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %141 = arith.mulf %138, %120 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %142 = arith.addf %100, %141 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %142, %arg4[%arg8 * 8 + 4, %arg9 * 2 + 1] {partition_indices = [4, 1], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %143 = affine.load %arg0[%arg8 * 8 + 5, %arg7 * 3 + 2] {partition_indices = [5, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %144 = arith.mulf %143, %117 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %145 = arith.addf %103, %144 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %145, %arg4[%arg8 * 8 + 5, %arg9 * 2] {partition_indices = [5, 0], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %146 = arith.mulf %143, %120 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %147 = arith.addf %105, %146 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %147, %arg4[%arg8 * 8 + 5, %arg9 * 2 + 1] {partition_indices = [5, 1], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %148 = affine.load %arg0[%arg8 * 8 + 6, %arg7 * 3 + 2] {partition_indices = [6, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %149 = arith.mulf %148, %117 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %150 = arith.addf %108, %149 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %150, %arg4[%arg8 * 8 + 6, %arg9 * 2] {partition_indices = [6, 0], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %151 = arith.mulf %148, %120 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %152 = arith.addf %110, %151 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %152, %arg4[%arg8 * 8 + 6, %arg9 * 2 + 1] {partition_indices = [6, 1], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %153 = affine.load %arg0[%arg8 * 8 + 7, %arg7 * 3 + 2] {partition_indices = [7, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>
        %154 = arith.mulf %153, %117 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %155 = arith.addf %113, %154 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %155, %arg4[%arg8 * 8 + 7, %arg9 * 2] {partition_indices = [7, 0], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %156 = arith.mulf %153, %120 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %157 = arith.addf %115, %156 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        affine.store %157, %arg4[%arg8 * 8 + 7, %arg9 * 2 + 1] {partition_indices = [7, 1], timing = #hls.t<21 -> 22, 1, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=25, iterLatency=22, minII=1>, parallel, timing = #hls.t<17530 -> 17578, 48, 48>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=125, iterLatency=22, minII=1>, parallel, timing = #hls.t<17530 -> 17678, 148, 148>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=2500, iterLatency=22, minII=1>, timing = #hls.t<0 -> 2523, 2523, 2523>}
  affine.for %arg7 = 0 to 40 {
    affine.for %arg8 = 0 to 5 {
      affine.for %arg9 = 0 to 35 {
        %0 = affine.load %arg2[%arg8 * 10, %arg7 * 2] {partition_indices = [0, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %1 = affine.load %arg3[%arg7 * 2, %arg9 * 2] {partition_indices = [0, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>>
        %2 = arith.mulf %0, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %3 = affine.load %arg5[%arg8 * 10, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %4 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %3 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %5 = arith.addf %4, %2 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %6 = affine.load %arg3[%arg7 * 2, %arg9 * 2 + 1] {partition_indices = [0, 1], timing = #hls.t<1 -> 3, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>>
        %7 = arith.mulf %0, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %8 = affine.load %arg5[%arg8 * 10, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %9 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %8 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %10 = arith.addf %9, %7 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %11 = affine.load %arg2[%arg8 * 10 + 1, %arg7 * 2] {partition_indices = [1, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %12 = arith.mulf %11, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %13 = affine.load %arg5[%arg8 * 10 + 1, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %14 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %13 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %15 = arith.addf %14, %12 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %16 = arith.mulf %11, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %17 = affine.load %arg5[%arg8 * 10 + 1, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %18 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %17 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %19 = arith.addf %18, %16 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %20 = affine.load %arg2[%arg8 * 10 + 2, %arg7 * 2] {partition_indices = [2, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %21 = arith.mulf %20, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %22 = affine.load %arg5[%arg8 * 10 + 2, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %23 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %22 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %24 = arith.addf %23, %21 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %25 = arith.mulf %20, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %26 = affine.load %arg5[%arg8 * 10 + 2, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %27 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %26 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %28 = arith.addf %27, %25 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %29 = affine.load %arg2[%arg8 * 10 + 3, %arg7 * 2] {partition_indices = [3, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %30 = arith.mulf %29, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %31 = affine.load %arg5[%arg8 * 10 + 3, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %32 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %31 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %33 = arith.addf %32, %30 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %34 = arith.mulf %29, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %35 = affine.load %arg5[%arg8 * 10 + 3, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %36 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %35 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %37 = arith.addf %36, %34 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %38 = affine.load %arg2[%arg8 * 10 + 4, %arg7 * 2] {partition_indices = [4, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %39 = arith.mulf %38, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %40 = affine.load %arg5[%arg8 * 10 + 4, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %41 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %40 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %42 = arith.addf %41, %39 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %43 = arith.mulf %38, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %44 = affine.load %arg5[%arg8 * 10 + 4, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %45 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %44 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %46 = arith.addf %45, %43 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %47 = affine.load %arg2[%arg8 * 10 + 5, %arg7 * 2] {partition_indices = [5, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %48 = arith.mulf %47, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %49 = affine.load %arg5[%arg8 * 10 + 5, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [5, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %50 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %49 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %51 = arith.addf %50, %48 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %52 = arith.mulf %47, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %53 = affine.load %arg5[%arg8 * 10 + 5, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [5, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %54 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %53 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %55 = arith.addf %54, %52 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %56 = affine.load %arg2[%arg8 * 10 + 6, %arg7 * 2] {partition_indices = [6, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %57 = arith.mulf %56, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %58 = affine.load %arg5[%arg8 * 10 + 6, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [6, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %59 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %58 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %60 = arith.addf %59, %57 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %61 = arith.mulf %56, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %62 = affine.load %arg5[%arg8 * 10 + 6, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [6, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %63 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %62 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %64 = arith.addf %63, %61 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %65 = affine.load %arg2[%arg8 * 10 + 7, %arg7 * 2] {partition_indices = [7, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %66 = arith.mulf %65, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %67 = affine.load %arg5[%arg8 * 10 + 7, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [7, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %68 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %67 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %69 = arith.addf %68, %66 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %70 = arith.mulf %65, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %71 = affine.load %arg5[%arg8 * 10 + 7, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [7, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %72 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %71 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %73 = arith.addf %72, %70 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %74 = affine.load %arg2[%arg8 * 10 + 8, %arg7 * 2] {partition_indices = [8, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %75 = arith.mulf %74, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %76 = affine.load %arg5[%arg8 * 10 + 8, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [8, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %77 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %76 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %78 = arith.addf %77, %75 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %79 = arith.mulf %74, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %80 = affine.load %arg5[%arg8 * 10 + 8, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [8, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %81 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %80 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %82 = arith.addf %81, %79 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %83 = affine.load %arg2[%arg8 * 10 + 9, %arg7 * 2] {partition_indices = [9, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %84 = arith.mulf %83, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %85 = affine.load %arg5[%arg8 * 10 + 9, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [9, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %86 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %85 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %87 = arith.addf %86, %84 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %88 = arith.mulf %83, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %89 = affine.load %arg5[%arg8 * 10 + 9, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [9, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %90 = affine.if affine_set<(d0) : (d0 * 2 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %89 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %91 = arith.addf %90, %88 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %92 = affine.load %arg2[%arg8 * 10, %arg7 * 2 + 1] {partition_indices = [0, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %93 = affine.load %arg3[%arg7 * 2 + 1, %arg9 * 2] {partition_indices = [1, 0], timing = #hls.t<5 -> 7, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>>
        %94 = arith.mulf %92, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %95 = arith.addf %5, %94 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %95, %arg5[%arg8 * 10, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %96 = affine.load %arg3[%arg7 * 2 + 1, %arg9 * 2 + 1] {partition_indices = [1, 1], timing = #hls.t<6 -> 8, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 2, d1 mod 2, d0 floordiv 2, d1 floordiv 2)>>
        %97 = arith.mulf %92, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %98 = arith.addf %10, %97 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %98, %arg5[%arg8 * 10, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %99 = affine.load %arg2[%arg8 * 10 + 1, %arg7 * 2 + 1] {partition_indices = [1, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %100 = arith.mulf %99, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %101 = arith.addf %15, %100 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %101, %arg5[%arg8 * 10 + 1, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %102 = arith.mulf %99, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %103 = arith.addf %19, %102 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %103, %arg5[%arg8 * 10 + 1, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %104 = affine.load %arg2[%arg8 * 10 + 2, %arg7 * 2 + 1] {partition_indices = [2, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %105 = arith.mulf %104, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %106 = arith.addf %24, %105 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %106, %arg5[%arg8 * 10 + 2, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %107 = arith.mulf %104, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %108 = arith.addf %28, %107 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %108, %arg5[%arg8 * 10 + 2, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %109 = affine.load %arg2[%arg8 * 10 + 3, %arg7 * 2 + 1] {partition_indices = [3, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %110 = arith.mulf %109, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %111 = arith.addf %33, %110 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %111, %arg5[%arg8 * 10 + 3, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %112 = arith.mulf %109, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %113 = arith.addf %37, %112 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %113, %arg5[%arg8 * 10 + 3, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %114 = affine.load %arg2[%arg8 * 10 + 4, %arg7 * 2 + 1] {partition_indices = [4, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %115 = arith.mulf %114, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %116 = arith.addf %42, %115 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %116, %arg5[%arg8 * 10 + 4, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %117 = arith.mulf %114, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %118 = arith.addf %46, %117 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %118, %arg5[%arg8 * 10 + 4, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %119 = affine.load %arg2[%arg8 * 10 + 5, %arg7 * 2 + 1] {partition_indices = [5, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %120 = arith.mulf %119, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %121 = arith.addf %51, %120 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %121, %arg5[%arg8 * 10 + 5, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [5, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %122 = arith.mulf %119, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %123 = arith.addf %55, %122 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %123, %arg5[%arg8 * 10 + 5, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [5, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %124 = affine.load %arg2[%arg8 * 10 + 6, %arg7 * 2 + 1] {partition_indices = [6, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %125 = arith.mulf %124, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %126 = arith.addf %60, %125 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %126, %arg5[%arg8 * 10 + 6, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [6, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %127 = arith.mulf %124, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %128 = arith.addf %64, %127 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %128, %arg5[%arg8 * 10 + 6, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [6, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %129 = affine.load %arg2[%arg8 * 10 + 7, %arg7 * 2 + 1] {partition_indices = [7, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %130 = arith.mulf %129, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %131 = arith.addf %69, %130 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %131, %arg5[%arg8 * 10 + 7, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [7, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %132 = arith.mulf %129, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %133 = arith.addf %73, %132 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %133, %arg5[%arg8 * 10 + 7, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [7, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %134 = affine.load %arg2[%arg8 * 10 + 8, %arg7 * 2 + 1] {partition_indices = [8, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %135 = arith.mulf %134, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %136 = arith.addf %78, %135 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %136, %arg5[%arg8 * 10 + 8, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [8, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %137 = arith.mulf %134, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %138 = arith.addf %82, %137 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %138, %arg5[%arg8 * 10 + 8, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [8, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %139 = affine.load %arg2[%arg8 * 10 + 9, %arg7 * 2 + 1] {partition_indices = [9, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 2, d0 floordiv 10, d1 floordiv 2)>>
        %140 = arith.mulf %139, %93 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %141 = arith.addf %87, %140 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        affine.store %141, %arg5[%arg8 * 10 + 9, %arg9 * 2] {max_mux_size = 10 : i64, partition_indices = [9, -1], timing = #hls.t<16 -> 17, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %142 = arith.mulf %139, %96 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %143 = arith.addf %91, %142 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        affine.store %143, %arg5[%arg8 * 10 + 9, %arg9 * 2 + 1] {max_mux_size = 10 : i64, partition_indices = [9, -1], timing = #hls.t<17 -> 18, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=35, iterLatency=18, minII=2>, parallel, timing = #hls.t<3512 -> 3600, 88, 88>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=175, iterLatency=18, minII=2>, parallel, timing = #hls.t<3512 -> 3880, 368, 368>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=7000, iterLatency=18, minII=2>, timing = #hls.t<2523 -> 16541, 14018, 14018>}
  affine.for %arg7 = 0 to 50 {
    affine.for %arg8 = 0 to 5 {
      affine.for %arg9 = 0 to 7 {
        %0 = affine.load %arg4[%arg8 * 8, %arg7] {max_mux_size = 2 : i64, partition_indices = [0, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %1 = affine.load %arg5[%arg7, %arg9 * 10] {max_mux_size = 10 : i64, partition_indices = [-1, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %2 = arith.mulf %0, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %3 = affine.load %arg6[%arg8 * 8, %arg9 * 10] {partition_indices = [0, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %4 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %3 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %5 = arith.addf %4, %2 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %5, %arg6[%arg8 * 8, %arg9 * 10] {partition_indices = [0, 0], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %6 = affine.load %arg5[%arg7, %arg9 * 10 + 1] {max_mux_size = 10 : i64, partition_indices = [-1, 1], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %7 = arith.mulf %0, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %8 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 1] {partition_indices = [0, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %9 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %8 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %10 = arith.addf %9, %7 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %10, %arg6[%arg8 * 8, %arg9 * 10 + 1] {partition_indices = [0, 1], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %11 = affine.load %arg5[%arg7, %arg9 * 10 + 2] {max_mux_size = 10 : i64, partition_indices = [-1, 2], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %12 = arith.mulf %0, %11 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %13 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 2] {partition_indices = [0, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %14 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %13 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %15 = arith.addf %14, %12 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %15, %arg6[%arg8 * 8, %arg9 * 10 + 2] {partition_indices = [0, 2], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %16 = affine.load %arg5[%arg7, %arg9 * 10 + 3] {max_mux_size = 10 : i64, partition_indices = [-1, 3], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %17 = arith.mulf %0, %16 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %18 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 3] {partition_indices = [0, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %19 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %18 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %20 = arith.addf %19, %17 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %20, %arg6[%arg8 * 8, %arg9 * 10 + 3] {partition_indices = [0, 3], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %21 = affine.load %arg5[%arg7, %arg9 * 10 + 4] {max_mux_size = 10 : i64, partition_indices = [-1, 4], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %22 = arith.mulf %0, %21 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %23 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 4] {partition_indices = [0, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %24 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %23 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %25 = arith.addf %24, %22 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %25, %arg6[%arg8 * 8, %arg9 * 10 + 4] {partition_indices = [0, 4], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %26 = affine.load %arg5[%arg7, %arg9 * 10 + 5] {max_mux_size = 10 : i64, partition_indices = [-1, 5], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %27 = arith.mulf %0, %26 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %28 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 5] {partition_indices = [0, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %29 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %28 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %30 = arith.addf %29, %27 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %30, %arg6[%arg8 * 8, %arg9 * 10 + 5] {partition_indices = [0, 5], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %31 = affine.load %arg5[%arg7, %arg9 * 10 + 6] {max_mux_size = 10 : i64, partition_indices = [-1, 6], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %32 = arith.mulf %0, %31 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %33 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 6] {partition_indices = [0, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %34 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %33 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %35 = arith.addf %34, %32 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %35, %arg6[%arg8 * 8, %arg9 * 10 + 6] {partition_indices = [0, 6], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %36 = affine.load %arg5[%arg7, %arg9 * 10 + 7] {max_mux_size = 10 : i64, partition_indices = [-1, 7], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %37 = arith.mulf %0, %36 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %38 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 7] {partition_indices = [0, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %39 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %38 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %40 = arith.addf %39, %37 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %40, %arg6[%arg8 * 8, %arg9 * 10 + 7] {partition_indices = [0, 7], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %41 = affine.load %arg5[%arg7, %arg9 * 10 + 8] {max_mux_size = 10 : i64, partition_indices = [-1, 8], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %42 = arith.mulf %0, %41 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %43 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 8] {partition_indices = [0, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %44 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %43 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %45 = arith.addf %44, %42 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %45, %arg6[%arg8 * 8, %arg9 * 10 + 8] {partition_indices = [0, 8], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %46 = affine.load %arg5[%arg7, %arg9 * 10 + 9] {max_mux_size = 10 : i64, partition_indices = [-1, 9], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 10, d1 mod 10, d0 floordiv 10, d1 floordiv 10)>>
        %47 = arith.mulf %0, %46 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %48 = affine.load %arg6[%arg8 * 8, %arg9 * 10 + 9] {partition_indices = [0, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %49 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %48 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %50 = arith.addf %49, %47 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %50, %arg6[%arg8 * 8, %arg9 * 10 + 9] {partition_indices = [0, 9], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %51 = affine.load %arg4[%arg8 * 8 + 1, %arg7] {max_mux_size = 2 : i64, partition_indices = [1, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %52 = arith.mulf %51, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %53 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10] {partition_indices = [1, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %54 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %53 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %55 = arith.addf %54, %52 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %55, %arg6[%arg8 * 8 + 1, %arg9 * 10] {partition_indices = [1, 0], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %56 = arith.mulf %51, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %57 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 1] {partition_indices = [1, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %58 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %57 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %59 = arith.addf %58, %56 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %59, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 1] {partition_indices = [1, 1], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %60 = arith.mulf %51, %11 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %61 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 2] {partition_indices = [1, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %62 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %61 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %63 = arith.addf %62, %60 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %63, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 2] {partition_indices = [1, 2], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %64 = arith.mulf %51, %16 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %65 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 3] {partition_indices = [1, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %66 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %65 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %67 = arith.addf %66, %64 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %67, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 3] {partition_indices = [1, 3], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %68 = arith.mulf %51, %21 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %69 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 4] {partition_indices = [1, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %70 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %69 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %71 = arith.addf %70, %68 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %71, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 4] {partition_indices = [1, 4], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %72 = arith.mulf %51, %26 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %73 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 5] {partition_indices = [1, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %74 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %73 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %75 = arith.addf %74, %72 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %75, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 5] {partition_indices = [1, 5], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %76 = arith.mulf %51, %31 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %77 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 6] {partition_indices = [1, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %78 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %77 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %79 = arith.addf %78, %76 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %79, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 6] {partition_indices = [1, 6], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %80 = arith.mulf %51, %36 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %81 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 7] {partition_indices = [1, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %82 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %81 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %83 = arith.addf %82, %80 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %83, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 7] {partition_indices = [1, 7], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %84 = arith.mulf %51, %41 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %85 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 8] {partition_indices = [1, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %86 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %85 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %87 = arith.addf %86, %84 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %87, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 8] {partition_indices = [1, 8], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %88 = arith.mulf %51, %46 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %89 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 10 + 9] {partition_indices = [1, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %90 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %89 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %91 = arith.addf %90, %88 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %91, %arg6[%arg8 * 8 + 1, %arg9 * 10 + 9] {partition_indices = [1, 9], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %92 = affine.load %arg4[%arg8 * 8 + 2, %arg7] {max_mux_size = 2 : i64, partition_indices = [2, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %93 = arith.mulf %92, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %94 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10] {partition_indices = [2, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %95 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %94 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %96 = arith.addf %95, %93 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %96, %arg6[%arg8 * 8 + 2, %arg9 * 10] {partition_indices = [2, 0], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %97 = arith.mulf %92, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %98 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 1] {partition_indices = [2, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %99 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %98 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %100 = arith.addf %99, %97 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %100, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 1] {partition_indices = [2, 1], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %101 = arith.mulf %92, %11 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %102 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 2] {partition_indices = [2, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %103 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %102 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %104 = arith.addf %103, %101 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %104, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 2] {partition_indices = [2, 2], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %105 = arith.mulf %92, %16 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %106 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 3] {partition_indices = [2, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %107 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %106 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %108 = arith.addf %107, %105 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %108, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 3] {partition_indices = [2, 3], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %109 = arith.mulf %92, %21 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %110 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 4] {partition_indices = [2, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %111 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %110 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %112 = arith.addf %111, %109 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %112, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 4] {partition_indices = [2, 4], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %113 = arith.mulf %92, %26 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %114 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 5] {partition_indices = [2, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %115 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %114 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %116 = arith.addf %115, %113 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %116, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 5] {partition_indices = [2, 5], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %117 = arith.mulf %92, %31 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %118 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 6] {partition_indices = [2, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %119 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %118 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %120 = arith.addf %119, %117 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %120, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 6] {partition_indices = [2, 6], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %121 = arith.mulf %92, %36 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %122 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 7] {partition_indices = [2, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %123 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %122 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %124 = arith.addf %123, %121 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %124, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 7] {partition_indices = [2, 7], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %125 = arith.mulf %92, %41 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %126 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 8] {partition_indices = [2, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %127 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %126 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %128 = arith.addf %127, %125 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %128, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 8] {partition_indices = [2, 8], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %129 = arith.mulf %92, %46 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %130 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 10 + 9] {partition_indices = [2, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %131 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %130 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %132 = arith.addf %131, %129 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %132, %arg6[%arg8 * 8 + 2, %arg9 * 10 + 9] {partition_indices = [2, 9], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %133 = affine.load %arg4[%arg8 * 8 + 3, %arg7] {max_mux_size = 2 : i64, partition_indices = [3, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %134 = arith.mulf %133, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %135 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10] {partition_indices = [3, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %136 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %135 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %137 = arith.addf %136, %134 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %137, %arg6[%arg8 * 8 + 3, %arg9 * 10] {partition_indices = [3, 0], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %138 = arith.mulf %133, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %139 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 1] {partition_indices = [3, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %140 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %139 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %141 = arith.addf %140, %138 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %141, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 1] {partition_indices = [3, 1], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %142 = arith.mulf %133, %11 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %143 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 2] {partition_indices = [3, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %144 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %143 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %145 = arith.addf %144, %142 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %145, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 2] {partition_indices = [3, 2], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %146 = arith.mulf %133, %16 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %147 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 3] {partition_indices = [3, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %148 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %147 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %149 = arith.addf %148, %146 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %149, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 3] {partition_indices = [3, 3], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %150 = arith.mulf %133, %21 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %151 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 4] {partition_indices = [3, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %152 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %151 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %153 = arith.addf %152, %150 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %153, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 4] {partition_indices = [3, 4], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %154 = arith.mulf %133, %26 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %155 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 5] {partition_indices = [3, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %156 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %155 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %157 = arith.addf %156, %154 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %157, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 5] {partition_indices = [3, 5], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %158 = arith.mulf %133, %31 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %159 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 6] {partition_indices = [3, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %160 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %159 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %161 = arith.addf %160, %158 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %161, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 6] {partition_indices = [3, 6], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %162 = arith.mulf %133, %36 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %163 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 7] {partition_indices = [3, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %164 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %163 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %165 = arith.addf %164, %162 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %165, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 7] {partition_indices = [3, 7], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %166 = arith.mulf %133, %41 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %167 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 8] {partition_indices = [3, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %168 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %167 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %169 = arith.addf %168, %166 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %169, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 8] {partition_indices = [3, 8], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %170 = arith.mulf %133, %46 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %171 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 10 + 9] {partition_indices = [3, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %172 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %171 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %173 = arith.addf %172, %170 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %173, %arg6[%arg8 * 8 + 3, %arg9 * 10 + 9] {partition_indices = [3, 9], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %174 = affine.load %arg4[%arg8 * 8 + 4, %arg7] {max_mux_size = 2 : i64, partition_indices = [4, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %175 = arith.mulf %174, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %176 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10] {partition_indices = [4, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %177 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %176 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %178 = arith.addf %177, %175 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %178, %arg6[%arg8 * 8 + 4, %arg9 * 10] {partition_indices = [4, 0], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %179 = arith.mulf %174, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %180 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 1] {partition_indices = [4, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %181 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %180 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %182 = arith.addf %181, %179 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %182, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 1] {partition_indices = [4, 1], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %183 = arith.mulf %174, %11 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %184 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 2] {partition_indices = [4, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %185 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %184 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %186 = arith.addf %185, %183 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %186, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 2] {partition_indices = [4, 2], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %187 = arith.mulf %174, %16 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %188 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 3] {partition_indices = [4, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %189 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %188 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %190 = arith.addf %189, %187 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %190, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 3] {partition_indices = [4, 3], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %191 = arith.mulf %174, %21 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %192 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 4] {partition_indices = [4, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %193 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %192 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %194 = arith.addf %193, %191 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %194, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 4] {partition_indices = [4, 4], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %195 = arith.mulf %174, %26 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %196 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 5] {partition_indices = [4, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %197 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %196 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %198 = arith.addf %197, %195 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %198, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 5] {partition_indices = [4, 5], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %199 = arith.mulf %174, %31 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %200 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 6] {partition_indices = [4, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %201 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %200 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %202 = arith.addf %201, %199 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %202, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 6] {partition_indices = [4, 6], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %203 = arith.mulf %174, %36 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %204 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 7] {partition_indices = [4, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %205 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %204 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %206 = arith.addf %205, %203 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %206, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 7] {partition_indices = [4, 7], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %207 = arith.mulf %174, %41 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %208 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 8] {partition_indices = [4, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %209 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %208 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %210 = arith.addf %209, %207 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %210, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 8] {partition_indices = [4, 8], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %211 = arith.mulf %174, %46 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %212 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 10 + 9] {partition_indices = [4, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %213 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %212 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %214 = arith.addf %213, %211 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %214, %arg6[%arg8 * 8 + 4, %arg9 * 10 + 9] {partition_indices = [4, 9], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %215 = affine.load %arg4[%arg8 * 8 + 5, %arg7] {max_mux_size = 2 : i64, partition_indices = [5, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %216 = arith.mulf %215, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %217 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10] {partition_indices = [5, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %218 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %217 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %219 = arith.addf %218, %216 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %219, %arg6[%arg8 * 8 + 5, %arg9 * 10] {partition_indices = [5, 0], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %220 = arith.mulf %215, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %221 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 1] {partition_indices = [5, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %222 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %221 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %223 = arith.addf %222, %220 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %223, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 1] {partition_indices = [5, 1], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %224 = arith.mulf %215, %11 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %225 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 2] {partition_indices = [5, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %226 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %225 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %227 = arith.addf %226, %224 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %227, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 2] {partition_indices = [5, 2], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %228 = arith.mulf %215, %16 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %229 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 3] {partition_indices = [5, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %230 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %229 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %231 = arith.addf %230, %228 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %231, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 3] {partition_indices = [5, 3], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %232 = arith.mulf %215, %21 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %233 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 4] {partition_indices = [5, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %234 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %233 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %235 = arith.addf %234, %232 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %235, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 4] {partition_indices = [5, 4], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %236 = arith.mulf %215, %26 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %237 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 5] {partition_indices = [5, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %238 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %237 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %239 = arith.addf %238, %236 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %239, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 5] {partition_indices = [5, 5], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %240 = arith.mulf %215, %31 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %241 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 6] {partition_indices = [5, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %242 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %241 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %243 = arith.addf %242, %240 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %243, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 6] {partition_indices = [5, 6], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %244 = arith.mulf %215, %36 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %245 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 7] {partition_indices = [5, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %246 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %245 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %247 = arith.addf %246, %244 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %247, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 7] {partition_indices = [5, 7], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %248 = arith.mulf %215, %41 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %249 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 8] {partition_indices = [5, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %250 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %249 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %251 = arith.addf %250, %248 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %251, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 8] {partition_indices = [5, 8], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %252 = arith.mulf %215, %46 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %253 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 10 + 9] {partition_indices = [5, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %254 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %253 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %255 = arith.addf %254, %252 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %255, %arg6[%arg8 * 8 + 5, %arg9 * 10 + 9] {partition_indices = [5, 9], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %256 = affine.load %arg4[%arg8 * 8 + 6, %arg7] {max_mux_size = 2 : i64, partition_indices = [6, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %257 = arith.mulf %256, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %258 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10] {partition_indices = [6, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %259 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %258 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %260 = arith.addf %259, %257 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %260, %arg6[%arg8 * 8 + 6, %arg9 * 10] {partition_indices = [6, 0], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %261 = arith.mulf %256, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %262 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 1] {partition_indices = [6, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %263 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %262 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %264 = arith.addf %263, %261 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %264, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 1] {partition_indices = [6, 1], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %265 = arith.mulf %256, %11 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %266 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 2] {partition_indices = [6, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %267 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %266 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %268 = arith.addf %267, %265 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %268, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 2] {partition_indices = [6, 2], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %269 = arith.mulf %256, %16 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %270 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 3] {partition_indices = [6, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %271 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %270 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %272 = arith.addf %271, %269 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %272, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 3] {partition_indices = [6, 3], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %273 = arith.mulf %256, %21 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %274 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 4] {partition_indices = [6, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %275 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %274 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %276 = arith.addf %275, %273 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %276, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 4] {partition_indices = [6, 4], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %277 = arith.mulf %256, %26 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %278 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 5] {partition_indices = [6, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %279 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %278 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %280 = arith.addf %279, %277 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %280, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 5] {partition_indices = [6, 5], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %281 = arith.mulf %256, %31 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %282 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 6] {partition_indices = [6, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %283 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %282 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %284 = arith.addf %283, %281 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %284, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 6] {partition_indices = [6, 6], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %285 = arith.mulf %256, %36 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %286 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 7] {partition_indices = [6, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %287 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %286 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %288 = arith.addf %287, %285 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %288, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 7] {partition_indices = [6, 7], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %289 = arith.mulf %256, %41 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %290 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 8] {partition_indices = [6, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %291 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %290 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %292 = arith.addf %291, %289 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %292, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 8] {partition_indices = [6, 8], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %293 = arith.mulf %256, %46 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %294 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 10 + 9] {partition_indices = [6, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %295 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %294 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %296 = arith.addf %295, %293 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %296, %arg6[%arg8 * 8 + 6, %arg9 * 10 + 9] {partition_indices = [6, 9], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %297 = affine.load %arg4[%arg8 * 8 + 7, %arg7] {max_mux_size = 2 : i64, partition_indices = [7, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %298 = arith.mulf %297, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %299 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10] {partition_indices = [7, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %300 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %299 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %301 = arith.addf %300, %298 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %301, %arg6[%arg8 * 8 + 7, %arg9 * 10] {partition_indices = [7, 0], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %302 = arith.mulf %297, %6 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %303 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 1] {partition_indices = [7, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %304 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %303 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %305 = arith.addf %304, %302 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %305, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 1] {partition_indices = [7, 1], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %306 = arith.mulf %297, %11 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %307 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 2] {partition_indices = [7, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %308 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %307 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %309 = arith.addf %308, %306 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %309, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 2] {partition_indices = [7, 2], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %310 = arith.mulf %297, %16 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %311 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 3] {partition_indices = [7, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %312 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %311 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %313 = arith.addf %312, %310 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %313, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 3] {partition_indices = [7, 3], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %314 = arith.mulf %297, %21 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %315 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 4] {partition_indices = [7, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %316 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %315 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %317 = arith.addf %316, %314 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %317, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 4] {partition_indices = [7, 4], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %318 = arith.mulf %297, %26 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %319 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 5] {partition_indices = [7, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %320 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %319 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %321 = arith.addf %320, %318 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %321, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 5] {partition_indices = [7, 5], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %322 = arith.mulf %297, %31 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %323 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 6] {partition_indices = [7, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %324 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %323 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %325 = arith.addf %324, %322 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %325, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 6] {partition_indices = [7, 6], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %326 = arith.mulf %297, %36 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %327 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 7] {partition_indices = [7, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %328 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %327 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %329 = arith.addf %328, %326 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %329, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 7] {partition_indices = [7, 7], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %330 = arith.mulf %297, %41 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %331 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 8] {partition_indices = [7, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %332 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %331 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %333 = arith.addf %332, %330 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %333, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 8] {partition_indices = [7, 8], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %334 = arith.mulf %297, %46 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %335 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 10 + 9] {partition_indices = [7, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
        %336 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %335 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %337 = arith.addf %336, %334 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        affine.store %337, %arg6[%arg8 * 8 + 7, %arg9 * 10 + 9] {partition_indices = [7, 9], timing = #hls.t<11 -> 12, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 10, d0 floordiv 8, d1 floordiv 10)>>
      } {loop_directive = #hls.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=7, iterLatency=12, minII=2>, parallel, timing = #hls.t<0 -> 26, 26, 26>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=35, iterLatency=12, minII=2>, parallel, timing = #hls.t<0 -> 82, 82, 82>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=1750, iterLatency=12, minII=2>, timing = #hls.t<16541 -> 20053, 3512, 3512>}
  return {timing = #hls.t<20053 -> 20053, 0, 0>}
}
