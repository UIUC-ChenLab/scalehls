#map0 = affine_map<()[s0, s1, s2, s3] -> (s0, s1, s2, s3)>
#map1 = affine_map<()[s0, s1, s2, s3, s4, s5] -> (s0, s1, s2 + s3, s4 + s5)>
#map2 = affine_map<() -> (0)>
#map3 = affine_map<() -> (3)>
#map4 = affine_map<()[s0] -> (s0)>
#map5 = affine_map<() -> (225)>
#map6 = affine_map<() -> (1)>

module {
  func @main_graph(%arg0: memref<1x3x227x227xf32>, %constant0: memref<3x3x3x3xf32>, %constant1: memref<3xf32>) -> memref<1x3x225x225xf32> {
    %cst = constant 0.000000e+00 : f32
    %1 = alloc() : memref<1x3x225x225xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 225 {
          affine.for %arg4 = 0 to 225 {
            affine.store %cst, %1[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x3x225x225xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %7 = affine.load %arg0[symbol(%arg1), symbol(%arg5), symbol(%arg3) + symbol(%arg6), symbol(%arg4) + symbol(%arg7)] : memref<1x3x227x227xf32>
                  %8 = affine.load %constant0[symbol(%arg2), symbol(%arg5), symbol(%arg6), symbol(%arg7)] : memref<3x3x3x3xf32>
                  %9 = affine.load %1[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x3x225x225xf32>
                  %10 = mulf %7, %8 : f32
                  %11 = addf %9, %10 : f32
                  affine.store %11, %1[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x3x225x225xf32>
                }
              }
            }
            %4 = affine.load %1[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x3x225x225xf32>
            %5 = affine.load %constant1[symbol(%arg2)] : memref<3xf32>
            %6 = addf %4, %5 : f32
            affine.store %6, %1[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x3x225x225xf32>
          }
        }
      }
    }
    return %1 : memref<1x3x225x225xf32>
  }
}