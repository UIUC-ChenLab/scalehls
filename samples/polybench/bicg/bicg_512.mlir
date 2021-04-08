func @bicg_512(%A: memref<512x512xf32>, %s: memref<512xf32>, %q: memref<512xf32>, %p: memref<512xf32>, %r: memref<512xf32>) {
  affine.for %i = 0 to 512 {
    affine.for %j = 0 to 512 {
      %0 = affine.load %s[%j] : memref<512xf32>
      %1 = affine.load %r[%i] : memref<512xf32>
      %2 = affine.load %A[%i, %j] : memref<512x512xf32>
      %3 = mulf %1, %2 : f32
      %4 = addf %0, %3 : f32
      affine.store %4, %s[%j] : memref<512xf32>
      %5 = affine.load %q[%i] : memref<512xf32>
      %6 = affine.load %p[%j] : memref<512xf32>
      %7 = mulf %2, %6 : f32
      %8 = addf %5, %7 : f32
      affine.store %8, %q[%i] : memref<512xf32>
    }
  }
  return
}
