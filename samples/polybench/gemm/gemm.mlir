func @gemm(%alpha: f32, %beta: f32, %C: memref<1024x1024xf32>, %A: memref<1024x1024xf32>, %B: memref<1024x1024xf32>) {
  affine.for %i = 0 to 1024 {
    affine.for %j = 0 to 1024 {
      %0 = affine.load %C[%i, %j] : memref<1024x1024xf32>
      %1 = mulf %beta, %0 : f32
      affine.store %1, %C[%i, %j] : memref<1024x1024xf32>
      affine.for %k = 0 to 1024 {
        %2 = affine.load %A[%i, %k] : memref<1024x1024xf32>
        %3 = affine.load %B[%k, %j] : memref<1024x1024xf32>
        %4 = affine.load %C[%i, %j] : memref<1024x1024xf32>
        %5 = mulf %alpha, %2 : f32
        %6 = mulf %5, %3 : f32
        %7 = addf %6, %4 : f32
        affine.store %7, %C[%i, %j] : memref<1024x1024xf32>
      }
    }
  }
  return
}
