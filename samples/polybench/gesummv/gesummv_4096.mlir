func @gesummv_4096(%alpha: f32, %beta: f32, %A: memref<4096x4096xf32>, %B: memref<4096x4096xf32>, %tmp: memref<4096xf32>, %x: memref<4096xf32>, %y: memref<4096xf32>) {
  affine.for %i = 0 to 4096 {
    affine.for %j = 0 to 4096 {
      %0 = affine.load %A[%i, %j] : memref<4096x4096xf32>
      %1 = affine.load %x[%j] : memref<4096xf32>
      %2 = affine.load %tmp[%i] : memref<4096xf32>
      %3 = mulf %0, %1 : f32
      %4 = addf %2, %3 : f32
      affine.store %4, %tmp[%i] : memref<4096xf32>
      %5 = affine.load %B[%i, %j] : memref<4096x4096xf32>
      %6 = affine.load %x[%j] : memref<4096xf32>
      %7 = affine.load %y[%i] : memref<4096xf32>
      %8 = mulf %5, %6 : f32
      %9 = addf %7, %8 : f32
      affine.store %9, %y[%i] : memref<4096xf32>
    }
    %10 = affine.load %tmp[%i] : memref<4096xf32>
    %11 = affine.load %y[%i] : memref<4096xf32>
    %12 = mulf %alpha, %10 : f32
    %13 = mulf %beta, %11 : f32
    %14 = addf %12, %13 : f32
    affine.store %14, %y[%i] : memref<4096xf32>
  }
  return
}
