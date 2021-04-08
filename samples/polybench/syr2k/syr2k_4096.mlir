#map = affine_map<(d0) -> (d0 + 1)>
func @syr2k_4096(%alpha: f32, %beta: f32, %C: memref<4096x4096xf32>, %A: memref<4096x4096xf32>, %B: memref<4096x4096xf32>) {
  affine.for %i = 0 to 4096 {
    affine.for %j = 0 to #map(%i) {
      %0 = affine.load %C[%i, %j] : memref<4096x4096xf32>
      %1 = mulf %beta, %0 : f32
      affine.store %1, %C[%i, %j] : memref<4096x4096xf32>
      affine.for %k = 0 to 4096 {
        %2 = affine.load %A[%i, %k] : memref<4096x4096xf32>
        %3 = affine.load %B[%j, %k] : memref<4096x4096xf32>
        %4 = affine.load %B[%i, %k] : memref<4096x4096xf32>
        %5 = affine.load %A[%j, %k] : memref<4096x4096xf32>
        %6 = affine.load %C[%i, %j] : memref<4096x4096xf32>
        %7 = mulf %2, %3 : f32
        %8 = mulf %4, %5 : f32
        %9 = addf %7, %8 : f32
        %10 = mulf %alpha, %9 : f32
        %11 = addf %6, %10 : f32
        affine.store %11, %C[%i, %j] : memref<4096x4096xf32>
      }
    }
  }
  return
}
