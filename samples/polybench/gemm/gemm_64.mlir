func @gemm_64(%alpha: f32, %beta: f32, %C: memref<64x64xf32>, %A: memref<64x64xf32>, %B: memref<64x64xf32>) {
  affine.for %i = 0 to 64 {
    affine.for %j = 0 to 64 {
      %0 = affine.load %C[%i, %j] : memref<64x64xf32>
      %1 = mulf %beta, %0 : f32
      affine.store %1, %C[%i, %j] : memref<64x64xf32>
      affine.for %k = 0 to 64 {
        %2 = affine.load %A[%i, %k] : memref<64x64xf32>
        %3 = affine.load %B[%k, %j] : memref<64x64xf32>
        %4 = affine.load %C[%i, %j] : memref<64x64xf32>
        %5 = mulf %alpha, %2 : f32
        %6 = mulf %5, %3 : f32
        %7 = addf %4, %6 : f32
        affine.store %7, %C[%i, %j] : memref<64x64xf32>
      }
    }
  }
  return
}
