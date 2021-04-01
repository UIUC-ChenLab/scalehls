func @gesummv(%alpha: f32, %beta: f32, %A: memref<1024x1024xf32>, %B: memref<1024x1024xf32>, %tmp: memref<1024xf32>, %x: memref<1024xf32>, %y: memref<1024xf32>) {
  affine.for %i = 0 to 1024 {
    affine.for %j = 0 to 1024 {
      %0 = affine.load %A[%i, %j] : memref<1024x1024xf32>
      %1 = affine.load %x[%j] : memref<1024xf32>
      %2 = affine.load %tmp[%i] : memref<1024xf32>
      %3 = mulf %0, %1 : f32
      %4 = addf %2, %3 : f32
      affine.store %4, %tmp[%i] : memref<1024xf32>
      %5 = affine.load %B[%i, %j] : memref<1024x1024xf32>
      %6 = affine.load %x[%j] : memref<1024xf32>
      %7 = affine.load %y[%i] : memref<1024xf32>
      %8 = mulf %5, %6 : f32
      %9 = addf %7, %8 : f32
      affine.store %9, %y[%i] : memref<1024xf32>
    }
    %10 = affine.load %tmp[%i] : memref<1024xf32>
    %11 = affine.load %y[%i] : memref<1024xf32>
    %12 = mulf %alpha, %10 : f32
    %13 = mulf %beta, %11 : f32
    %14 = addf %12, %13 : f32
    affine.store %14, %y[%i] : memref<1024xf32>
  }
  return
}
