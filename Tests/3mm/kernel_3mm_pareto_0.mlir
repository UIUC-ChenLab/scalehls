func @kernel_3mm(%arg0: memref<40x60xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 3, d0 floordiv 8, d1 floordiv 3)>>, %arg1: memref<60x50xf32, affine_map<(d0, d1) -> (d0 mod 3, d1 mod 2, d0 floordiv 3, d1 floordiv 2)>>, %arg2: memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>, %arg3: memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>, %arg4: memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>, %arg5: memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>, %arg6: memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>) attributes {llvm.linkage = #llvm.linkage<external>, resource = #hls.r<lut=0, dsp=240, bram=0>, timing = #hls.t<0 -> 27771, 27771, 27771>, top_func} {
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
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=25, iterLatency=22, minII=1>, parallel, timing = #hls.t<25246 -> 25294, 48, 48>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=125, iterLatency=22, minII=1>, parallel, timing = #hls.t<25246 -> 25394, 148, 148>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=2500, iterLatency=22, minII=1>, timing = #hls.t<0 -> 2523, 2523, 2523>}
  affine.for %arg7 = 0 to 16 {
    affine.for %arg8 = 0 to 10 {
      affine.for %arg9 = 0 to 14 {
        %0 = affine.load %arg2[%arg8 * 5, %arg7 * 5] {partition_indices = [0, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %1 = affine.load %arg3[%arg7 * 5, %arg9 * 5] {partition_indices = [0, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %2 = arith.mulf %0, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %3 = affine.load %arg5[%arg8 * 5, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %4 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %3 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %5 = arith.addf %4, %2 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %6 = affine.load %arg3[%arg7 * 5, %arg9 * 5 + 1] {partition_indices = [0, 1], timing = #hls.t<1 -> 3, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %7 = arith.mulf %0, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %8 = affine.load %arg5[%arg8 * 5, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %9 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %8 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %10 = arith.addf %9, %7 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %11 = affine.load %arg3[%arg7 * 5, %arg9 * 5 + 2] {partition_indices = [0, 2], timing = #hls.t<2 -> 4, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %12 = arith.mulf %0, %11 {timing = #hls.t<4 -> 8, 4, 1>} : f32
        %13 = affine.load %arg5[%arg8 * 5, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<6 -> 8, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %14 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %13 : f32
        } {timing = #hls.t<8 -> 8, 0, 0>}
        %15 = arith.addf %14, %12 {timing = #hls.t<8 -> 13, 5, 1>} : f32
        %16 = affine.load %arg3[%arg7 * 5, %arg9 * 5 + 3] {partition_indices = [0, 3], timing = #hls.t<3 -> 5, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %17 = arith.mulf %0, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %18 = affine.load %arg5[%arg8 * 5, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<7 -> 9, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %19 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %18 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %20 = arith.addf %19, %17 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        %21 = affine.load %arg3[%arg7 * 5, %arg9 * 5 + 4] {partition_indices = [0, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %22 = arith.mulf %0, %21 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %23 = affine.load %arg5[%arg8 * 5, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<8 -> 10, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %24 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %23 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %25 = arith.addf %24, %22 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %26 = affine.load %arg2[%arg8 * 5 + 1, %arg7 * 5] {partition_indices = [1, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %27 = arith.mulf %26, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %28 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %29 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %28 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %30 = arith.addf %29, %27 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %31 = arith.mulf %26, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %32 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %33 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %32 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %34 = arith.addf %33, %31 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %35 = arith.mulf %26, %11 {timing = #hls.t<4 -> 8, 4, 1>} : f32
        %36 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<6 -> 8, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %37 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %36 : f32
        } {timing = #hls.t<8 -> 8, 0, 0>}
        %38 = arith.addf %37, %35 {timing = #hls.t<8 -> 13, 5, 1>} : f32
        %39 = arith.mulf %26, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %40 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<7 -> 9, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %41 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %40 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %42 = arith.addf %41, %39 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        %43 = arith.mulf %26, %21 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %44 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<8 -> 10, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %45 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %44 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %46 = arith.addf %45, %43 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %47 = affine.load %arg2[%arg8 * 5 + 2, %arg7 * 5] {partition_indices = [2, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %48 = arith.mulf %47, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %49 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %50 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %49 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %51 = arith.addf %50, %48 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %52 = arith.mulf %47, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %53 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %54 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %53 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %55 = arith.addf %54, %52 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %56 = arith.mulf %47, %11 {timing = #hls.t<4 -> 8, 4, 1>} : f32
        %57 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<6 -> 8, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %58 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %57 : f32
        } {timing = #hls.t<8 -> 8, 0, 0>}
        %59 = arith.addf %58, %56 {timing = #hls.t<8 -> 13, 5, 1>} : f32
        %60 = arith.mulf %47, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %61 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<7 -> 9, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %62 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %61 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %63 = arith.addf %62, %60 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        %64 = arith.mulf %47, %21 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %65 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<8 -> 10, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %66 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %65 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %67 = arith.addf %66, %64 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %68 = affine.load %arg2[%arg8 * 5 + 3, %arg7 * 5] {partition_indices = [3, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %69 = arith.mulf %68, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %70 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %71 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %70 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %72 = arith.addf %71, %69 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %73 = arith.mulf %68, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %74 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %75 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %74 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %76 = arith.addf %75, %73 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %77 = arith.mulf %68, %11 {timing = #hls.t<4 -> 8, 4, 1>} : f32
        %78 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<6 -> 8, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %79 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %78 : f32
        } {timing = #hls.t<8 -> 8, 0, 0>}
        %80 = arith.addf %79, %77 {timing = #hls.t<8 -> 13, 5, 1>} : f32
        %81 = arith.mulf %68, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %82 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<7 -> 9, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %83 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %82 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %84 = arith.addf %83, %81 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        %85 = arith.mulf %68, %21 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %86 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<8 -> 10, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %87 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %86 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %88 = arith.addf %87, %85 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %89 = affine.load %arg2[%arg8 * 5 + 4, %arg7 * 5] {partition_indices = [4, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %90 = arith.mulf %89, %1 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %91 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<4 -> 6, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %92 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<6 -> 6, 0, 0>} %91 : f32
        } {timing = #hls.t<6 -> 6, 0, 0>}
        %93 = arith.addf %92, %90 {timing = #hls.t<6 -> 11, 5, 1>} : f32
        %94 = arith.mulf %89, %6 {timing = #hls.t<3 -> 7, 4, 1>} : f32
        %95 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %96 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<7 -> 7, 0, 0>} %95 : f32
        } {timing = #hls.t<7 -> 7, 0, 0>}
        %97 = arith.addf %96, %94 {timing = #hls.t<7 -> 12, 5, 1>} : f32
        %98 = arith.mulf %89, %11 {timing = #hls.t<4 -> 8, 4, 1>} : f32
        %99 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<6 -> 8, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %100 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<8 -> 8, 0, 0>} %99 : f32
        } {timing = #hls.t<8 -> 8, 0, 0>}
        %101 = arith.addf %100, %98 {timing = #hls.t<8 -> 13, 5, 1>} : f32
        %102 = arith.mulf %89, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %103 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<7 -> 9, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %104 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %103 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %105 = arith.addf %104, %102 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        %106 = arith.mulf %89, %21 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %107 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<8 -> 10, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %108 = affine.if affine_set<(d0) : (d0 * 5 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %107 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %109 = arith.addf %108, %106 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %110 = affine.load %arg2[%arg8 * 5, %arg7 * 5 + 1] {partition_indices = [0, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %111 = affine.load %arg3[%arg7 * 5 + 1, %arg9 * 5] {partition_indices = [1, 0], timing = #hls.t<5 -> 7, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %112 = arith.mulf %110, %111 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %113 = arith.addf %5, %112 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %114 = affine.load %arg3[%arg7 * 5 + 1, %arg9 * 5 + 1] {partition_indices = [1, 1], timing = #hls.t<6 -> 8, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %115 = arith.mulf %110, %114 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %116 = arith.addf %10, %115 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        %117 = affine.load %arg3[%arg7 * 5 + 1, %arg9 * 5 + 2] {partition_indices = [1, 2], timing = #hls.t<7 -> 9, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %118 = arith.mulf %110, %117 {timing = #hls.t<9 -> 13, 4, 1>} : f32
        %119 = arith.addf %15, %118 {timing = #hls.t<13 -> 18, 5, 1>} : f32
        %120 = affine.load %arg3[%arg7 * 5 + 1, %arg9 * 5 + 3] {partition_indices = [1, 3], timing = #hls.t<8 -> 10, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %121 = arith.mulf %110, %120 {timing = #hls.t<10 -> 14, 4, 1>} : f32
        %122 = arith.addf %20, %121 {timing = #hls.t<14 -> 19, 5, 1>} : f32
        %123 = affine.load %arg3[%arg7 * 5 + 1, %arg9 * 5 + 4] {partition_indices = [1, 4], timing = #hls.t<9 -> 11, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %124 = arith.mulf %110, %123 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %125 = arith.addf %25, %124 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %126 = affine.load %arg2[%arg8 * 5 + 1, %arg7 * 5 + 1] {partition_indices = [1, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %127 = arith.mulf %126, %111 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %128 = arith.addf %30, %127 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %129 = arith.mulf %126, %114 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %130 = arith.addf %34, %129 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        %131 = arith.mulf %126, %117 {timing = #hls.t<9 -> 13, 4, 1>} : f32
        %132 = arith.addf %38, %131 {timing = #hls.t<13 -> 18, 5, 1>} : f32
        %133 = arith.mulf %126, %120 {timing = #hls.t<10 -> 14, 4, 1>} : f32
        %134 = arith.addf %42, %133 {timing = #hls.t<14 -> 19, 5, 1>} : f32
        %135 = arith.mulf %126, %123 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %136 = arith.addf %46, %135 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %137 = affine.load %arg2[%arg8 * 5 + 2, %arg7 * 5 + 1] {partition_indices = [2, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %138 = arith.mulf %137, %111 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %139 = arith.addf %51, %138 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %140 = arith.mulf %137, %114 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %141 = arith.addf %55, %140 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        %142 = arith.mulf %137, %117 {timing = #hls.t<9 -> 13, 4, 1>} : f32
        %143 = arith.addf %59, %142 {timing = #hls.t<13 -> 18, 5, 1>} : f32
        %144 = arith.mulf %137, %120 {timing = #hls.t<10 -> 14, 4, 1>} : f32
        %145 = arith.addf %63, %144 {timing = #hls.t<14 -> 19, 5, 1>} : f32
        %146 = arith.mulf %137, %123 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %147 = arith.addf %67, %146 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %148 = affine.load %arg2[%arg8 * 5 + 3, %arg7 * 5 + 1] {partition_indices = [3, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %149 = arith.mulf %148, %111 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %150 = arith.addf %72, %149 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %151 = arith.mulf %148, %114 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %152 = arith.addf %76, %151 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        %153 = arith.mulf %148, %117 {timing = #hls.t<9 -> 13, 4, 1>} : f32
        %154 = arith.addf %80, %153 {timing = #hls.t<13 -> 18, 5, 1>} : f32
        %155 = arith.mulf %148, %120 {timing = #hls.t<10 -> 14, 4, 1>} : f32
        %156 = arith.addf %84, %155 {timing = #hls.t<14 -> 19, 5, 1>} : f32
        %157 = arith.mulf %148, %123 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %158 = arith.addf %88, %157 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %159 = affine.load %arg2[%arg8 * 5 + 4, %arg7 * 5 + 1] {partition_indices = [4, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %160 = arith.mulf %159, %111 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %161 = arith.addf %93, %160 {timing = #hls.t<11 -> 16, 5, 1>} : f32
        %162 = arith.mulf %159, %114 {timing = #hls.t<8 -> 12, 4, 1>} : f32
        %163 = arith.addf %97, %162 {timing = #hls.t<12 -> 17, 5, 1>} : f32
        %164 = arith.mulf %159, %117 {timing = #hls.t<9 -> 13, 4, 1>} : f32
        %165 = arith.addf %101, %164 {timing = #hls.t<13 -> 18, 5, 1>} : f32
        %166 = arith.mulf %159, %120 {timing = #hls.t<10 -> 14, 4, 1>} : f32
        %167 = arith.addf %105, %166 {timing = #hls.t<14 -> 19, 5, 1>} : f32
        %168 = arith.mulf %159, %123 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %169 = arith.addf %109, %168 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %170 = affine.load %arg2[%arg8 * 5, %arg7 * 5 + 2] {partition_indices = [0, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %171 = affine.load %arg3[%arg7 * 5 + 2, %arg9 * 5] {partition_indices = [2, 0], timing = #hls.t<10 -> 12, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %172 = arith.mulf %170, %171 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %173 = arith.addf %113, %172 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        %174 = affine.load %arg3[%arg7 * 5 + 2, %arg9 * 5 + 1] {partition_indices = [2, 1], timing = #hls.t<11 -> 13, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %175 = arith.mulf %170, %174 {timing = #hls.t<13 -> 17, 4, 1>} : f32
        %176 = arith.addf %116, %175 {timing = #hls.t<17 -> 22, 5, 1>} : f32
        %177 = affine.load %arg3[%arg7 * 5 + 2, %arg9 * 5 + 2] {partition_indices = [2, 2], timing = #hls.t<12 -> 14, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %178 = arith.mulf %170, %177 {timing = #hls.t<14 -> 18, 4, 1>} : f32
        %179 = arith.addf %119, %178 {timing = #hls.t<18 -> 23, 5, 1>} : f32
        %180 = affine.load %arg3[%arg7 * 5 + 2, %arg9 * 5 + 3] {partition_indices = [2, 3], timing = #hls.t<13 -> 15, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %181 = arith.mulf %170, %180 {timing = #hls.t<15 -> 19, 4, 1>} : f32
        %182 = arith.addf %122, %181 {timing = #hls.t<19 -> 24, 5, 1>} : f32
        %183 = affine.load %arg3[%arg7 * 5 + 2, %arg9 * 5 + 4] {partition_indices = [2, 4], timing = #hls.t<14 -> 16, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %184 = arith.mulf %170, %183 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %185 = arith.addf %125, %184 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %186 = affine.load %arg2[%arg8 * 5 + 1, %arg7 * 5 + 2] {partition_indices = [1, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %187 = arith.mulf %186, %171 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %188 = arith.addf %128, %187 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        %189 = arith.mulf %186, %174 {timing = #hls.t<13 -> 17, 4, 1>} : f32
        %190 = arith.addf %130, %189 {timing = #hls.t<17 -> 22, 5, 1>} : f32
        %191 = arith.mulf %186, %177 {timing = #hls.t<14 -> 18, 4, 1>} : f32
        %192 = arith.addf %132, %191 {timing = #hls.t<18 -> 23, 5, 1>} : f32
        %193 = arith.mulf %186, %180 {timing = #hls.t<15 -> 19, 4, 1>} : f32
        %194 = arith.addf %134, %193 {timing = #hls.t<19 -> 24, 5, 1>} : f32
        %195 = arith.mulf %186, %183 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %196 = arith.addf %136, %195 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %197 = affine.load %arg2[%arg8 * 5 + 2, %arg7 * 5 + 2] {partition_indices = [2, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %198 = arith.mulf %197, %171 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %199 = arith.addf %139, %198 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        %200 = arith.mulf %197, %174 {timing = #hls.t<13 -> 17, 4, 1>} : f32
        %201 = arith.addf %141, %200 {timing = #hls.t<17 -> 22, 5, 1>} : f32
        %202 = arith.mulf %197, %177 {timing = #hls.t<14 -> 18, 4, 1>} : f32
        %203 = arith.addf %143, %202 {timing = #hls.t<18 -> 23, 5, 1>} : f32
        %204 = arith.mulf %197, %180 {timing = #hls.t<15 -> 19, 4, 1>} : f32
        %205 = arith.addf %145, %204 {timing = #hls.t<19 -> 24, 5, 1>} : f32
        %206 = arith.mulf %197, %183 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %207 = arith.addf %147, %206 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %208 = affine.load %arg2[%arg8 * 5 + 3, %arg7 * 5 + 2] {partition_indices = [3, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %209 = arith.mulf %208, %171 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %210 = arith.addf %150, %209 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        %211 = arith.mulf %208, %174 {timing = #hls.t<13 -> 17, 4, 1>} : f32
        %212 = arith.addf %152, %211 {timing = #hls.t<17 -> 22, 5, 1>} : f32
        %213 = arith.mulf %208, %177 {timing = #hls.t<14 -> 18, 4, 1>} : f32
        %214 = arith.addf %154, %213 {timing = #hls.t<18 -> 23, 5, 1>} : f32
        %215 = arith.mulf %208, %180 {timing = #hls.t<15 -> 19, 4, 1>} : f32
        %216 = arith.addf %156, %215 {timing = #hls.t<19 -> 24, 5, 1>} : f32
        %217 = arith.mulf %208, %183 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %218 = arith.addf %158, %217 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %219 = affine.load %arg2[%arg8 * 5 + 4, %arg7 * 5 + 2] {partition_indices = [4, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %220 = arith.mulf %219, %171 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %221 = arith.addf %161, %220 {timing = #hls.t<16 -> 21, 5, 1>} : f32
        %222 = arith.mulf %219, %174 {timing = #hls.t<13 -> 17, 4, 1>} : f32
        %223 = arith.addf %163, %222 {timing = #hls.t<17 -> 22, 5, 1>} : f32
        %224 = arith.mulf %219, %177 {timing = #hls.t<14 -> 18, 4, 1>} : f32
        %225 = arith.addf %165, %224 {timing = #hls.t<18 -> 23, 5, 1>} : f32
        %226 = arith.mulf %219, %180 {timing = #hls.t<15 -> 19, 4, 1>} : f32
        %227 = arith.addf %167, %226 {timing = #hls.t<19 -> 24, 5, 1>} : f32
        %228 = arith.mulf %219, %183 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %229 = arith.addf %169, %228 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %230 = affine.load %arg2[%arg8 * 5, %arg7 * 5 + 3] {partition_indices = [0, 3], timing = #hls.t<15 -> 17, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %231 = affine.load %arg3[%arg7 * 5 + 3, %arg9 * 5] {partition_indices = [3, 0], timing = #hls.t<15 -> 17, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %232 = arith.mulf %230, %231 {timing = #hls.t<17 -> 21, 4, 1>} : f32
        %233 = arith.addf %173, %232 {timing = #hls.t<21 -> 26, 5, 1>} : f32
        %234 = affine.load %arg3[%arg7 * 5 + 3, %arg9 * 5 + 1] {partition_indices = [3, 1], timing = #hls.t<16 -> 18, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %235 = arith.mulf %230, %234 {timing = #hls.t<18 -> 22, 4, 1>} : f32
        %236 = arith.addf %176, %235 {timing = #hls.t<22 -> 27, 5, 1>} : f32
        %237 = affine.load %arg3[%arg7 * 5 + 3, %arg9 * 5 + 2] {partition_indices = [3, 2], timing = #hls.t<17 -> 19, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %238 = arith.mulf %230, %237 {timing = #hls.t<19 -> 23, 4, 1>} : f32
        %239 = arith.addf %179, %238 {timing = #hls.t<23 -> 28, 5, 1>} : f32
        %240 = affine.load %arg3[%arg7 * 5 + 3, %arg9 * 5 + 3] {partition_indices = [3, 3], timing = #hls.t<18 -> 20, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %241 = arith.mulf %230, %240 {timing = #hls.t<20 -> 24, 4, 1>} : f32
        %242 = arith.addf %182, %241 {timing = #hls.t<24 -> 29, 5, 1>} : f32
        %243 = affine.load %arg3[%arg7 * 5 + 3, %arg9 * 5 + 4] {partition_indices = [3, 4], timing = #hls.t<19 -> 21, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %244 = arith.mulf %230, %243 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %245 = arith.addf %185, %244 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %246 = affine.load %arg2[%arg8 * 5 + 1, %arg7 * 5 + 3] {partition_indices = [1, 3], timing = #hls.t<15 -> 17, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %247 = arith.mulf %246, %231 {timing = #hls.t<17 -> 21, 4, 1>} : f32
        %248 = arith.addf %188, %247 {timing = #hls.t<21 -> 26, 5, 1>} : f32
        %249 = arith.mulf %246, %234 {timing = #hls.t<18 -> 22, 4, 1>} : f32
        %250 = arith.addf %190, %249 {timing = #hls.t<22 -> 27, 5, 1>} : f32
        %251 = arith.mulf %246, %237 {timing = #hls.t<19 -> 23, 4, 1>} : f32
        %252 = arith.addf %192, %251 {timing = #hls.t<23 -> 28, 5, 1>} : f32
        %253 = arith.mulf %246, %240 {timing = #hls.t<20 -> 24, 4, 1>} : f32
        %254 = arith.addf %194, %253 {timing = #hls.t<24 -> 29, 5, 1>} : f32
        %255 = arith.mulf %246, %243 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %256 = arith.addf %196, %255 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %257 = affine.load %arg2[%arg8 * 5 + 2, %arg7 * 5 + 3] {partition_indices = [2, 3], timing = #hls.t<15 -> 17, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %258 = arith.mulf %257, %231 {timing = #hls.t<17 -> 21, 4, 1>} : f32
        %259 = arith.addf %199, %258 {timing = #hls.t<21 -> 26, 5, 1>} : f32
        %260 = arith.mulf %257, %234 {timing = #hls.t<18 -> 22, 4, 1>} : f32
        %261 = arith.addf %201, %260 {timing = #hls.t<22 -> 27, 5, 1>} : f32
        %262 = arith.mulf %257, %237 {timing = #hls.t<19 -> 23, 4, 1>} : f32
        %263 = arith.addf %203, %262 {timing = #hls.t<23 -> 28, 5, 1>} : f32
        %264 = arith.mulf %257, %240 {timing = #hls.t<20 -> 24, 4, 1>} : f32
        %265 = arith.addf %205, %264 {timing = #hls.t<24 -> 29, 5, 1>} : f32
        %266 = arith.mulf %257, %243 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %267 = arith.addf %207, %266 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %268 = affine.load %arg2[%arg8 * 5 + 3, %arg7 * 5 + 3] {partition_indices = [3, 3], timing = #hls.t<15 -> 17, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %269 = arith.mulf %268, %231 {timing = #hls.t<17 -> 21, 4, 1>} : f32
        %270 = arith.addf %210, %269 {timing = #hls.t<21 -> 26, 5, 1>} : f32
        %271 = arith.mulf %268, %234 {timing = #hls.t<18 -> 22, 4, 1>} : f32
        %272 = arith.addf %212, %271 {timing = #hls.t<22 -> 27, 5, 1>} : f32
        %273 = arith.mulf %268, %237 {timing = #hls.t<19 -> 23, 4, 1>} : f32
        %274 = arith.addf %214, %273 {timing = #hls.t<23 -> 28, 5, 1>} : f32
        %275 = arith.mulf %268, %240 {timing = #hls.t<20 -> 24, 4, 1>} : f32
        %276 = arith.addf %216, %275 {timing = #hls.t<24 -> 29, 5, 1>} : f32
        %277 = arith.mulf %268, %243 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %278 = arith.addf %218, %277 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %279 = affine.load %arg2[%arg8 * 5 + 4, %arg7 * 5 + 3] {partition_indices = [4, 3], timing = #hls.t<15 -> 17, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %280 = arith.mulf %279, %231 {timing = #hls.t<17 -> 21, 4, 1>} : f32
        %281 = arith.addf %221, %280 {timing = #hls.t<21 -> 26, 5, 1>} : f32
        %282 = arith.mulf %279, %234 {timing = #hls.t<18 -> 22, 4, 1>} : f32
        %283 = arith.addf %223, %282 {timing = #hls.t<22 -> 27, 5, 1>} : f32
        %284 = arith.mulf %279, %237 {timing = #hls.t<19 -> 23, 4, 1>} : f32
        %285 = arith.addf %225, %284 {timing = #hls.t<23 -> 28, 5, 1>} : f32
        %286 = arith.mulf %279, %240 {timing = #hls.t<20 -> 24, 4, 1>} : f32
        %287 = arith.addf %227, %286 {timing = #hls.t<24 -> 29, 5, 1>} : f32
        %288 = arith.mulf %279, %243 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %289 = arith.addf %229, %288 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %290 = affine.load %arg2[%arg8 * 5, %arg7 * 5 + 4] {partition_indices = [0, 4], timing = #hls.t<20 -> 22, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %291 = affine.load %arg3[%arg7 * 5 + 4, %arg9 * 5] {partition_indices = [4, 0], timing = #hls.t<20 -> 22, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %292 = arith.mulf %290, %291 {timing = #hls.t<22 -> 26, 4, 1>} : f32
        %293 = arith.addf %233, %292 {timing = #hls.t<26 -> 31, 5, 1>} : f32
        affine.store %293, %arg5[%arg8 * 5, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<31 -> 32, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %294 = affine.load %arg3[%arg7 * 5 + 4, %arg9 * 5 + 1] {partition_indices = [4, 1], timing = #hls.t<21 -> 23, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %295 = arith.mulf %290, %294 {timing = #hls.t<23 -> 27, 4, 1>} : f32
        %296 = arith.addf %236, %295 {timing = #hls.t<27 -> 32, 5, 1>} : f32
        affine.store %296, %arg5[%arg8 * 5, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<32 -> 33, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %297 = affine.load %arg3[%arg7 * 5 + 4, %arg9 * 5 + 2] {partition_indices = [4, 2], timing = #hls.t<22 -> 24, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %298 = arith.mulf %290, %297 {timing = #hls.t<24 -> 28, 4, 1>} : f32
        %299 = arith.addf %239, %298 {timing = #hls.t<28 -> 33, 5, 1>} : f32
        affine.store %299, %arg5[%arg8 * 5, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<33 -> 34, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %300 = affine.load %arg3[%arg7 * 5 + 4, %arg9 * 5 + 3] {partition_indices = [4, 3], timing = #hls.t<23 -> 25, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %301 = arith.mulf %290, %300 {timing = #hls.t<25 -> 29, 4, 1>} : f32
        %302 = arith.addf %242, %301 {timing = #hls.t<29 -> 34, 5, 1>} : f32
        affine.store %302, %arg5[%arg8 * 5, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<34 -> 35, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %303 = affine.load %arg3[%arg7 * 5 + 4, %arg9 * 5 + 4] {partition_indices = [4, 4], timing = #hls.t<24 -> 26, 2, 1>} : memref<80x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %304 = arith.mulf %290, %303 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %305 = arith.addf %245, %304 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        affine.store %305, %arg5[%arg8 * 5, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [0, -1], timing = #hls.t<35 -> 36, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %306 = affine.load %arg2[%arg8 * 5 + 1, %arg7 * 5 + 4] {partition_indices = [1, 4], timing = #hls.t<20 -> 22, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %307 = arith.mulf %306, %291 {timing = #hls.t<22 -> 26, 4, 1>} : f32
        %308 = arith.addf %248, %307 {timing = #hls.t<26 -> 31, 5, 1>} : f32
        affine.store %308, %arg5[%arg8 * 5 + 1, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<31 -> 32, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %309 = arith.mulf %306, %294 {timing = #hls.t<23 -> 27, 4, 1>} : f32
        %310 = arith.addf %250, %309 {timing = #hls.t<27 -> 32, 5, 1>} : f32
        affine.store %310, %arg5[%arg8 * 5 + 1, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<32 -> 33, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %311 = arith.mulf %306, %297 {timing = #hls.t<24 -> 28, 4, 1>} : f32
        %312 = arith.addf %252, %311 {timing = #hls.t<28 -> 33, 5, 1>} : f32
        affine.store %312, %arg5[%arg8 * 5 + 1, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<33 -> 34, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %313 = arith.mulf %306, %300 {timing = #hls.t<25 -> 29, 4, 1>} : f32
        %314 = arith.addf %254, %313 {timing = #hls.t<29 -> 34, 5, 1>} : f32
        affine.store %314, %arg5[%arg8 * 5 + 1, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<34 -> 35, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %315 = arith.mulf %306, %303 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %316 = arith.addf %256, %315 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        affine.store %316, %arg5[%arg8 * 5 + 1, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [1, -1], timing = #hls.t<35 -> 36, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %317 = affine.load %arg2[%arg8 * 5 + 2, %arg7 * 5 + 4] {partition_indices = [2, 4], timing = #hls.t<20 -> 22, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %318 = arith.mulf %317, %291 {timing = #hls.t<22 -> 26, 4, 1>} : f32
        %319 = arith.addf %259, %318 {timing = #hls.t<26 -> 31, 5, 1>} : f32
        affine.store %319, %arg5[%arg8 * 5 + 2, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<31 -> 32, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %320 = arith.mulf %317, %294 {timing = #hls.t<23 -> 27, 4, 1>} : f32
        %321 = arith.addf %261, %320 {timing = #hls.t<27 -> 32, 5, 1>} : f32
        affine.store %321, %arg5[%arg8 * 5 + 2, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<32 -> 33, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %322 = arith.mulf %317, %297 {timing = #hls.t<24 -> 28, 4, 1>} : f32
        %323 = arith.addf %263, %322 {timing = #hls.t<28 -> 33, 5, 1>} : f32
        affine.store %323, %arg5[%arg8 * 5 + 2, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<33 -> 34, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %324 = arith.mulf %317, %300 {timing = #hls.t<25 -> 29, 4, 1>} : f32
        %325 = arith.addf %265, %324 {timing = #hls.t<29 -> 34, 5, 1>} : f32
        affine.store %325, %arg5[%arg8 * 5 + 2, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<34 -> 35, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %326 = arith.mulf %317, %303 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %327 = arith.addf %267, %326 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        affine.store %327, %arg5[%arg8 * 5 + 2, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [2, -1], timing = #hls.t<35 -> 36, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %328 = affine.load %arg2[%arg8 * 5 + 3, %arg7 * 5 + 4] {partition_indices = [3, 4], timing = #hls.t<20 -> 22, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %329 = arith.mulf %328, %291 {timing = #hls.t<22 -> 26, 4, 1>} : f32
        %330 = arith.addf %270, %329 {timing = #hls.t<26 -> 31, 5, 1>} : f32
        affine.store %330, %arg5[%arg8 * 5 + 3, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<31 -> 32, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %331 = arith.mulf %328, %294 {timing = #hls.t<23 -> 27, 4, 1>} : f32
        %332 = arith.addf %272, %331 {timing = #hls.t<27 -> 32, 5, 1>} : f32
        affine.store %332, %arg5[%arg8 * 5 + 3, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<32 -> 33, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %333 = arith.mulf %328, %297 {timing = #hls.t<24 -> 28, 4, 1>} : f32
        %334 = arith.addf %274, %333 {timing = #hls.t<28 -> 33, 5, 1>} : f32
        affine.store %334, %arg5[%arg8 * 5 + 3, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<33 -> 34, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %335 = arith.mulf %328, %300 {timing = #hls.t<25 -> 29, 4, 1>} : f32
        %336 = arith.addf %276, %335 {timing = #hls.t<29 -> 34, 5, 1>} : f32
        affine.store %336, %arg5[%arg8 * 5 + 3, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<34 -> 35, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %337 = arith.mulf %328, %303 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %338 = arith.addf %278, %337 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        affine.store %338, %arg5[%arg8 * 5 + 3, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [3, -1], timing = #hls.t<35 -> 36, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %339 = affine.load %arg2[%arg8 * 5 + 4, %arg7 * 5 + 4] {partition_indices = [4, 4], timing = #hls.t<20 -> 22, 2, 1>} : memref<50x80xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 5, d0 floordiv 5, d1 floordiv 5)>>
        %340 = arith.mulf %339, %291 {timing = #hls.t<22 -> 26, 4, 1>} : f32
        %341 = arith.addf %281, %340 {timing = #hls.t<26 -> 31, 5, 1>} : f32
        affine.store %341, %arg5[%arg8 * 5 + 4, %arg9 * 5] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<31 -> 32, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %342 = arith.mulf %339, %294 {timing = #hls.t<23 -> 27, 4, 1>} : f32
        %343 = arith.addf %283, %342 {timing = #hls.t<27 -> 32, 5, 1>} : f32
        affine.store %343, %arg5[%arg8 * 5 + 4, %arg9 * 5 + 1] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<32 -> 33, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %344 = arith.mulf %339, %297 {timing = #hls.t<24 -> 28, 4, 1>} : f32
        %345 = arith.addf %285, %344 {timing = #hls.t<28 -> 33, 5, 1>} : f32
        affine.store %345, %arg5[%arg8 * 5 + 4, %arg9 * 5 + 2] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<33 -> 34, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %346 = arith.mulf %339, %300 {timing = #hls.t<25 -> 29, 4, 1>} : f32
        %347 = arith.addf %287, %346 {timing = #hls.t<29 -> 34, 5, 1>} : f32
        affine.store %347, %arg5[%arg8 * 5 + 4, %arg9 * 5 + 3] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<34 -> 35, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %348 = arith.mulf %339, %303 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %349 = arith.addf %289, %348 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        affine.store %349, %arg5[%arg8 * 5 + 4, %arg9 * 5 + 4] {max_mux_size = 10 : i64, partition_indices = [4, -1], timing = #hls.t<35 -> 36, 1, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
      } {loop_directive = #hls.ld<pipeline=true, targetII=3, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=14, iterLatency=36, minII=5>, parallel, timing = #hls.t<14013 -> 14116, 103, 103>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=140, iterLatency=36, minII=5>, parallel, timing = #hls.t<14013 -> 14746, 733, 733>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=2240, iterLatency=36, minII=5>, timing = #hls.t<2523 -> 13756, 11233, 11233>}
  affine.for %arg7 = 0 to 50 {
    affine.for %arg8 = 0 to 10 {
      affine.for %arg9 = 0 to 7 {
        %0 = affine.load %arg4[%arg8 * 4, %arg7] {max_mux_size = 8 : i64, partition_indices = [-1, -1], timing = #hls.t<0 -> 2, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %1 = affine.load %arg5[%arg7, %arg9 * 10] {max_mux_size = 5 : i64, partition_indices = [-1, 0], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %2 = arith.mulf %0, %1 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %3 = affine.load %arg6[%arg8 * 4, %arg9 * 10] {partition_indices = [0, 0], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %4 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %3 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %5 = arith.addf %4, %2 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %5, %arg6[%arg8 * 4, %arg9 * 10] {partition_indices = [0, 0], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %6 = affine.load %arg5[%arg7, %arg9 * 10 + 1] {max_mux_size = 5 : i64, partition_indices = [-1, 1], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %7 = arith.mulf %0, %6 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %8 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 1] {partition_indices = [0, 1], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %9 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %8 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %10 = arith.addf %9, %7 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %10, %arg6[%arg8 * 4, %arg9 * 10 + 1] {partition_indices = [0, 1], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %11 = affine.load %arg5[%arg7, %arg9 * 10 + 2] {max_mux_size = 5 : i64, partition_indices = [-1, 2], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %12 = arith.mulf %0, %11 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %13 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 2] {partition_indices = [0, 2], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %14 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %13 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %15 = arith.addf %14, %12 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %15, %arg6[%arg8 * 4, %arg9 * 10 + 2] {partition_indices = [0, 2], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %16 = affine.load %arg5[%arg7, %arg9 * 10 + 3] {max_mux_size = 5 : i64, partition_indices = [-1, 3], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %17 = arith.mulf %0, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %18 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 3] {partition_indices = [0, 3], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %19 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %18 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %20 = arith.addf %19, %17 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %20, %arg6[%arg8 * 4, %arg9 * 10 + 3] {partition_indices = [0, 3], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %21 = affine.load %arg5[%arg7, %arg9 * 10 + 4] {max_mux_size = 5 : i64, partition_indices = [-1, 4], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %22 = arith.mulf %0, %21 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %23 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 4] {partition_indices = [0, 4], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %24 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %23 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %25 = arith.addf %24, %22 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %25, %arg6[%arg8 * 4, %arg9 * 10 + 4] {partition_indices = [0, 4], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %26 = affine.load %arg5[%arg7, %arg9 * 10 + 5] {max_mux_size = 5 : i64, partition_indices = [-1, 5], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %27 = arith.mulf %0, %26 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %28 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 5] {partition_indices = [0, 5], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %29 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %28 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %30 = arith.addf %29, %27 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %30, %arg6[%arg8 * 4, %arg9 * 10 + 5] {partition_indices = [0, 5], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %31 = affine.load %arg5[%arg7, %arg9 * 10 + 6] {max_mux_size = 5 : i64, partition_indices = [-1, 6], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %32 = arith.mulf %0, %31 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %33 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 6] {partition_indices = [0, 6], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %34 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %33 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %35 = arith.addf %34, %32 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %35, %arg6[%arg8 * 4, %arg9 * 10 + 6] {partition_indices = [0, 6], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %36 = affine.load %arg5[%arg7, %arg9 * 10 + 7] {max_mux_size = 5 : i64, partition_indices = [-1, 7], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %37 = arith.mulf %0, %36 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %38 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 7] {partition_indices = [0, 7], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %39 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %38 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %40 = arith.addf %39, %37 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %40, %arg6[%arg8 * 4, %arg9 * 10 + 7] {partition_indices = [0, 7], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %41 = affine.load %arg5[%arg7, %arg9 * 10 + 8] {max_mux_size = 5 : i64, partition_indices = [-1, 8], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %42 = arith.mulf %0, %41 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %43 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 8] {partition_indices = [0, 8], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %44 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %43 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %45 = arith.addf %44, %42 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %45, %arg6[%arg8 * 4, %arg9 * 10 + 8] {partition_indices = [0, 8], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %46 = affine.load %arg5[%arg7, %arg9 * 10 + 9] {max_mux_size = 5 : i64, partition_indices = [-1, 9], timing = #hls.t<3 -> 5, 2, 1>} : memref<50x70xf32, affine_map<(d0, d1) -> (d0 mod 5, d1 mod 10, d0 floordiv 5, d1 floordiv 10)>>
        %47 = arith.mulf %0, %46 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %48 = affine.load %arg6[%arg8 * 4, %arg9 * 10 + 9] {partition_indices = [0, 9], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %49 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %48 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %50 = arith.addf %49, %47 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %50, %arg6[%arg8 * 4, %arg9 * 10 + 9] {partition_indices = [0, 9], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %51 = affine.load %arg4[%arg8 * 4 + 1, %arg7] {max_mux_size = 8 : i64, partition_indices = [-1, -1], timing = #hls.t<1 -> 3, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %52 = arith.mulf %51, %1 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %53 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10] {partition_indices = [1, 0], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %54 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %53 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %55 = arith.addf %54, %52 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %55, %arg6[%arg8 * 4 + 1, %arg9 * 10] {partition_indices = [1, 0], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %56 = arith.mulf %51, %6 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %57 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 1] {partition_indices = [1, 1], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %58 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %57 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %59 = arith.addf %58, %56 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %59, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 1] {partition_indices = [1, 1], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %60 = arith.mulf %51, %11 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %61 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 2] {partition_indices = [1, 2], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %62 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %61 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %63 = arith.addf %62, %60 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %63, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 2] {partition_indices = [1, 2], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %64 = arith.mulf %51, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %65 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 3] {partition_indices = [1, 3], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %66 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %65 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %67 = arith.addf %66, %64 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %67, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 3] {partition_indices = [1, 3], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %68 = arith.mulf %51, %21 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %69 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 4] {partition_indices = [1, 4], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %70 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %69 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %71 = arith.addf %70, %68 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %71, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 4] {partition_indices = [1, 4], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %72 = arith.mulf %51, %26 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %73 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 5] {partition_indices = [1, 5], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %74 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %73 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %75 = arith.addf %74, %72 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %75, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 5] {partition_indices = [1, 5], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %76 = arith.mulf %51, %31 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %77 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 6] {partition_indices = [1, 6], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %78 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %77 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %79 = arith.addf %78, %76 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %79, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 6] {partition_indices = [1, 6], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %80 = arith.mulf %51, %36 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %81 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 7] {partition_indices = [1, 7], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %82 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %81 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %83 = arith.addf %82, %80 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %83, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 7] {partition_indices = [1, 7], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %84 = arith.mulf %51, %41 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %85 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 8] {partition_indices = [1, 8], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %86 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %85 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %87 = arith.addf %86, %84 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %87, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 8] {partition_indices = [1, 8], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %88 = arith.mulf %51, %46 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %89 = affine.load %arg6[%arg8 * 4 + 1, %arg9 * 10 + 9] {partition_indices = [1, 9], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %90 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %89 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %91 = arith.addf %90, %88 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %91, %arg6[%arg8 * 4 + 1, %arg9 * 10 + 9] {partition_indices = [1, 9], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %92 = affine.load %arg4[%arg8 * 4 + 2, %arg7] {max_mux_size = 8 : i64, partition_indices = [-1, -1], timing = #hls.t<2 -> 4, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %93 = arith.mulf %92, %1 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %94 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10] {partition_indices = [2, 0], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %95 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %94 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %96 = arith.addf %95, %93 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %96, %arg6[%arg8 * 4 + 2, %arg9 * 10] {partition_indices = [2, 0], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %97 = arith.mulf %92, %6 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %98 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 1] {partition_indices = [2, 1], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %99 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %98 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %100 = arith.addf %99, %97 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %100, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 1] {partition_indices = [2, 1], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %101 = arith.mulf %92, %11 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %102 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 2] {partition_indices = [2, 2], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %103 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %102 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %104 = arith.addf %103, %101 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %104, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 2] {partition_indices = [2, 2], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %105 = arith.mulf %92, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %106 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 3] {partition_indices = [2, 3], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %107 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %106 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %108 = arith.addf %107, %105 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %108, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 3] {partition_indices = [2, 3], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %109 = arith.mulf %92, %21 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %110 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 4] {partition_indices = [2, 4], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %111 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %110 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %112 = arith.addf %111, %109 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %112, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 4] {partition_indices = [2, 4], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %113 = arith.mulf %92, %26 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %114 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 5] {partition_indices = [2, 5], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %115 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %114 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %116 = arith.addf %115, %113 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %116, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 5] {partition_indices = [2, 5], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %117 = arith.mulf %92, %31 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %118 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 6] {partition_indices = [2, 6], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %119 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %118 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %120 = arith.addf %119, %117 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %120, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 6] {partition_indices = [2, 6], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %121 = arith.mulf %92, %36 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %122 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 7] {partition_indices = [2, 7], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %123 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %122 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %124 = arith.addf %123, %121 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %124, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 7] {partition_indices = [2, 7], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %125 = arith.mulf %92, %41 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %126 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 8] {partition_indices = [2, 8], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %127 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %126 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %128 = arith.addf %127, %125 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %128, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 8] {partition_indices = [2, 8], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %129 = arith.mulf %92, %46 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %130 = affine.load %arg6[%arg8 * 4 + 2, %arg9 * 10 + 9] {partition_indices = [2, 9], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %131 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %130 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %132 = arith.addf %131, %129 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %132, %arg6[%arg8 * 4 + 2, %arg9 * 10 + 9] {partition_indices = [2, 9], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %133 = affine.load %arg4[%arg8 * 4 + 3, %arg7] {max_mux_size = 8 : i64, partition_indices = [-1, -1], timing = #hls.t<3 -> 5, 2, 1>} : memref<40x50xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 2, d0 floordiv 8, d1 floordiv 2)>>
        %134 = arith.mulf %133, %1 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %135 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10] {partition_indices = [3, 0], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %136 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %135 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %137 = arith.addf %136, %134 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %137, %arg6[%arg8 * 4 + 3, %arg9 * 10] {partition_indices = [3, 0], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %138 = arith.mulf %133, %6 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %139 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 1] {partition_indices = [3, 1], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %140 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %139 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %141 = arith.addf %140, %138 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %141, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 1] {partition_indices = [3, 1], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %142 = arith.mulf %133, %11 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %143 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 2] {partition_indices = [3, 2], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %144 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %143 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %145 = arith.addf %144, %142 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %145, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 2] {partition_indices = [3, 2], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %146 = arith.mulf %133, %16 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %147 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 3] {partition_indices = [3, 3], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %148 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %147 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %149 = arith.addf %148, %146 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %149, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 3] {partition_indices = [3, 3], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %150 = arith.mulf %133, %21 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %151 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 4] {partition_indices = [3, 4], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %152 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %151 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %153 = arith.addf %152, %150 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %153, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 4] {partition_indices = [3, 4], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %154 = arith.mulf %133, %26 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %155 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 5] {partition_indices = [3, 5], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %156 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %155 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %157 = arith.addf %156, %154 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %157, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 5] {partition_indices = [3, 5], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %158 = arith.mulf %133, %31 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %159 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 6] {partition_indices = [3, 6], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %160 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %159 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %161 = arith.addf %160, %158 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %161, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 6] {partition_indices = [3, 6], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %162 = arith.mulf %133, %36 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %163 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 7] {partition_indices = [3, 7], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %164 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %163 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %165 = arith.addf %164, %162 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %165, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 7] {partition_indices = [3, 7], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %166 = arith.mulf %133, %41 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %167 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 8] {partition_indices = [3, 8], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %168 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %167 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %169 = arith.addf %168, %166 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %169, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 8] {partition_indices = [3, 8], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %170 = arith.mulf %133, %46 {timing = #hls.t<5 -> 9, 4, 1>} : f32
        %171 = affine.load %arg6[%arg8 * 4 + 3, %arg9 * 10 + 9] {partition_indices = [3, 9], timing = #hls.t<7 -> 9, 2, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
        %172 = affine.if affine_set<(d0) : (d0 == 0)>(%arg7) -> f32 {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %cst : f32
        } else {
          affine.yield {timing = #hls.t<9 -> 9, 0, 0>} %171 : f32
        } {timing = #hls.t<9 -> 9, 0, 0>}
        %173 = arith.addf %172, %170 {timing = #hls.t<9 -> 14, 5, 1>} : f32
        affine.store %173, %arg6[%arg8 * 4 + 3, %arg9 * 10 + 9] {partition_indices = [3, 9], timing = #hls.t<14 -> 15, 1, 1>} : memref<40x70xf32, affine_map<(d0, d1) -> (d0 mod 4, d1 mod 10, d0 floordiv 4, d1 floordiv 10)>>
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=7, iterLatency=15, minII=4>, parallel, timing = #hls.t<0 -> 41, 41, 41>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=70, iterLatency=15, minII=4>, parallel, timing = #hls.t<0 -> 293, 293, 293>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=3500, iterLatency=15, minII=4>, timing = #hls.t<13756 -> 27769, 14013, 14013>}
  return {timing = #hls.t<27769 -> 27769, 0, 0>}
}
