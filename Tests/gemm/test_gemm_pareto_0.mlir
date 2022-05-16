func @test_gemm(%arg0: f32, %arg1: f32, %arg2: memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>, %arg3: memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>, %arg4: memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>) attributes {llvm.linkage = #llvm.linkage<external>, resource = #hls.r<lut=0, dsp=239, bram=0>, timing = #hls.t<0 -> 6196, 6196, 6196>, top_func} {
  affine.for %arg5 = 0 to 8 {
    affine.for %arg6 = 0 to 64 {
      affine.for %arg7 = 0 to 4 {
        %0 = affine.load %arg2[%arg6, %arg7 * 16] {partition_indices = [0, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %1 = arith.mulf %0, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %2 = affine.load %arg3[%arg6, %arg5 * 8] {partition_indices = [0, 0], timing = #hls.t<0 -> 2, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>
        %3 = arith.mulf %arg0, %2 {timing = #hls.t<2 -> 6, 4, 1>} : f32
        %4 = affine.load %arg4[%arg5 * 8, %arg7 * 16] {partition_indices = [0, 0], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %5 = arith.mulf %3, %4 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %6 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %1 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %0 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %7 = arith.addf %6, %5 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %8 = affine.load %arg2[%arg6, %arg7 * 16 + 1] {partition_indices = [0, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %9 = arith.mulf %8, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %10 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 1] {partition_indices = [0, 1], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %11 = arith.mulf %3, %10 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %12 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %9 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %8 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %13 = arith.addf %12, %11 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %14 = affine.load %arg2[%arg6, %arg7 * 16 + 2] {partition_indices = [0, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %15 = arith.mulf %14, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %16 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 2] {partition_indices = [0, 2], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %17 = arith.mulf %3, %16 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %18 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %15 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %14 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %19 = arith.addf %18, %17 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %20 = affine.load %arg2[%arg6, %arg7 * 16 + 3] {partition_indices = [0, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %21 = arith.mulf %20, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %22 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 3] {partition_indices = [0, 3], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %23 = arith.mulf %3, %22 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %24 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %21 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %20 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %25 = arith.addf %24, %23 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %26 = affine.load %arg2[%arg6, %arg7 * 16 + 4] {partition_indices = [0, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %27 = arith.mulf %26, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %28 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 4] {partition_indices = [0, 4], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %29 = arith.mulf %3, %28 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %30 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %27 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %26 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %31 = arith.addf %30, %29 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %32 = affine.load %arg2[%arg6, %arg7 * 16 + 5] {partition_indices = [0, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %33 = arith.mulf %32, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %34 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 5] {partition_indices = [0, 5], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %35 = arith.mulf %3, %34 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %36 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %33 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %32 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %37 = arith.addf %36, %35 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %38 = affine.load %arg2[%arg6, %arg7 * 16 + 6] {partition_indices = [0, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %39 = arith.mulf %38, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %40 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 6] {partition_indices = [0, 6], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %41 = arith.mulf %3, %40 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %42 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %39 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %38 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %43 = arith.addf %42, %41 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %44 = affine.load %arg2[%arg6, %arg7 * 16 + 7] {partition_indices = [0, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %45 = arith.mulf %44, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %46 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 7] {partition_indices = [0, 7], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %47 = arith.mulf %3, %46 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %48 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %45 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %44 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %49 = arith.addf %48, %47 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %50 = affine.load %arg2[%arg6, %arg7 * 16 + 8] {partition_indices = [0, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %51 = arith.mulf %50, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %52 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 8] {partition_indices = [0, 8], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %53 = arith.mulf %3, %52 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %54 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %51 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %50 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %55 = arith.addf %54, %53 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %56 = affine.load %arg2[%arg6, %arg7 * 16 + 9] {partition_indices = [0, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %57 = arith.mulf %56, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %58 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 9] {partition_indices = [0, 9], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %59 = arith.mulf %3, %58 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %60 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %57 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %56 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %61 = arith.addf %60, %59 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %62 = affine.load %arg2[%arg6, %arg7 * 16 + 10] {partition_indices = [0, 10], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %63 = arith.mulf %62, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %64 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 10] {partition_indices = [0, 10], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %65 = arith.mulf %3, %64 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %66 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %63 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %62 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %67 = arith.addf %66, %65 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %68 = affine.load %arg2[%arg6, %arg7 * 16 + 11] {partition_indices = [0, 11], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %69 = arith.mulf %68, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %70 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 11] {partition_indices = [0, 11], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %71 = arith.mulf %3, %70 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %72 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %69 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %68 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %73 = arith.addf %72, %71 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %74 = affine.load %arg2[%arg6, %arg7 * 16 + 12] {partition_indices = [0, 12], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %75 = arith.mulf %74, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %76 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 12] {partition_indices = [0, 12], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %77 = arith.mulf %3, %76 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %78 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %75 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %74 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %79 = arith.addf %78, %77 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %80 = affine.load %arg2[%arg6, %arg7 * 16 + 13] {partition_indices = [0, 13], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %81 = arith.mulf %80, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %82 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 13] {partition_indices = [0, 13], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %83 = arith.mulf %3, %82 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %84 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %81 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %80 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %85 = arith.addf %84, %83 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %86 = affine.load %arg2[%arg6, %arg7 * 16 + 14] {partition_indices = [0, 14], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %87 = arith.mulf %86, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %88 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 14] {partition_indices = [0, 14], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %89 = arith.mulf %3, %88 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %90 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %87 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %86 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %91 = arith.addf %90, %89 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %92 = affine.load %arg2[%arg6, %arg7 * 16 + 15] {partition_indices = [0, 15], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %93 = arith.mulf %92, %arg1 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %94 = affine.load %arg4[%arg5 * 8, %arg7 * 16 + 15] {partition_indices = [0, 15], timing = #hls.t<4 -> 6, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %95 = arith.mulf %3, %94 {timing = #hls.t<6 -> 10, 4, 1>} : f32
        %96 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f32 {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %93 : f32
        } else {
          affine.yield {timing = #hls.t<10 -> 10, 0, 0>} %92 : f32
        } {timing = #hls.t<10 -> 10, 0, 0>}
        %97 = arith.addf %96, %95 {timing = #hls.t<10 -> 15, 5, 1>} : f32
        %98 = affine.load %arg3[%arg6, %arg5 * 8 + 1] {partition_indices = [0, 1], timing = #hls.t<5 -> 7, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>
        %99 = arith.mulf %arg0, %98 {timing = #hls.t<7 -> 11, 4, 1>} : f32
        %100 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16] {partition_indices = [1, 0], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %101 = arith.mulf %99, %100 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %102 = arith.addf %7, %101 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %103 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 1] {partition_indices = [1, 1], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %104 = arith.mulf %99, %103 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %105 = arith.addf %13, %104 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %106 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 2] {partition_indices = [1, 2], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %107 = arith.mulf %99, %106 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %108 = arith.addf %19, %107 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %109 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 3] {partition_indices = [1, 3], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %110 = arith.mulf %99, %109 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %111 = arith.addf %25, %110 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %112 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 4] {partition_indices = [1, 4], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %113 = arith.mulf %99, %112 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %114 = arith.addf %31, %113 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %115 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 5] {partition_indices = [1, 5], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %116 = arith.mulf %99, %115 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %117 = arith.addf %37, %116 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %118 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 6] {partition_indices = [1, 6], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %119 = arith.mulf %99, %118 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %120 = arith.addf %43, %119 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %121 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 7] {partition_indices = [1, 7], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %122 = arith.mulf %99, %121 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %123 = arith.addf %49, %122 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %124 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 8] {partition_indices = [1, 8], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %125 = arith.mulf %99, %124 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %126 = arith.addf %55, %125 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %127 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 9] {partition_indices = [1, 9], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %128 = arith.mulf %99, %127 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %129 = arith.addf %61, %128 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %130 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 10] {partition_indices = [1, 10], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %131 = arith.mulf %99, %130 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %132 = arith.addf %67, %131 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %133 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 11] {partition_indices = [1, 11], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %134 = arith.mulf %99, %133 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %135 = arith.addf %73, %134 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %136 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 12] {partition_indices = [1, 12], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %137 = arith.mulf %99, %136 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %138 = arith.addf %79, %137 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %139 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 13] {partition_indices = [1, 13], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %140 = arith.mulf %99, %139 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %141 = arith.addf %85, %140 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %142 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 14] {partition_indices = [1, 14], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %143 = arith.mulf %99, %142 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %144 = arith.addf %91, %143 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %145 = affine.load %arg4[%arg5 * 8 + 1, %arg7 * 16 + 15] {partition_indices = [1, 15], timing = #hls.t<9 -> 11, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %146 = arith.mulf %99, %145 {timing = #hls.t<11 -> 15, 4, 1>} : f32
        %147 = arith.addf %97, %146 {timing = #hls.t<15 -> 20, 5, 1>} : f32
        %148 = affine.load %arg3[%arg6, %arg5 * 8 + 2] {partition_indices = [0, 2], timing = #hls.t<10 -> 12, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>
        %149 = arith.mulf %arg0, %148 {timing = #hls.t<12 -> 16, 4, 1>} : f32
        %150 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16] {partition_indices = [2, 0], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %151 = arith.mulf %149, %150 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %152 = arith.addf %102, %151 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %153 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 1] {partition_indices = [2, 1], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %154 = arith.mulf %149, %153 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %155 = arith.addf %105, %154 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %156 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 2] {partition_indices = [2, 2], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %157 = arith.mulf %149, %156 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %158 = arith.addf %108, %157 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %159 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 3] {partition_indices = [2, 3], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %160 = arith.mulf %149, %159 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %161 = arith.addf %111, %160 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %162 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 4] {partition_indices = [2, 4], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %163 = arith.mulf %149, %162 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %164 = arith.addf %114, %163 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %165 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 5] {partition_indices = [2, 5], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %166 = arith.mulf %149, %165 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %167 = arith.addf %117, %166 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %168 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 6] {partition_indices = [2, 6], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %169 = arith.mulf %149, %168 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %170 = arith.addf %120, %169 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %171 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 7] {partition_indices = [2, 7], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %172 = arith.mulf %149, %171 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %173 = arith.addf %123, %172 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %174 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 8] {partition_indices = [2, 8], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %175 = arith.mulf %149, %174 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %176 = arith.addf %126, %175 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %177 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 9] {partition_indices = [2, 9], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %178 = arith.mulf %149, %177 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %179 = arith.addf %129, %178 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %180 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 10] {partition_indices = [2, 10], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %181 = arith.mulf %149, %180 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %182 = arith.addf %132, %181 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %183 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 11] {partition_indices = [2, 11], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %184 = arith.mulf %149, %183 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %185 = arith.addf %135, %184 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %186 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 12] {partition_indices = [2, 12], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %187 = arith.mulf %149, %186 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %188 = arith.addf %138, %187 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %189 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 13] {partition_indices = [2, 13], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %190 = arith.mulf %149, %189 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %191 = arith.addf %141, %190 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %192 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 14] {partition_indices = [2, 14], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %193 = arith.mulf %149, %192 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %194 = arith.addf %144, %193 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %195 = affine.load %arg4[%arg5 * 8 + 2, %arg7 * 16 + 15] {partition_indices = [2, 15], timing = #hls.t<14 -> 16, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %196 = arith.mulf %149, %195 {timing = #hls.t<16 -> 20, 4, 1>} : f32
        %197 = arith.addf %147, %196 {timing = #hls.t<20 -> 25, 5, 1>} : f32
        %198 = affine.load %arg3[%arg6, %arg5 * 8 + 3] {partition_indices = [0, 3], timing = #hls.t<15 -> 17, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>
        %199 = arith.mulf %arg0, %198 {timing = #hls.t<17 -> 21, 4, 1>} : f32
        %200 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16] {partition_indices = [3, 0], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %201 = arith.mulf %199, %200 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %202 = arith.addf %152, %201 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %203 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 1] {partition_indices = [3, 1], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %204 = arith.mulf %199, %203 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %205 = arith.addf %155, %204 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %206 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 2] {partition_indices = [3, 2], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %207 = arith.mulf %199, %206 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %208 = arith.addf %158, %207 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %209 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 3] {partition_indices = [3, 3], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %210 = arith.mulf %199, %209 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %211 = arith.addf %161, %210 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %212 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 4] {partition_indices = [3, 4], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %213 = arith.mulf %199, %212 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %214 = arith.addf %164, %213 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %215 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 5] {partition_indices = [3, 5], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %216 = arith.mulf %199, %215 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %217 = arith.addf %167, %216 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %218 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 6] {partition_indices = [3, 6], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %219 = arith.mulf %199, %218 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %220 = arith.addf %170, %219 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %221 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 7] {partition_indices = [3, 7], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %222 = arith.mulf %199, %221 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %223 = arith.addf %173, %222 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %224 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 8] {partition_indices = [3, 8], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %225 = arith.mulf %199, %224 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %226 = arith.addf %176, %225 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %227 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 9] {partition_indices = [3, 9], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %228 = arith.mulf %199, %227 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %229 = arith.addf %179, %228 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %230 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 10] {partition_indices = [3, 10], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %231 = arith.mulf %199, %230 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %232 = arith.addf %182, %231 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %233 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 11] {partition_indices = [3, 11], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %234 = arith.mulf %199, %233 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %235 = arith.addf %185, %234 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %236 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 12] {partition_indices = [3, 12], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %237 = arith.mulf %199, %236 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %238 = arith.addf %188, %237 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %239 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 13] {partition_indices = [3, 13], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %240 = arith.mulf %199, %239 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %241 = arith.addf %191, %240 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %242 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 14] {partition_indices = [3, 14], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %243 = arith.mulf %199, %242 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %244 = arith.addf %194, %243 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %245 = affine.load %arg4[%arg5 * 8 + 3, %arg7 * 16 + 15] {partition_indices = [3, 15], timing = #hls.t<19 -> 21, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %246 = arith.mulf %199, %245 {timing = #hls.t<21 -> 25, 4, 1>} : f32
        %247 = arith.addf %197, %246 {timing = #hls.t<25 -> 30, 5, 1>} : f32
        %248 = affine.load %arg3[%arg6, %arg5 * 8 + 4] {partition_indices = [0, 4], timing = #hls.t<20 -> 22, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>
        %249 = arith.mulf %arg0, %248 {timing = #hls.t<22 -> 26, 4, 1>} : f32
        %250 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16] {partition_indices = [4, 0], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %251 = arith.mulf %249, %250 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %252 = arith.addf %202, %251 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %253 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 1] {partition_indices = [4, 1], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %254 = arith.mulf %249, %253 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %255 = arith.addf %205, %254 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %256 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 2] {partition_indices = [4, 2], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %257 = arith.mulf %249, %256 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %258 = arith.addf %208, %257 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %259 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 3] {partition_indices = [4, 3], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %260 = arith.mulf %249, %259 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %261 = arith.addf %211, %260 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %262 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 4] {partition_indices = [4, 4], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %263 = arith.mulf %249, %262 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %264 = arith.addf %214, %263 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %265 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 5] {partition_indices = [4, 5], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %266 = arith.mulf %249, %265 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %267 = arith.addf %217, %266 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %268 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 6] {partition_indices = [4, 6], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %269 = arith.mulf %249, %268 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %270 = arith.addf %220, %269 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %271 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 7] {partition_indices = [4, 7], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %272 = arith.mulf %249, %271 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %273 = arith.addf %223, %272 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %274 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 8] {partition_indices = [4, 8], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %275 = arith.mulf %249, %274 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %276 = arith.addf %226, %275 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %277 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 9] {partition_indices = [4, 9], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %278 = arith.mulf %249, %277 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %279 = arith.addf %229, %278 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %280 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 10] {partition_indices = [4, 10], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %281 = arith.mulf %249, %280 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %282 = arith.addf %232, %281 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %283 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 11] {partition_indices = [4, 11], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %284 = arith.mulf %249, %283 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %285 = arith.addf %235, %284 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %286 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 12] {partition_indices = [4, 12], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %287 = arith.mulf %249, %286 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %288 = arith.addf %238, %287 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %289 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 13] {partition_indices = [4, 13], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %290 = arith.mulf %249, %289 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %291 = arith.addf %241, %290 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %292 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 14] {partition_indices = [4, 14], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %293 = arith.mulf %249, %292 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %294 = arith.addf %244, %293 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %295 = affine.load %arg4[%arg5 * 8 + 4, %arg7 * 16 + 15] {partition_indices = [4, 15], timing = #hls.t<24 -> 26, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %296 = arith.mulf %249, %295 {timing = #hls.t<26 -> 30, 4, 1>} : f32
        %297 = arith.addf %247, %296 {timing = #hls.t<30 -> 35, 5, 1>} : f32
        %298 = affine.load %arg3[%arg6, %arg5 * 8 + 5] {partition_indices = [0, 5], timing = #hls.t<25 -> 27, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>
        %299 = arith.mulf %arg0, %298 {timing = #hls.t<27 -> 31, 4, 1>} : f32
        %300 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16] {partition_indices = [5, 0], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %301 = arith.mulf %299, %300 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %302 = arith.addf %252, %301 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %303 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 1] {partition_indices = [5, 1], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %304 = arith.mulf %299, %303 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %305 = arith.addf %255, %304 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %306 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 2] {partition_indices = [5, 2], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %307 = arith.mulf %299, %306 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %308 = arith.addf %258, %307 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %309 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 3] {partition_indices = [5, 3], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %310 = arith.mulf %299, %309 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %311 = arith.addf %261, %310 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %312 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 4] {partition_indices = [5, 4], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %313 = arith.mulf %299, %312 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %314 = arith.addf %264, %313 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %315 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 5] {partition_indices = [5, 5], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %316 = arith.mulf %299, %315 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %317 = arith.addf %267, %316 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %318 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 6] {partition_indices = [5, 6], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %319 = arith.mulf %299, %318 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %320 = arith.addf %270, %319 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %321 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 7] {partition_indices = [5, 7], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %322 = arith.mulf %299, %321 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %323 = arith.addf %273, %322 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %324 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 8] {partition_indices = [5, 8], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %325 = arith.mulf %299, %324 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %326 = arith.addf %276, %325 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %327 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 9] {partition_indices = [5, 9], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %328 = arith.mulf %299, %327 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %329 = arith.addf %279, %328 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %330 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 10] {partition_indices = [5, 10], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %331 = arith.mulf %299, %330 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %332 = arith.addf %282, %331 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %333 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 11] {partition_indices = [5, 11], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %334 = arith.mulf %299, %333 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %335 = arith.addf %285, %334 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %336 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 12] {partition_indices = [5, 12], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %337 = arith.mulf %299, %336 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %338 = arith.addf %288, %337 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %339 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 13] {partition_indices = [5, 13], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %340 = arith.mulf %299, %339 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %341 = arith.addf %291, %340 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %342 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 14] {partition_indices = [5, 14], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %343 = arith.mulf %299, %342 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %344 = arith.addf %294, %343 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %345 = affine.load %arg4[%arg5 * 8 + 5, %arg7 * 16 + 15] {partition_indices = [5, 15], timing = #hls.t<29 -> 31, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %346 = arith.mulf %299, %345 {timing = #hls.t<31 -> 35, 4, 1>} : f32
        %347 = arith.addf %297, %346 {timing = #hls.t<35 -> 40, 5, 1>} : f32
        %348 = affine.load %arg3[%arg6, %arg5 * 8 + 6] {partition_indices = [0, 6], timing = #hls.t<30 -> 32, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>
        %349 = arith.mulf %arg0, %348 {timing = #hls.t<32 -> 36, 4, 1>} : f32
        %350 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16] {partition_indices = [6, 0], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %351 = arith.mulf %349, %350 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %352 = arith.addf %302, %351 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %353 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 1] {partition_indices = [6, 1], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %354 = arith.mulf %349, %353 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %355 = arith.addf %305, %354 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %356 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 2] {partition_indices = [6, 2], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %357 = arith.mulf %349, %356 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %358 = arith.addf %308, %357 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %359 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 3] {partition_indices = [6, 3], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %360 = arith.mulf %349, %359 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %361 = arith.addf %311, %360 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %362 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 4] {partition_indices = [6, 4], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %363 = arith.mulf %349, %362 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %364 = arith.addf %314, %363 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %365 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 5] {partition_indices = [6, 5], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %366 = arith.mulf %349, %365 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %367 = arith.addf %317, %366 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %368 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 6] {partition_indices = [6, 6], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %369 = arith.mulf %349, %368 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %370 = arith.addf %320, %369 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %371 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 7] {partition_indices = [6, 7], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %372 = arith.mulf %349, %371 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %373 = arith.addf %323, %372 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %374 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 8] {partition_indices = [6, 8], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %375 = arith.mulf %349, %374 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %376 = arith.addf %326, %375 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %377 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 9] {partition_indices = [6, 9], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %378 = arith.mulf %349, %377 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %379 = arith.addf %329, %378 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %380 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 10] {partition_indices = [6, 10], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %381 = arith.mulf %349, %380 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %382 = arith.addf %332, %381 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %383 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 11] {partition_indices = [6, 11], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %384 = arith.mulf %349, %383 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %385 = arith.addf %335, %384 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %386 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 12] {partition_indices = [6, 12], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %387 = arith.mulf %349, %386 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %388 = arith.addf %338, %387 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %389 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 13] {partition_indices = [6, 13], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %390 = arith.mulf %349, %389 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %391 = arith.addf %341, %390 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %392 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 14] {partition_indices = [6, 14], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %393 = arith.mulf %349, %392 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %394 = arith.addf %344, %393 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %395 = affine.load %arg4[%arg5 * 8 + 6, %arg7 * 16 + 15] {partition_indices = [6, 15], timing = #hls.t<34 -> 36, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %396 = arith.mulf %349, %395 {timing = #hls.t<36 -> 40, 4, 1>} : f32
        %397 = arith.addf %347, %396 {timing = #hls.t<40 -> 45, 5, 1>} : f32
        %398 = affine.load %arg3[%arg6, %arg5 * 8 + 7] {partition_indices = [0, 7], timing = #hls.t<35 -> 37, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 8, d0, d1 floordiv 8)>>
        %399 = arith.mulf %arg0, %398 {timing = #hls.t<37 -> 41, 4, 1>} : f32
        %400 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16] {partition_indices = [7, 0], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %401 = arith.mulf %399, %400 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %402 = arith.addf %352, %401 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %402, %arg2[%arg6, %arg7 * 16] {partition_indices = [0, 0], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %403 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 1] {partition_indices = [7, 1], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %404 = arith.mulf %399, %403 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %405 = arith.addf %355, %404 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %405, %arg2[%arg6, %arg7 * 16 + 1] {partition_indices = [0, 1], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %406 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 2] {partition_indices = [7, 2], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %407 = arith.mulf %399, %406 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %408 = arith.addf %358, %407 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %408, %arg2[%arg6, %arg7 * 16 + 2] {partition_indices = [0, 2], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %409 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 3] {partition_indices = [7, 3], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %410 = arith.mulf %399, %409 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %411 = arith.addf %361, %410 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %411, %arg2[%arg6, %arg7 * 16 + 3] {partition_indices = [0, 3], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %412 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 4] {partition_indices = [7, 4], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %413 = arith.mulf %399, %412 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %414 = arith.addf %364, %413 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %414, %arg2[%arg6, %arg7 * 16 + 4] {partition_indices = [0, 4], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %415 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 5] {partition_indices = [7, 5], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %416 = arith.mulf %399, %415 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %417 = arith.addf %367, %416 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %417, %arg2[%arg6, %arg7 * 16 + 5] {partition_indices = [0, 5], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %418 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 6] {partition_indices = [7, 6], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %419 = arith.mulf %399, %418 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %420 = arith.addf %370, %419 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %420, %arg2[%arg6, %arg7 * 16 + 6] {partition_indices = [0, 6], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %421 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 7] {partition_indices = [7, 7], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %422 = arith.mulf %399, %421 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %423 = arith.addf %373, %422 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %423, %arg2[%arg6, %arg7 * 16 + 7] {partition_indices = [0, 7], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %424 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 8] {partition_indices = [7, 8], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %425 = arith.mulf %399, %424 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %426 = arith.addf %376, %425 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %426, %arg2[%arg6, %arg7 * 16 + 8] {partition_indices = [0, 8], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %427 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 9] {partition_indices = [7, 9], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %428 = arith.mulf %399, %427 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %429 = arith.addf %379, %428 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %429, %arg2[%arg6, %arg7 * 16 + 9] {partition_indices = [0, 9], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %430 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 10] {partition_indices = [7, 10], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %431 = arith.mulf %399, %430 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %432 = arith.addf %382, %431 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %432, %arg2[%arg6, %arg7 * 16 + 10] {partition_indices = [0, 10], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %433 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 11] {partition_indices = [7, 11], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %434 = arith.mulf %399, %433 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %435 = arith.addf %385, %434 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %435, %arg2[%arg6, %arg7 * 16 + 11] {partition_indices = [0, 11], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %436 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 12] {partition_indices = [7, 12], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %437 = arith.mulf %399, %436 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %438 = arith.addf %388, %437 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %438, %arg2[%arg6, %arg7 * 16 + 12] {partition_indices = [0, 12], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %439 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 13] {partition_indices = [7, 13], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %440 = arith.mulf %399, %439 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %441 = arith.addf %391, %440 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %441, %arg2[%arg6, %arg7 * 16 + 13] {partition_indices = [0, 13], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %442 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 14] {partition_indices = [7, 14], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %443 = arith.mulf %399, %442 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %444 = arith.addf %394, %443 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %444, %arg2[%arg6, %arg7 * 16 + 14] {partition_indices = [0, 14], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
        %445 = affine.load %arg4[%arg5 * 8 + 7, %arg7 * 16 + 15] {partition_indices = [7, 15], timing = #hls.t<39 -> 41, 2, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (d0 mod 8, d1 mod 16, d0 floordiv 8, d1 floordiv 16)>>
        %446 = arith.mulf %399, %445 {timing = #hls.t<41 -> 45, 4, 1>} : f32
        %447 = arith.addf %397, %446 {timing = #hls.t<45 -> 50, 5, 1>} : f32
        affine.store %447, %arg2[%arg6, %arg7 * 16 + 15] {partition_indices = [0, 15], timing = #hls.t<50 -> 51, 1, 1>} : memref<64x64xf32, affine_map<(d0, d1) -> (0, d1 mod 16, d0, d1 floordiv 16)>>
      } {loop_directive = #hls.ld<pipeline=true, targetII=3, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=4, iterLatency=51, minII=3>, parallel, timing = #hls.t<0 -> 62, 62, 62>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=256, iterLatency=51, minII=3>, parallel, timing = #hls.t<0 -> 818, 818, 818>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=2048, iterLatency=51, minII=3>, timing = #hls.t<0 -> 6194, 6194, 6194>}
  return {timing = #hls.t<6194 -> 6194, 0, 0>}
}
