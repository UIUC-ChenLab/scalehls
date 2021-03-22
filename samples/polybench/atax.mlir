func @atax(%A: memref<64x64xf32>, %x: memref<64xf32>, %y: memref<64xf32>, %tmp: memref<64xf32>) {
  // affine.for %i = 0 to 64 {
  //   %cst = constant 0.0 : f32
  //   affine.store %cst, %y[%i] : memref<64xf32>
  // }
  affine.for %i = 0 to 64 {
    // %cst = constant 0.0 : f32
    // affine.store %cst, %tmp[%i] : memref<64xf32>
    affine.for %j = 0 to 64 {
      %0 = affine.load %A[%i, %j] : memref<64x64xf32>
      %1 = affine.load %x[%j] : memref<64xf32>
      %2 = affine.load %tmp[%i] : memref<64xf32>
      %3 = mulf %1, %0 : f32
      %4 = addf %3, %2 : f32
      affine.store %4, %tmp[%i] : memref<64xf32>
    }
    affine.for %j = 0 to 64 {
      %5 = affine.load %A[%i, %j] : memref<64x64xf32>
      %6 = affine.load %tmp[%i] : memref<64xf32>
      %7 = affine.load %y[%j] : memref<64xf32>
      %8 = mulf %6, %5 : f32
      %9 = addf %8, %7 : f32
      affine.store %9, %y[%j] : memref<64xf32>
    }
  }
  return
}
