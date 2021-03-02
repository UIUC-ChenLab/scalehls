func @bicg(%A: memref<1024x1024xf32>, %p: memref<1024xf32>, %r: memref<1024xf32>, %q: memref<1024xf32>, %s: memref<1024xf32>) {
  affine.for %i = 0 to 1024 {
    %cst = constant 0.0 : f32
    affine.store %cst, %s[%i] : memref<1024xf32>
  }
  affine.for %i = 0 to 1024 {
    %cst = constant 0.0 : f32
    affine.store %cst, %q[%i] : memref<1024xf32>
    affine.for %j = 0 to 1024 {
      %0 = affine.load %A[%i, %j] : memref<1024x1024xf32>
      %1 = affine.load %r[%i] : memref<1024xf32>
      %2 = affine.load %s[%j] : memref<1024xf32>
      %3 = mulf %1, %0 : f32
      %4 = addf %3, %2 : f32
      affine.store %4, %s[%j] : memref<1024xf32>
      %5 = affine.load %p[%j] : memref<1024xf32>
      %6 = affine.load %q[%i] : memref<1024xf32>
      %7 = mulf %5, %0 : f32
      %8 = addf %7, %6 : f32
      affine.store %8, %q[%i] : memref<1024xf32>
    }
  }
  return
}
