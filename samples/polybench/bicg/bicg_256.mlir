func @bicg_256(%A: memref<256x256xf32>, %s: memref<256xf32>, %q: memref<256xf32>, %p: memref<256xf32>, %r: memref<256xf32>) {
  affine.for %i = 0 to 256 {
    affine.for %j = 0 to 256 {
      %0 = affine.load %s[%j] : memref<256xf32>
      %1 = affine.load %r[%i] : memref<256xf32>
      %2 = affine.load %A[%i, %j] : memref<256x256xf32>
      %3 = mulf %1, %2 : f32
      %4 = addf %0, %3 : f32
      affine.store %4, %s[%j] : memref<256xf32>
      %5 = affine.load %q[%i] : memref<256xf32>
      %6 = affine.load %p[%j] : memref<256xf32>
      %7 = mulf %2, %6 : f32
      %8 = addf %5, %7 : f32
      affine.store %8, %q[%i] : memref<256xf32>
    }
  }
  return
}
