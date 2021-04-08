func @bicg_64(%A: memref<64x64xf32>, %s: memref<64xf32>, %q: memref<64xf32>, %p: memref<64xf32>, %r: memref<64xf32>) {
  affine.for %i = 0 to 64 {
    affine.for %j = 0 to 64 {
      %0 = affine.load %s[%j] : memref<64xf32>
      %1 = affine.load %r[%i] : memref<64xf32>
      %2 = affine.load %A[%i, %j] : memref<64x64xf32>
      %3 = mulf %1, %2 : f32
      %4 = addf %0, %3 : f32
      affine.store %4, %s[%j] : memref<64xf32>
      %5 = affine.load %q[%i] : memref<64xf32>
      %6 = affine.load %p[%j] : memref<64xf32>
      %7 = mulf %2, %6 : f32
      %8 = addf %5, %7 : f32
      affine.store %8, %q[%i] : memref<64xf32>
    }
  }
  return
}
