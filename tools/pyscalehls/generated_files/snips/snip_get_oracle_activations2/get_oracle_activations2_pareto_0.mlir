func @get_oracle_activations2(%arg0: memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>, %arg1: memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=288, bram=0>, timing = #hlscpp.t<0 -> 32, 32, 32>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg4 = 0 to 2 {
    %0 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %1 = affine.load %arg0[%arg4 * 96] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %3 = arith.addf %2, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %4 = affine.load %arg3[%arg4 * 32] {partition_indices = [0], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %5 = affine.load %arg0[%arg4 * 96 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %7 = arith.addf %6, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %8 = affine.load %arg3[%arg4 * 32 + 1] {partition_indices = [1], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %9 = affine.load %arg0[%arg4 * 96 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %10 = arith.mulf %0, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %11 = arith.addf %10, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %12 = affine.load %arg3[%arg4 * 32 + 2] {partition_indices = [2], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %13 = affine.load %arg0[%arg4 * 96 + 9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %14 = arith.mulf %0, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %15 = arith.addf %14, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %16 = affine.load %arg3[%arg4 * 32 + 3] {partition_indices = [3], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %17 = affine.load %arg0[%arg4 * 96 + 12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %18 = arith.mulf %0, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %19 = arith.addf %18, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %20 = affine.load %arg3[%arg4 * 32 + 4] {partition_indices = [4], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %21 = affine.load %arg0[%arg4 * 96 + 15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %22 = arith.mulf %0, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %23 = arith.addf %22, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %24 = affine.load %arg3[%arg4 * 32 + 5] {partition_indices = [5], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %25 = affine.load %arg0[%arg4 * 96 + 18] {partition_indices = [18], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %26 = arith.mulf %0, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %27 = arith.addf %26, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %28 = affine.load %arg3[%arg4 * 32 + 6] {partition_indices = [6], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %29 = affine.load %arg0[%arg4 * 96 + 21] {partition_indices = [21], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %30 = arith.mulf %0, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %31 = arith.addf %30, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %32 = affine.load %arg3[%arg4 * 32 + 7] {partition_indices = [7], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %33 = affine.load %arg0[%arg4 * 96 + 24] {partition_indices = [24], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %34 = arith.mulf %0, %33 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %35 = arith.addf %34, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %36 = affine.load %arg3[%arg4 * 32 + 8] {partition_indices = [8], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %37 = affine.load %arg0[%arg4 * 96 + 27] {partition_indices = [27], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %38 = arith.mulf %0, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %39 = arith.addf %38, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %40 = affine.load %arg3[%arg4 * 32 + 9] {partition_indices = [9], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %41 = affine.load %arg0[%arg4 * 96 + 30] {partition_indices = [30], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %42 = arith.mulf %0, %41 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %43 = arith.addf %42, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %44 = affine.load %arg3[%arg4 * 32 + 10] {partition_indices = [10], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %45 = affine.load %arg0[%arg4 * 96 + 33] {partition_indices = [33], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %46 = arith.mulf %0, %45 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %47 = arith.addf %46, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %48 = affine.load %arg3[%arg4 * 32 + 11] {partition_indices = [11], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %49 = affine.load %arg0[%arg4 * 96 + 36] {partition_indices = [36], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %50 = arith.mulf %0, %49 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %51 = arith.addf %50, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %52 = affine.load %arg3[%arg4 * 32 + 12] {partition_indices = [12], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %53 = affine.load %arg0[%arg4 * 96 + 39] {partition_indices = [39], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %54 = arith.mulf %0, %53 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %55 = arith.addf %54, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %56 = affine.load %arg3[%arg4 * 32 + 13] {partition_indices = [13], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %57 = affine.load %arg0[%arg4 * 96 + 42] {partition_indices = [42], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %58 = arith.mulf %0, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %59 = arith.addf %58, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %60 = affine.load %arg3[%arg4 * 32 + 14] {partition_indices = [14], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %61 = affine.load %arg0[%arg4 * 96 + 45] {partition_indices = [45], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %62 = arith.mulf %0, %61 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %63 = arith.addf %62, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %64 = affine.load %arg3[%arg4 * 32 + 15] {partition_indices = [15], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %65 = affine.load %arg0[%arg4 * 96 + 48] {partition_indices = [48], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %66 = arith.mulf %0, %65 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %67 = arith.addf %66, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %68 = affine.load %arg3[%arg4 * 32 + 16] {partition_indices = [16], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %69 = affine.load %arg0[%arg4 * 96 + 51] {partition_indices = [51], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %70 = arith.mulf %0, %69 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %71 = arith.addf %70, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %72 = affine.load %arg3[%arg4 * 32 + 17] {partition_indices = [17], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %73 = affine.load %arg0[%arg4 * 96 + 54] {partition_indices = [54], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %74 = arith.mulf %0, %73 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %75 = arith.addf %74, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %76 = affine.load %arg3[%arg4 * 32 + 18] {partition_indices = [18], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %77 = affine.load %arg0[%arg4 * 96 + 57] {partition_indices = [57], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %78 = arith.mulf %0, %77 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %79 = arith.addf %78, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %80 = affine.load %arg3[%arg4 * 32 + 19] {partition_indices = [19], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %81 = affine.load %arg0[%arg4 * 96 + 60] {partition_indices = [60], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %82 = arith.mulf %0, %81 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %83 = arith.addf %82, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %84 = affine.load %arg3[%arg4 * 32 + 20] {partition_indices = [20], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %85 = affine.load %arg0[%arg4 * 96 + 63] {partition_indices = [63], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %86 = arith.mulf %0, %85 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %87 = arith.addf %86, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %88 = affine.load %arg3[%arg4 * 32 + 21] {partition_indices = [21], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %89 = affine.load %arg0[%arg4 * 96 + 66] {partition_indices = [66], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %90 = arith.mulf %0, %89 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %91 = arith.addf %90, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %92 = affine.load %arg3[%arg4 * 32 + 22] {partition_indices = [22], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %93 = affine.load %arg0[%arg4 * 96 + 69] {partition_indices = [69], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %94 = arith.mulf %0, %93 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %95 = arith.addf %94, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %96 = affine.load %arg3[%arg4 * 32 + 23] {partition_indices = [23], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %97 = affine.load %arg0[%arg4 * 96 + 72] {partition_indices = [72], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %98 = arith.mulf %0, %97 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %99 = arith.addf %98, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %100 = affine.load %arg3[%arg4 * 32 + 24] {partition_indices = [24], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %101 = affine.load %arg0[%arg4 * 96 + 75] {partition_indices = [75], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %102 = arith.mulf %0, %101 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %103 = arith.addf %102, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %104 = affine.load %arg3[%arg4 * 32 + 25] {partition_indices = [25], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %105 = affine.load %arg0[%arg4 * 96 + 78] {partition_indices = [78], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %106 = arith.mulf %0, %105 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %107 = arith.addf %106, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %108 = affine.load %arg3[%arg4 * 32 + 26] {partition_indices = [26], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %109 = affine.load %arg0[%arg4 * 96 + 81] {partition_indices = [81], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %110 = arith.mulf %0, %109 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %111 = arith.addf %110, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %112 = affine.load %arg3[%arg4 * 32 + 27] {partition_indices = [27], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %113 = affine.load %arg0[%arg4 * 96 + 84] {partition_indices = [84], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %114 = arith.mulf %0, %113 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %115 = arith.addf %114, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %116 = affine.load %arg3[%arg4 * 32 + 28] {partition_indices = [28], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %117 = affine.load %arg0[%arg4 * 96 + 87] {partition_indices = [87], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %118 = arith.mulf %0, %117 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %119 = arith.addf %118, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %120 = affine.load %arg3[%arg4 * 32 + 29] {partition_indices = [29], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %121 = affine.load %arg0[%arg4 * 96 + 90] {partition_indices = [90], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %122 = arith.mulf %0, %121 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %123 = arith.addf %122, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %124 = affine.load %arg3[%arg4 * 32 + 30] {partition_indices = [30], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %125 = affine.load %arg0[%arg4 * 96 + 93] {partition_indices = [93], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %126 = arith.mulf %0, %125 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %127 = arith.addf %126, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %128 = affine.load %arg3[%arg4 * 32 + 31] {partition_indices = [31], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %129 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %130 = affine.load %arg0[%arg4 * 96 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %131 = arith.mulf %129, %130 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %132 = arith.addf %3, %131 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %133 = affine.load %arg0[%arg4 * 96 + 4] {partition_indices = [4], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %134 = arith.mulf %129, %133 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %135 = arith.addf %7, %134 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %136 = affine.load %arg0[%arg4 * 96 + 7] {partition_indices = [7], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %137 = arith.mulf %129, %136 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %138 = arith.addf %11, %137 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %139 = affine.load %arg0[%arg4 * 96 + 10] {partition_indices = [10], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %140 = arith.mulf %129, %139 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %141 = arith.addf %15, %140 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %142 = affine.load %arg0[%arg4 * 96 + 13] {partition_indices = [13], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %143 = arith.mulf %129, %142 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %144 = arith.addf %19, %143 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %145 = affine.load %arg0[%arg4 * 96 + 16] {partition_indices = [16], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %146 = arith.mulf %129, %145 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %147 = arith.addf %23, %146 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %148 = affine.load %arg0[%arg4 * 96 + 19] {partition_indices = [19], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %149 = arith.mulf %129, %148 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %150 = arith.addf %27, %149 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %151 = affine.load %arg0[%arg4 * 96 + 22] {partition_indices = [22], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %152 = arith.mulf %129, %151 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %153 = arith.addf %31, %152 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %154 = affine.load %arg0[%arg4 * 96 + 25] {partition_indices = [25], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %155 = arith.mulf %129, %154 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %156 = arith.addf %35, %155 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %157 = affine.load %arg0[%arg4 * 96 + 28] {partition_indices = [28], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %158 = arith.mulf %129, %157 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %159 = arith.addf %39, %158 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %160 = affine.load %arg0[%arg4 * 96 + 31] {partition_indices = [31], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %161 = arith.mulf %129, %160 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %162 = arith.addf %43, %161 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %163 = affine.load %arg0[%arg4 * 96 + 34] {partition_indices = [34], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %164 = arith.mulf %129, %163 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %165 = arith.addf %47, %164 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %166 = affine.load %arg0[%arg4 * 96 + 37] {partition_indices = [37], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %167 = arith.mulf %129, %166 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %168 = arith.addf %51, %167 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %169 = affine.load %arg0[%arg4 * 96 + 40] {partition_indices = [40], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %170 = arith.mulf %129, %169 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %171 = arith.addf %55, %170 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %172 = affine.load %arg0[%arg4 * 96 + 43] {partition_indices = [43], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %173 = arith.mulf %129, %172 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %174 = arith.addf %59, %173 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %175 = affine.load %arg0[%arg4 * 96 + 46] {partition_indices = [46], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %176 = arith.mulf %129, %175 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %177 = arith.addf %63, %176 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %178 = affine.load %arg0[%arg4 * 96 + 49] {partition_indices = [49], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %179 = arith.mulf %129, %178 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %180 = arith.addf %67, %179 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %181 = affine.load %arg0[%arg4 * 96 + 52] {partition_indices = [52], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %182 = arith.mulf %129, %181 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %183 = arith.addf %71, %182 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %184 = affine.load %arg0[%arg4 * 96 + 55] {partition_indices = [55], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %185 = arith.mulf %129, %184 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %186 = arith.addf %75, %185 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %187 = affine.load %arg0[%arg4 * 96 + 58] {partition_indices = [58], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %188 = arith.mulf %129, %187 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %189 = arith.addf %79, %188 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %190 = affine.load %arg0[%arg4 * 96 + 61] {partition_indices = [61], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %191 = arith.mulf %129, %190 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %192 = arith.addf %83, %191 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %193 = affine.load %arg0[%arg4 * 96 + 64] {partition_indices = [64], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %194 = arith.mulf %129, %193 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %195 = arith.addf %87, %194 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %196 = affine.load %arg0[%arg4 * 96 + 67] {partition_indices = [67], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %197 = arith.mulf %129, %196 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %198 = arith.addf %91, %197 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %199 = affine.load %arg0[%arg4 * 96 + 70] {partition_indices = [70], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %200 = arith.mulf %129, %199 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %201 = arith.addf %95, %200 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %202 = affine.load %arg0[%arg4 * 96 + 73] {partition_indices = [73], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %203 = arith.mulf %129, %202 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %204 = arith.addf %99, %203 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %205 = affine.load %arg0[%arg4 * 96 + 76] {partition_indices = [76], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %206 = arith.mulf %129, %205 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %207 = arith.addf %103, %206 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %208 = affine.load %arg0[%arg4 * 96 + 79] {partition_indices = [79], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %209 = arith.mulf %129, %208 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %210 = arith.addf %107, %209 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %211 = affine.load %arg0[%arg4 * 96 + 82] {partition_indices = [82], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %212 = arith.mulf %129, %211 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %213 = arith.addf %111, %212 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %214 = affine.load %arg0[%arg4 * 96 + 85] {partition_indices = [85], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %215 = arith.mulf %129, %214 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %216 = arith.addf %115, %215 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %217 = affine.load %arg0[%arg4 * 96 + 88] {partition_indices = [88], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %218 = arith.mulf %129, %217 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %219 = arith.addf %119, %218 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %220 = affine.load %arg0[%arg4 * 96 + 91] {partition_indices = [91], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %221 = arith.mulf %129, %220 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %222 = arith.addf %123, %221 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %223 = affine.load %arg0[%arg4 * 96 + 94] {partition_indices = [94], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %224 = arith.mulf %129, %223 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %225 = arith.addf %127, %224 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %226 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %227 = affine.load %arg0[%arg4 * 96 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %228 = arith.mulf %226, %227 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %229 = arith.addf %132, %228 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %230 = arith.mulf %229, %4 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %230, %arg2[%arg4 * 32] {partition_indices = [0], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %231 = affine.load %arg0[%arg4 * 96 + 5] {partition_indices = [5], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %232 = arith.mulf %226, %231 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %233 = arith.addf %135, %232 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %234 = arith.mulf %233, %8 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %234, %arg2[%arg4 * 32 + 1] {partition_indices = [1], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %235 = affine.load %arg0[%arg4 * 96 + 8] {partition_indices = [8], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %236 = arith.mulf %226, %235 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %237 = arith.addf %138, %236 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %238 = arith.mulf %237, %12 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %238, %arg2[%arg4 * 32 + 2] {partition_indices = [2], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %239 = affine.load %arg0[%arg4 * 96 + 11] {partition_indices = [11], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %240 = arith.mulf %226, %239 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %241 = arith.addf %141, %240 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %242 = arith.mulf %241, %16 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %242, %arg2[%arg4 * 32 + 3] {partition_indices = [3], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %243 = affine.load %arg0[%arg4 * 96 + 14] {partition_indices = [14], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %244 = arith.mulf %226, %243 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %245 = arith.addf %144, %244 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %246 = arith.mulf %245, %20 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %246, %arg2[%arg4 * 32 + 4] {partition_indices = [4], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %247 = affine.load %arg0[%arg4 * 96 + 17] {partition_indices = [17], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %248 = arith.mulf %226, %247 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %249 = arith.addf %147, %248 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %250 = arith.mulf %249, %24 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %250, %arg2[%arg4 * 32 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %251 = affine.load %arg0[%arg4 * 96 + 20] {partition_indices = [20], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %252 = arith.mulf %226, %251 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %253 = arith.addf %150, %252 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %254 = arith.mulf %253, %28 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %254, %arg2[%arg4 * 32 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %255 = affine.load %arg0[%arg4 * 96 + 23] {partition_indices = [23], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %256 = arith.mulf %226, %255 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %257 = arith.addf %153, %256 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %258 = arith.mulf %257, %32 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %258, %arg2[%arg4 * 32 + 7] {partition_indices = [7], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %259 = affine.load %arg0[%arg4 * 96 + 26] {partition_indices = [26], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %260 = arith.mulf %226, %259 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %261 = arith.addf %156, %260 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %262 = arith.mulf %261, %36 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %262, %arg2[%arg4 * 32 + 8] {partition_indices = [8], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %263 = affine.load %arg0[%arg4 * 96 + 29] {partition_indices = [29], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %264 = arith.mulf %226, %263 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %265 = arith.addf %159, %264 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %266 = arith.mulf %265, %40 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %266, %arg2[%arg4 * 32 + 9] {partition_indices = [9], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %267 = affine.load %arg0[%arg4 * 96 + 32] {partition_indices = [32], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %268 = arith.mulf %226, %267 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %269 = arith.addf %162, %268 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %270 = arith.mulf %269, %44 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %270, %arg2[%arg4 * 32 + 10] {partition_indices = [10], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %271 = affine.load %arg0[%arg4 * 96 + 35] {partition_indices = [35], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %272 = arith.mulf %226, %271 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %273 = arith.addf %165, %272 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %274 = arith.mulf %273, %48 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %274, %arg2[%arg4 * 32 + 11] {partition_indices = [11], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %275 = affine.load %arg0[%arg4 * 96 + 38] {partition_indices = [38], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %276 = arith.mulf %226, %275 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %277 = arith.addf %168, %276 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %278 = arith.mulf %277, %52 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %278, %arg2[%arg4 * 32 + 12] {partition_indices = [12], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %279 = affine.load %arg0[%arg4 * 96 + 41] {partition_indices = [41], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %280 = arith.mulf %226, %279 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %281 = arith.addf %171, %280 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %282 = arith.mulf %281, %56 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %282, %arg2[%arg4 * 32 + 13] {partition_indices = [13], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %283 = affine.load %arg0[%arg4 * 96 + 44] {partition_indices = [44], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %284 = arith.mulf %226, %283 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %285 = arith.addf %174, %284 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %286 = arith.mulf %285, %60 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %286, %arg2[%arg4 * 32 + 14] {partition_indices = [14], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %287 = affine.load %arg0[%arg4 * 96 + 47] {partition_indices = [47], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %288 = arith.mulf %226, %287 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %289 = arith.addf %177, %288 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %290 = arith.mulf %289, %64 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %290, %arg2[%arg4 * 32 + 15] {partition_indices = [15], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %291 = affine.load %arg0[%arg4 * 96 + 50] {partition_indices = [50], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %292 = arith.mulf %226, %291 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %293 = arith.addf %180, %292 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %294 = arith.mulf %293, %68 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %294, %arg2[%arg4 * 32 + 16] {partition_indices = [16], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %295 = affine.load %arg0[%arg4 * 96 + 53] {partition_indices = [53], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %296 = arith.mulf %226, %295 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %297 = arith.addf %183, %296 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %298 = arith.mulf %297, %72 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %298, %arg2[%arg4 * 32 + 17] {partition_indices = [17], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %299 = affine.load %arg0[%arg4 * 96 + 56] {partition_indices = [56], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %300 = arith.mulf %226, %299 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %301 = arith.addf %186, %300 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %302 = arith.mulf %301, %76 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %302, %arg2[%arg4 * 32 + 18] {partition_indices = [18], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %303 = affine.load %arg0[%arg4 * 96 + 59] {partition_indices = [59], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %304 = arith.mulf %226, %303 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %305 = arith.addf %189, %304 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %306 = arith.mulf %305, %80 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %306, %arg2[%arg4 * 32 + 19] {partition_indices = [19], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %307 = affine.load %arg0[%arg4 * 96 + 62] {partition_indices = [62], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %308 = arith.mulf %226, %307 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %309 = arith.addf %192, %308 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %310 = arith.mulf %309, %84 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %310, %arg2[%arg4 * 32 + 20] {partition_indices = [20], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %311 = affine.load %arg0[%arg4 * 96 + 65] {partition_indices = [65], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %312 = arith.mulf %226, %311 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %313 = arith.addf %195, %312 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %314 = arith.mulf %313, %88 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %314, %arg2[%arg4 * 32 + 21] {partition_indices = [21], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %315 = affine.load %arg0[%arg4 * 96 + 68] {partition_indices = [68], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %316 = arith.mulf %226, %315 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %317 = arith.addf %198, %316 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %318 = arith.mulf %317, %92 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %318, %arg2[%arg4 * 32 + 22] {partition_indices = [22], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %319 = affine.load %arg0[%arg4 * 96 + 71] {partition_indices = [71], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %320 = arith.mulf %226, %319 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %321 = arith.addf %201, %320 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %322 = arith.mulf %321, %96 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %322, %arg2[%arg4 * 32 + 23] {partition_indices = [23], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %323 = affine.load %arg0[%arg4 * 96 + 74] {partition_indices = [74], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %324 = arith.mulf %226, %323 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %325 = arith.addf %204, %324 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %326 = arith.mulf %325, %100 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %326, %arg2[%arg4 * 32 + 24] {partition_indices = [24], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %327 = affine.load %arg0[%arg4 * 96 + 77] {partition_indices = [77], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %328 = arith.mulf %226, %327 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %329 = arith.addf %207, %328 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %330 = arith.mulf %329, %104 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %330, %arg2[%arg4 * 32 + 25] {partition_indices = [25], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %331 = affine.load %arg0[%arg4 * 96 + 80] {partition_indices = [80], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %332 = arith.mulf %226, %331 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %333 = arith.addf %210, %332 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %334 = arith.mulf %333, %108 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %334, %arg2[%arg4 * 32 + 26] {partition_indices = [26], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %335 = affine.load %arg0[%arg4 * 96 + 83] {partition_indices = [83], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %336 = arith.mulf %226, %335 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %337 = arith.addf %213, %336 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %338 = arith.mulf %337, %112 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %338, %arg2[%arg4 * 32 + 27] {partition_indices = [27], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %339 = affine.load %arg0[%arg4 * 96 + 86] {partition_indices = [86], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %340 = arith.mulf %226, %339 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %341 = arith.addf %216, %340 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %342 = arith.mulf %341, %116 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %342, %arg2[%arg4 * 32 + 28] {partition_indices = [28], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %343 = affine.load %arg0[%arg4 * 96 + 89] {partition_indices = [89], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %344 = arith.mulf %226, %343 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %345 = arith.addf %219, %344 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %346 = arith.mulf %345, %120 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %346, %arg2[%arg4 * 32 + 29] {partition_indices = [29], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %347 = affine.load %arg0[%arg4 * 96 + 92] {partition_indices = [92], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %348 = arith.mulf %226, %347 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %349 = arith.addf %222, %348 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %350 = arith.mulf %349, %124 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %350, %arg2[%arg4 * 32 + 30] {partition_indices = [30], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %351 = affine.load %arg0[%arg4 * 96 + 95] {partition_indices = [95], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %352 = arith.mulf %226, %351 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %353 = arith.addf %225, %352 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %354 = arith.mulf %353, %128 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %354, %arg2[%arg4 * 32 + 31] {partition_indices = [31], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=2, iterLatency=26, minII=2>, timing = #hlscpp.t<0 -> 30, 30, 30>}
  return {timing = #hlscpp.t<30 -> 30, 0, 0>}
}
